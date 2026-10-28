// Lot 7 – Position GPS d'une adresse de livraison du client (mêmes n° de champ que sur Customer, 90002).
// Si la commande a un Ship-to Code, la carte de la tournée utilise cette position ; sinon celle du client.
tableextension 90080 "GNC Ship-to Address" extends "Ship-to Address"
{
    fields
    {
        field(90011; "GNC Latitude"; Decimal)
        {
            Caption = 'Latitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 6 : 6;
            MinValue = -90;
            MaxValue = 90;
        }
        field(90012; "GNC Longitude"; Decimal)
        {
            Caption = 'Longitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 6 : 6;
            MinValue = -180;
            MaxValue = 180;
        }
    }
}
