// Liste (lecture seule) du détail par demande des lignes de commande.
// S'ouvre en cliquant sur la colonne "Grouped Requests" des lignes de commande, d'expédition ou de facture.
page 90059 "GNC Grouped Request Lines"
{
    Caption = 'Grouped Request Lines';
    PageType = List;
    SourceTable = "GNC Grouped Request Line";
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Order No."; Rec."Order No.")
                {
                    ToolTip = 'Specifies the sales order that contains the line.';
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ToolTip = 'Specifies the line of the sales order.';
                    Visible = false;
                }
                field("Request No."; Rec."Request No.")
                {
                    ToolTip = 'Specifies the request collection (sales quote) that the quantity comes from.';
                }
                field("Request Date"; Rec."Request Date")
                {
                    ToolTip = 'Specifies the document date of the request.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ToolTip = 'Specifies the salesperson who collected the request.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer of the request.';
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of the line.';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the item or account number.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the line.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity requested in this request.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the unit of measure.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the unit price of the request line.';
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ToolTip = 'Specifies the line discount of the request line.';
                }
            }
        }
    }
}
