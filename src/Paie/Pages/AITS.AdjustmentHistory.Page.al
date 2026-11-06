page 70058 "Salary Adjustment History"
{
    PageType = List;
    SourceTable = "Employee Posted Absence";
    Editable = false;
    ApplicationArea = all;
    //SourceTableView = where("Entry Type" = filter("Salary Adjustement"));
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
                field("Adjustment Amount"; Rec.Amount) { ApplicationArea = all; }
                field(Remarks; Rec.Remarks) { ApplicationArea = all; }



            }
        }
    }

}