// Lot 7 – Fiche article : case "Cold Chain".
// 1.0.0.38 – Codes NPC et MOH (imprimés sur les documents de vente).
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
            field("GNC NPC Code"; Rec."GNC NPC Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the national product code (NPC) of the item. It is printed on the sales documents.';
            }
            field("GNC MOH Code"; Rec."GNC MOH Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Ministry of Health (MOH) code of the item. It is printed on the sales documents.';
            }
        }
    }
}
