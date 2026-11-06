namespace LABSCloud.LABSCloud;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Payables;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Purchases.History;

pageextension 50008 PaymentJournalExt extends "Payment Journal"
{
    layout
    {
        addafter(Amount)
        {
            field("Debit Amount "; Rec."Debit Amount")
            {
                ApplicationArea = all;
            }

            field("Credit Amount "; Rec."Credit Amount")
            {
                ApplicationArea = all;
            }
        }

    }

    actions
    {


        addafter(Post)
        {
            action("Calculate WHT")
            {
                Caption = 'Calculate WHT';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    GeneralJournalLine: Record "Gen. Journal Line";
                    GeneralJournalLine1: Record "Gen. Journal Line";
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                    PurchaseInvoiceHeader: Record "Purch. Inv. Header";
                    GeneralEdgerSetup: Record "General Ledger Setup";
                    WHTAmount: Decimal;
                    Compteur: Integer;
                    TextL001: Label 'Confirm this action ?';
                begin
                    if not confirm(TextL001) then exit;
                    GeneralEdgerSetup.get;
                    GeneralJournalLine.SetRange("Journal Template Name", rec."Journal Template Name");
                    GeneralJournalLine.SetRange("Journal Batch Name", rec."Journal Batch Name");
                    GeneralJournalLine.SetRange("Account Type", GeneralJournalLine."Account Type"::Vendor);
                    GeneralJournalLine.setfilter("Applies-to ID", '<>%1', '');
                    if GeneralJournalLine.FindFirst() then
                        repeat
                            VendorLedgerEntry.SetRange("Applies-to ID", GeneralJournalLine."Applies-to ID");
                            VendorLedgerEntry.SetRange("Vendor No.", GeneralJournalLine."Account No.");
                            if VendorLedgerEntry.FindFirst() then
                                repeat
                                    Compteur += 10;
                                    if VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice then begin
                                        PurchaseInvoiceHeader.get(VendorLedgerEntry."Document No.");
                                        if (PurchaseInvoiceHeader."Withholding Tax Type" <> '') and (PurchaseInvoiceHeader."WHT Rate" <> 0) then begin
                                            PurchaseInvoiceHeader.CalcFields("Amount Including VAT");
                                            WHTAmount := PurchaseInvoiceHeader."Amount Including VAT" * PurchaseInvoiceHeader."WHT Rate" / 100; // Adjust if needed
                                            GeneralJournalLine1.Copy(GeneralJournalLine);
                                            GeneralJournalLine1."Line No." := GeneralJournalLine."Line No." + Compteur;
                                            GeneralJournalLine1."Account Type" := GeneralJournalLine1."Account Type"::"G/L Account";
                                            GeneralJournalLine1.Validate("Account No.", GeneralEdgerSetup."WHT Credit Account");
                                            GeneralJournalLine1.Validate(Amount, WHTAmount);
                                            GeneralJournalLine1."Source Type" := GeneralJournalLine1."Source Type"::Vendor;
                                            GeneralJournalLine1."Source No." := GeneralJournalLine1."Source No.";
                                            if not GeneralJournalLine1.Insert() then GeneralJournalLine.Modify();
                                            CurrPage.Update();

                                        end;
                                    end;
                                until VendorLedgerEntry.Next() = 0;
                            GeneralJournalLine."WHT Integerated" := true;
                            GeneralJournalLine.Modify();
                        until GeneralJournalLine.Next() = 0;
                end;

            }

        }
        addbefore(Post)
        {
            action(Post_)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'P&ost';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = PostOrder;
                ShortCutKey = 'F9';
                ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                trigger OnAction()
                var
                    GeneralJournalLine: Record "Gen. Journal Line";
                    GeneralJournalLine1: Record "Gen. Journal Line";
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                    PurchaseInvoiceHeader: Record "Purch. Inv. Header";
                    GeneralEdgerSetup: Record "General Ledger Setup";
                    TextL001: Label 'You Must launch The Calculation Of WHT';
                begin
                    GeneralEdgerSetup.get;
                    GeneralJournalLine.SetRange("Journal Template Name", rec."Journal Template Name");
                    GeneralJournalLine.SetRange("Journal Batch Name", rec."Journal Batch Name");
                    GeneralJournalLine.SetRange("Account Type", GeneralJournalLine."Account Type"::Vendor);
                    GeneralJournalLine.setfilter("Applies-to ID", '<>%1', '');
                    GeneralJournalLine.setrange("WHT Integerated", false);
                    if GeneralJournalLine.FindFirst() then
                        repeat
                            VendorLedgerEntry.SetRange("Applies-to ID", GeneralJournalLine."Applies-to ID");
                            VendorLedgerEntry.SetRange("Vendor No.", GeneralJournalLine."Account No.");
                            if VendorLedgerEntry.FindFirst() then
                                repeat
                                    if VendorLedgerEntry."Document Type" = VendorLedgerEntry."Document Type"::Invoice then begin
                                        PurchaseInvoiceHeader.get(VendorLedgerEntry."Document No.");
                                        if (PurchaseInvoiceHeader."Withholding Tax Type" <> '') and (PurchaseInvoiceHeader."WHT Rate" <> 0) then begin
                                            Error(TextL001);

                                        end;
                                    end;
                                until VendorLedgerEntry.Next() = 0;
                        until GeneralJournalLine.Next() = 0;
                    Rec.SendToPosting(Codeunit::"Gen. Jnl.-Post");
                    CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                    CurrPage.Update(false);
                end;
            }
        }
        modify("Post")
        { Visible = false; }
    }
}
