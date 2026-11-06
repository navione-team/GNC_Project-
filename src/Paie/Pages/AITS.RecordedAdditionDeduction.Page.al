page 70044 "Recorded Addition & Deduction"
{
    PageType = List;
    SourceTable = "Employee Posted Absence";
    SourceTableView = WHERE("Entry Type" = FILTER(= "Deduction" | "Addition"));
    Editable = false;
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
                field("Employee No."; rec."Employee No.")
                {

                }
                field("Employee Full Name"; rec."Employee Full Name")
                {

                }
                field("Posting month"; rec."Posting month")
                {

                }
                field("Posting year"; rec."Posting year")
                {

                }
                field(Amount; rec.Amount)
                {

                }
                field(Description; rec.Description)
                {

                }
            }
        }
    }

    actions
    {
    }
}

