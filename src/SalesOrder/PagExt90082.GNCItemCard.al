// Lot 7 – Fiche article : case "Cold Chain".
pageextension 90082 "GNC Item Card" extends "Item Card"
{
    layout
    {
        addafter("Item Category Code")
        {
            field("GNC Cold Chain"; Rec."GNC Cold Chain")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the item must be kept cold during delivery (refrigerated van).';
            }
        }
    }
}
