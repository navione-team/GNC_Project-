// Page "Customer Salesperson Assignments" (le "New menu" de l'exigence 1.7).
// Ouverte depuis la page d'accueil (tous les clients), la fiche client ou la fiche commercial (filtrée).
page 90033 "GNC Cust. Salesperson Assign."
{
    Caption = 'Customer Salesperson Assignments';
    PageType = List;
    SourceTable = "GNC Cust. Salesperson Assign.";
    ApplicationArea = All;
    UsageCategory = Lists;
    // La ligne est enregistrée seulement quand on la quitte (tous les champs saisis, y compris le commercial)
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the customer.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the assignment is for one item or for an item category.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item or the item category.';

                    trigger OnValidate()
                    begin
                        ProductDescription := Rec.GetProductDescription();
                    end;
                }
                field(ProductDescription; ProductDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the item or the item category.';
                    Editable = false;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the sales representative responsible for this customer and product.';
                }
                field("Salesperson Name"; Rec."Salesperson Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the sales representative.';
                }
            }
        }
    }

    var
        ProductDescription: Text[100];

    trigger OnAfterGetRecord()
    begin
        ProductDescription := Rec.GetProductDescription();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ProductDescription := '';
        // Si la page est filtrée sur un seul client ou un seul commercial, on le reprend
        if Rec.GetFilter("Customer No.") <> '' then
            if Rec.GetRangeMin("Customer No.") = Rec.GetRangeMax("Customer No.") then
                Rec."Customer No." := Rec.GetRangeMin("Customer No.");
        if Rec.GetFilter("Salesperson Code") <> '' then
            if Rec.GetRangeMin("Salesperson Code") = Rec.GetRangeMax("Salesperson Code") then
                Rec."Salesperson Code" := Rec.GetRangeMin("Salesperson Code");
    end;
}
