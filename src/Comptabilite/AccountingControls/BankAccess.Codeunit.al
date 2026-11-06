codeunit 50321 "NAV Bank Access Control"
{
    procedure IsRestricted(BankAccountNo: Code[20]): Boolean
    var
        Access: Record "NAV User Bank Access";
    begin
        if BankAccountNo = '' then
            exit(false);
        Access.SetCurrentKey("Bank Account No.");
        Access.SetRange("Bank Account No.", BankAccountNo);
        exit(not Access.IsEmpty());
    end;

    procedure HasAccess(UserName: Code[50]; BankAccountNo: Code[20]): Boolean
    var
        Access: Record "NAV User Bank Access";
    begin
        if not IsRestricted(BankAccountNo) then
            exit(true);
        if Access.Get(UserName, BankAccountNo) then
            exit(true);
        exit(Access.Get(UserName, ''));
    end;

    procedure CheckAccess(BankAccountNo: Code[20])
    begin
        if not HasAccess(CopyStr(UserId(), 1, 50), BankAccountNo) then
            Error(NoAccessErr, UserId(), BankAccountNo);
    end;

    // ---------- Early checks, when the account is entered ----------
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Account No.', false, false)]
    local procedure GenJnlLineOnAfterValidateAccountNo(var Rec: Record "Gen. Journal Line")
    begin
        if Rec."Account Type" = Rec."Account Type"::"Bank Account" then
            CheckAccess(Rec."Account No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Bal. Account No.', false, false)]
    local procedure GenJnlLineOnAfterValidateBalAccountNo(var Rec: Record "Gen. Journal Line")
    begin
        if Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account" then
            CheckAccess(Rec."Bal. Account No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Bal. Account No.', false, false)]
    local procedure SalesHeaderOnAfterValidateBalAccountNo(var Rec: Record "Sales Header")
    begin
        if Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account" then
            CheckAccess(Rec."Bal. Account No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Payment Method Code', false, false)]
    local procedure SalesHeaderOnAfterValidatePaymentMethod(var Rec: Record "Sales Header")
    begin
        if Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account" then
            CheckAccess(Rec."Bal. Account No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Bal. Account No.', false, false)]
    local procedure PurchHeaderOnAfterValidateBalAccountNo(var Rec: Record "Purchase Header")
    begin
        if Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account" then
            CheckAccess(Rec."Bal. Account No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Payment Method Code', false, false)]
    local procedure PurchHeaderOnAfterValidatePaymentMethod(var Rec: Record "Purchase Header")
    begin
        if Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account" then
            CheckAccess(Rec."Bal. Account No.");
    end;

    // ---------- Final guard: every posting on a bank / cash account ----------
    // (journals, documents with payment method, payment registration, reconciliation...)
    [EventSubscriber(ObjectType::Table, Database::"Bank Account Ledger Entry", 'OnBeforeInsertEvent', '', false, false)]
    local procedure BankLedgerEntryOnBeforeInsert(var Rec: Record "Bank Account Ledger Entry")
    begin
        if Rec.IsTemporary() then
            exit;
        CheckAccess(Rec."Bank Account No.");
    end;

    var
        NoAccessErr: Label 'User %1 is not allowed to use bank / cash account %2. Ask the finance administrator to grant access in User Bank Account Access.', Comment = '%1 = user, %2 = bank account';
}
