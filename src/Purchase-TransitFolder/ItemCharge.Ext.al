tableextension 50200 "NAV Item Charge" extends "Item Charge"
{
    fields
    {
        field(50200; "Calculation Type"; Enum "NAV Charge Calc. Type")
        {
            Caption = 'Calculation Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                case "Calculation Type" of
                    "Calculation Type"::"By Amount":
                        "Default Percent" := 0;
                    "Calculation Type"::"By Percent":
                        "Default Amount" := 0;
                end;
            end;
        }
        field(50201; "By Default"; Boolean)
        {
            Caption = 'By Default';
            DataClassification = CustomerContent;
        }
        field(50202; "Default Percent"; Decimal)
        {
            Caption = 'Default %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;

            trigger OnValidate()
            begin
                if "Default Percent" <> 0 then
                    TestField("Calculation Type", "Calculation Type"::"By Percent");
            end;
        }
        field(50203; "Default Amount"; Decimal)
        {
            Caption = 'Default Amount (LCY)';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Default Amount" <> 0 then
                    TestField("Calculation Type", "Calculation Type"::"By Amount");
            end;
        }
        field(50204; "Default Vendor No."; Code[20])
        {
            Caption = 'Default Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        // Account credited by the estimated charge accrual posted at goods receipt
        // (e.g. 1109002 Freight Clearing Charges, 1109003 Customs Clearing...)
        field(50205; "Clearing Account No."; Code[20])
        {
            Caption = 'Clearing Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
    }
}

pageextension 50200 "NAV Item Charges" extends "Item Charges"
{
    layout
    {
        addafter(Description)
        {
            field("Calculation Type"; Rec."Calculation Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how the charge is calculated in the transit folder: fixed amount or percentage of the orders amount excluding VAT.';
            }
            field("By Default"; Rec."By Default")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that this charge is automatically inserted in every new transit folder.';
            }
            field("Default Percent"; Rec."Default Percent")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the default percentage (By Percent calculation type).';
            }
            field("Default Amount"; Rec."Default Amount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the default fixed amount in local currency (By Amount calculation type).';
            }
            field("Default Vendor No."; Rec."Default Vendor No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the default vendor for this charge (forwarding agent, carrier, customs...).';
            }
            field("Clearing Account No."; Rec."Clearing Account No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the clearing account credited with the estimated amount of this charge when the goods of a transit folder are received. The accrual is reversed when the charge is invoiced. Leave it empty to post the charge only at invoice (standard behavior).';
            }
        }
    }
}
