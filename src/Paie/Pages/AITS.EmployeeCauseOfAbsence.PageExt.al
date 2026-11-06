pageextension 70040 "Cause of Absence PageExt" extends "Causes of Absence"
{
    layout
    {
        addafter("Unit of Measure Code")
        {
            field(Type; Rec.Type)
            {
                ApplicationArea = All;
            }
        }
    }
}
