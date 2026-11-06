// Lot 8 – Table temporaire des rapports de ventes : une ligne par groupe ou par document.
// Rien n'est enregistré en base. Le sens des colonnes dépend du rapport.
table 90102 "GNC Sales Report Buffer"
{
    Caption = 'Sales Report Buffer';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Code"; Code[50])
        {
            Caption = 'Code';
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(5; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(6; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
        }
        field(7; Status; Text[30])
        {
            Caption = 'Status';
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(9; "Amount 1"; Decimal)
        {
            Caption = 'Amount 1';
        }
        field(10; "Amount 2"; Decimal)
        {
            Caption = 'Amount 2';
        }
        field(11; "Amount 3"; Decimal)
        {
            Caption = 'Amount 3';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ByCode; "Code")
        {
        }
    }
}
