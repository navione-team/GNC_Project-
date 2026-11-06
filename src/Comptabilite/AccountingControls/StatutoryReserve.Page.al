page 50321 "NAV Statutory Reserve Setup"
{
    Caption = 'Statutory Reserve Setup';
    PageType = Card;
    SourceTable = "NAV Statutory Reserve Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Reserve Account No."; Rec."Reserve Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the statutory reserve account (3400), credited by the reserve entry.';
                }
                field("Retained Earnings Account No."; Rec."Retained Earnings Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the retained earnings account (3200), debited by the reserve entry. It is the account that receives the result in Close Income Statement.';
                }
                field("Capital Account Filter"; Rec."Capital Account Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the share capital accounts used for the ceiling, e.g. 3100 or 3100..3199.';
                }
                field("Reserve %"; Rec."Reserve %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the share of the net profit transferred to the statutory reserve (10 %).';
                }
                field("Max. % of Capital"; Rec."Max. % of Capital")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ceiling of the statutory reserve as a % of the capital (30 %). Once reached, no reserve is posted any more. 0 = no ceiling.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Calculate)
            {
                ApplicationArea = All;
                Caption = 'Calculate Statutory Reserve';
                Image = CalculateBalanceAccount;
                RunObject = report "NAV Calc. Statutory Reserve";
                ToolTip = 'Calculates the statutory reserve of a closed fiscal year and creates the journal lines.';
            }
        }
        area(Promoted)
        {
            actionref(Calculate_Promoted; Calculate) { }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
