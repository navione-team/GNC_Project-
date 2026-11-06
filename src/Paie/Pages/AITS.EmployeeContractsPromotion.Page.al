page 70049 "Employee Contracts & Promotion"
{
    PageType = List;
    Editable = false;
    SourceTable = "Employee Contract History";
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; rec."Entry Type")
                {
                }
                field("Employment Date"; rec."Employment Date")
                {
                }
                field("Employee No"; rec."Employee No")
                {
                }
                field("Contract No"; rec."Contract No")
                {
                }
                field("Employee Name"; rec."Employee Name")
                {
                }
                field("Promotion Date"; rec."Promotion Date")
                {
                }
                field("Basic Salary"; rec."Basic Salary")
                {
                }
                field(Accomodation; rec.Accomodation)
                {
                }
                field(Transportation; rec.Transportation)
                {
                }
                field(Mobile; rec.Mobile)
                {
                }
                field("Other Allowance"; rec."Other Allowance")
                {
                }
                field(Bonus; rec.Bonus)
                {
                }
                field("Total Package"; rec."Total Package")
                {
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
        }
    }
}

