page 70015 "Recorded Attendance"
{
    Editable = false;
    PageType = List;
    Permissions = TableData "Recorded Attendance TimeSheet" = rimd;
    SourceTable = "Recorded Attendance TimeSheet";
    //Editable = false;
    ApplicationArea = all;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No"; Rec."Entry No")
                {
                }
                field(Employee; Rec.Employee)
                {
                }
                field("Employee Full Name"; Rec."Employee Full Name")
                {
                }
                field(Date; Rec.Date)
                {
                }
                field(Day; Rec.Day)
                {
                }
                field(Month; Rec.Month)
                {
                }
                field(Year; Rec.Year)
                {
                }
                field("Time In"; Rec."Time In")
                {
                }
                field("Time Out"; Rec."Time Out")
                {
                }
                field("Worked Hours"; Rec."Worked Hours")
                {
                }
                field("Absence Hours"; Rec."Absence Hours")
                {
                }
                field("Absence Reason"; Rec."Absence Reason")
                {
                }
                field(Comment; Rec.Comment)
                {
                }
                field("Over Hours"; Rec."Over Hours")
                {
                }
                field("Store Code"; Rec."Store Code")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Holiday"; Rec.Holiday)
                {
                }
                field("Time In1"; Rec."Time In1")
                {
                }
                field("Time Out1"; Rec."Time Out1")
                {
                }
                field("Employee Calander"; Rec."Employee Calander")
                {
                }
            }
        }
    }

    actions
    {
    }
}

