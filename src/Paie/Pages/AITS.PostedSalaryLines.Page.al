page 70027 "Posted Salary Lines"
{
    PageType = ListPart;
    SourceTable = "Rec.Salary Line";
    ApplicationArea = all;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(Employee; Rec.Employee)
                {
                }
                field("Full Name"; Rec."Full Name")
                {
                }
                field("Employee SID"; Rec."Employee SID")
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
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                }
                field("Payment Method"; Rec."Payment Method")
                {
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("Basic Salary"; Rec."Basic Salary")
                {
                }
                field("Accomodation Allowance"; Rec."Accomodation Allowance")
                {
                }
                field("Tickets Allowances Amount"; Rec."Tickets Allowances Amount")
                {
                }
                field("Mobile Allowance"; Rec."Mobile Allowance")
                {
                }
                field("Transport Allowance"; Rec."Transport Allowance")
                {
                }
                field("Bonus Allowance"; Rec."Bonus Allowance")
                {
                }

                field("Other Allowance"; Rec."Other Allowance")
                {
                }
                field(Adjustment; Rec.Adjustment)
                {

                }


                field("Gross Salary"; Rec."Gross Salary")
                {
                }
                field(Deductions; Rec.Deductions)
                { }
                field("Employee Insurance Amount"; Rec."Employee Insurance Amount")
                { }

                field(Advance; Rec.Advance)
                {
                }
                field(Loan; Rec.Loan)
                {
                }
                field(Addition; Rec.Addition)
                {
                }

                field("EOSB Amount"; Rec."EOSB Amount")
                {
                }

                field("Annual Leave  Amount"; Rec."Annual Leave  Amount")
                {
                }
                field("Net Pay"; Rec."Net Pay")
                {
                }
            }
        }
    }

    actions
    {
    }
}

