tableextension 70030 "Cause of Absence Ext" extends "Cause of Absence"
{
    fields
    {
        field(70000; "Type"; Option)
        {
            Caption = 'Type';
            OptionMembers = ,Deductible,"Non Deductible";
            OptionCaption = ',Deductible,Non Deductible';
        }
    }
}