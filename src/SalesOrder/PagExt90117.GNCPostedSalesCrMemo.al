// 1.0.0.42 – Fiche avoir vente enregistré : action « Print GNC Credit Note » (rapport 90116,
// modèle du document CN-01821 du client : motif, facture d'origine, codes NPC / MOH, QR code).
pageextension 90117 "GNC Posted Sales Cr. Memo" extends "Posted Sales Credit Memo"
{
    actions
    {
        addafter(Print)
        {
            action(GNCPrintCreditNote)
            {
                ApplicationArea = All;
                Caption = 'Print GNC Credit Note';
                Image = PrintVoucher;
                ToolTip = 'Print the GNC credit note with the reason, the original invoice, the NPC and MOH codes and the QR code.';

                trigger OnAction()
                var
                    SalesCrMemoHeader: Record "Sales Cr.Memo Header";
                begin
                    SalesCrMemoHeader := Rec;
                    SalesCrMemoHeader.SetRecFilter();
                    Report.RunModal(Report::"GNC Credit Note", true, false, SalesCrMemoHeader);
                end;
            }
        }
        addafter(Print_Promoted)
        {
            actionref(GNCPrintCreditNote_Promoted; GNCPrintCreditNote)
            {
            }
        }
    }
}
