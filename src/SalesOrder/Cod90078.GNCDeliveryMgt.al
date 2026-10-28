// Lot 7 – Plan de livraison et interface magasin (consignes du manager : priorité Normal / Urgent /
// Very Urgent + chauffeur ; FRD 10.6 : le magasin vérifie le stock et enregistre l'expédition).
// - Priorité : choisie sur la demande, recopiée sur la commande ; au regroupement, la plus urgente gagne.
// - Chauffeur obligatoire pour expédier une commande (sauf "Driver Optional on Shipment" dans GNC Sales Setup).
// - Expédition depuis le plan de livraison : Ship seulement (la facture reste à faire par les ventes / finance).
codeunit 90078 "GNC Delivery Mgt."
{
    var
        DriverRequiredErr: Label 'Select a driver on sales order %1 before posting the shipment.', Comment = '%1 = order no.';
        ShipQst: Label 'Do you want to post the shipment of sales order %1 (%2)?', Comment = '%1 = order no., %2 = customer name';
        StockAvailableTxt: Label 'Available';
        StockPartialTxt: Label 'Partial';
        StockNotAvailableTxt: Label 'Not Available';

    // Ordre de tri du plan de livraison : le plus urgent d'abord
    procedure GetPrioritySort(Priority: Enum "GNC Delivery Priority"): Integer
    begin
        case Priority of
            Priority::"Very Urgent":
                exit(1);
            Priority::Urgent:
                exit(2);
        end;
        exit(3);
    end;

    // Regroupement (codeunit 90056) : la commande garde la priorité la plus urgente de ses demandes
    procedure KeepHighestPriority(OrderNo: Code[20]; RequestHeader: Record "Sales Header")
    var
        SalesOrderHeader: Record "Sales Header";
    begin
        if not SalesOrderHeader.Get(SalesOrderHeader."Document Type"::Order, OrderNo) then
            exit;
        if RequestHeader."GNC Delivery Priority".AsInteger() > SalesOrderHeader."GNC Delivery Priority".AsInteger() then begin
            SalesOrderHeader.Validate("GNC Delivery Priority", RequestHeader."GNC Delivery Priority");
            SalesOrderHeader.Modify();
        end;
    end;

    // Commandes créées avant la version 1.0.0.22 : ordre de tri vide (0) → Normal (3)
    procedure FixOldPrioritySort()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("GNC Priority Sort", 0);
        if not SalesHeader.IsEmpty() then
            SalesHeader.ModifyAll("GNC Priority Sort", GetPrioritySort(SalesHeader."GNC Delivery Priority"::Normal));
    end;

    // ---------- Expédition ----------

    // Bouton "Ship" du plan de livraison : expédition seulement (pas de facture)
    procedure ShipOrder(var SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
        if not Confirm(ShipQst, true, SalesHeader."No.", SalesHeader."Sell-to Customer Name") then
            exit;
        SalesHeader.Ship := true;
        SalesHeader.Invoice := false;
        SalesPost.Run(SalesHeader);
    end;

    // Chauffeur obligatoire pour toute expédition de commande (plan de livraison, fiche commande...)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckSalesDoc', '', false, false)]
    local procedure CheckDriverOnAfterCheckSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; WhseShip: Boolean; WhseReceive: Boolean; PreviewMode: Boolean; var ErrorMessageMgt: Codeunit "Error Message Management")
    var
        GNCSalesSetup: Record "GNC Sales Setup";
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            exit;
        if not SalesHeader.Ship then
            exit;
        if SalesHeader."GNC Driver Code" <> '' then
            exit;
        GNCSalesSetup.GetSetup();
        if GNCSalesSetup."Driver Optional on Shipment" then
            exit;
        Error(DriverRequiredErr, SalesHeader."No.");
    end;

    // ---------- Stock ----------

    // Stock des articles à expédier (FRD : « check stock availability before shipment ») :
    // Available = tout est en stock dans le magasin de la ligne, Partial = une partie, Not Available = rien.
    // Simple comparaison quantité restante / stock du magasin (sans tenir compte des autres commandes).
    procedure GetStockStatus(SalesHeader: Record "Sales Header"; var StyleTxt: Text): Text
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        LineCount: Integer;
        AvailableCount: Integer;
        PartialCount: Integer;
    begin
        StyleTxt := 'Standard';
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("Outstanding Qty. (Base)", '>0');
        if SalesLine.FindSet() then
            repeat
                if Item.Get(SalesLine."No.") then
                    if Item.Type = Item.Type::Inventory then begin
                        LineCount += 1;
                        Item.SetRange("Location Filter", SalesLine."Location Code");
                        Item.SetRange("Variant Filter", SalesLine."Variant Code");
                        Item.CalcFields(Inventory);
                        if Item.Inventory >= SalesLine."Outstanding Qty. (Base)" then
                            AvailableCount += 1
                        else
                            if Item.Inventory > 0 then
                                PartialCount += 1;
                    end;
            until SalesLine.Next() = 0;

        if LineCount = 0 then
            exit(''); // rien à prendre en stock (services...)
        if AvailableCount = LineCount then begin
            StyleTxt := 'Favorable';
            exit(StockAvailableTxt);
        end;
        if (AvailableCount + PartialCount) > 0 then begin
            StyleTxt := 'Ambiguous';
            exit(StockPartialTxt);
        end;
        StyleTxt := 'Unfavorable';
        exit(StockNotAvailableTxt);
    end;
}
