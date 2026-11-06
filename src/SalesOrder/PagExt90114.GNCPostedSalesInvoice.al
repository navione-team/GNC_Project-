// 1.0.0.39 – Fiche facture vente enregistrée : action « Print Tax Invoice » qui imprime la
// facture fiscale GNC (rapport 90113, arabe / anglais, lots, QR code) pour cette facture.
pageextension 90114 "GNC Posted Sales Invoice" extends "Posted Sales Invoice"
{
    actions
    {
        addafter(Print)
        {
            action(GNCPrintTaxInvoice)
            {
                ApplicationArea = All;
                Caption = 'Print Tax Invoice';
                Image = PrintVoucher;
                ToolTip = 'Print the GNC tax invoice (Arabic / English) with the lots, expiry dates and the QR code.';

                trigger OnAction()
                var
                    SalesInvHeader: Record "Sales Invoice Header";
                begin
                    SalesInvHeader := Rec;
                    SalesInvHeader.SetRecFilter();
                    Report.RunModal(Report::"GNC Tax Invoice", true, false, SalesInvHeader);
                end;
            }
        }
        addafter(Print_Promoted)
        {
            actionref(GNCPrintTaxInvoice_Promoted; GNCPrintTaxInvoice)
            {
            }
        }
    }
}
