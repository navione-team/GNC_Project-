// Lot 7 – Plan de livraison / interface magasin (consignes du manager).
// Commandes libérées (Released) pas encore complètement expédiées, les plus urgentes d'abord,
// puis la plus ancienne (n° de commande). Le magasin choisit le chauffeur, vérifie le stock
// et expédie (bouton Ship = expédition seulement).
page 90077 "GNC Delivery Plan"
{
    Caption = 'Delivery Plan';
    PageType = List;
    SourceTable = "Sales Header";
    SourceTableView = sorting("GNC Priority Sort")
                      where("Document Type" = const(Order), Status = const(Released), "Completely Shipped" = const(false));
    CardPageId = "Sales Order";
    ApplicationArea = All;
    UsageCategory = Tasks;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Orders)
            {
                field("GNC Delivery Priority"; Rec."GNC Delivery Priority")
                {
                    StyleExpr = PriorityStyle;
                    ToolTip = 'Specifies how urgent the delivery is. It comes from the customer request and can be changed here.';

                    trigger OnValidate()
                    begin
                        SetStyles();
                    end;
                }
                field("No."; Rec."No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the sales order number.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the customer.';
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    Editable = false;
                    ToolTip = 'Specifies the delivery address.';
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    Editable = false;
                    ToolTip = 'Specifies the delivery city.';
                }
                field("Ship-to Phone No."; Rec."Ship-to Phone No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the phone number at the delivery address.';
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies when the order must be shipped.';
                }
                field("Requested Delivery Date"; Rec."Requested Delivery Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies the date when the customer wants to receive the order.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the location from which the order is shipped.';
                }
                field(StockStatus; StockStatus)
                {
                    Caption = 'Stock';
                    Editable = false;
                    StyleExpr = StockStyle;
                    ToolTip = 'Specifies if the items still to ship are in stock at the location of each line: Available, Partial or Not Available. Empty if the order has no stock item.';
                }
                field("GNC Driver Code"; Rec."GNC Driver Code")
                {
                    ToolTip = 'Specifies the driver who delivers the order. A driver is required to post the shipment.';
                }
                field("GNC Driver Name"; Rec."GNC Driver Name")
                {
                    ToolTip = 'Specifies the name of the driver.';
                }
                field("GNC Stop No."; Rec."GNC Stop No.")
                {
                    ToolTip = 'Specifies the position of the order in the round of the driver, saved from the delivery round map.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the salesperson of the order.';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    Editable = false;
                    ToolTip = 'Specifies the total amount of the order including VAT.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenOrder)
            {
                Caption = 'Open Order';
                Image = Document;
                RunObject = page "Sales Order";
                RunPageLink = "Document Type" = field("Document Type"), "No." = field("No.");
                ToolTip = 'Open the sales order to see its lines.';
            }
            action(Ship)
            {
                Caption = 'Ship';
                Image = PostedShipment;
                ToolTip = 'Post the shipment of the selected order (shipment only, the invoice is created later). A driver is required.';

                trigger OnAction()
                var
                    GNCDeliveryMgt: Codeunit "GNC Delivery Mgt.";
                begin
                    GNCDeliveryMgt.ShipOrder(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Drivers)
            {
                Caption = 'Drivers';
                Image = Employee;
                RunObject = page "GNC Drivers";
                ToolTip = 'Set up the drivers.';
            }
            // Carte de la tournée du chauffeur de la commande choisie, pour sa date d'expédition
            action(DeliveryRound)
            {
                Caption = 'Delivery Round';
                Image = Route;
                ToolTip = 'Show the round of the driver of the selected order on a map, with the optimised stop sequence.';

                trigger OnAction()
                var
                    GNCDeliveryRound: Page "GNC Delivery Round";
                begin
                    GNCDeliveryRound.SetRound(Rec."GNC Driver Code", Rec."Shipment Date");
                    GNCDeliveryRound.Run();
                end;
            }
        }
        area(Promoted)
        {
            actionref(OpenOrder_Promoted; OpenOrder)
            {
            }
            actionref(Ship_Promoted; Ship)
            {
            }
            actionref(DeliveryRound_Promoted; DeliveryRound)
            {
            }
            actionref(Drivers_Promoted; Drivers)
            {
            }
        }
    }

    var
        StockStatus: Text;
        StockStyle: Text;
        PriorityStyle: Text;

    trigger OnOpenPage()
    var
        GNCDeliveryMgt: Codeunit "GNC Delivery Mgt.";
    begin
        GNCDeliveryMgt.FixOldPrioritySort();
    end;

    trigger OnAfterGetRecord()
    var
        GNCDeliveryMgt: Codeunit "GNC Delivery Mgt.";
    begin
        StockStatus := GNCDeliveryMgt.GetStockStatus(Rec, StockStyle);
        SetStyles();
    end;

    // Very Urgent en rouge, Urgent en orange
    local procedure SetStyles()
    begin
        case Rec."GNC Delivery Priority" of
            Rec."GNC Delivery Priority"::"Very Urgent":
                PriorityStyle := 'Unfavorable';
            Rec."GNC Delivery Priority"::Urgent:
                PriorityStyle := 'Ambiguous';
            else
                PriorityStyle := 'Standard';
        end;
    end;
}
