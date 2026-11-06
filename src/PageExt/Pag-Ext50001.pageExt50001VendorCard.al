namespace OnePassProject.OnePassProject;

using Microsoft.Purchases.Vendor;

pageextension 50001 "page-Ext50001.Vendor Card" extends "Vendor Card"//26
{
    layout
    {

        addafter(General)
        {

            group(WithHoldingTax)
            {
                field("Withholding Tax Type"; Rec."Withholding Tax Type")
                {
                    ApplicationArea = all;
                }
                field(Related; Rec.Related)
                {
                    ApplicationArea = all;
                }
                field("Vendor Activity"; Rec."Vendor Activity")
                {
                    ApplicationArea = all;
                }
            }

        }
    }
}

