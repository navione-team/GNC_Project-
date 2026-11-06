page 70032 "Employee Postroup ListPart"
{
    PageType = ListPart;
    SourceTable = "Employee Posting Group";
    ApplicationArea = All;
    Editable = true;
    Caption = 'Employee Posting Group';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field("G/L Expense Account"; Rec."G/L Expense Account")
                {
                    ApplicationArea = All;
                }
                field("G/L Accrual Account"; Rec."Payables Account")
                {
                    ApplicationArea = All;
                }

                // Newly added fields
                field("G/L Basic Salary"; Rec."G/L Basic Salary")
                {
                    ApplicationArea = All;
                }
                field("G/L Housing Allowance"; Rec."G/L Housing Allowance")
                {
                    ApplicationArea = All;
                }
                field("G/L Transportation Allowance"; Rec."G/L Transportation Allowance")
                {
                    ApplicationArea = All;
                }
                field("G/L Mobile Allowance"; Rec."G/L Mobile Allowance")
                {
                    ApplicationArea = All;
                }
                field("G/L Education Allowance"; Rec."G/L Education Allowance")
                {
                    ApplicationArea = All;
                }
                field("G/L Staff Bonus"; Rec."G/L Staff Bonus")
                {
                    ApplicationArea = All;
                }
                field("G/L Leave Ticket Expenses"; Rec."G/L Leave Ticket Expenses")
                {
                    ApplicationArea = All;
                }
                field("G/L Leave Salary Expenses"; Rec."G/L Leave Salary Expenses")
                {
                    ApplicationArea = All;
                }
                field("G/L End of Service Indemnity"; Rec."G/L End of Service Indemnity")
                {
                    ApplicationArea = All;
                }
                field("G/L Social Security (GOSI)"; Rec."G/L Social Security (GOSI)")
                {
                    ApplicationArea = All;
                }
                field("G/L Sales Comm"; Rec."G/L Sales Comm")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
