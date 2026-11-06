page 70028 "Absence History SubPage"
{
    PageType = ListPart;
    SourceTable = "Employee Posted Absence";
    Editable = false;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater("Absence History")
            {
                field("Employee No."; Rec."Employee No.")
                {
                    Caption = 'Employee No.';
                }
                field("Employee Full Name"; Rec."Employee Full Name")
                {
                    Caption = 'Employee Full Name';
                }
                field("From Date"; Rec."From Date")
                {
                    Caption = 'Start Date';
                }
                field("To Date"; Rec."To Date")
                {
                    Caption = 'End Date';
                }
                field("Cause of Absence Code"; Rec."Cause of Absence Code")
                {
                    Caption = 'Cause of Absence';
                }
                field(Description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field("Line type"; Rec."Line type")
                {
                    Caption = 'Line Type';
                }
                field("Quantity(days)"; Rec."Quantity(days)")
                {
                    Caption = 'Total Days';
                }
                field(Quantity; Rec.Quantity)
                {
                    Caption = 'Quantity (Hours)';
                }
                field("Posting month"; Rec."Posting month")
                {
                    Caption = 'Posting Month';
                }
                field("Posting year"; Rec."Posting year")
                {
                    Caption = 'Posting Year';
                }
            }
        }
    }

    actions
    {
        // You can add action definitions here if needed in the future
    }
}
