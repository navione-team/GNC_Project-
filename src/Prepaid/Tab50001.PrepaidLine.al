table 50001 PrepaidLine
{
    Caption = 'PrepaidLine';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No. Prepaid"; Code[20])
        {
            Caption = 'No. Prepaid';
        }
        field(2; "Due Date"; Date)
        {
            Caption = 'Due Date ';
        }
        field(3; Amount; Decimal)
        {
            Caption = 'Amount';
        }
        field(4; Integrated; Boolean)
        {
            Caption = 'Integrated';
            Editable = false;
        }
    }
    keys
    {
        key(PK; "No. Prepaid", "Due Date")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        TextL001: Label 'This Line is integrated';
    begin
        if rec.Integrated then Error(TextL001);
    end;
}
