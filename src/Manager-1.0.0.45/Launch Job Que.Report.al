report 50003 "Launch Job Que"
{
    ApplicationArea = All;
    Caption = 'Launch Job Que';
    UsageCategory = Tasks;
    ProcessingOnly = true;

    dataset
    {
        dataitem(PrepaiedHeader; "Company Information")
        {
            trigger OnAfterGetRecord()
            var
                GlobalFunction: Codeunit "Global Function";
            begin
                GlobalFunction.InsertPrepaidRental();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
}
