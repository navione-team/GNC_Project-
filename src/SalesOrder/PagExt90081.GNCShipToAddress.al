// Lot 7 – Fiche adresse de livraison : position GPS pour la carte de la tournée.
pageextension 90081 "GNC Ship-to Address" extends "Ship-to Address"
{
    layout
    {
        addlast(General)
        {
            field("GNC Latitude"; Rec."GNC Latitude")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the GPS latitude of this delivery address. Used on the delivery round map.';
            }
            field("GNC Longitude"; Rec."GNC Longitude")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the GPS longitude of this delivery address. Used on the delivery round map.';
            }
        }
    }
}
