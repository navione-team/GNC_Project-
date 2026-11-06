table 50000 WithholdingTaxTypes
{
    Caption = 'WithholdingTaxTypes';
    DataClassification = ToBeClassified;
    LookupPageId = "Withholding Tax Type";
    DrillDownPageId = "Withholding Tax Type";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = AccountData;
            Caption = 'Code';
        }

        field(2; Description; Text[100])
        {
            DataClassification = AccountData;
            Caption = 'Description';
        }

        field(3; "Related Rate %"; Decimal)
        {
            DataClassification = AccountData;
            Caption = 'Related Rate %';
        }

        field(4; "Nonrelated Rate %"; Decimal)
        {
            DataClassification = AccountData;
            Caption = 'Nonrelated Rate %';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
