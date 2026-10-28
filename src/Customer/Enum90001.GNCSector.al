// Secteur du client : privé ou gouvernemental (titres "PRIVATE Sector" / "Goverment" du FRD).
// Extensible pour pouvoir ajouter d'autres secteurs plus tard sans casser les données.
enum 90001 "GNC Sector"
{
    Extensible = true;
    Caption = 'Sector';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Private)
    {
        Caption = 'Private';
    }
    value(2; Government)
    {
        Caption = 'Government';
    }
}
