page 70034 "Posted Salary List"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "Rec.Salary Header";
    ApplicationArea = all;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("Total Net Pay"; Rec."Total Net Pay")
                {
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("View Details")
            {
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Posted Salaries";
                RunPageOnRec = true;
            }
        }
    }
}

