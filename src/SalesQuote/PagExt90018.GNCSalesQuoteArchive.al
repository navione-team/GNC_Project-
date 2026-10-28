// Fiche d'un devis archivé : onglet "Quote Result" avec le statut, le motif et le commentaire.
// L'action standard "Restore" de cette fiche permet de recréer un devis clôturé (codeunit 90019).
pageextension 90018 "GNC Sales Quote Archive" extends "Sales Quote Archive"
{
    layout
    {
        addafter(General)
        {
            group(GNCQuoteResult)
            {
                Caption = 'Quote Result';

                field("GNC Quote Status"; Rec."GNC Quote Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the result of the quote: open, won (converted to an order) or failed.';
                }
                field("GNC Closed"; Rec."GNC Closed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the quote was closed as a failed sale.';
                }
                field("GNC Failed Reason Code"; Rec."GNC Failed Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies why the sale failed.';
                }
                field("GNC Failed Comment"; Rec."GNC Failed Comment")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies a comment about the failed sale.';
                }
            }
        }
    }
}
