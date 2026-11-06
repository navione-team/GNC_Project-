table 50321 "NAV Statutory Reserve Setup"
{
    Caption = 'Statutory Reserve Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10; "Reserve Account No."; Code[20])
        {
            Caption = 'Statutory Reserve Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), "Income/Balance" = const("Balance Sheet"));
        }
        field(11; "Retained Earnings Account No."; Code[20])
        {
            Caption = 'Retained Earnings Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), "Income/Balance" = const("Balance Sheet"));
        }
        // e.g. 3100..3199 : accounts that make up the share capital
        field(12; "Capital Account Filter"; Text[250])
        {
            Caption = 'Capital Account Filter';

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if "Capital Account Filter" <> '' then
                    GLAccount.SetFilter("No.", "Capital Account Filter");
            end;
        }
        field(13; "Reserve %"; Decimal)
        {
            Caption = 'Reserve % of Net Profit';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
            InitValue = 10;
        }
        field(14; "Max. % of Capital"; Decimal)
        {
            Caption = 'Reserve Ceiling (% of Capital)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            InitValue = 30;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

    procedure GetSetup()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}
