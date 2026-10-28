// Lot 7 – Priorité de livraison (consigne du manager : Normal / Urgent / Very Urgent).
// Choisie par le commercial sur la demande (devis), recopiée sur la commande et l'expédition.
enum 90071 "GNC Delivery Priority"
{
    Extensible = true;

    value(0; Normal)
    {
        Caption = 'Normal';
    }
    value(1; Urgent)
    {
        Caption = 'Urgent';
    }
    value(2; "Very Urgent")
    {
        Caption = 'Very Urgent';
    }
}
