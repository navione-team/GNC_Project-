// Lot 7 – Expédition enregistrée : priorité et chauffeur (lecture seule).
pageextension 90076 "GNC Posted Sales Shipment" extends "Posted Sales Shipment"
{
    layout
    {
        addlast(General)
        {
            field("GNC Delivery Priority"; Rec."GNC Delivery Priority")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how urgent the delivery was.';
            }
            field("GNC Driver Code"; Rec."GNC Driver Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the driver who delivered the shipment.';
            }
            field("GNC Driver Name"; Rec."GNC Driver Name")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the name of the driver.';
            }
        }
    }
}
