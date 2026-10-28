// Lignes de l'expédition enregistrée : demande d'origine et commercial de chaque ligne (lecture seule).
pageextension 90051 "GNC Posted Sales Shpt. Subform" extends "Posted Sales Shpt. Subform"
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
            field("GNC Grouped Requests"; Rec."GNC Grouped Requests")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how many request lines the order line comes from. Choose the number to see the quantity of each request.';
            }
            field("GNC Bonus Line"; Rec."GNC Bonus Line")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the line is a free bonus line.';
            }
        }
    }
}
