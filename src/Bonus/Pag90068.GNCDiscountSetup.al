// Lot 6 – Liste des taux de remise GNC (client / article / catégorie / client + article).
page 90068 "GNC Discount Setup"
{
    Caption = 'Discount Setup';
    PageType = List;
    SourceTable = "GNC Discount Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    // La règle n'est enregistrée qu'en quittant la ligne (tous les champs saisis)
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Rules)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer who receives the discount. Leave empty for all customers.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer.';
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies if the discount is for an item, an item category or all items of the customer.';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the item or item category. Leave empty when the type is All Items.';
                }
                field(ProductDescription; Rec.GetProductDescription())
                {
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the description of the item or item category.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the line discount % suggested on the request and sales order lines.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ToolTip = 'Specifies the first date of the discount (order date). Leave empty if there is no start date.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ToolTip = 'Specifies the last date of the discount (order date). Leave empty if there is no end date.';
                }
            }
        }
    }
}
