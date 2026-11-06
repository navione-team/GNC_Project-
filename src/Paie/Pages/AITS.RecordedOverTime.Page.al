page 70046 "Recorded OverTime"
{
    PageType = List;
    SourceTable = "Employee Posted Absence";
    SourceTableView = WHERE("Entry Type" = FILTER("Over Time"));
    ApplicationArea = all;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
                field("Over Time Hours"; rec."Over Time Hours")
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

