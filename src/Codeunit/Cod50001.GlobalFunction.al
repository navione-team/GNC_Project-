namespace LABSCloud.LABSCloud;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Document;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Sales.Posting;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sales.History;
using Microsoft.Purchases.Document;
using Microsoft.Finance.GeneralLedger.Reversal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Item;

codeunit 50001 "Global Function"
{
    Permissions = TableData 21 = rimd, tabledata 271 = rimd, tabledata 32 = rimd, tabledata 17 = rimd, tabledata 113 = rimd;
    trigger OnRun()
    var
        myInt: Integer;
    begin

    end;

    procedure InsertPrepaidRental()
    var
        PrepaidLine: Record PrepaidLine;
        PrepaidHeader: Record PrepaiedHeader;
        GeneralJournalSetup: Record "General Ledger Setup";
        GeneraJournalLine: Record "Gen. Journal Line";
        Compteur: Integer;

    begin
        GeneralJournalSetup.get;
        GeneraJournalLine.setrange("Journal Template Name", GeneralJournalSetup."Default Gen. Jrnl Prepaid Temp");
        GeneraJournalLine.setrange("Journal Batch Name", GeneralJournalSetup."Default Gen. Jrnl Prep Batch");
        GeneraJournalLine.DeleteAll();
        PrepaidLine.setfilter("Due Date", '<=%1', WorkDate());
        PrepaidLine.SetRange(Integrated, false);
        if PrepaidLine.FindFirst() then
            repeat
                Compteur += 10000;
                PrepaidHeader.get(PrepaidLine."No. Prepaid");
                // Debit 
                GeneraJournalLine.init;
                GeneraJournalLine."Journal Template Name" := GeneralJournalSetup."Default Gen. Jrnl Prepaid Temp";
                GeneraJournalLine."Journal Batch Name" := GeneralJournalSetup."Default Gen. Jrnl Prep Batch";
                GeneraJournalLine."Line No." := Compteur;
                GeneraJournalLine."Document No." := PrepaidLine."No. Prepaid";
                GeneraJournalLine.VALIDATE("Posting Date", PrepaidLine."Due Date");
                GeneraJournalLine."Account Type" := GeneraJournalLine."Account Type"::"G/L Account";
                GeneraJournalLine.VALIDATE("Account No.", PrepaidHeader."Debit Amount Account");
                GeneraJournalLine.Validate("Source Code", GeneralJournalSetup."Prepaid Source Code");
                GeneraJournalLine.Validate(amount, PrepaidLine.Amount);
                GeneraJournalLine.Prepaid := true;
                GeneraJournalLine.Insert();
                Compteur += 10000;
                // Credit
                GeneraJournalLine.init;
                GeneraJournalLine."Journal Template Name" := GeneralJournalSetup."Default Gen. Jrnl Prepaid Temp";
                GeneraJournalLine."Journal Batch Name" := GeneralJournalSetup."Default Gen. Jrnl Prep Batch";
                GeneraJournalLine."Line No." := Compteur;
                GeneraJournalLine."Document No." := PrepaidLine."No. Prepaid";
                GeneraJournalLine.VALIDATE("Posting Date", PrepaidLine."Due Date");
                GeneraJournalLine."Account Type" := GeneraJournalLine."Account Type"::"G/L Account";
                GeneraJournalLine.VALIDATE("Account No.", PrepaidHeader."Credit Amount Account");
                GeneraJournalLine.Validate("Source Code", GeneralJournalSetup."Prepaid Source Code");
                GeneraJournalLine.Validate(amount, -PrepaidLine.Amount);
                GeneraJournalLine.Insert();
                // Generate Entries
                GeneraJournalLine.Reset();
                GeneraJournalLine.setrange("Journal Template Name", GeneralJournalSetup."Default Gen. Jrnl Prepaid Temp");
                GeneraJournalLine.setrange("Journal Batch Name", GeneralJournalSetup."Default Gen. Jrnl Prep Batch");
                //if GeneraJournalLine.FindFirst() THEN
                //    CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", GeneraJournalLine);
                PrepaidLine.Integrated := true;
                PrepaidLine.Modify();
            until PrepaidLine.Next() = 0;
    end;

    procedure LettrerClient(PClient: Code[20]; PLettre: Code[30])
    var
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ApplyingCustomerLedgEntry: Record "Cust. Ledger Entry";
        CustEntrySetApplID: Codeunit "Cust. Entry-SetAppl.ID";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
    begin
        CustLedgerEntry.reset;
        CustLedgerEntry2.RESET();
        CustLedgerEntry2.SETRANGE(Open, TRUE);
        CustLedgerEntry2.SETRANGE("Document Type", CustLedgerEntry2."Document Type"::invoice);
        CustLedgerEntry2.SetRange("External Document No.", PLettre);
        // CustLedgerEntry2.SetRange("Document No.", ParaNumDocOrigine);
        CustLedgerEntry2.SETRANGE("Customer No.", PClient);
        IF CustLedgerEntry2.FINDFIRST THEN begin
            CustLedgerEntry.COPY(CustLedgerEntry2);
            ApplyCustEntryFormEntry(CustLedgerEntry);
            CustLedgerEntry.GET(CustLedgerEntry."Entry No.");
            ApplyingCustomerLedgEntry.Reset();
            ApplyingCustomerLedgEntry.SETRANGE("External Document No.", PLettre);
            ApplyingCustomerLedgEntry.SETFILTER("Entry No.", '<>%1', CustLedgerEntry."Entry No.");
            ApplyingCustomerLedgEntry.SETRANGE("Document Type", ApplyingCustomerLedgEntry."Document Type"::payment);
            ApplyingCustomerLedgEntry.SETRANGE(Open, TRUE);
            ApplyingCustomerLedgEntry.SETRANGE("Customer No.", PClient);
            IF ApplyingCustomerLedgEntry.FINDFIRST THEN BEGIN
                CustEntrySetApplID.SetApplId(ApplyingCustomerLedgEntry, CustLedgerEntry, '');
                CustEntryApplyPostedEntries.Apply(CustLedgerEntry, ApplyUnapplyParameters);
            END;
        end;
        // REPEAT

        // UNTIL CustLedgerEntry2.NEXT = 0;
    end;

    Procedure ApplyCustEntryFormEntry(VAR ApplyingCustLedgEntry: Record "Cust. Ledger Entry")

    var
        CustEntryApplID: code[50];
        CustLedgEntry: Record "Cust. Ledger Entry";
        TextL001: Label '';

    begin
        IF NOT ApplyingCustLedgEntry.Open THEN
            ERROR(TextL001);

        CustEntryApplID := USERID;
        IF CustEntryApplID = '' THEN
            CustEntryApplID := '***';
        IF ApplyingCustLedgEntry."Remaining Amount" = 0 THEN
            ApplyingCustLedgEntry.CALCFIELDS("Remaining Amount");

        ApplyingCustLedgEntry."Applying Entry" := TRUE;
        ApplyingCustLedgEntry."Applies-to ID" := CustEntryApplID;
        ApplyingCustLedgEntry."Amount to Apply" := ApplyingCustLedgEntry."Remaining Amount";
        CODEUNIT.RUN(CODEUNIT::"Cust. Entry-Edit", ApplyingCustLedgEntry);
        COMMIT();

        CustLedgEntry.SETCURRENTKEY("Customer No.", Open, Positive);
        CustLedgEntry.SETRANGE("Customer No.", ApplyingCustLedgEntry."Customer No.");
        CustLedgEntry.SETRANGE(Open, TRUE);
        RunApplyCustEntries(CustLedgEntry, ApplyingCustLedgEntry);
    end;

    Procedure RunApplyCustEntries(VAR CustLedgEntry: Record "Cust. Ledger Entry"; VAR ApplyingCustLedgEntry: Record "Cust. Ledger Entry")
    var
        ApplyCustEntries: page "Apply Customer Entries";

    begin
        IF CustLedgEntry.FINDFIRST THEN BEGIN
            ApplyCustEntries.SetCustLedgEntry(ApplyingCustLedgEntry);
            ApplyCustEntries.SETRECORD(CustLedgEntry);
            ApplyCustEntries.SETTABLEVIEW(CustLedgEntry);
            //  ApplyCustEntries.RunModal;
            CLEAR(ApplyCustEntries);
            ApplyingCustLedgEntry."Applying Entry" := FALSE;
            ApplyingCustLedgEntry."Applies-to ID" := '';
            ApplyingCustLedgEntry."Amount to Apply" := 0;
        END;
    end;

    procedure UpdateCustomeLedgerEntry(ParaDocumentNo: Code[20]; ParaExternalDoc: code[20])
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustomerLedgerEntry.SetRange("Document No.", ParaDocumentNo);
        if CustomerLedgerEntry.FindFirst() then begin
            CustomerLedgerEntry."External Document No." := ParaExternalDoc;
            CustomerLedgerEntry.Modify();
        end;

    end;


    procedure UpdateBankLedgerEntry(ParaSequence: Integer; ParaStatmenLinetNo: Integer; ParaStatmentNo: code[20])
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        if BankAccountLedgerEntry.get(ParaSequence) then begin
            BankAccountLedgerEntry."Statement Status" := BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied";
            BankAccountLedgerEntry."Statement Line No." := ParaStatmenLinetNo;
            BankAccountLedgerEntry."Statement No." := ParaStatmentNo;
            BankAccountLedgerEntry.Modify();
        end;

    end;

    procedure UpdateBankLedgerEntryExternalDocument()
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccountLedgerEntry.SetRange("External Document No.", '');
        if BankAccountLedgerEntry.FindFirst() then
            repeat
                BankAccountLedgerEntry."External Document No." := BankAccountLedgerEntry."Document No.";
                BankAccountLedgerEntry.Modify();
            until BankAccountLedgerEntry.Next() = 0;
        Message('Process Finished');
    end;

    procedure UpdateBankLedgerEntryOpen()
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccountLedgerEntry.setfilter("Posting Date", '<=%1', 20260630D);
        BankAccountLedgerEntry.ModifyAll(Open, false);

        Message('Process Finished');
    end;

    procedure UpdateWarrantyDate(ParaItem: code[20]; ParaSerialNumber: code[20]; ParaDate: Date)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
    begin
        item.get(ParaItem);
        if format(item."Expiration Calculation") <> '' THEN begin
            ItemLedgerEntry.SetRange("Item No.", ParaItem);
            ItemLedgerEntry.SetRange("Serial No.", ParaSerialNumber);
            ItemLedgerEntry.ModifyAll("Warranty Date", CalcDate(item."Expiration Calculation", ParaDate));
        end;

    end;


    procedure UpdateGlEntry()
    var
        GlEntry: Record "G/L Entry";
        Item: Record Item;
    begin
        GlEntry.SetRange("Posting Date", 20210101D, 20221231D);
        if GlEntry.FindFirst() then
            repeat
                GlEntry.Amount := GlEntry.Amount / 100;
                GlEntry."Source Currency Amount" := GlEntry."Source Currency Amount" / 100;
                GlEntry."VAT Amount" := GlEntry."VAT Amount" / 100;
                GlEntry."Additional-Currency Amount" := GlEntry."Additional-Currency Amount" / 100;
                GlEntry."Add.-Currency Debit Amount" := GlEntry."Add.-Currency Debit Amount" / 100;
                GlEntry."Add.-Currency Credit Amount" := GlEntry."Add.-Currency Credit Amount" / 100;
                GlEntry."Credit Amount" := GlEntry."Credit Amount" / 100;
                GlEntry."Debit Amount" := GlEntry."Debit Amount" / 100;
                GlEntry.modify;
            until GlEntry.Next() = 0;
    end;



    procedure UpdateProductId(ParaItem: code[20]; ParaIdSubsrciption: code[20])
    var
        PostedSalesHeader: Record "Sales Invoice Header";
        PostedSalesLine: Record "Sales Invoice Line";
        Item: Record Item;
    begin
        item.get(ParaItem);
        PostedSalesHeader.SetRange("External Document No.", ParaIdSubsrciption);
        if PostedSalesHeader.FindFirst() then begin
            PostedSalesLine.setrange("Document No.", PostedSalesHeader."No.");
            if PostedSalesLine.FindFirst() then
                repeat
                    PostedSalesLine."No." := ParaItem;
                    PostedSalesLine.Description := Item.Description;
                    PostedSalesLine.Modify();
                until PostedSalesLine.Next() = 0;
        end;


    end;





    procedure GetPurchLineForItemChargeAssgntPurch(var PurchaseLine: Record "Purchase Line"; var ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetPurchLineForItemChargeAssgntPurch(PurchaseLine, ItemChargeAssgntPurch, IsHandled);
        if IsHandled then
            exit;

        PurchaseLine.Get(ItemChargeAssgntPurch."Applies-to Doc. Type", ItemChargeAssgntPurch."Applies-to Doc. No.", ItemChargeAssgntPurch."Applies-to Doc. Line No.");
    end;

    procedure OnBeforeGetPurchLineForItemChargeAssgntPurch(var PurchaseLine: Record "Purchase Line"; var ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; var IsHandled: Boolean)
    begin
    end;






    var
        GCompteur: Integer;

        IsPayment: Boolean;
        Balance: Decimal;
        Article: Code[20];
        Master: Code[20];
        Qte: Integer;
        CodeBarre2: Code[20];
        GSalesFeader: Record "Sales Header";

}
