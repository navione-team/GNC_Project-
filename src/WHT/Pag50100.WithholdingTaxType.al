namespace LABS.LABS;

page 50005 "Withholding Tax Type"
{
    ApplicationArea = All;
    Caption = 'Withholding Tax Type';
    PageType = List;
    SourceTable = WithholdingTaxTypes;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Nonrelated Rate %"; Rec."Nonrelated Rate %")
                {
                    ToolTip = 'Specifies the value of the Nonrelated Rate % field.', Comment = '%';
                }
                field("Related Rate %"; Rec."Related Rate %")
                {
                    ToolTip = 'Specifies the value of the Related Rate % field.', Comment = '%';
                }
            }
        }
    }
}
