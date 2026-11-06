page 70010 "Posted Loan & Advance"
{
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Rec. Loan & Advance";
    ApplicationArea = all;
    Editable = false;
    //ApplicationArea =Basic,Suite;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; rec."No.")
                {
                }
                field(Employee; rec.Employee)
                {
                }
                field(Name; rec.Name)
                {
                }
                field("Job Title"; rec."Job Title")
                {
                }
                field(Type; rec.Type)
                {
                }
                field("Document type"; rec."Document type")
                {
                }
                field(Amount; rec.Amount)
                {
                }
                field("Interest %"; rec."Interest %")
                {
                }
                field("Total to repay"; rec."Total to repay")
                {
                }
                field("Repayment slices"; rec."Repayment slices")
                {
                    Editable = false;
                }
                field("No. Series"; rec."No. Series")
                {
                }
                field("Document Date"; rec."Document Date")
                {
                }
                field("Repaiment lines"; rec."Repaiment lines")
                {
                }
                field("Paid amount"; rec."Paid amount")
                {
                }
                field("Repaid %"; rec."Repaid %")
                {
                }
                field(Status; rec.Status)
                {
                }
                field("Posting Date"; rec."Posting Date")
                {
                }
                field("Start Date"; rec."Start Date")
                {
                }
                field("End Date"; rec."End Date")
                {
                }
                field("User ID"; rec."User ID")
                {
                }
                field("Last Date Modified"; rec."Last Date Modified")
                {
                }
                field(Observation; rec.Observation)
                {
                }
                field(Month; rec.Month)
                {
                }
                field(Year; rec.Year)
                {
                }
                field(Checked; rec.Checked)
                {
                }
                field("Payment No"; rec."Payment No")
                {
                }
                field(Paid; rec.Paid)
                {
                }
                field("Loan Paid Amount"; rec."Loan Paid Amount")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewDocument)
            {
                ApplicationArea = All;
                Caption = 'View Document';
                Image = View;
                RunObject = Page "Posted Loans";
                RunPageOnRec = true;
                // Promoted = true;
                // PromotedCategory = Process;
            }
        }
    }
}