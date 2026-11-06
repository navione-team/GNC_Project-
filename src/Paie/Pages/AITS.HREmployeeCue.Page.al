page 70053 "HR Manager Cues"
{
    PageType = CardPart;
    SourceTable = Employee;
    Caption = 'HR Overview';
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            cuegroup("HR Overview")
            {
                field(EmployeeCount; TheCount)
                {
                    Caption = 'Total Employees';
                    DrillDown = true;
                    DrillDownPageId = "Employee List";
                }
            }
        }
    }

    var
        TheCount: Integer;

    trigger OnOpenPage()
    begin
        TheCount := CountEmployees;
    end;

    local procedure CountEmployees(): Integer
    var
        Emp: Record Employee;
    begin
        Emp.Reset();
        exit(Emp.Count);
    end;
}
