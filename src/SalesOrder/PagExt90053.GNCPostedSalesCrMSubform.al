// Lignes de l'avoir enregistré : demande d'origine et commercial de chaque ligne (lecture seule).
pageextension 90053 "GNC Posted Sales Cr.M. Subform" extends "Posted Sales Cr. Memo Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("GNC Request No."; Rec."GNC Request No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the request collection (sales quote) that this line comes from.';
            }
            field("GNC Salesperson Code"; Rec."GNC Salesperson Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the salesperson who collected the request for this line.';
            }
            field("GNC Bonus Line"; Rec."GNC Bonus Line")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the line is a free bonus line.';
            }
        }
    }
}
