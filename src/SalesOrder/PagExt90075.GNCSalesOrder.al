// Lot 7 – Fiche commande : priorité de livraison et chauffeur (modifiables ici ou dans le plan de livraison).
pageextension 90075 "GNC Sales Order" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("GNC Delivery Priority"; Rec."GNC Delivery Priority")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how urgent the delivery is. It comes from the customer request.';
            }
            field("GNC Driver Code"; Rec."GNC Driver Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the driver who delivers the order. A driver is required to post the shipment.';
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            // REQ-DB-017 : approbation des remises exceptionnelles de la commande
            action(GNCApproveDiscounts)
            {
                ApplicationArea = All;
                Caption = 'Approve Exceptional Discounts';
                Image = Approve;
                ToolTip = 'Approve the exceptional line discounts of this order, so that it can be released.';

                trigger OnAction()
                var
                    GNCDiscountMgt: Codeunit "GNC Discount Mgt.";
                begin
                    GNCDiscountMgt.ApproveExceptionalDiscounts(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        // 1.0.0.42 – bon de commande imprimé GNC (rapport 90115, modèle du document SO-05200 du client)
        addafter("Print Confirmation")
        {
            action(GNCPrintSalesOrder)
            {
                ApplicationArea = All;
                Caption = 'Print GNC Sales Order';
                Image = PrintDocument;
                ToolTip = 'Print the GNC sales order with the NPC and MOH codes of the items.';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader := Rec;
                    SalesHeader.SetRecFilter();
                    Report.RunModal(Report::"GNC Sales Order", true, false, SalesHeader);
                end;
            }
        }
        addafter("Print Confirmation_Promoted")
        {
            actionref(GNCPrintSalesOrder_Promoted; GNCPrintSalesOrder)
            {
            }
        }
    }
}
