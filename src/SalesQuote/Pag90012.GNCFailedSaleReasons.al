// Page de saisie des motifs de vente ratée (menu Setup de la page d'accueil GNC).
page 90012 "GNC Failed Sale Reasons"
{
    Caption = 'Failed Sale Reasons';
    PageType = List;
    SourceTable = "GNC Failed Sale Reason";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the failed sale reason.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the failed sale reason.';
                }
            }
        }
    }
}
