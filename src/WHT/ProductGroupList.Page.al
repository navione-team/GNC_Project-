page 90020 "Product Group List"
{
    ApplicationArea = All;
    Caption = 'Product Groups';
    PageType = List;
    SourceTable = "Product Group";
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
                    ToolTip = 'Specifies the code that identifies the product group.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the product group.';
                }
            }
        }
    }
}
