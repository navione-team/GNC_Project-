codeunit 70004 "Payroll Posting Mgt."
{
    // Caption = 'Payroll Posting Management';

    procedure PostPayroll(var SalaryHeader: Record "Salary Header")
    var
        SalaryLine: Record "Salary Line";
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
        LineNo: Integer;
        BatchName: Code[10];
    begin
        // Define journal template/batch to use
        BatchName := 'PAYROLL';

        // Delete any previous unposted payroll lines
        GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
        GenJnlLine.SetRange("Journal Batch Name", BatchName);
        GenJnlLine.DeleteAll();

        LineNo := 10000;

        // Loop through Salary Lines for this header
        SalaryLine.SetRange("Document No.", SalaryHeader.No);
        if SalaryLine.FindSet() then
            repeat
                // -----------------------------
                // 1. Debit Expenses
                // -----------------------------
                SalaryLine.CalcFields("Accomodation Allowance", "Transport Allowance",
                "Mobile Allowance", "Education Allowance", "Bonus Allowance");
                InsertGLLine(SalaryHeader, LineNo, '620201', SalaryLine."Basic Salary", true);
                InsertGLLine(SalaryHeader, LineNo, '620202', SalaryLine."Accomodation Allowance", true);
                InsertGLLine(SalaryHeader, LineNo, '620203', SalaryLine."Transport Allowance", true);
                InsertGLLine(SalaryHeader, LineNo, '620204', SalaryLine."Mobile Allowance", true);
                InsertGLLine(SalaryHeader, LineNo, '620205', SalaryLine."Education Allowance", true);
                InsertGLLine(SalaryHeader, LineNo, '620206', SalaryLine."Bonus Allowance", true);
                InsertGLLine(SalaryHeader, LineNo, '620207', SalaryLine."Tickets Allowances Amount", true);
                InsertGLLine(SalaryHeader, LineNo, '620208', SalaryLine."Annual Leave  Amount", true);
                InsertGLLine(SalaryHeader, LineNo, '620209', SalaryLine."EOSB Amount", true);


                // -----------------------------
                // 2. Credit Deductions
                // -----------------------------
                InsertGLLine(SalaryHeader, LineNo, '620601', SalaryLine."Employee Insurance Amount", false);
                InsertGLLine(SalaryHeader, LineNo, '1110', SalaryLine.Loan, false);
                InsertGLLine(SalaryHeader, LineNo, '1108', SalaryLine.Advance, false);
                InsertGLLine(SalaryHeader, LineNo, '620210', SalaryLine."GOSI Employee Amount", false);
                InsertGLLine(SalaryHeader, LineNo, '620299', SalaryLine.Deductions, false); // generic deduction

                // -----------------------------
                // 3. Credit Employee (Net Pay)
                // -----------------------------
                InsertEmployeeLine(SalaryHeader, SalaryLine, LineNo);
                // -----------------------------
                // 4. (Optional) Bank Line
                // -----------------------------
                InsertBankLine(SalaryHeader, LineNo, 'BANKNUJUD', SalaryLine."Net Pay");

            until SalaryLine.Next() = 0;



        // -----------------------------
        // 5. Post Journal → creates G/L + Employee + Bank entries
        // -----------------------------
        /* GenJnlLine.Reset();
         GenJnlLine.SetRange("Journal Template Name", 'GENERAL');
         GenJnlLine.SetRange("Journal Batch Name", BatchName);
         if GenJnlLine.FindFirst() then
             CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", GenJnlLine);

         Message('Payroll %1 posted successfully.', SalaryHeader.No);*/
    end;

    // ===========================================================
    // Helper: Insert G/L Expense or Deduction Line
    // ===========================================================
    local procedure InsertGLLine(SalaryHeader: Record "Salary Header"; var LineNo: Integer; GLAcc: Code[20]; Amount: Decimal; Debit: Boolean)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if Amount = 0 then
            exit;

        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := 'GENERAL';
        GenJnlLine."Journal Batch Name" := 'PAYROLL';
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Posting Date" := SalaryHeader."Posting Date";
        GenJnlLine."Document No." := SalaryHeader.No;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := GLAcc;
        GenJnlLine.Description := SalaryHeader.Description;

        if Debit then
            GenJnlLine.VALIDATE(Amount, Round(Amount, 0.01))
        else
            GenJnlLine.VALIDATE(Amount, Round(-Amount, 0.01));

        GenJnlLine.Insert();
        LineNo += 10000;
    end;

    // ===========================================================
    // Helper: Insert Employee Net Pay Line
    // ===========================================================
    local procedure InsertEmployeeLine(SalaryHeader: Record "Salary Header"; SalaryLine: Record "Salary Line"; var LineNo: Integer)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if SalaryLine."Net Pay" = 0 then
            exit;

        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := 'GENERAL';
        GenJnlLine."Journal Batch Name" := 'PAYROLL';
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Posting Date" := SalaryHeader."Posting Date";
        GenJnlLine."Document No." := SalaryHeader.No;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Employee;
        GenJnlLine.Validate("Account No.", SalaryLine.Employee);

        GenJnlLine.Description := 'Salary ' + SalaryLine."Full Name" + ' ' +
                                  Format(SalaryHeader."Posting Month") + '/' + Format(SalaryHeader."Posting Year");

        GenJnlLine.Amount := -Round(SalaryLine."Net Pay", 0.01);

        // Auto-application setup
        GenJnlLine."Applies-to ID" := SalaryHeader.No;

        // Dimensions
        if SalaryLine."Global Dimension 1 Code" <> '' then
            GenJnlLine.Validate("Shortcut Dimension 1 Code", SalaryLine."Global Dimension 1 Code");
        if SalaryLine."Global Dimension 2 Code" <> '' then
            GenJnlLine.Validate("Shortcut Dimension 2 Code", SalaryLine."Global Dimension 2 Code");

        GenJnlLine.Insert();
        LineNo += 10000;
    end;

    // ===========================================================
    // Helper: Insert Bank Account Line
    // ===========================================================
    local procedure InsertBankLine(SalaryHeader: Record "Salary Header"; var LineNo: Integer; BankAcc: Code[20]; TotalAmount: Decimal)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if TotalAmount = 0 then
            exit;

        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := 'GENERAL';
        GenJnlLine."Journal Batch Name" := 'PAYROLL';
        GenJnlLine."Line No." := LineNo;
        GenJnlLine."Posting Date" := SalaryHeader."Posting Date";
        GenJnlLine."Document No." := SalaryHeader.No;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"Bank Account";
        GenJnlLine."Account No." := BankAcc;
        GenJnlLine.Description := 'Payroll ' + SalaryHeader.Description;
        GenJnlLine.Validate(Amount, Round(TotalAmount, 0.01)); // Debit bank

        GenJnlLine.Insert();
        LineNo += 10000;
    end;
}
