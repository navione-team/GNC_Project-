// Lot 4 – « PO to be regrouped » (FRD 1.4–1.6) : plusieurs Request Collections (devis) approuvées
// du même client deviennent UNE seule commande.
// Hypothèses de travail (CLAUDE.md, hyp. 3, à valider par le chef de projet), réglables dans GNC Sales Setup :
// - seulement les demandes Released (approuvées), non clôturées, au commercial confirmé par PIN ;
// - même client, même client facturé, même adresse de livraison (Ship-to Code), même devise
//   et (réglage "Request Grouping") même Document Date ;
// - même article + commercial + unité + magasin + prix + remise → une ligne cumulée
//   (réglage "Do Not Merge Identical Lines"), le détail par demande reste dans la table 90058.
// Fonctionnement : la 1re demande (plus petit numéro) passe par le Make Order standard (en-tête,
// commentaires, archivage Won, contrôle PIN...), les suivantes sont ajoutées à cette commande,
// archivées Won puis supprimées comme le fait le Make Order standard.
codeunit 90056 "GNC Request Grouping Mgt."
{
    var
        NotConfirmedErr: Label 'Request %1 cannot be grouped: its salesperson has not been confirmed by PIN.', Comment = '%1 = request (quote) number';
        NoRequestToGroupErr: Label 'There is no released request to group with request %1.', Comment = '%1 = request (quote) number';
        OrderCreatedMsg: Label 'Sales order %1 has been created for customer %2. It groups the requests %3.', Comment = '%1 = order no., %2 = customer name, %3 = list of request numbers';
        OpenOrderQst: Label '%1\\Do you want to open the sales order?', Comment = '%1 = result message';
        OrdersCreatedMsg: Label '%1 sales order(s) created:\%2', Comment = '%1 = number of orders, %2 = one line per order';
        OrderLineTxt: Label '- %1 (%2): requests %3', Comment = '%1 = order no., %2 = customer name, %3 = list of request numbers';
        NothingToGroupMsg: Label 'There is no released request to group.';
        SkippedMsg: Label 'Not grouped because the salesperson has not been confirmed by PIN: %1.', Comment = '%1 = list of request numbers';

    // ---------- Actions de l'écran "Requests to Group" (page 90055) ----------

    // Crée la commande du groupe de la demande choisie (même client, même jour...)
    procedure GroupRequestsOf(SelectedRequest: Record "Sales Header")
    var
        SalesOrderHeader: Record "Sales Header";
        GNCSalespersonPINMgt: Codeunit "GNC Salesperson PIN Mgt.";
        SkippedNos: List of [Code[20]];
        RequestNos: Text;
        ResultMsg: Text;
    begin
        if not GNCSalespersonPINMgt.IsSalespersonConfirmed(SelectedRequest) then
            Error(NotConfirmedErr, SelectedRequest."No.");
        if not CreateOrderForGroup(SelectedRequest, SalesOrderHeader, RequestNos, SkippedNos) then
            Error(NoRequestToGroupErr, SelectedRequest."No.");
        Commit(); // la commande est créée, même si l'utilisateur ne l'ouvre pas

        ResultMsg := StrSubstNo(OrderCreatedMsg, SalesOrderHeader."No.", SalesOrderHeader."Sell-to Customer Name", RequestNos);
        if SkippedNos.Count() > 0 then
            ResultMsg += '\\' + StrSubstNo(SkippedMsg, ListToText(SkippedNos));
        if Confirm(OpenOrderQst, true, ResultMsg) then
            Page.Run(Page::"Sales Order", SalesOrderHeader);
    end;

    // Crée toutes les commandes : un groupe après l'autre
    procedure GroupAllRequests()
    var
        Request: Record "Sales Header";
        SalesOrderHeader: Record "Sales Header";
        CandidateNos: List of [Code[20]];
        SkippedNos: List of [Code[20]];
        RequestNo: Code[20];
        RequestNos: Text;
        Summary: Text;
        OrderCount: Integer;
    begin
        // 1. Liste des demandes à traiter (on la garde à part : les demandes regroupées sont supprimées)
        SetEligibleFilters(Request);
        Request.SetCurrentKey("Document Type", "Sell-to Customer No.");
        if Request.FindSet() then
            repeat
                CandidateNos.Add(Request."No.");
            until Request.Next() = 0;
        if CandidateNos.Count() = 0 then begin
            Message(NothingToGroupMsg);
            exit;
        end;

        // 2. Chaque demande encore présente donne son groupe (les autres membres du groupe disparaissent)
        foreach RequestNo in CandidateNos do
            if Request.Get(Request."Document Type"::Quote, RequestNo) and not SkippedNos.Contains(RequestNo) then
                if CreateOrderForGroup(Request, SalesOrderHeader, RequestNos, SkippedNos) then begin
                    Commit(); // une commande terminée reste créée si une suivante échoue
                    OrderCount += 1;
                    Summary += StrSubstNo(OrderLineTxt, SalesOrderHeader."No.", SalesOrderHeader."Sell-to Customer Name", RequestNos) + '\';
                end;

        if OrderCount = 0 then
            Summary := NothingToGroupMsg
        else
            Summary := StrSubstNo(OrdersCreatedMsg, OrderCount, Summary);
        if SkippedNos.Count() > 0 then
            Summary += '\' + StrSubstNo(SkippedMsg, ListToText(SkippedNos));
        Message(Summary);
    end;

    // ---------- Filtres ----------

    // Demandes pouvant être regroupées : devis approuvés (Released) et non clôturés
    procedure SetEligibleFilters(var Request: Record "Sales Header")
    begin
        Request.Reset();
        Request.SetRange("Document Type", Request."Document Type"::Quote);
        Request.SetRange(Status, Request.Status::Released);
        Request.SetRange("GNC Closed", false);
    end;

    // Demandes du même groupe que RefRequest
    local procedure SetGroupFilters(var Request: Record "Sales Header"; RefRequest: Record "Sales Header")
    var
        GNCSalesSetup: Record "GNC Sales Setup";
    begin
        SetEligibleFilters(Request);
        Request.SetRange("Sell-to Customer No.", RefRequest."Sell-to Customer No.");
        // Contraintes d'une commande BC : un seul client facturé, une adresse de livraison, une devise
        Request.SetRange("Bill-to Customer No.", RefRequest."Bill-to Customer No.");
        Request.SetRange("Ship-to Code", RefRequest."Ship-to Code");
        Request.SetRange("Currency Code", RefRequest."Currency Code");
        Request.SetRange("Prices Including VAT", RefRequest."Prices Including VAT");

        GNCSalesSetup.GetSetup();
        if GNCSalesSetup."Request Grouping" = GNCSalesSetup."Request Grouping"::"Same Customer and Day" then
            Request.SetRange("Document Date", RefRequest."Document Date");
    end;

    // ---------- Création de la commande ----------

    // Renvoie false s'il n'y a aucune demande à regrouper dans ce groupe.
    // SkippedNos reçoit les demandes du groupe dont le commercial n'est pas confirmé par PIN.
    local procedure CreateOrderForGroup(RefRequest: Record "Sales Header"; var SalesOrderHeader: Record "Sales Header"; var RequestNos: Text; var SkippedNos: List of [Code[20]]): Boolean
    var
        Request: Record "Sales Header";
        GNCSalespersonPINMgt: Codeunit "GNC Salesperson PIN Mgt.";
        GNCBonusMgt: Codeunit "GNC Bonus Mgt.";
        GNCDeliveryMgt: Codeunit "GNC Delivery Mgt.";
        SalesQuoteToOrder: Codeunit "Sales-Quote to Order";
        GroupNos: List of [Code[20]];
        RequestNo: Code[20];
        i: Integer;
    begin
        // 1. Demandes du groupe, par numéro croissant (la plus ancienne donne l'en-tête de la commande)
        SetGroupFilters(Request, RefRequest);
        if Request.FindSet() then
            repeat
                if GNCSalespersonPINMgt.IsSalespersonConfirmed(Request) then
                    GroupNos.Add(Request."No.")
                else
                    if not SkippedNos.Contains(Request."No.") then
                        SkippedNos.Add(Request."No.");
            until Request.Next() = 0;
        if GroupNos.Count() = 0 then
            exit(false);

        // 2. La 1re demande : Make Order standard (crée l'en-tête et les lignes, archive Won, supprime le devis)
        //    Le bonus (lot 5) est reporté à la fin, pour être calculé sur les lignes cumulées
        Request.Get(Request."Document Type"::Quote, GroupNos.Get(1));
        GNCBonusMgt.PostponeBonusForRequest(Request."No.");
        SalesQuoteToOrder.Run(Request);
        SalesQuoteToOrder.GetSalesOrderHeader(SalesOrderHeader);

        // 3. Les suivantes : leurs lignes sont ajoutées (ou cumulées) dans cette commande
        for i := 2 to GroupNos.Count() do begin
            Request.Get(Request."Document Type"::Quote, GroupNos.Get(i));
            GNCDeliveryMgt.KeepHighestPriority(SalesOrderHeader."No.", Request); // lot 7 : la plus urgente gagne
            AppendRequestToOrder(Request, SalesOrderHeader);
        end;
        SalesOrderHeader.Get(SalesOrderHeader."Document Type", SalesOrderHeader."No.");

        // 4. Bonus et remises additionnelles (lot 5) sur la commande complète
        GNCBonusMgt.ApplyBonusToOrder(SalesOrderHeader);

        RequestNos := '';
        foreach RequestNo in GroupNos do begin
            if RequestNos <> '' then
                RequestNos += ', ';
            RequestNos += RequestNo;
        end;
        exit(true);
    end;

    // Ajoute les lignes d'une demande à la commande, puis archive (Won) et supprime la demande
    local procedure AppendRequestToOrder(var RequestHeader: Record "Sales Header"; SalesOrderHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        RequestLine: Record "Sales Line";
        SalesOrderLine: Record "Sales Line";
        GNCRequestTraceability: Codeunit "GNC Request Traceability";
        LineNoMap: Dictionary of [Integer, Integer]; // n° ligne de demande → n° ligne de commande
        MergedRequestLineNos: List of [Integer];
        SalespersonCode: Code[20];
        NextLineNo: Integer;
    begin
        Customer.Get(SalesOrderHeader."Bill-to Customer No.");
        SalespersonCode := RequestHeader."GNC PIN Salesperson Code";
        if SalespersonCode = '' then
            SalespersonCode := RequestHeader."Salesperson Code";
        NextLineNo := GetLastLineNo(SalesOrderHeader) + 10000;

        RequestLine.SetRange("Document Type", RequestHeader."Document Type");
        RequestLine.SetRange("Document No.", RequestHeader."No.");
        if RequestLine.FindSet() then
            repeat
                // Texte étendu rattaché à une ligne cumulée : la ligne de commande a déjà le sien
                if not IsAttachedToMergedLine(RequestLine, MergedRequestLineNos) then begin
                    if FindLineToMerge(SalesOrderHeader, RequestLine, SalespersonCode, SalesOrderLine) then begin
                        MergeIntoOrderLine(SalesOrderLine, RequestLine);
                        MergedRequestLineNos.Add(RequestLine."Line No.");
                    end else begin
                        InsertOrderLine(SalesOrderHeader, Customer, RequestHeader, RequestLine, SalespersonCode, NextLineNo, LineNoMap, SalesOrderLine);
                        LineNoMap.Add(RequestLine."Line No.", SalesOrderLine."Line No.");
                        NextLineNo += 10000;
                    end;
                    GNCRequestTraceability.InsertGroupedRequestLine(SalesOrderLine, RequestHeader, RequestLine);
                end;
            until RequestLine.Next() = 0;

        ArchiveRequestAsWon(RequestHeader);
        DeleteRequest(RequestHeader);
    end;

    local procedure IsAttachedToMergedLine(RequestLine: Record "Sales Line"; MergedRequestLineNos: List of [Integer]): Boolean
    begin
        exit((RequestLine."Attached to Line No." <> 0) and MergedRequestLineNos.Contains(RequestLine."Attached to Line No."));
    end;

    // Ligne de commande identique (article, variante, unité, magasin, prix, remise, commercial) ?
    local procedure FindLineToMerge(SalesOrderHeader: Record "Sales Header"; RequestLine: Record "Sales Line"; SalespersonCode: Code[20]; var SalesOrderLine: Record "Sales Line"): Boolean
    var
        GNCSalesSetup: Record "GNC Sales Setup";
    begin
        GNCSalesSetup.GetSetup();
        if GNCSalesSetup."Do Not Merge Identical Lines" then
            exit(false);
        if (RequestLine.Type <> RequestLine.Type::Item) or (RequestLine."No." = '') or (RequestLine."Attached to Line No." <> 0) then
            exit(false);

        SalesOrderLine.Reset();
        SalesOrderLine.SetRange("Document Type", SalesOrderHeader."Document Type");
        SalesOrderLine.SetRange("Document No.", SalesOrderHeader."No.");
        SalesOrderLine.SetRange(Type, SalesOrderLine.Type::Item);
        SalesOrderLine.SetRange("No.", RequestLine."No.");
        SalesOrderLine.SetRange("Variant Code", RequestLine."Variant Code");
        SalesOrderLine.SetRange("Unit of Measure Code", RequestLine."Unit of Measure Code");
        SalesOrderLine.SetRange("Location Code", RequestLine."Location Code");
        SalesOrderLine.SetRange("Unit Price", RequestLine."Unit Price");
        SalesOrderLine.SetRange("Line Discount %", RequestLine."Line Discount %");
        SalesOrderLine.SetRange("GNC Salesperson Code", SalespersonCode);
        SalesOrderLine.SetRange("Attached to Line No.", 0);
        SalesOrderLine.SetRange("Quantity Shipped", 0);
        exit(SalesOrderLine.FindFirst());
    end;

    // Cumul : on ajoute la quantité de la demande à la ligne de commande existante
    local procedure MergeIntoOrderLine(var SalesOrderLine: Record "Sales Line"; RequestLine: Record "Sales Line")
    var
        UnitPrice: Decimal;
        LineDiscountPct: Decimal;
    begin
        UnitPrice := SalesOrderLine."Unit Price";
        LineDiscountPct := SalesOrderLine."Line Discount %";
        SalesOrderLine.Validate(Quantity, SalesOrderLine.Quantity + RequestLine.Quantity);
        // Le changement de quantité peut recalculer le prix (listes de prix) : on garde le prix convenu
        if SalesOrderLine."Unit Price" <> UnitPrice then
            SalesOrderLine.Validate("Unit Price", UnitPrice);
        if SalesOrderLine."Line Discount %" <> LineDiscountPct then
            SalesOrderLine.Validate("Line Discount %", LineDiscountPct);
        SalesOrderLine.Modify(true);
    end;

    // Nouvelle ligne de commande : copie de la ligne de demande, comme le Make Order standard (codeunit 86)
    local procedure InsertOrderLine(SalesOrderHeader: Record "Sales Header"; Customer: Record Customer; RequestHeader: Record "Sales Header"; RequestLine: Record "Sales Line"; SalespersonCode: Code[20]; NewLineNo: Integer; LineNoMap: Dictionary of [Integer, Integer]; var SalesOrderLine: Record "Sales Line")
    var
        PrepaymentMgt: Codeunit "Prepayment Mgt.";
        AttachedToLineNo: Integer;
    begin
        SalesOrderLine := RequestLine;
        SalesOrderLine."Document Type" := SalesOrderHeader."Document Type";
        SalesOrderLine."Document No." := SalesOrderHeader."No.";
        SalesOrderLine."Line No." := NewLineNo;
        // Texte étendu : on le rattache au nouveau n° de la ligne d'article
        if RequestLine."Attached to Line No." <> 0 then
            if LineNoMap.Get(RequestLine."Attached to Line No.", AttachedToLineNo) then
                SalesOrderLine."Attached to Line No." := AttachedToLineNo
            else
                SalesOrderLine."Attached to Line No." := 0;
        SalesOrderLine."Transaction Type" := SalesOrderHeader."Transaction Type";
        if Customer."Prepayment %" <> 0 then
            SalesOrderLine."Prepayment %" := Customer."Prepayment %";
        PrepaymentMgt.SetSalesPrepaymentPct(SalesOrderLine, SalesOrderHeader."Posting Date");
        SalesOrderLine.Validate("Prepayment %");
        if SalesOrderLine."No." <> '' then
            SalesOrderLine.DefaultDeferralCode();

        // Traçabilité (lot 3) : demande d'origine et commercial confirmé par PIN
        SalesOrderLine."GNC Request No." := RequestHeader."No.";
        if SalesOrderLine.Type <> SalesOrderLine.Type::" " then
            SalesOrderLine."GNC Salesperson Code" := SalespersonCode;
        SalesOrderLine.Insert();
    end;

    local procedure GetLastLineNo(SalesOrderHeader: Record "Sales Header"): Integer
    var
        SalesOrderLine: Record "Sales Line";
    begin
        SalesOrderLine.SetRange("Document Type", SalesOrderHeader."Document Type");
        SalesOrderLine.SetRange("Document No.", SalesOrderHeader."No.");
        if SalesOrderLine.FindLast() then
            exit(SalesOrderLine."Line No.");
        exit(0);
    end;

    // ---------- Fin de la demande regroupée (comme le Make Order standard) ----------

    // Statut Won + archive (même règle que le Make Order : codeunit 90019)
    local procedure ArchiveRequestAsWon(var RequestHeader: Record "Sales Header")
    var
        GNCSalesSetup: Record "GNC Sales Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        ArchiveManagement: Codeunit ArchiveManagement;
    begin
        RequestHeader."GNC Quote Status" := RequestHeader."GNC Quote Status"::Won;
        RequestHeader.Modify();

        GNCSalesSetup.GetSetup();
        SalesSetup.Get();
        if GNCSalesSetup."Archive Quote on Make Order" or (SalesSetup."Archive Quotes" <> SalesSetup."Archive Quotes"::Never) then
            ArchiveManagement.StoreSalesDocument(RequestHeader, false);
    end;

    // Suppression du devis, comme à la fin du Make Order standard.
    // Ses commentaires ne sont pas recopiés dans la commande (ils restent dans l'archive).
    local procedure DeleteRequest(var RequestHeader: Record "Sales Header")
    var
        RequestLine: Record "Sales Line";
        SalesCommentLine: Record "Sales Comment Line";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        ApprovalsMgmt.DeleteApprovalEntries(RequestHeader.RecordId);
        SalesCommentLine.DeleteComments(RequestHeader."Document Type".AsInteger(), RequestHeader."No.");
        RequestHeader.DeleteLinks();
        RequestHeader.Delete();

        RequestLine.SetRange("Document Type", RequestHeader."Document Type");
        RequestLine.SetRange("Document No.", RequestHeader."No.");
        RequestLine.DeleteAll();
    end;

    local procedure ListToText(Values: List of [Code[20]]): Text
    var
        Value: Code[20];
        Result: Text;
    begin
        foreach Value in Values do begin
            if Result <> '' then
                Result += ', ';
            Result += Value;
        end;
        exit(Result);
    end;
}
