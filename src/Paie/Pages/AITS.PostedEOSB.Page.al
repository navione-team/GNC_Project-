page 70050 "Posted EOSB"
{
    PageType = List;
    SourceTable = "Recorded Leave entries";
    SourceTableView = SORTING(Employee) WHERE("Entry Type" = FILTER("End of service"));
    Editable = false;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    ShowCaption = false;
                }
                field("Employee"; Rec.Employee)
                {
                    ShowCaption = false;
                }
                field("Name"; Rec.Name)
                {
                    ShowCaption = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ShowCaption = false;
                }
                field("Employement Date"; Rec."Employement Date")
                {
                    ShowCaption = false;
                }
                field("Joining Date"; Rec."Joining Date")
                {
                    ShowCaption = false;
                }
                field("Last Working Date"; Rec."Last Working Date")
                {
                    ShowCaption = false;
                }
                field("Payroll Month"; Rec."Payroll Month")
                {
                    ShowCaption = false;
                }
                field("Year"; Rec.Year)
                {
                    ShowCaption = false;
                }
                field("Basis Salary"; Rec."Basis Salary")
                {
                    ShowCaption = false;
                }
                field("Total entitlement Leave Days"; Rec."Total entitlement Leave Days")
                {
                    ShowCaption = false;
                }
                field("Leave Salary Entitled"; Rec."Leave Salary Entitled")
                {
                    ShowCaption = false;
                }
                field("Pending Salary"; Rec."Pending Salary")
                {
                    ShowCaption = false;
                }
                field("Service Year"; Rec."Service Year")
                {
                    ShowCaption = false;
                }
                field("Ticket Amount"; Rec."Ticket Amount")
                {
                    ShowCaption = false;
                }
                field("EOSB Amount"; Rec."EOSB Amount")
                {
                    ShowCaption = false;
                }
                field("EOSB Advance Amount"; Rec."EOSB Advance Amount")
                {
                    ShowCaption = false;
                }
                field("Total Amount  To pay"; Rec."Total Amount  To pay")
                {
                    ShowCaption = false;
                }
                field("Status"; Rec.Status)
                {
                    ShowCaption = false;
                }
                field("Payment No"; Rec."Payment No")
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

