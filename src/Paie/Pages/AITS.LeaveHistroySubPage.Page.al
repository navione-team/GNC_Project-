page 70036 "Leave Histroy SubPage"
{
    PageType = ListPart;
    SourceTable = "Recorded Leave entries";
    ApplicationArea = all;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Employee; rec.Employee)
                {
                }
                field(Name; rec.Name)
                {
                }
                field("Posting Date"; rec."Posting Date")
                {
                }
                field("Payroll Month"; rec."Payroll Month")
                {
                }
                field("From date"; rec."From date")
                {
                }
                field("To date"; rec."To date")
                {
                }
                field(Year; rec.Year)
                {
                }
                field("Entry Type"; rec."Entry Type")
                {
                }
                field("Quantity Days"; rec."Quantity Days")
                {
                }
                field("Total Amount  To pay"; rec."Total Amount  To pay")
                {
                }
            }
        }
    }

    actions
    {
    }
}

