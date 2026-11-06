page 70055 "Over Time transaction History"
{
    PageType = List;
    SourceTable = "Employee Posted Absence";
    Editable = false;
    SourceTableView = where("Entry Type" = filter("Over Time"));
    ApplicationArea = all;
    layout
    {
        area(Content)
        {
            repeater(group)
            {
                field("Entry Type"; Rec."Entry Type") { ApplicationArea = all; }
                field("Employee No."; Rec."Employee No.") { ApplicationArea = all; }
                field("Employee Full Name"; Rec."Employee Full Name") { ApplicationArea = all; }
                field("Posting month"; Rec."Posting month") { ApplicationArea = all; }
                field("Posting year"; Rec."Posting year") { ApplicationArea = all; }
                field("Over Time Hours"; Rec."Over Time Hours") { ApplicationArea = all; }
                field("Over Time Amount"; Rec."Over Time Amount")
                {
                    ApplicationArea = all;
                    Style = StrongAccent;
                }

            }
        }
    }

}