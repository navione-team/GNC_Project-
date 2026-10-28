// Lot 6 – Règle de priorité quand plusieurs remises GNC s'appliquent (FRD règle 17), réglée dans GNC Sales Setup.
enum 90066 "GNC Discount Priority"
{
    Extensible = true;

    // Client + article > client + catégorie > client (tous articles) > article > catégorie
    value(0; "Most Specific")
    {
        Caption = 'Most Specific';
    }
    // La remise la plus élevée gagne (comme le standard BC)
    value(1; "Highest Discount")
    {
        Caption = 'Highest Discount';
    }
}
