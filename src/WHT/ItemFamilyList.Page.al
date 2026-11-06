page 90021 "Item Family List"
{
    ApplicationArea = All;
    Caption = 'Item Families';
    PageType = List;
    SourceTable = "Item Family";
    UsageCategory = Lists;
    Editable = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code that identifies the item family.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the item family.';
                }
            }
        }
    }
}
