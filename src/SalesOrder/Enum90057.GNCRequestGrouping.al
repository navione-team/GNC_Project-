// Règle de regroupement des Request Collections en une seule commande (FRD 1.4, hypothèse 3).
// Valeur 0 = valeur par défaut (aussi pour l'enregistrement GNC Sales Setup déjà existant).
// Dans tous les cas, on ne regroupe que les demandes du même client, même client facturé,
// même adresse de livraison (Ship-to Code) et même devise.
enum 90057 "GNC Request Grouping"
{
    Extensible = true;
    Caption = 'Request Grouping';

    // Même client ET même Document Date (une commande par client et par jour)
    value(0; "Same Customer and Day")
    {
        Caption = 'Same Customer and Day';
    }
    // Même client, toutes dates confondues
    value(1; "Same Customer")
    {
        Caption = 'Same Customer (all dates)';
    }
}
