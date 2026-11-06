namespace LABSV.LABSV;
using Microsoft.Sales.Posting;
using Microsoft.Purchases.Document;
using Microsoft.Finance.Dimension;
using Microsoft.Purchases.Vendor;
using System.Security.User;
using Microsoft.Inventory.Posting;
using Microsoft.CRM.Contact;
using Microsoft.Purchases.Posting;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Document;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 50003 Events
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var HideProgressWindow: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var IsHandled: Boolean)
    begin
        if PurchaseHeader."Withholding Tax Type" <> '' then begin
            HandleWHTPostingAfterInvoice(PurchaseHeader, CommitIsSupressed);
        end;
    end;


    procedure HandleWHTPostingAfterInvoice(var PurchaseHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)
    var
        VendL: Record Vendor;
        WHTType: Record "WithholdingTaxTypes";
        GLSetup: Record "General Ledger Setup";
        GenJnlLineWHT: Record "Gen. Journal Line";
        GlEntry: Record "G/L Entry";
        TempJnlLineDim: Record "Dim. Value per Account";
        TemplateCode: Code[10];
        BatchCode: Code[10];
        WHTAmount: Decimal;
        Rate: Decimal;
        GenJnlLineDocNo: Code[20];
        GenJnlLineExtDocNo: Code[35];
        SrcCode: Code[10];
        GenJnlLineDocType: Enum "Gen. Journal Document Type";
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
    begin
        GlEntry.SetRange("Document No.", PurchaseHeader."No.");
        GlEntry.SetRange("External Document No.", 'WHT');
        if GlEntry.FindFirst() then exit;
        GLSetup.GET();
        IF PurchaseHeader."WHT Rate" = 0 THEN EXIT;
        GenJnlLineWHT.Reset();
        GenJnlLineWHT.setrange("Journal Template Name", GLSetup."WHT Journal Template Code");
        GenJnlLineWHT.setrange("Journal Batch Name", GLSetup."WHT Journal Batch Code");
        GenJnlLineWHT.DeleteAll();


        GLSetup.TESTFIELD("WHT Journal Template Code");
        GLSetup.TESTFIELD("WHT Journal Batch Code");

        //   WHTType.GET(VendL."Withholding Tax Type");
        PurchaseHeader.CalcFields("Amount Including VAT");
        WHTAmount := (PurchaseHeader."Amount Including VAT" / PurchaseHeader."Currency Factor") * PurchaseHeader."WHT Rate" / 100; // Adjust if needed
        WHTAmount := Round(WHTAmount, 0.01);
        GenJnlLineWHT.INIT();
        GenJnlLineWHT."Line No." := 10000;
        GenJnlLineWHT."Journal Template Name" := GLSetup."WHT Journal Template Code";
        GenJnlLineWHT."Journal Batch Name" := GLSetup."WHT Journal Batch Code";
        GenJnlLineWHT."Posting Date" := PurchaseHeader."Posting Date";
        GenJnlLineWHT."Document Date" := PurchaseHeader."Document Date";
        GenJnlLineWHT.Description := 'Withholding Tax for Vendor Invoice';
        GenJnlLineWHT."Shortcut Dimension 1 Code" := PurchaseHeader."Shortcut Dimension 1 Code";
        GenJnlLineWHT."Shortcut Dimension 2 Code" := PurchaseHeader."Shortcut Dimension 2 Code";
        GenJnlLineWHT."Account Type" := GenJnlLineWHT."Account Type"::"G/L Account";
        GenJnlLineWHT.Validate("Account No.", GLSetup."WHT Debit Account");
        GenJnlLineWHT."Source Type" := GenJnlLineWHT."Source Type"::Vendor;
        GenJnlLineWHT."Source No." := PurchaseHeader."Buy-from Vendor No.";
        GenJnlLineWHT."Document No." := PurchaseHeader."No.";
        GenJnlLineWHT."External Document No." := 'WHT';
        // GenJnlLineWHT.validate("Currency Code", PurchaseHeader."Currency Code");
        GenJnlLineWHT.validate(Amount, WHTAmount);
        GenJnlLineWHT."Hide Dialog" := true;
        GenJnlLineWHT.Insert();
        // CREDIT 
        GenJnlLineWHT.INIT();
        GenJnlLineWHT."Line No." := 20000;
        GenJnlLineWHT."Journal Template Name" := GLSetup."WHT Journal Template Code";
        GenJnlLineWHT."Journal Batch Name" := GLSetup."WHT Journal Batch Code";
        GenJnlLineWHT."Posting Date" := PurchaseHeader."Posting Date";
        GenJnlLineWHT."Document Date" := PurchaseHeader."Document Date";
        GenJnlLineWHT.Description := 'Withholding Tax for Vendor Invoice';
        GenJnlLineWHT."Shortcut Dimension 1 Code" := PurchaseHeader."Shortcut Dimension 1 Code";
        GenJnlLineWHT."Shortcut Dimension 2 Code" := PurchaseHeader."Shortcut Dimension 2 Code";
        GenJnlLineWHT."Account Type" := GenJnlLineWHT."Account Type"::"G/L Account";
        GenJnlLineWHT.Validate("Account No.", GLSetup."WHT credit Account");
        GenJnlLineWHT."Document No." := PurchaseHeader."No.";
        GenJnlLineWHT."Source Type" := GenJnlLineWHT."Source Type"::Vendor;
        GenJnlLineWHT."Source No." := PurchaseHeader."Buy-from Vendor No.";
        GenJnlLineWHT."External Document No." := 'WHT';
        GenJnlLineWHT."Hide Dialog" := true;
        // GenJnlLineWHT.validate("Currency Code", PurchaseHeader."Currency Code");
        GenJnlLineWHT.validate(Amount, -WHTAmount); // Credit Amount
        GenJnlLineWHT.Insert();
        GenJnlLineWHT.Reset();
        GenJnlLineWHT.setrange("Journal Template Name", GLSetup."WHT Journal Template Code");
        GenJnlLineWHT.setrange("Journal Batch Name", GLSetup."WHT Journal Batch Code");
        if GenJnlLineWHT.FindFirst() THEN
            GenJnlPost.Run(GenJnlLineWHT);

    end;


    var

        GCompteur: Integer;
        GeneralJournalSetup: Record "General Ledger Setup";
        GeneraJournalLine: Record "Gen. Journal Line";
}
