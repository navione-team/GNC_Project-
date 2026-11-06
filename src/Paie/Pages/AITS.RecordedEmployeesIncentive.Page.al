page 70045 "Recorded Employee's Incentive"
{
    Editable = false;
    PageType = List;
    SourceTable = "Employee Posted Absence";
    SourceTableView = WHERE("Entry Type" = FILTER("Over Time"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; rec."Entry Type")
                {
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
                field("Incentive Amount"; rec."Incentive Amount")
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

