pageextension 90023 "Item Card Ext" extends "Item Card"
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
            field("Arabic Description"; Rec."Arabic Description")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Arabic description of the item.';
            }
            field("Units per Pack"; Rec."Units per Pack")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how many units are contained in one pack.';
            }
            field("Tablets per Pack"; Rec."Tablets per Pack")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how many tablets are contained in one pack.';
            }
            field("Sales Price per Pack"; Rec."Sales Price per Pack")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sales price for one pack of the item.';
            }
            field("Sales Price per Tablet"; Rec."Sales Price per Tablet")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sales price for one tablet of the item.';
            }
            field("Default Location Code"; Rec."Default Location Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the default location for the item.';
            }
            field(Remarks; Rec.Remarks)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies additional remarks about the item.';
            }
        }
    }
}
