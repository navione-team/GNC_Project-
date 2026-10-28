// Écran « PO to be regrouped » (FRD 1.4) : les Request Collections approuvées (Released) en attente,
// triées par client. Les actions créent une seule commande par groupe (codeunit 90056).
page 90055 "GNC Requests to Group"
{
    Caption = 'Requests to Group';
    PageType = List;
    SourceTable = "Sales Header";
    SourceTableView = sorting("Document Type", "Sell-to Customer No.") where("Document Type" = const(Quote), Status = const(Released), "GNC Closed" = const(false));
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "Sales Quote";

    layout
    {
        area(Content)
        {
            repeater(Requests)
            {
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ToolTip = 'Specifies the customer of the request.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the date of the request. Depending on GNC Sales Setup, only requests of the same day are grouped.';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the request collection (sales quote).';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ToolTip = 'Specifies the salesperson of the request.';
                }
                field(SalespersonConfirmed; SalespersonConfirmed)
                {
                    Caption = 'Salesperson Confirmed';
                    ToolTip = 'Specifies if the salesperson has been confirmed by PIN. Requests without a confirmed salesperson are not grouped.';
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ToolTip = 'Specifies the ship-to address. Requests with different ship-to addresses go to different orders.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency of the request.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount of the request, excluding VAT.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateGroupedOrder)
            {
                Caption = 'Create Grouped Order';
                Image = MakeOrder;
                ToolTip = 'Create one sales order with all released requests of the same group as the selected request (same customer, ship-to address, currency and, depending on GNC Sales Setup, same day).';

                trigger OnAction()
                var
                    GNCRequestGroupingMgt: Codeunit "GNC Request Grouping Mgt.";
                begin
                    GNCRequestGroupingMgt.GroupRequestsOf(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CreateAllGroupedOrders)
            {
                Caption = 'Create All Grouped Orders';
                Image = CreateDocuments;
                ToolTip = 'Create the grouped sales orders for all released requests in this list.';

                trigger OnAction()
                var
                    GNCRequestGroupingMgt: Codeunit "GNC Request Grouping Mgt.";
                begin
                    GNCRequestGroupingMgt.GroupAllRequests();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(GroupedRequestLines)
            {
                Caption = 'Grouped Request Lines';
                Image = List;
                RunObject = page "GNC Grouped Request Lines";
                ToolTip = 'View which request lines were grouped into which sales order lines.';
            }
        }
        area(Promoted)
        {
            actionref(CreateGroupedOrder_Promoted; CreateGroupedOrder)
            {
            }
            actionref(CreateAllGroupedOrders_Promoted; CreateAllGroupedOrders)
            {
            }
        }
    }

    var
        SalespersonConfirmed: Boolean;

    trigger OnAfterGetRecord()
    var
        GNCSalespersonPINMgt: Codeunit "GNC Salesperson PIN Mgt.";
    begin
        SalespersonConfirmed := GNCSalespersonPINMgt.IsSalespersonConfirmed(Rec);
    end;
}
