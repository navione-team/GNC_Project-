// Rounding rule applied when a quantity converted into tablets has decimals
// (e.g. 0.51 PACK x 30 = 15.3 TABLET)
enum 50240 "NAV Tablet Rounding Method"
{
    Caption = 'Tablet Rounding Method';
    Extensible = true;

    value(0; "Use Default")
    {
        Caption = 'Use Default';
    }
    value(1; Nearest)
    {
        Caption = 'Nearest';
    }
    value(2; Up)
    {
        Caption = 'Up';
    }
    value(3; Down)
    {
        Caption = 'Down';
    }
}

// How the tablet sales price is determined
enum 50241 "NAV Tablet Price Method"
{
    Caption = 'Tablet Price Method';
    Extensible = true;

    value(0; Independent)
    {
        Caption = 'Independent';
    }
    value(1; "From Pack Price")
    {
        Caption = 'From Pack Price';
    }
}
