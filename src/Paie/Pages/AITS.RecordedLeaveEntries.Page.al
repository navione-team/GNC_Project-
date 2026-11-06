page 70019 "Recorded Leave Entries"
{
    PageType = List;
    SourceTable = "Recorded Leave entries";
    ApplicationArea = all;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Employee; Rec.Employee)
                {
                }
                field(Name; Rec.Name)
                {
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("From date"; Rec."From date")
                {
                }
                field("To date"; Rec."To date")
                {
                }
                field("Payroll Month"; Rec."Payroll Month")
                {
                }
                field(Year; Rec.Year)
                {
                }
                field("Entry Type"; Rec."Entry Type")
                {
                }
                field("Quantity Days"; Rec."Quantity Days")
                {
                }
                field("Line No"; Rec."Line No")
                {
                    Visible = false;
                }
                field("Contract Code"; Rec."Contract Code")
                {
                }
                field("Basis Salary"; Rec."Basis Salary")
                {
                }
                field(Housing; Rec.Housing)
                {
                }
                field("Total Amount  To pay"; Rec."Total Amount  To pay")
                {
                }
                field("Manuel Input Days"; Rec."Manuel Input Days")
                {
                }
                field("Resume Date"; Rec."Resume Date")
                {
                }
                field("Last Working Date"; Rec."Last Working Date")
                {
                }
                field(TA; Rec.TA)
                {
                    Visible = false;
                }
                field(MA; Rec.MA)
                {
                    Visible = false;
                }
                field(Other; Rec.Other)
                {
                    Visible = false;
                }
                field("Other Deduction"; Rec."Other Deduction")
                {
                    Visible = false;
                }
                field("Cause of Absence Code"; Rec."Cause of Absence Code")
                {
                    Visible = false;
                }
                field("Joining Date"; Rec."Joining Date")
                {
                }
                field("Total entitlement Leave Days"; Rec."Total entitlement Leave Days")
                {
                }
                field("Unpaid Leave"; Rec."Unpaid Leave")
                {
                }
                field("Total Leave Taken"; Rec."Total Leave Taken")
                {
                }
                field("Total Romaining"; Rec."Total Romaining")
                {
                }
                field("Employement Date"; Rec."Employement Date")
                {
                }
                field("Service Year"; Rec."Service Year")
                {
                }
                field("Total Unpaid Days"; Rec."Total Unpaid Days")
                {
                }
                field("Pending Salary"; Rec."Pending Salary")
                {
                }
                field("EOSB Amount"; Rec."EOSB Amount")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Version No"; Rec."Version No")
                {
                    Visible = false;
                }
                field("Direction Approve"; Rec."Direction Approve")
                {
                }
                field("Direction Approve date"; Rec."Direction Approve date")
                {
                }
                field("Account Approve"; Rec."Account Approve")
                {
                }
                field("Account Approve Date"; Rec."Account Approve Date")
                {
                }
                field("EOSB Tenure"; Rec."EOSB Tenure")
                {
                }
                field("Leave Salary Entitled"; Rec."Leave Salary Entitled")
                {
                }
                field("QID Cost"; Rec."QID Cost")
                {
                    Visible = false;
                }
                field("HC Cost"; Rec."HC Cost")
                {
                    Visible = false;
                }
                field("Grounds for Term. Code"; Rec."Grounds for Term. Code")
                {
                    Visible = false;
                }
                field("QID Expiry Date"; Rec."QID Expiry Date")
                {
                    Visible = false;
                }
                field("HC Expiry Date"; Rec."HC Expiry Date")
                {
                    Visible = false;
                }
                field("Total Absent Days"; Rec."Total Absent Days")
                {
                }
                field("Eligible Vacation"; Rec."Eligible Vacation")
                {
                }
                field("Eligible EOSB Tenure Days"; Rec."Eligible EOSB Tenure Days")
                {
                }
                field("Ac.Userid"; Rec."Ac.Userid")
                {
                    Visible = false;
                }
                field("Gm.UserId"; Rec."Gm.UserId")
                {
                    Visible = false;
                }
                field("User ID"; Rec."User ID")
                {
                    Visible = false;
                }
                field("Last modified date"; Rec."Last modified date")
                {
                }
                field("Total Unpaid OT Amount"; Rec."Total Unpaid OT Amount")
                {
                    Visible = false;
                }
                field("Ticket Amount"; Rec."Ticket Amount")
                {
                }
                field("EOSB Advance Amount"; Rec."EOSB Advance Amount")
                {
                }
            }
        }
    }

    actions
    {
    }
}

