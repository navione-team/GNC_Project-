page 70001 "Allowances List"
{
    PageType = List;
    SourceTable = "Allowance Code";
    SourceTableView = ORDER(Ascending);
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Allowance type"; Rec."Allowance type")
                {
                }
                field(Code; Rec.Code)
                {
                }

                field(Description; Rec.Description)
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Sequence);
    end;


}

