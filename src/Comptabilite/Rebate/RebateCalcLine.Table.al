// Detail of a rebate calculation: the documents (or item lines for Core Rebate)
// that make up the rebate base. Credit memos can be excluded with "Include".
table 50304 "NAV Rebate Calc. Line"
{
    Caption = 'Rebate Calculation Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Calculation No."; Code[20])
        {
            Caption = 'Calculation No.';
            TableRelation = "NAV Rebate Calculation";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Document Type"; Enum "NAV Rebate Source Doc. Type")
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
        }
        field(6; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            Editable = false;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(8; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(9; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount Excl. VAT (LCY)';
            AutoFormatType = 1;
            Editable = false;
        }
        field(10; "Rebate Amount (LCY)"; Decimal)
        {
            Caption = 'Rebate Amount (LCY)';
            AutoFormatType = 1;
            Editable = false;
        }
        // Credit memos only: untick to keep the credit memo out of the deduction
        field(11; Include; Boolean)
        {
            Caption = 'Include';
            InitValue = true;

            trigger OnValidate()
            var
                RebateCalc: Record "NAV Rebate Calculation";
            begin
                if "Document Type" <> "Document Type"::"Credit Memo" then
                    Error(IncludeErr);
                RebateCalc.Get("Calculation No.");
                RebateCalc.TestStatus(RebateCalc.Status::Calculated);
            end;
        }
        field(12; "Due Date"; Date)
        {
            Caption = 'Due Date';
            Editable = false;
        }
        field(13; "Closed at Date"; Date)
        {
            Caption = 'Paid on';
            Editable = false;
        }
        field(14; "Paid in Period"; Boolean)
        {
            Caption = 'Paid in Period';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Calculation No.", "Line No.") { Clustered = true; }
        key(Type; "Calculation No.", "Document Type", Include)
        {
            SumIndexFields = "Amount (LCY)", "Rebate Amount (LCY)";
        }
    }

    var
        IncludeErr: Label 'Only credit memos can be excluded from the rebate base.';
}
