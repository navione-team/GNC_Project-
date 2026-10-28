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
}
