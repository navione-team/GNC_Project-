// Lot 5 – Colonne "Allow Edit Bonus Lines" dans la page User Setup.
// Lot 6 – Colonnes "Max Line Discount %" et "Sales Location Code".
pageextension 90064 "GNC User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("GNC Allow Edit Bonus Lines"; Rec."GNC Allow Edit Bonus Lines")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the user can change or delete the bonus lines of sales orders.';
            }
            // Lot 6
            field("GNC Max Line Discount %"; Rec."GNC Max Line Discount %")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the highest line discount % that the user can enter manually, above the suggested discount. Used when Control Manual Discount is selected in GNC Sales Setup.';
            }
            field("GNC Location Code"; Rec."GNC Location Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the location that is filled in automatically on the sales quotes (requests), orders and invoices created by the user. The user can still change it on the document.';
            }
        }
    }
}
