// Écran des paramètres ventes GNC (fiche à enregistrement unique).
page 90038 "GNC Sales Setup"
{
    Caption = 'GNC Sales Setup';
    PageType = Card;
    SourceTable = "GNC Sales Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(SalesQuotes)
            {
                Caption = 'Sales Quotes (Request Collection)';

                field("Archive Quote on Make Order"; Rec."Archive Quote on Make Order")
                {
                    ToolTip = 'Specifies if the quote is always archived with the status Won when it is converted to an order (Make Order), whatever the Archive Quotes setting in Sales & Receivables Setup.';
                }
            }
            // Lot 4 : écran "Requests to Group"
            group(RequestGrouping)
            {
                Caption = 'Requests to Group';

                field("Request Grouping"; Rec."Request Grouping")
                {
                    ToolTip = 'Specifies which released requests are grouped into one sales order: the same customer on the same document date, or the same customer whatever the date. Requests are always grouped only if they have the same customer, bill-to customer, ship-to code and currency.';
                }
                field("Do Not Merge Identical Lines"; Rec."Do Not Merge Identical Lines")
                {
                    ToolTip = 'Specifies if identical lines of grouped requests (same item, salesperson, unit, location, price and discount) stay as separate order lines. If not selected, they are merged into one line and the detail per request is kept in Grouped Request Lines.';
                }
            }
            // Lot 6 : remises GNC (Discount Setup)
            group(Discounts)
            {
                Caption = 'Discounts';

                field("Discount Priority"; Rec."Discount Priority")
                {
                    ToolTip = 'Specifies which discount of the Discount Setup is suggested when several rules apply: the most specific rule (customer + item, customer + category, customer, item, category) or the highest discount.';
                }
                field("Control Manual Discount"; Rec."Control Manual Discount")
                {
                    ToolTip = 'Specifies if a line discount entered manually above the suggested discount is limited by the Max Line Discount % of the user in User Setup.';
                }
            }
            // Lot 7 : plan de livraison
            group(Delivery)
            {
                Caption = 'Delivery';

                field("Driver Optional on Shipment"; Rec."Driver Optional on Shipment")
                {
                    ToolTip = 'Specifies if a sales order can be shipped without a driver (for example when the customer collects the goods). If not selected, a driver is required to post the shipment.';
                }
                field("Warehouse Latitude"; Rec."Warehouse Latitude")
                {
                    ToolTip = 'Specifies the GPS latitude of the warehouse where the delivery rounds start and end. Leave 0 to use 2nd Industrial City, Riyadh.';
                }
                field("Warehouse Longitude"; Rec."Warehouse Longitude")
                {
                    ToolTip = 'Specifies the GPS longitude of the warehouse where the delivery rounds start and end. Leave 0 to use 2nd Industrial City, Riyadh.';
                }
                field("Round Start Time"; Rec."Round Start Time")
                {
                    ToolTip = 'Specifies when the delivery rounds leave the warehouse. Leave empty to use 06:30.';
                }
                field("Average Speed (km/h)"; Rec."Average Speed (km/h)")
                {
                    ToolTip = 'Specifies the average speed in the city used to estimate the arrival times. Leave 0 to use 28 km/h.';
                }
            }
        }
    }

    // À la première ouverture, on crée l'enregistrement unique avec les valeurs par défaut
    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
