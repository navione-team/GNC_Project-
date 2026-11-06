pageextension 50002 PurchaseOrderExtension extends "Purchase Order"
{
    layout
    {
        addafter("Buy-from Vendor Name")
        {
            field("Withholding Tax Type"; Rec."Withholding Tax Type")
            {
                ApplicationArea = all;
                Editable = false;
            }
            field(Related; Rec.Related)
            {
                ApplicationArea = all;
                editable = false;
            }
            field("WHT Rate"; Rec."WHT Rate")
            {
                ApplicationArea = all;
                editable = false;
            }
        }
    }
}
