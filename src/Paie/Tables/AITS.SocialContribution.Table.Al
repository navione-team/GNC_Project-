table 70027 "Social Contribution"
{
    Caption = 'Social Contribution';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; "Description"; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(3; "Employer's part"; Decimal)
        {
            Caption = 'Employer''s part';
            DataClassification = CustomerContent;
        }

        field(4; "Employee's part"; Decimal)
        {
            Caption = 'Employee''s part';
            DataClassification = CustomerContent;
        }

        field(5; "Basis of Calculation"; Option)
        {
            Caption = 'Basis of Calculation';
            OptionMembers = "Base = Gross GOSI";
        }

        field(6; "Apply to Saudi Only"; Boolean)
        {
            Caption = 'Apply to Saudi Only';
            DataClassification = CustomerContent;
        }

        field(7; "Deductible of Taxable Basis"; Boolean)
        {
            Caption = 'Deductible of Taxable Basis';
            DataClassification = CustomerContent;
        }

        field(8; "Employee G/L Account"; Code[20])
        {
            Caption = 'Employee : G/L Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }

        field(9; "Employer G/L Account"; Code[20])
        {
            Caption = 'Employer : G/L Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }

        field(10; "Employer Bal. Account No."; Code[20])
        {
            Caption = 'Employer : Bal. Account No.';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }

        field(11; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = SystemMetadata;
        }

        field(12; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
