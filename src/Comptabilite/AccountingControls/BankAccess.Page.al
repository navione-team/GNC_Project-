page 50320 "NAV User Bank Access"
{
    Caption = 'User Bank Account Access';
    PageType = List;
    SourceTable = "NAV User Bank Access";
    ApplicationArea = All;
    UsageCategory = Administration;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user allowed to post on the bank / cash account.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank or cash account. Leave empty to give the user access to all accounts (e.g. the chief accountant). As soon as an account has one line, only the users listed can post on it.';
                }
                field("Bank Account Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the bank or cash account.';
                }
            }
        }
    }
}
