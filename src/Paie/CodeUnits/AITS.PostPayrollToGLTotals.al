codeunit 70050 "Payroll Posting (Grouped)"
{
    Subtype = Normal;

    procedure PostGroupedToSalaryJournal(var SalaryHeader: Record "Salary Header")
    var
        SalaryLine: Record "Salary Line";
        EmpPostingGroup: Record "Employee Posting Group";
        HRSetup: Record "Human Resources Setup";
        Totals: Dictionary of [Text, Decimal];
        TotalNetPay: Decimal;
        TotalLoan: Decimal;
        TotalAdvance: Decimal;
        TotalInsurance: Decimal;
        TotalAdjustment: Decimal;
        TotalDeduction: Decimal;
        TotalLeaveTicket: Decimal;
        TotalLeaveSalary: Decimal;
        TotalEOS: Decimal;
        TotalHealthIns: Decimal;
    begin
        Clear(Totals);
        Clear(TotalNetPay);
        Clear(TotalLoan);
        Clear(TotalAdvance);
        Clear(TotalInsurance);
        Clear(TotalAdjustment);
        Clear(TotalDeduction);
        Clear(TotalLeaveTicket);
        Clear(TotalLeaveSalary);
        Clear(TotalEOS);
        Clear(TotalHealthIns);

        SalaryLine.Reset();
        SalaryLine.SetRange("Document No.", SalaryHeader."No");
        if not SalaryLine.FindSet() then
            exit;

        if not HRSetup.Get() then
            Error('Human Resources Setup is missing.');

        repeat
            SalaryLine.CalcFields("Accomodation Allowance", "Transport Allowance", "Mobile Allowance",
                                  "Education Allowance", "Bonus Allowance");
            if not EmpPostingGroup.Get(SalaryLine."Employee Posting Group") then
                Error('Employee Posting Group "%1" is missing on employee %2.', SalaryLine."Employee Posting Group", SalaryLine.Employee);

            // ---------------- Debit grouped ----------------
            AddDebit(Totals, EmpPostingGroup.Code, 'Total Basic Salary', EmpPostingGroup."G/L Basic Salary", SalaryLine."Basic Salary");
            AddDebit(Totals, EmpPostingGroup.Code, 'Total Housing Allowance', EmpPostingGroup."G/L Housing Allowance", SalaryLine."Accomodation Allowance");
            AddDebit(Totals, EmpPostingGroup.Code, 'Total Transport Allowance', EmpPostingGroup."G/L Transportation Allowance", SalaryLine."Transport Allowance");
            AddDebit(Totals, EmpPostingGroup.Code, 'Total Mobile Allowance', EmpPostingGroup."G/L Mobile Allowance", SalaryLine."Mobile Allowance");
            AddDebit(Totals, EmpPostingGroup.Code, 'Total Education Allowance', EmpPostingGroup."G/L Education Allowance", SalaryLine."Education Allowance");
            AddDebit(Totals, EmpPostingGroup.Code, 'Total Staff Bonus', EmpPostingGroup."G/L Staff Bonus", SalaryLine.Bonus);
            AddDebit(Totals, EmpPostingGroup.Code, 'Total Ticket Expenses', EmpPostingGroup."G/L Leave Ticket Expenses", SalaryLine."Tickets Allowances Amount");
            AddDebit(Totals, EmpPostingGroup.Code, 'Total Leave Salary', EmpPostingGroup."G/L Leave Salary Expenses", SalaryLine."Annual Leave  Amount");
            AddDebit(Totals, EmpPostingGroup.Code, 'Total End of Service Indemnity', EmpPostingGroup."G/L End of Service Indemnity", SalaryLine."EOSB Amount");
            AddDebit(Totals, EmpPostingGroup.Code, 'Total GOSI (Employee)', EmpPostingGroup."G/L Social Security (GOSI)", -SalaryLine."GOSI Employee Amount");
            AddDebit(Totals, EmpPostingGroup.Code, 'Total Sales Commission', EmpPostingGroup."G/L Sales Comm", SalaryLine."Incentive Amount");

            // ---------------- Credit totals ----------------
            TotalInsurance += SalaryLine."Employee Insurance Amount";
            TotalLoan += SalaryLine.Loan;
            TotalAdvance += SalaryLine.Advance;
            TotalAdjustment += SalaryLine.Adjustment;
            TotalDeduction += SalaryLine.Deductions;
            TotalNetPay += SalaryLine."Net Pay";
            TotalLeaveTicket += SalaryLine."Tickets Allowances Amount";
            TotalLeaveSalary += SalaryLine."Annual Leave  Amount";
            TotalEOS += SalaryLine."EOSB Amount";
            TotalHealthIns += SalaryLine."Employee Insurance Amount";
        until SalaryLine.Next() = 0;

        // Insert all debit lines
        InsertAllDebitLines(Totals, SalaryHeader."Posting Date", SalaryHeader."No");

        // ---- Credit lines ----
        if HRSetup."Leave Tickets Prov. Acc" = '' then
            Error('"Leave Tickets Prov. Acc" is not defined in HR Setup.');
        InsertCreditLine(HRSetup."Leave Tickets Prov. Acc", 'Leave Ticket Provision', -TotalLeaveTicket, SalaryHeader."Posting Date", SalaryHeader."No");

        if HRSetup."Leave Days Prov. Acc" = '' then
            Error('""Leave Days Prov. Acc"" is not defined in HR Setup.');
        InsertCreditLine(HRSetup."Leave Days Prov. Acc", 'Leave Salary Provision', -TotalLeaveSalary, SalaryHeader."Posting Date", SalaryHeader."No");

        if HRSetup."EOS Provision Acc" = '' then
            Error('""EOS Provision Acc"" is not defined in HR Setup.');
        InsertCreditLine(HRSetup."EOS Provision Acc", 'EOS Indemnity Provision', -TotalEOS, SalaryHeader."Posting Date", SalaryHeader."No");

        if HRSetup."Health Insurance Acc" = '' then
            Error('"Health Insurance Acc" is not defined in HR Setup.');
        InsertCreditLine(HRSetup."Health Insurance Acc", 'Health Insurance', -TotalHealthIns, SalaryHeader."Posting Date", SalaryHeader."No");

        if HRSetup."Prepaid Health Insurance Acc" = '' then
            Error('"Prepaid Health Insurance Acc" is not defined in HR Setup.');
        InsertCreditLine(HRSetup."Prepaid Health Insurance Acc", 'Prepaid Health Insurance', TotalHealthIns, SalaryHeader."Posting Date", SalaryHeader."No");

        if HRSetup."Net Payroll Acc" = '' then
            Error('"Net Payroll Acc" is not defined in HR Setup.');
        InsertCreditLine(HRSetup."Net Payroll Acc", 'Payroll Clearing (Net Pay)', -TotalNetPay, SalaryHeader."Posting Date", SalaryHeader."No");

        if HRSetup."Staff Loan Acc" = '' then
            Error('"Staff Loan Acc" is not defined in HR Setup.');
        InsertCreditLine(HRSetup."Staff Loan Acc", 'Staff Loan (Total)', -TotalLoan, SalaryHeader."Posting Date", SalaryHeader."No");

        if HRSetup."Staff Advance Acc" = '' then
            Error('"Staff Advance Acc" is not defined in HR Setup.');
        InsertCreditLine(HRSetup."Staff Advance Acc", 'Staff Advance (Total)', -TotalAdvance, SalaryHeader."Posting Date", SalaryHeader."No");
    end;

    // ========================= Helpers =========================

    local procedure AddDebit(var Totals: Dictionary of [Text, Decimal]; PostingGroup: Code[20]; ComponentText: Text; GLAcc: Code[20]; AmountToAdd: Decimal)
    var
        txtKey: Text;
        CurVal: Decimal;
    begin
        if AmountToAdd = 0 then
            exit;
        if GLAcc = '' then
            Error('Missing G/L Account for "%1" in Employee Posting Group "%2".', ComponentText, PostingGroup);

        txtKey := Format(PostingGroup) + '|' + ComponentText + '|' + Format(GLAcc);
        if Totals.Get(txtKey, CurVal) then
            Totals.Set(txtKey, CurVal + AmountToAdd)
        else
            Totals.Add(txtKey, AmountToAdd);
    end;

    local procedure InsertAllDebitLines(var Totals: Dictionary of [Text, Decimal]; PostingDate: Date; DocNo: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
        KeyTxt: Text;
        Val: Decimal;
        PostingGroup: Code[20];
        ComponentText: Text[100];
        GLAcc: Code[20];
        PipePos1: Integer;
        RestTxt: Text;
        PipePos2: Integer;
    begin
        foreach KeyTxt in Totals.Keys do begin
            if Totals.Get(KeyTxt, Val) and (Val <> 0) then begin
                PipePos1 := StrPos(KeyTxt, '|');
                PipePos2 := StrPos(CopyStr(KeyTxt, PipePos1 + 1), '|') + PipePos1;

                PostingGroup := CopyStr(KeyTxt, 1, PipePos1 - 1);
                ComponentText := CopyStr(KeyTxt, PipePos1 + 1, PipePos2 - PipePos1 - 1);
                GLAcc := CopyStr(KeyTxt, PipePos2 + 1);

                Clear(GenJnlLine);
                GenJnlLine.Init();
                GenJnlLine."Journal Template Name" := 'GENERAL';
                GenJnlLine."Journal Batch Name" := 'PAYROLL';
                GenJnlLine."Line No." := GetNextLineNo('GENERAL', 'PAYROLL');
                GenJnlLine."Posting Date" := PostingDate;
                GenJnlLine."Document No." := DocNo;
                GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                GenJnlLine."Account No." := GLAcc;
                GenJnlLine.Description := Format(PostingGroup) + ' ' + ComponentText;
                GenJnlLine.Amount := Val;
                GenJnlLine.Insert(true);
            end;
        end;
    end;

    local procedure InsertCreditLine(AccNo: Code[20]; DescTxt: Text[100]; CreditAmt: Decimal; PostingDate: Date; DocNo: Code[20])
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if CreditAmt = 0 then
            exit;

        Clear(GenJnlLine);
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := 'GENERAL';
        GenJnlLine."Journal Batch Name" := 'PAYROLL';
        GenJnlLine."Line No." := GetNextLineNo('GENERAL', 'PAYROLL'); // 👈 added to fix missing line no
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Document No." := DocNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := AccNo;
        GenJnlLine.Description := DescTxt;
        GenJnlLine.Amount := CreditAmt;
        GenJnlLine.Insert(true);
    end;

    local procedure GetNextLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Journal Template Name", TemplateName);
        GenJnlLine.SetRange("Journal Batch Name", BatchName);
        if GenJnlLine.FindLast() then
            exit(GenJnlLine."Line No." + 10000)
        else
            exit(10000);
    end;
}
