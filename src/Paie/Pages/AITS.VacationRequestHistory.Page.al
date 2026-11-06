page 70003 "Vacation Request History"
{
    Editable = false;
    PageType = List;
    SourceTable = "Vacation Request History";
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Employee; Rec.Employee)
                {
                }
                field("Full Name"; Rec."Full Name")
                {
                }
                field(Departement; Rec.Departement)
                {
                }
                field("Vacation Start Date"; Rec."Vacation Start Date")
                {
                }
                field("Vacation End Date"; Rec."Vacation End Date")
                {
                }
                field("Number of Days"; Rec."Number of Days")
                {
                }
                field("Reason For Leave"; Rec."Reason For Leave")
                {
                }
                field("Manager Approve"; Rec."Manager Approve")
                {
                }
                field("HR Approve"; Rec."HR Approve")
                {
                }
                field("CEO Approve"; Rec."CEO Approve")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field(Store; Rec.Store)
                {
                }
                field("Document Date"; Rec."Document Date")
                {
                }
                field("User ID"; Rec."User ID")
                {
                }
                field(Comment; Rec.Comment)
                {
                }
                field(Hide; Rec.Hide)
                {
                }
                field("Entry Type"; Rec."Entry Type")
                {
                }
                field("Resume Date"; Rec."Resume Date")
                {
                }
                field("Last Working Date"; Rec."Last Working Date")
                {
                }
                field("Total Vacation taken"; Rec."Total Vacation taken")
                {
                }
                field("Employment Date"; Rec."Employment Date")
                {
                }
                field("Unpaid Leave"; Rec."Unpaid Leave")
                {
                }
                field("Grant Exception"; Rec."Grant Exception")
                {
                }
            }
        }
    }

    actions
    {
    }
}

