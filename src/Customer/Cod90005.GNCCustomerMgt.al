// Contrôles métier client (FRD exigence 1.1 : Name, Phone No. et CR No. obligatoires).
// GLN n'est PAS contrôlé : décision du chef de projet (2026-10-17), le GLN est optionnel.
// On ne bloque pas la création de la fiche (les données peuvent être complétées plus tard),
// mais on empêche d'utiliser le client sur un document de vente tant qu'il manque un de ces champs.
codeunit 90005 "GNC Customer Mgt."
{
    // Abonné à l'événement standard déclenché après la saisie du client dans l'en-tête de vente
    // (devis, commande, facture, avoir...). Aucune modification du code standard.
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure CheckMandatoryFieldsOnAfterValidateSellToCustomer(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."Sell-to Customer No." = '' then
            exit;
        CheckMandatoryFields(Rec."Sell-to Customer No.");
    end;

    // TestField affiche un message d'erreur clair indiquant le champ manquant et le client
    procedure CheckMandatoryFields(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        Customer.TestField(Name);
        Customer.TestField("Phone No.");
        Customer.TestField("GNC CR No.");
    end;
}
