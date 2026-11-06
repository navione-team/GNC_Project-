page 70017 "Employee Sponsor/Payer List"
{
    PageType = List;
    SourceTable = "Employee Sponsor/Payer";
    SourceTableView = ORDER(Ascending);
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field("Payer Bank"; Rec."Payer Bank") { ApplicationArea = All; }
                field("Payer EID"; Rec."Payer EID") { ApplicationArea = All; }
                field("Payer IBAN"; Rec."Payer IBAN") { ApplicationArea = All; }
                field("Payer QID"; Rec."Payer QID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
        }
    }
}
