page 70024 "Posted Employee Absence"
{
    PageType = List;
    SourceTable = "Employee Posted Absence";
    SourceTableView = WHERE("Entry Type" = FILTER(= " "));
    Editable = false;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee No."; rec."Employee No.")
                {
                }
                field("Employee Full Name"; Rec."Employee Full Name")
                {

                }
                field("Entry No."; rec."Entry No.")
                {
                }
                field("From Date"; rec."From Date")
                {
                }
                field("To Date"; rec."To Date")
                {
                }
                field("Cause of Absence Code"; rec."Cause of Absence Code")
                {
                }
                field(Description; rec.Description)
                {
                }
                field(Quantity; rec.Quantity)
                {
                }
                field("Unit of Measure Code"; rec."Unit of Measure Code")
                {
                }
                field(Comment; rec.Comment)
                {
                }
                field("Quantity (Base)"; rec."Quantity (Base)")
                {
                }
                field("Qty. per Unit of Measure"; rec."Qty. per Unit of Measure")
                {
                }
                field("Global Dimension 1 Code"; rec."Global Dimension 1 Code")
                {
                }
                field("Global Dimension 2 Code"; rec."Global Dimension 2 Code")
                {
                }
                field("Posting month"; rec."Posting month")
                {
                }
                field("Posting year"; rec."Posting year")
                {
                }
                field("Line type"; rec."Line type")
                {
                }
                field("User ID"; rec."User ID")
                {
                }

                field("Quantity(days)"; rec."Quantity(days)")
                {
                }
                field("Date Time"; rec."Date Time")
                {
                }
            }
        }
    }

    actions
    {
    }
}

