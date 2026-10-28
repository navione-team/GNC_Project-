// Page de saisie des classifications client (recherche BC : "Customer Classifications").
page 90000 "GNC Cust. Classifications"
{
    Caption = 'Customer Classifications';
    PageType = List;
    SourceTable = "GNC Cust. Classification";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which customer classification list the code belongs to.';
                }
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the classification code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the classification code.';
                }
            }
        }
    }
}
