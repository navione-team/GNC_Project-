// OBSOLÈTE depuis 1.0.0.11 : remplacé par la table 90041 "GNC Salesperson Sub-Type"
// (liste filtrable selon le Type). Gardé seulement pour l'ancien champ 90002 déjà publié.
// Sous-type du commercial, d'après le tableau "Sales Representative Type" du FRD :
// - Private Sector : Pharma, OTC, Medical Device
// - Government     : Institution, Tender, Medical Device
// Le contrôle Type / Sous-type est fait dans la tableextension 90035.
enum 90039 "GNC Salesperson Sub-Type"
{
    Extensible = true;
    Caption = 'Salesperson Sub-Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Pharma)
    {
        Caption = 'Pharma';
    }
    value(2; OTC)
    {
        Caption = 'OTC';
    }
    value(3; "Medical Device")
    {
        Caption = 'Medical Device';
    }
    value(4; Institution)
    {
        Caption = 'Institution';
    }
    value(5; Tender)
    {
        Caption = 'Tender';
    }
}
