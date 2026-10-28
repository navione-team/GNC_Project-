// Type de classification client (FRD exigence 1.1).
// Une seule table "GNC Cust. Classification" stocke toutes les listes ;
// ce enum indique à quelle liste appartient chaque code.
// Les noms de valeurs sont entre guillemets : "Area" est un mot réservé en AL
// (area(Content) dans les pages) et provoque une erreur de syntaxe sans guillemets.
enum 90000 "GNC Classification Type"
{
    Extensible = true;
    Caption = 'Classification Type';

    value(0; "Customer Type")
    {
        Caption = 'Customer Type';
    }
    value(1; "Area")
    {
        Caption = 'Area';
    }
    value(2; "Line")
    {
        Caption = 'Line';
    }
    value(3; "Business Unit")
    {
        Caption = 'Business Unit';
    }
    value(4; "Division")
    {
        Caption = 'Division';
    }
    value(5; "Region")
    {
        Caption = 'Region';
    }
}
