// Liste des sous-types de commerciaux (paramétrage).
// À la première ouverture, si la liste est vide, les sous-types du FRD sont créés automatiquement.
page 90042 "GNC Salesperson Sub-Types"
{
    Caption = 'Salesperson Sub-Types';
    PageType = List;
    SourceTable = "GNC Salesperson Sub-Type";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the salesperson type (Private or Government) that this sub-type belongs to.';
                }
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code of the sub-type.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the sub-type.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SubType: Record "GNC Salesperson Sub-Type";
    begin
        if SubType.IsEmpty() then
            SubType.InsertDefaultSubTypes();
    end;
}
