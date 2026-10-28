// Lot 7 – Article à transporter au froid (chaîne du froid). Une commande avec au moins une ligne
// d'article froid est un arrêt « froid » sur la carte de la tournée (page 90083).
// Extension séparée de l'ancienne "Item Ext" (90022, migration) pour ne pas toucher à ses objets.
tableextension 90079 "GNC Item" extends Item
{
    fields
    {
        field(90050; "GNC Cold Chain"; Boolean)
        {
            Caption = 'Cold Chain';
            DataClassification = CustomerContent;
        }
    }
}
