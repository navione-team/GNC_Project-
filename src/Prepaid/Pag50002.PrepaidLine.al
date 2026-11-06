page 50002 PrepaidLine
{
    ApplicationArea = All;
    Caption = 'PrepaidLine';
    PageType = ListPart;
    SourceTable = PrepaidLine;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Echu Date "; Rec."Due Date")
                {
                    ToolTip = 'Specifies the value of the Echu Date field.', Comment = '%';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.', Comment = '%';
                }
                field(Integrated; Rec.Integrated)
                {
                    ToolTip = 'Specifies the value of the Integrated field.', Comment = '%';
                }
            }
        }
    }
}
