tableextension 90025 "G/L Account Ext" extends "G/L Account"
{
    fields
    {
        field(90040; "Account Usage Type"; Option)
        {
            Caption = 'Account Usage Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Sales,Purchase,"Item Charge";
            OptionCaption = ' ,Sales,Purchase,Item Charge';
        }
    }
}
