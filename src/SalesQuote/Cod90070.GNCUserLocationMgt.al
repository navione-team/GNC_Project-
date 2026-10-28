// Lot 6 – Magasin par utilisateur (consigne du manager « User Setup : location par utilisateur », hyp. 11).
// Quand l'utilisateur choisit le client d'une demande (devis), d'une commande ou d'une facture, le standard
// met le magasin du client (ou de son adresse de livraison) ; on le remplace par le magasin de l'utilisateur
// ("Sales Location Code" dans User Setup). Les lignes saisies ensuite reprennent ce magasin (standard).
// Vide dans User Setup (ou pas de ligne User Setup) = comportement standard. Modifiable à la main ensuite.
// La commande créée par Make Order reprend le magasin de la demande (copie standard).
codeunit 90070 "GNC User Location Mgt."
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure SetUserLocationOnAfterValidateSellToCustomer(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        LocationCode: Code[10];
    begin
        if Rec.IsTemporary() or (Rec."Sell-to Customer No." = '') then
            exit;
        if not (Rec."Document Type" in [Rec."Document Type"::Quote, Rec."Document Type"::Order, Rec."Document Type"::Invoice]) then
            exit;
        LocationCode := GetUserLocation();
        if (LocationCode <> '') and (Rec."Location Code" <> LocationCode) then
            Rec.Validate("Location Code", LocationCode);
    end;

    procedure GetUserLocation(): Code[10]
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            exit(UserSetup."GNC Location Code");
        exit('');
    end;
}
