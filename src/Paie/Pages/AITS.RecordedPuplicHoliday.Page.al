page 70047 "Recorded Puplic Holiday"
{
    PageType = List;
    SourceTable = "Employee Posted Absence";
    SourceTableView = WHERE("Entry Type" = FILTER("Puplic Holiday"));
    ApplicationArea = all;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; rec."Entry Type")
                {
                    Editable = false;
                    ShowCaption = false;
                }
                field("Employee No."; rec."Employee No.")
                {
                    ShowCaption = false;
                }
                field("Employee Full Name"; rec."Employee Full Name")
                {
                    ShowCaption = false;
                }
                field("Posting month"; rec."Posting month")
                {
                    ShowCaption = false;
                }
                field("Posting year"; rec."Posting year")
                {
                    ShowCaption = false;
                }
                field("OverTime Quantity Days"; rec."OverTime Quantity Days")
                {
                    ShowCaption = false;
                }
                field("Over time Rate"; rec."Over time Rate")
                {
                    ShowCaption = false;
                }
                field("Over Time Amount"; rec."Over Time Amount")
                {
                    ShowCaption = false;
                }
                field(Description; rec.Description)
                {
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
    }
}

