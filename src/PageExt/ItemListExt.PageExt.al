pageextension 90024 "Item List Ext" extends "Item List"
{
    layout
    {
        addafter("Item Category Code")
        {
            field("Product Group Code"; Rec."Product Group Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the product group that the item belongs to.';
            }
            field("Item Family Code"; Rec."Item Family Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the item family that the item belongs to.';
            }
        }
    }
}
