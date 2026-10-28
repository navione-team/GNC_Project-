pageextension 90026 "G/L Account Card Ext" extends "G/L Account Card"
{
    layout
    {
        addafter("Account Type")
        {
            field("Account Usage Type"; Rec."Account Usage Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how the G/L account is used: for sales, for purchases, or for item charges.';
            }
        }
    }
}
