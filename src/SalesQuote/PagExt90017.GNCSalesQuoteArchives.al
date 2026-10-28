// Liste des devis archivés : colonnes GNC pour voir le résultat de chaque devis
// (Won / Failed) et le motif. Filtrer Quote Status = Failed donne l'historique des ventes ratées.
pageextension 90017 "GNC Sales Quote Archives" extends "Sales Quote Archives"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("GNC Quote Status"; Rec."GNC Quote Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the result of the quote: open, won (converted to an order) or failed.';
            }
            field("GNC Failed Reason Code"; Rec."GNC Failed Reason Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies why the sale failed.';
            }
            field("GNC Failed Comment"; Rec."GNC Failed Comment")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies a comment about the failed sale.';
            }
            field("GNC Closed"; Rec."GNC Closed")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the quote was closed as a failed sale.';
            }
        }
    }
}
