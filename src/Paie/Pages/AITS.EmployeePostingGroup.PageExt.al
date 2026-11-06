pageextension 70060 "Emp.Posting Groups" extends "Employee Posting Groups"
{
    layout
    {
        addafter("Payables Account") // you can also use addafter(<FieldName>) if you want to control the position
        {
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
