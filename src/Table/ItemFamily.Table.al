table 90021 "Item Family"
{
    Caption = 'Item Family';
    DataClassification = CustomerContent;
    LookupPageId = "Item Family List";
    DrillDownPageId = "Item Family List";

    fields
    {
        field(1; "Code"; Code[30])
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
