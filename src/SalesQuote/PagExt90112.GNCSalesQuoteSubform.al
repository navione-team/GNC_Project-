// REQ-DB-017 : lignes de la demande (Request Collection).
// Affiche si la remise de la ligne est exceptionnelle (au-dessus du maximum permis)
// et qui l'a approuvée. Les deux champs sont remplis par le codeunit 90069, pas à la main.
pageextension 90112 "GNC Sales Quote Subform" extends "Sales Quote Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("GNC Exceptional Discount"; Rec."GNC Exceptional Discount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the line discount is above the maximum allowed. The request cannot be released until the discount is approved.';
            }
            field("GNC Discount Approved By"; Rec."GNC Discount Approved By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the user who approved the exceptional line discount. It is cleared when the discount is changed.';
            }
        }
    }
}
