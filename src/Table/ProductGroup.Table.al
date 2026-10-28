table 90020 "Product Group"
{
    Caption = 'Product Group';
    DataClassification = CustomerContent;
    LookupPageId = "Product Group List";
    DrillDownPageId = "Product Group List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
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
