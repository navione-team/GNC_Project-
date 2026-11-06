// Calculation type of item charges (landed costs)
enum 50200 "NAV Charge Calc. Type"
{
    Caption = 'Charge Calculation Type';
    Extensible = true;

    value(0; "By Amount")
    {
        Caption = 'By Amount';
    }
    value(1; "By Percent")
    {
        Caption = 'By Percent';
    }
}

// Status of the import (transit) folder
enum 50201 "NAV Transit Folder Status"
{
    Caption = 'Transit Folder Status';
    Extensible = true;

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Released)
    {
        Caption = 'Released';
    }
    value(2; "Charges Created")
    {
        Caption = 'Charges Created';
    }
}
