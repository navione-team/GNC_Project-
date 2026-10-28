// Lot 5 – Liste des règles de bonus (client + article → quantité gratuite, remise additionnelle).
page 90061 "GNC Bonus Setup"
{
    Caption = 'Bonus Setup';
    PageType = List;
    SourceTable = "GNC Bonus Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    // La règle n'est enregistrée qu'en quittant la ligne (tous les champs saisis),
    // sinon BC l'insère dès le 1er champ et le contrôle "quantité ou remise" échoue
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Rules)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer who receives the bonus.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the item concerned by the bonus rule.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the description of the item.';
                }
                field("Bonus Quantity"; Rec."Bonus Quantity")
                {
                    ToolTip = 'Specifies the free quantity added as a separate bonus line (100% discount) when a sales order is created from a request.';
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ToolTip = 'Specifies the minimum ordered quantity to receive the bonus. Leave 0 to grant the bonus whatever the quantity.';
                }
                field("Additional Discount %"; Rec."Additional Discount %")
                {
                    ToolTip = 'Specifies the discount % added to the discount of the ordered line (for example 10% + 2% = 12%).';
                }
                field("MOH Discount %"; Rec."MOH Discount %")
                {
                    ToolTip = 'Specifies the discount % imposed by the Ministry of Health. It is added to the discount of the ordered line only for customers of the Government sector.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ToolTip = 'Specifies the first date of the rule (order date). Leave empty if the rule has no start date.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ToolTip = 'Specifies the last date of the rule (order date). Leave empty if the rule has no end date.';
                }
            }
        }
    }
}
