// Traçabilité demande → commande → expédition → facture, par ligne (FRD 1.5, REQ-SR-006, REQ-SO-007).
// - Make Order : chaque ligne de la commande reçoit le n° de la Request Collection (devis)
//   et le commercial confirmé par son PIN.
// - Ligne ajoutée à la main sur un document (hors devis) : commercial de l'en-tête par défaut.
// - Détail demande → ligne de commande (table 90058, lot 4), gardé après la validation.
// Ensuite, le standard recopie ces champs (mêmes numéros) sur les lignes expédiées, facturées et d'avoir.
// Aucune modification du code standard : uniquement des event subscribers.
codeunit 90054 "GNC Request Traceability"
{
    // Make Order : juste avant l'insertion de chaque ligne de commande (copie de la ligne du devis)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnBeforeInsertSalesOrderLine', '', false, false)]
    local procedure SetTraceabilityOnBeforeInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line"; SalesOrderHeader: Record "Sales Header"; SalesQuoteLine: Record "Sales Line"; SalesQuoteHeader: Record "Sales Header")
    begin
        SalesOrderLine."GNC Request No." := SalesQuoteHeader."No.";

        // Lignes de commentaire (Type vide) : pas de commercial
        if SalesOrderLine.Type = SalesOrderLine.Type::" " then
            exit;
        // Commercial confirmé par PIN (toujours rempli : le Make Order est refusé sans PIN, codeunit 90036)
        if SalesQuoteHeader."GNC PIN Salesperson Code" <> '' then
            SalesOrderLine."GNC Salesperson Code" := SalesQuoteHeader."GNC PIN Salesperson Code"
        else
            SalesOrderLine."GNC Salesperson Code" := SalesQuoteHeader."Salesperson Code";
    end;

    // Make Order : après l'insertion de chaque ligne, on note le détail demande → ligne de commande (table 90058)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnAfterInsertSalesOrderLine', '', false, false)]
    local procedure InsertDetailOnAfterInsertSalesOrderLine(var SalesOrderLine: Record "Sales Line"; SalesOrderHeader: Record "Sales Header"; SalesQuoteLine: Record "Sales Line"; SalesQuoteHeader: Record "Sales Header")
    begin
        InsertGroupedRequestLine(SalesOrderLine, SalesQuoteHeader, SalesQuoteLine);
    end;

    // Note qu'une ligne de demande (devis) a été reprise dans une ligne de commande.
    // Aussi appelée par le regroupement (codeunit 90056), y compris quand la ligne est cumulée.
    procedure InsertGroupedRequestLine(SalesOrderLine: Record "Sales Line"; SalesQuoteHeader: Record "Sales Header"; SalesQuoteLine: Record "Sales Line")
    var
        GroupedRequestLine: Record "GNC Grouped Request Line";
    begin
        // Lignes de commentaire / texte étendu : pas de détail
        if SalesQuoteLine.Type = SalesQuoteLine.Type::" " then
            exit;

        GroupedRequestLine.Init();
        GroupedRequestLine."Order No." := SalesOrderLine."Document No.";
        GroupedRequestLine."Order Line No." := SalesOrderLine."Line No.";
        GroupedRequestLine."Request No." := SalesQuoteHeader."No.";
        GroupedRequestLine."Request Line No." := SalesQuoteLine."Line No.";
        GroupedRequestLine."Salesperson Code" := SalesOrderLine."GNC Salesperson Code";
        GroupedRequestLine."Customer No." := SalesQuoteHeader."Sell-to Customer No.";
        GroupedRequestLine."Request Date" := SalesQuoteHeader."Document Date";
        GroupedRequestLine.Type := SalesQuoteLine.Type;
        GroupedRequestLine."No." := SalesQuoteLine."No.";
        GroupedRequestLine.Description := SalesQuoteLine.Description;
        GroupedRequestLine.Quantity := SalesQuoteLine.Quantity;
        GroupedRequestLine."Unit of Measure Code" := SalesQuoteLine."Unit of Measure Code";
        GroupedRequestLine."Unit Price" := SalesQuoteLine."Unit Price";
        GroupedRequestLine."Line Discount %" := SalesQuoteLine."Line Discount %";
        GroupedRequestLine.Insert();
    end;

    // Ligne de commande supprimée par l'utilisateur : on supprime son détail.
    // - RunTrigger = false : suppression par la validation (Post) → on garde le détail pour la traçabilité.
    // - Ligne déjà expédiée : on garde aussi le détail (ex. "Delete Invoiced Sales Orders").
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteDetailOnAfterDeleteSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    var
        GroupedRequestLine: Record "GNC Grouped Request Line";
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit;
        if Rec."Quantity Shipped" <> 0 then
            exit;
        GroupedRequestLine.SetRange("Order No.", Rec."Document No.");
        GroupedRequestLine.SetRange("Order Line No.", Rec."Line No.");
        GroupedRequestLine.DeleteAll();
    end;

    // Ligne ajoutée à la main (commande, facture, avoir...) : on propose le commercial de l'en-tête.
    // Pas sur le devis : là, le commercial est sur l'en-tête et les lignes sont remplies au Make Order.
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure SetHeaderSalespersonOnAfterValidateNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        if Rec."Document Type" = Rec."Document Type"::Quote then
            exit;
        if (Rec."GNC Request No." <> '') or (Rec."GNC Salesperson Code" <> '') then
            exit; // ligne venue d'une demande, ou commercial déjà choisi
        if Rec.Type = Rec.Type::" " then
            exit;
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;
        Rec."GNC Salesperson Code" := SalesHeader."Salesperson Code";
    end;
}
