// OBSOLÈTE depuis 1.0.0.12 : gardé seulement pour l'ancien champ 11 de GNC Sales Setup (déjà publié).
// Que faire quand un commercial confirme (PIN) une demande pour un client
// qui a déjà une demande confirmée (approuvée, non convertie) du même commercial ?
// Paramètre "Duplicate Request Check" de GNC Sales Setup.
enum 90040 "GNC Duplicate Check"
{
    Extensible = false;
    Caption = 'Duplicate Check';

    value(0; "None")
    {
        Caption = 'None';
    }
    // Message d'information, la saisie continue
    value(1; Warn)
    {
        Caption = 'Warn';
    }
    // Erreur : le commercial ne peut pas confirmer la demande
    value(2; Block)
    {
        Caption = 'Block';
    }
}
