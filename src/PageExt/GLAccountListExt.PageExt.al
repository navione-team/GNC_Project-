pageextension 90027 "G/L Account List Ext" extends "G/L Account List"
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
