// Lot 7 – Article à transporter au froid (chaîne du froid). Une commande avec au moins une ligne
// d'article froid est un arrêt « froid » sur la carte de la tournée (page 90083).
// Extension séparée de l'ancienne "Item Ext" (90022, migration) pour ne pas toucher à ses objets.
// 1.0.0.38 – Codes NPC et MOH de l'article, vus dans les documents GNC actuels (commande, avoir) :
// NPC = code national du produit, MOH = code du ministère de la Santé. Simples codes d'identification,
// à imprimer sur les documents de vente (ils n'ont aucun lien avec la remise MOH du lot 5).
tableextension 90079 "GNC Item" extends Item
{
    fields
    {
        field(90050; "GNC Cold Chain"; Boolean)
        {
            Caption = 'Cold Chain';
            DataClassification = CustomerContent;
        }
        field(90051; "GNC NPC Code"; Code[20])
        {
            Caption = 'NPC Code';
            DataClassification = CustomerContent;
        }
        field(90052; "GNC MOH Code"; Code[20])
        {
            Caption = 'MOH Code';
            DataClassification = CustomerContent;
        }
    }
}
