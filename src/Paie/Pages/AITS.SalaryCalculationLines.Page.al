page 70014 "Salary Calculation Lines"
{
    //  AccessByPermission = TableData "Salary Line" = RIMD;
    Description = 'Salary Details';
    Editable = true;
    PageType = ListPart;
    Permissions = TableData "Salary Line" = rimd;
    SourceTable = "Salary Line";
    SourceTableView = SORTING("Employment Date");
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    Visible = false;
                }
                field("Line No"; Rec."Line No")
                {
                    Visible = false;
                }
                field("Payment Type"; Rec."Payment Type")
                {
                    Visible = False;
                    Editable = False;
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field(Employee; Rec.Employee)
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Full Name"; Rec."Full Name")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Employee SID"; Rec."Employee SID")
                {
                }
                field("Payer Code"; Rec."Payer Code")
                {
                    Style = Standard;
                    StyleExpr = TRUE;
                }
                field("Employee Departement"; Rec."Employee Departement")
                {
                }
                field("Employee Posting Group"; Rec."Employee Posting Group")
                {
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                }
                field(Position; Rec.Position)
                {
                }
                field("Posting Month"; Rec."Posting Month")
                {
                }
                field("Posting Year"; Rec."Posting Year")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Employee Nationality"; Rec."Employee Nationality")
                {
                }
                field("Employment Date"; Rec."Employment Date")
                {
                }
                field(IBAN; Rec.IBAN)
                {
                }
                field("Employee Contract Code"; Rec."Employee Contract Code")
                {
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                }
                field("Paid Days"; Rec."Paid Days")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Abscence Days"; Rec."Abscence Days")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Worked Days"; Rec."Worked Days")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Attendance Rate"; Rec."Attendance Rate")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Payment Method"; Rec."Payment Method")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("Creation Date"; Rec."Creation Date")
                {
                }
                field("Basic Salary"; Rec."Basic Salary")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Accomodation Allowance"; Rec."Accomodation Allowance")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Mobile Allowance"; Rec."Mobile Allowance")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Transport Allowance"; Rec."Transport Allowance")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Staff Bonus"; Rec."Bonus Allowance")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Education Allowance"; Rec."Education Allowance")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Others Allowance"; Rec."Other Allowance")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Adjustement"; rec.Adjustment)
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Gross Salary"; Rec."Gross Salary")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }

                field(Deductions; Rec.Deductions)
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field(Advance; Rec.Advance)
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field(Loan; Rec.Loan)
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Holiday Salary"; Rec."Holiday Salary")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field(Addition; Rec.Addition)
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("GOSI Employee Amount"; Rec."GOSI Employee Amount")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("GOSI Employer Amount"; Rec."GOSI Employer Amount")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }

                field("Pending Salary Days"; Rec."Pending Salary Days")
                {
                }
                field("Pending Salary Amount"; Rec."Pending Salary Amount")
                {
                }
                field("Annual Leave Days Qty"; Rec."Annual Leave Days Qty")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Annual Leave  Amount"; Rec."Annual Leave  Amount")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("EOSB Amount"; Rec."EOSB Amount")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Tickets Allowances Amount"; Rec."Tickets Allowances Amount")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }

                field("Net Pay"; Rec."Net Pay")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
            }
        }
    }

    actions
    {
    }

    var
        Rec_Salary_header: Record "Rec.Salary Header";
}

