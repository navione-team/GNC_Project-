page 70033 "Posted Salaries"
{
    DeleteAllowed = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "Rec.Salary Header";
    ApplicationArea = all;
    Editable = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(No; Rec.No)
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Posting Month"; Rec."Posting Month")
                {
                }
                field("Posting Year"; Rec."Posting Year")
                {
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("Document Date"; Rec."Document Date")
                {
                }
                field("Total Gross Salary"; Rec."Total Gross Salary")
                {
                }
                field("Total Advance"; Rec."Total Advance")
                {
                }
                field("Total Loan"; Rec."Total Loan")
                {
                }
                field("Total Net Pay"; Rec."Total Net Pay")
                {
                }
            }
            part(Control10014512; "Posted Salary Lines")
            {
                SubPageLink = "Document No." = FIELD(No);
            }
        }
    }

    actions
    {
    }
}

