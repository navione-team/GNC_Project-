// Gestion des ventes ratées (FRD § 9.1 "Failed sales", règles précisées par le chef de projet) :
// - Clôturer : statut Failed + motif + commentaire, copie dans les archives, puis retrait de la liste des devis.
// - Won : posé automatiquement quand un devis est transformé en commande ; le devis est archivé
//   si le paramètre "Archive Quote on Make Order" (GNC Sales Setup) est à Oui.
// - Restaurer : un devis clôturé peut être recréé depuis les archives.
// Aucune modification du code standard : uniquement des event subscribers.
codeunit 90019 "GNC Sales Quote Mgt."
{
    var
        QuoteClosedMsg: Label 'Quote %1 has been closed as failed and archived. You can find it in Sales Quote Archives.', Comment = '%1 = quote number';
        RestoreQst: Label 'Do you want to restore closed quote %1 (version %2)?', Comment = '%1 = quote number, %2 = archive version';
        QuoteRestoredMsg: Label 'Quote %1 has been restored.', Comment = '%1 = quote number';

    // Appelée par l'action "Close as Failed" de la fiche devis. Renvoie true si le devis a été clôturé.
    procedure CloseQuoteAsFailed(var SalesHeader: Record "Sales Header"): Boolean
    var
        ArchiveManagement: Codeunit ArchiveManagement;
        CloseQuoteDialog: Page "GNC Close Quote";
    begin
        SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Quote);

        // 1. Demande du motif (obligatoire) et du commentaire
        CloseQuoteDialog.SetQuoteNo(SalesHeader."No.");
        if CloseQuoteDialog.RunModal() <> Action::OK then
            exit(false);

        // 2. Marque le devis comme vente ratée
        SalesHeader."GNC Quote Status" := SalesHeader."GNC Quote Status"::Failed;
        SalesHeader."GNC Failed Reason Code" := CloseQuoteDialog.GetReasonCode();
        SalesHeader."GNC Failed Comment" := CloseQuoteDialog.GetComment();
        SalesHeader."GNC Closed" := true;
        SalesHeader.Modify();

        // 3. Copie dans les archives (toujours, quel que soit le paramètre "Archive Quotes")
        ArchiveManagement.StoreSalesDocument(SalesHeader, false);

        // 4. Retire le devis de la liste des devis en cours (l'archive reste)
        SalesHeader.Delete(true);

        Message(QuoteClosedMsg, SalesHeader."No.");
        exit(true);
    end;

    // À la suppression d'un devis, le standard l'archive automatiquement selon le paramétrage.
    // Pour un devis clôturé, l'archive vient d'être faite à l'étape 3 : on évite une 2e copie.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, 'OnBeforeAutoArchiveSalesDocument', '', false, false)]
    local procedure SkipAutoArchiveForClosedQuote(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        if SalesHeader."GNC Closed" then
            IsHandled := true;
    end;

    // Devis transformé en commande ("Make Order") : juste avant son archivage, on le marque Won.
    // Le standard n'archive le devis que si "Archive Quotes" (Sales & Receivables Setup) n'est pas
    // à Never. Si le paramètre GNC "Archive Quote on Make Order" est à Oui, on archive nous-mêmes
    // (toujours, sans question) et on saute l'archivage standard : pas de double archive.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnBeforeArchiveSalesQuote', '', false, false)]
    local procedure SetWonOnBeforeArchiveSalesQuote(var SalesQuoteHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        GNCSalesSetup: Record "GNC Sales Setup";
        ArchiveManagement: Codeunit ArchiveManagement;
    begin
        SalesQuoteHeader."GNC Quote Status" := SalesQuoteHeader."GNC Quote Status"::Won;

        GNCSalesSetup.GetSetup();
        if not GNCSalesSetup."Archive Quote on Make Order" then
            exit; // comportement standard (selon "Archive Quotes")

        ArchiveManagement.StoreSalesDocument(SalesQuoteHeader, false);
        IsHandled := true;
    end;

    // La restauration standard exige que le devis existe encore. Un devis clôturé a été retiré :
    // dans ce cas on le recrée nous-mêmes à partir de la version d'archive choisie.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ArchiveManagement, 'OnBeforeRestoreSalesDocument', '', false, false)]
    local procedure RestoreClosedQuoteOnBeforeRestoreSalesDocument(var SalesHeaderArchive: Record "Sales Header Archive"; var IsHandled: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeaderArchive."Document Type" <> SalesHeaderArchive."Document Type"::Quote then
            exit;
        if SalesHeader.Get(SalesHeaderArchive."Document Type", SalesHeaderArchive."No.") then
            exit; // le devis existe encore : restauration standard
        if not WasQuoteClosed(SalesHeaderArchive) then
            exit; // devis supprimé ou transformé en commande : comportement standard

        IsHandled := true;
        RestoreClosedQuote(SalesHeaderArchive);
    end;

    local procedure WasQuoteClosed(SalesHeaderArchive: Record "Sales Header Archive"): Boolean
    var
        ClosedVersion: Record "Sales Header Archive";
    begin
        ClosedVersion.SetRange("Document Type", SalesHeaderArchive."Document Type");
        ClosedVersion.SetRange("No.", SalesHeaderArchive."No.");
        ClosedVersion.SetRange("Doc. No. Occurrence", SalesHeaderArchive."Doc. No. Occurrence");
        ClosedVersion.SetRange("GNC Closed", true);
        exit(not ClosedVersion.IsEmpty());
    end;

    local procedure RestoreClosedQuote(var SalesHeaderArchive: Record "Sales Header Archive")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLineArchive: Record "Sales Line Archive";
    begin
        if not Confirm(RestoreQst, true, SalesHeaderArchive."No.", SalesHeaderArchive."Version No.") then
            exit;

        // En-tête : copie de l'archive, puis remise à l'état "en cours"
        SalesHeaderArchive.CalcFields("Work Description");
        SalesHeader.Init();
        SalesHeader.TransferFields(SalesHeaderArchive);
        SalesHeader.Status := SalesHeader.Status::Open;
        SalesHeader."GNC Quote Status" := SalesHeader."GNC Quote Status"::Open;
        SalesHeader."GNC Failed Reason Code" := '';
        SalesHeader."GNC Failed Comment" := '';
        SalesHeader."GNC Closed" := false;
        SalesHeader.Insert(false);

        // Lignes : copiées telles qu'archivées (mêmes prix et remises que le devis d'origine)
        SalesLineArchive.SetRange("Document Type", SalesHeaderArchive."Document Type");
        SalesLineArchive.SetRange("Document No.", SalesHeaderArchive."No.");
        SalesLineArchive.SetRange("Doc. No. Occurrence", SalesHeaderArchive."Doc. No. Occurrence");
        SalesLineArchive.SetRange("Version No.", SalesHeaderArchive."Version No.");
        if SalesLineArchive.FindSet() then
            repeat
                SalesLine.Init();
                SalesLine.TransferFields(SalesLineArchive);
                SalesLine.Insert(false);
            until SalesLineArchive.Next() = 0;

        Message(QuoteRestoredMsg, SalesHeader."No.");
    end;
}
