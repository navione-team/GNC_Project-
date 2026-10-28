// Petite liste « Very urgent deliveries » de la page d'accueil : commandes très urgentes à livrer,
// chauffeur (« No driver » en rouge) et stock (couleur). Cliquer sur un n° ouvre la commande.
page 90099 "GNC Urgent Deliveries Part"
{
    Caption = 'Very Urgent Deliveries';
    PageType = ListPart;
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Order), Status = const(Released), "Completely Shipped" = const(false),
                            "GNC Delivery Priority" = const("Very Urgent"));
    CardPageId = "Sales Order";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Orders)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales order number.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer';
                    ToolTip = 'Specifies the customer.';
                }
                field(DriverText; DriverText)
                {
                    ApplicationArea = All;
                    Caption = 'Driver';
                    StyleExpr = DriverStyle;
                    ToolTip = 'Specifies the driver of the order. A driver is required to ship.';
                }
                field(StockText; StockText)
                {
                    ApplicationArea = All;
                    Caption = 'Stock';
                    StyleExpr = StockStyle;
                    ToolTip = 'Specifies if the items to ship are in stock: Available, Partial or Not Available.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenDeliveryPlan)
            {
                ApplicationArea = All;
                Caption = 'Delivery Plan';
                Image = List;
                RunObject = page "GNC Delivery Plan Board";
                ToolTip = 'Open the delivery plan to assign drivers and ship the orders.';
            }
        }
    }

    var
        DriverText: Text;
        DriverStyle: Text;
        StockText: Text;
        StockStyle: Text;
        NoDriverTxt: Label 'No driver';

    trigger OnAfterGetRecord()
    var
        GNCDeliveryMgt: Codeunit "GNC Delivery Mgt.";
    begin
        if Rec."GNC Driver Code" = '' then begin
            DriverText := NoDriverTxt;
            DriverStyle := 'Unfavorable';
        end else begin
            Rec.CalcFields("GNC Driver Name");
            DriverText := Rec."GNC Driver Code" + ' · ' + Rec."GNC Driver Name";
            DriverStyle := 'Standard';
        end;
        StockText := GNCDeliveryMgt.GetStockStatus(Rec, StockStyle);
    end;
}
