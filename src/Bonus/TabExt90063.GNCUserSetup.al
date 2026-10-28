// Lot 5 – Autorisation de modifier ou supprimer les lignes bonus (FRD REQ-DB-016).
// Cochée par l'administrateur dans User Setup. Contrôle dans le codeunit 90062.
// Lot 6 – Remise maximum saisie à la main (codeunit 90069) et magasin de l'utilisateur (codeunit 90070).
// N° de champ 90100 (et non 90000) : la table User Setup a déjà des champs d'une autre extension Navione.
tableextension 90063 "GNC User Setup" extends "User Setup"
{
    fields
    {
        field(90100; "GNC Allow Edit Bonus Lines"; Boolean)
        {
            Caption = 'Allow Edit Bonus Lines';
            DataClassification = CustomerContent;
        }
        // Lot 6 – Remise maximum que l'utilisateur peut saisir à la main sur une ligne (FRD REQ-DB-015).
        // Contrôle actif seulement si "Control Manual Discount" est coché dans GNC Sales Setup (codeunit 90069).
        field(90101; "GNC Max Line Discount %"; Decimal)
        {
            Caption = 'Max Line Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
        }
        // Lot 6 – Magasin (location) de l'utilisateur, recopié sur ses documents de vente (hyp. 11, codeunit 90070)
        field(90102; "GNC Location Code"; Code[10])
        {
            Caption = 'Sales Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code where("Use As In-Transit" = const(false));
        }
    }
}
