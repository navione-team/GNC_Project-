// Damaged area of each location: fields added in SalesControls.Ext.al (Location extension 50262)
tableextension 50271 "NAV User Setup Damaged" extends "User Setup"
{
    fields
    {
        // Can take stock out of Damaged bins (destruction, supplier return, adjustment, reclassification)
        field(50270; "Damaged Stock Approver"; Boolean)
        {
            Caption = 'Damaged Stock Approver';
            DataClassification = CustomerContent;
        }
    }
}

tableextension 50272 "NAV Inventory Setup Damaged" extends "Inventory Setup"
{
    fields
    {
        field(50270; "Damage Transfer Nos."; Code[20])
        {
            Caption = 'Damage Transfer Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }
}

pageextension 50271 "NAV User Setup Damaged" extends "User Setup"
{
    layout
    {
        addafter("User ID")
        {
            field("Damaged Stock Approver"; Rec."Damaged Stock Approver")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the user can take stock out of damaged bins (destruction, supplier return, adjustment, reclassification).';
            }
        }
    }
}

pageextension 50272 "NAV Inventory Setup Damaged" extends "Inventory Setup"
{
    layout
    {
        addlast(Numbering)
        {
            field("Damage Transfer Nos."; Rec."Damage Transfer Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number series of damage transfers.';
            }
        }
    }
}
