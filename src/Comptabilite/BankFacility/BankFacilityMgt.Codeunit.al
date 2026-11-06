codeunit 50310 "NAV Bank Facility Mgt."
{
    // ======================================================================
    // Initial entry   Debit Bank / Credit Bank Facility Account
    // ======================================================================
    procedure GenerateInitialEntry(var Facility: Record "NAV Bank Facility")
    var
        Setup: Record "NAV Bank Facility Setup";
        LineNo: Integer;
    begin
        Facility.TestStatusDraft();
        Facility.TestField("Bank Account No.");
        Facility.TestField("Facility Date");
        Facility.TestField("Due Date");
        Facility.TestField(Amount);
        Facility.TestField("Facility Account No.");
        CheckBankAccount(Facility."Bank Account No.");
        GetSetupAndCheckBatch(Setup);

        LineNo := GetNextLineNo(Setup);
        InsertJnlLine(Setup, Facility, LineNo, Facility."Facility Date", Enum::"Gen. Journal Account Type"::"Bank Account",
            Facility."Bank Account No.", Facility.Amount, CopyStr(StrSubstNo(InitialTxt, Facility."No.", Facility.Description), 1, 100));
        InsertJnlLine(Setup, Facility, LineNo, Facility."Facility Date", Enum::"Gen. Journal Account Type"::"G/L Account",
            Facility."Facility Account No.", -Facility.Amount, CopyStr(StrSubstNo(InitialTxt, Facility."No.", Facility.Description), 1, 100));

        Facility.Status := Facility.Status::"Initial Pending";
        Facility.Modify();
        if not Setup."Review Before Posting" then
            PostEntries(Setup, Facility);
    end;

    // ======================================================================
    // Maturity entry  Debit Bank Facility Account (amount)
    //                 Debit Bank Commission Account (commission)
    //                 Credit Bank (amount + commission)
    // One maturity entry per facility: it cannot be generated twice.
    // ======================================================================
    procedure GenerateMaturityEntry(var Facility: Record "NAV Bank Facility")
    var
        Setup: Record "NAV Bank Facility Setup";
        LineNo: Integer;
    begin
        if Facility.Status <> Facility.Status::Open then
            Error(NotOpenErr, Facility."No.", Facility.Status);
        if Facility."Maturity Generated" then
            Error(AlreadyGeneratedErr, Facility."No.");
        Facility.TestField("Due Date");
        if Facility."Commission Amount" <> 0 then
            Facility.TestField("Commission Account No.");
        CheckBankAccount(Facility."Bank Account No.");
        GetSetupAndCheckBatch(Setup);

        LineNo := GetNextLineNo(Setup);
        InsertJnlLine(Setup, Facility, LineNo, Facility."Due Date", Enum::"Gen. Journal Account Type"::"G/L Account",
            Facility."Facility Account No.", Facility.Amount, CopyStr(StrSubstNo(RepaymentTxt, Facility."No."), 1, 100));
        if Facility."Commission Amount" <> 0 then
            InsertJnlLine(Setup, Facility, LineNo, Facility."Due Date", Enum::"Gen. Journal Account Type"::"G/L Account",
                Facility."Commission Account No.", Facility."Commission Amount", CopyStr(StrSubstNo(CommissionTxt, Facility."No."), 1, 100));
        InsertJnlLine(Setup, Facility, LineNo, Facility."Due Date", Enum::"Gen. Journal Account Type"::"Bank Account",
            Facility."Bank Account No.", -(Facility.Amount + Facility."Commission Amount"), CopyStr(StrSubstNo(RepaymentTxt, Facility."No."), 1, 100));

        Facility."Maturity Generated" := true;
        Facility."Maturity Total" := Facility.Amount + Facility."Commission Amount";
        Facility.Status := Facility.Status::Matured;
        Facility.Modify();
        if not Setup."Review Before Posting" then
            PostEntries(Setup, Facility);
    end;

    // Job queue: generates the maturity entry of every open facility whose due date is reached
    procedure ProcessDueFacilities(): Integer
    var
        Facility: Record "NAV Bank Facility";
        ToProcess: Record "NAV Bank Facility";
        NoProcessed: Integer;
    begin
        Facility.SetCurrentKey(Status, "Due Date");
        Facility.SetRange(Status, Facility.Status::Open);
        Facility.SetRange("Maturity Generated", false);
        Facility.SetFilter("Due Date", '<>%1&..%2', 0D, Today());
        if Facility.FindSet() then
            repeat
                ToProcess.Get(Facility."No.");
                GenerateMaturityEntry(ToProcess);
                NoProcessed += 1;
            until Facility.Next() = 0;
        exit(NoProcessed);
    end;

    // Removes the generated lines that are still in the journal and resets the status
    procedure CancelPendingEntry(var Facility: Record "NAV Bank Facility")
    var
        Setup: Record "NAV Bank Facility Setup";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        if not (Facility.Status in [Facility.Status::"Initial Pending", Facility.Status::Matured]) then
            Error(NothingPendingErr, Facility."No.");
        Setup.Get();
        GenJnlLine.SetRange("Journal Template Name", Setup."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", Setup."Journal Batch Name");
        GenJnlLine.SetRange("Document No.", Facility."No.");
        GenJnlLine.DeleteAll(true);
        if Facility.Status = Facility.Status::"Initial Pending" then
            Facility.Status := Facility.Status::Draft
        else begin
            Facility.Status := Facility.Status::Open;
            Facility."Maturity Generated" := false;
            Facility."Maturity Total" := 0;
        end;
        Facility.Modify();
    end;

    procedure OpenJournal()
    var
        Setup: Record "NAV Bank Facility Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlManagement: Codeunit GenJnlManagement;
    begin
        Setup.Get();
        Setup.TestField("Journal Template Name");
        Setup.TestField("Journal Batch Name");
        GenJnlBatch.Get(Setup."Journal Template Name", Setup."Journal Batch Name");
        GenJnlManagement.TemplateSelectionFromBatch(GenJnlBatch);
    end;

    // ======================================================================
    // Helpers
    // ======================================================================
    local procedure PostEntries(Setup: Record "NAV Bank Facility Setup"; var Facility: Record "NAV Bank Facility")
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Journal Template Name", Setup."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", Setup."Journal Batch Name");
        GenJnlLine.FindFirst();
        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJnlLine);
        // the status is updated when the bank ledger entry is posted (see subscriber below)
        Facility.Get(Facility."No.");
    end;

    local procedure GetSetupAndCheckBatch(var Setup: Record "NAV Bank Facility Setup")
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        Setup.Get();
        Setup.TestField("Journal Template Name");
        Setup.TestField("Journal Batch Name");
        GenJnlBatch.Get(Setup."Journal Template Name", Setup."Journal Batch Name");
        // the facility no. is the document no.: a no. series on the batch would refuse it
        GenJnlBatch.TestField("No. Series", '');
        if not Setup."Review Before Posting" then begin
            // automatic posting posts the whole batch: it must contain only the facility lines
            GenJnlLine.SetRange("Journal Template Name", Setup."Journal Template Name");
            GenJnlLine.SetRange("Journal Batch Name", Setup."Journal Batch Name");
            if not GenJnlLine.IsEmpty() then
                Error(BatchNotEmptyErr, Setup."Journal Template Name", Setup."Journal Batch Name");
        end;
    end;

    local procedure CheckBankAccount(BankAccountNo: Code[20])
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get(BankAccountNo);
        BankAccount.TestField(Blocked, false);
    end;

    local procedure GetNextLineNo(Setup: Record "NAV Bank Facility Setup"): Integer
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Journal Template Name", Setup."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", Setup."Journal Batch Name");
        if GenJnlLine.FindLast() then
            exit(GenJnlLine."Line No.");
        exit(0);
    end;

    local procedure InsertJnlLine(Setup: Record "NAV Bank Facility Setup"; Facility: Record "NAV Bank Facility"; var LineNo: Integer; PostingDate: Date; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; LineAmount: Decimal; LineDescription: Text[100])
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        GenJnlTemplate.Get(Setup."Journal Template Name");
        LineNo += 10000;
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := Setup."Journal Template Name";
        GenJnlLine."Journal Batch Name" := Setup."Journal Batch Name";
        GenJnlLine."Line No." := LineNo;
        GenJnlLine.Validate("Posting Date", PostingDate);
        GenJnlLine."Document Date" := PostingDate;
        GenJnlLine."Document No." := Facility."No.";
        GenJnlLine."External Document No." := Facility."Bank Reference";
        GenJnlLine.Validate("Account Type", AccountType);
        GenJnlLine.Validate("Account No.", AccountNo);
        if AccountType = AccountType::"G/L Account" then begin
            // no VAT on the facility entries
            GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
            GenJnlLine."Gen. Bus. Posting Group" := '';
            GenJnlLine."Gen. Prod. Posting Group" := '';
            GenJnlLine."VAT Bus. Posting Group" := '';
            GenJnlLine."VAT Prod. Posting Group" := '';
        end;
        GenJnlLine.Validate("Currency Code", Facility."Currency Code");
        GenJnlLine.Validate(Amount, LineAmount);
        GenJnlLine.Description := LineDescription;
        GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
        GenJnlLine.Insert(true);
    end;

    // ======================================================================
    // Status update when the bank entry of a facility is posted
    // (journal posted by the user, or automatic posting)
    // ======================================================================
    [EventSubscriber(ObjectType::Table, Database::"Bank Account Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertBankLedgerEntry(var Rec: Record "Bank Account Ledger Entry"; RunTrigger: Boolean)
    var
        Facility: Record "NAV Bank Facility";
    begin
        if Rec.IsTemporary() then
            exit;
        if StrLen(Rec."Document No.") > MaxStrLen(Facility."No.") then
            exit;
        if not Facility.Get(Rec."Document No.") then
            exit;
        if Facility."Bank Account No." <> Rec."Bank Account No." then
            exit;
        case true of
            (Facility.Status in [Facility.Status::Draft, Facility.Status::"Initial Pending"]) and (Rec.Amount > 0):
                begin
                    Facility.Status := Facility.Status::Open;
                    Facility."Initial Posting Date" := Rec."Posting Date";
                    Facility."Initial Bank Entry No." := Rec."Entry No.";
                    Facility.Modify();
                end;
            (Facility.Status = Facility.Status::Matured) and (Rec.Amount < 0):
                begin
                    Facility.Status := Facility.Status::Processed;
                    Facility."Maturity Posting Date" := Rec."Posting Date";
                    Facility."Maturity Bank Entry No." := Rec."Entry No.";
                    Facility.Modify();
                end;
        end;
    end;

    var
        InitialTxt: Label 'Bank facility %1 %2', Comment = '%1 = no., %2 = description';
        RepaymentTxt: Label 'Bank facility %1 repayment', Comment = '%1 = no.';
        CommissionTxt: Label 'Bank facility %1 commission', Comment = '%1 = no.';
        NotOpenErr: Label 'Bank facility %1 has status %2. The maturity entry requires status Open (initial entry posted).', Comment = '%1 = no., %2 = status';
        AlreadyGeneratedErr: Label 'The maturity entry of bank facility %1 has already been generated.', Comment = '%1 = no.';
        NothingPendingErr: Label 'Bank facility %1 has no entry waiting in the journal.', Comment = '%1 = no.';
        BatchNotEmptyErr: Label 'Journal batch %1 %2 must be empty for the automatic posting of bank facilities. Post or delete its lines, or tick Review Entries Before Posting in the setup.', Comment = '%1 = template, %2 = batch';
}

codeunit 50311 "NAV Bank Facility Maturity Job"
{
    // Job Queue: run daily. Generates the maturity entries of the facilities due today or earlier.
    trigger OnRun()
    var
        FacilityMgt: Codeunit "NAV Bank Facility Mgt.";
    begin
        FacilityMgt.ProcessDueFacilities();
    end;
}
