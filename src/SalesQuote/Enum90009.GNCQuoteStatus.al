// Statut commercial du devis (FRD § 9.1 "Failed sales", précisé par le chef de projet le 2026-10-17).
// Open = en cours ; Won = transformé en commande ; Failed = vente ratée (clôturé avec un motif).
// À ne pas confondre avec le champ standard Status (Open/Released) du document.
enum 90009 "GNC Quote Status"
{
    Extensible = true;
    Caption = 'Quote Status';

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Won)
    {
        Caption = 'Won';
    }
    value(2; Failed)
    {
        Caption = 'Failed';
    }
}
