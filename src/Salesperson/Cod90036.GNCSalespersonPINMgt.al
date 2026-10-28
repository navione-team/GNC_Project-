// Identification du commercial par PIN sur la Request Collection (devis).
// - ApplyPIN : retrouve le commercial à partir du PIN et le pose sur le devis.
// - Contrôle : on ne peut pas envoyer le devis en approbation ni le transformer
//   en commande (Make Order) si le commercial n'a pas été confirmé par son PIN.
// Aucune modification du code standard : uniquement des event subscribers.
codeunit 90036 "GNC Salesperson PIN Mgt."
{
    var
        InvalidPINErr: Label 'The PIN is not valid.';
        PINNotConfirmedErr: Label 'The salesperson of quote %1 has not been confirmed. The salesperson must enter their PIN on the quote.', Comment = '%1 = quote number';

    // Appelée par le champ "Salesperson PIN" de la fiche devis.
    // Le PIN lui-même n'est jamais enregistré sur le document : seul le commercial trouvé l'est.
    procedure ApplyPIN(var SalesHeader: Record "Sales Header"; PIN: Text)
    var
        Salesperson: Record "Salesperson/Purchaser";
        GNCRequestCollectionMgt: Codeunit "GNC Request Collection Mgt.";
    begin
        if PIN = '' then
            exit;
        Salesperson.SetRange("GNC PIN", PIN);
        if not Salesperson.FindFirst() then
            Error(InvalidPINErr);

        // Le client déjà saisi doit être dans le portefeuille du commercial,
        // et les articles déjà saisis doivent lui être affectés (codeunit 90043)
        GNCRequestCollectionMgt.CheckCustomerInPortfolio(SalesHeader, Salesperson.Code);
        GNCRequestCollectionMgt.CheckAllItemsAllowed(SalesHeader, Salesperson.Code);

        // Validate : le standard contrôle le commercial (bloqué...) et met à jour les dimensions
        SalesHeader.Validate("Salesperson Code", Salesperson.Code);
        SalesHeader."GNC PIN Salesperson Code" := Salesperson.Code;
    end;

    // Le commercial est confirmé si le Salesperson Code actuel est bien celui donné par le PIN.
    // Au changement de client, le codeunit 90043 remet le commercial du PIN (s'il est dans son portefeuille).
    procedure IsSalespersonConfirmed(SalesHeader: Record "Sales Header"): Boolean
    begin
        exit((SalesHeader."Salesperson Code" <> '') and
             (SalesHeader."Salesperson Code" = SalesHeader."GNC PIN Salesperson Code"));
    end;

    local procedure CheckSalespersonConfirmed(SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Quote then
            exit;
        if not IsSalespersonConfirmed(SalesHeader) then
            Error(PINNotConfirmedErr, SalesHeader."No.");
    end;

    // Make Order (fiche et liste des devis) : contrôle avant la création de la commande
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnBeforeOnRun', '', false, false)]
    local procedure CheckPINOnBeforeMakeOrder(var SalesHeader: Record "Sales Header")
    begin
        CheckSalespersonConfirmed(SalesHeader);
    end;

    // Send Approval Request (workflow) : contrôle avant l'envoi en approbation
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterCheckSalesApprovalPossible', '', false, false)]
    local procedure CheckPINOnAfterCheckSalesApprovalPossible(var SalesHeader: Record "Sales Header")
    begin
        CheckSalespersonConfirmed(SalesHeader);
    end;
}
