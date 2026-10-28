// Lot 4 – Données de l'écran visuel « Requests to Group » (page 90092).
// Demandes approuvées (Released, non clôturées), réparties en groupes avec la même règle que le
// regroupement (codeunit 90056) : même client, client facturé, adresse de livraison, devise,
// prix TTC/HT et, selon GNC Sales Setup, même Document Date. Pour chaque groupe : ses demandes,
// leurs lignes et les règles bonus de ses articles (l'aperçu est calculé dans la page JavaScript).
codeunit 90093 "GNC Requests Group Data"
{
    var
        AllDatesTxt: Label 'all dates';

    procedure BuildGroups(var Created: JsonArray) Data: JsonObject
    var
        GNCSalesSetup: Record "GNC Sales Setup";
        Request: Record "Sales Header";
        GNCRequestGroupingMgt: Codeunit "GNC Request Grouping Mgt.";
        Rule: JsonObject;
        Groups: JsonArray;
        Keys: List of [Text];
        GroupKey: Text;
        SameDay: Boolean;
    begin
        GNCSalesSetup.GetSetup();
        SameDay := GNCSalesSetup."Request Grouping" = GNCSalesSetup."Request Grouping"::"Same Customer and Day";
        Data.Add('dateText', Format(WorkDate(), 0, '<Weekday Text> <Day> <Month Text> <Year4>'));
        Rule.Add('sameDay', SameDay);
        Rule.Add('merge', not GNCSalesSetup."Do Not Merge Identical Lines");
        Data.Add('rule', Rule);

        // 1. Les groupes, dans l'ordre des clients
        GNCRequestGroupingMgt.SetEligibleFilters(Request);
        Request.SetCurrentKey("Document Type", "Sell-to Customer No.");
        if Request.FindSet() then
            repeat
                GroupKey := GetGroupKey(Request, SameDay);
                if not Keys.Contains(GroupKey) then
                    Keys.Add(GroupKey);
            until Request.Next() = 0;

        // 2. Le contenu de chaque groupe (demandes par numéro croissant, comme le regroupement)
        foreach GroupKey in Keys do
            Groups.Add(BuildGroup(GroupKey, SameDay));
        Data.Add('groups', Groups);
        Data.Add('created', Created);
    end;

    // Clé du groupe = mêmes critères que SetGroupFilters (codeunit 90056)
    local procedure GetGroupKey(Request: Record "Sales Header"; SameDay: Boolean): Text
    var
        GroupKey: Text;
    begin
        GroupKey := Request."Sell-to Customer No." + '|' + Request."Bill-to Customer No." + '|' + Request."Ship-to Code" + '|' +
                    Request."Currency Code" + '|' + Format(Request."Prices Including VAT");
        if SameDay then
            GroupKey += '|' + Format(Request."Document Date", 0, 9);
        exit(GroupKey);
    end;

    local procedure BuildGroup(GroupKey: Text; SameDay: Boolean) GroupJson: JsonObject
    var
        Request: Record "Sales Header";
        Customer: Record Customer;
        GNCRequestGroupingMgt: Codeunit "GNC Request Grouping Mgt.";
        Requests: JsonArray;
        Bonus: JsonArray;
        ItemNos: List of [Code[20]];
        First: Boolean;
        OrderDate: Date;
    begin
        First := true;
        GNCRequestGroupingMgt.SetEligibleFilters(Request);
        Request.SetCurrentKey("Document Type", "No.");
        if Request.FindSet() then
            repeat
                if GetGroupKey(Request, SameDay) = GroupKey then begin
                    if First then begin
                        GroupJson.Add('key', GroupKey);
                        GroupJson.Add('customerNo', Request."Sell-to Customer No.");
                        GroupJson.Add('name', Request."Sell-to Customer Name");
                        if SameDay then
                            GroupJson.Add('dateText', Format(Request."Document Date"))
                        else
                            GroupJson.Add('dateText', AllDatesTxt);
                        if Customer.Get(Request."Sell-to Customer No.") then;
                        GroupJson.Add('gov', Customer."GNC Sector" = Customer."GNC Sector"::Government);
                        // La commande reprend la date de la 1re demande : c'est la date des règles bonus
                        OrderDate := Request."Order Date";
                        if OrderDate = 0D then
                            OrderDate := WorkDate();
                        First := false;
                    end;
                    Requests.Add(BuildRequest(Request, ItemNos));
                end;
            until Request.Next() = 0;
        GroupJson.Add('requests', Requests);

        BuildBonusRules(Customer."No.", ItemNos, OrderDate, Bonus);
        GroupJson.Add('bonus', Bonus);
    end;

    local procedure BuildRequest(Request: Record "Sales Header"; var ItemNos: List of [Code[20]]) RequestJson: JsonObject
    var
        RequestLine: Record "Sales Line";
        Salesperson: Record "Salesperson/Purchaser";
        GNCSalespersonPINMgt: Codeunit "GNC Salesperson PIN Mgt.";
        Lines: JsonArray;
        LineJson: JsonObject;
        SalespersonCode: Code[20];
    begin
        SalespersonCode := Request."GNC PIN Salesperson Code";
        if SalespersonCode = '' then
            SalespersonCode := Request."Salesperson Code";
        if Salesperson.Get(SalespersonCode) then;

        RequestLine.SetRange("Document Type", Request."Document Type");
        RequestLine.SetRange("Document No.", Request."No.");
        if RequestLine.FindSet() then
            repeat
                Clear(LineJson);
                if RequestLine.Type = RequestLine.Type::Item then
                    LineJson.Add('type', 'Item')
                else
                    LineJson.Add('type', 'Other');
                LineJson.Add('item', RequestLine."No.");
                LineJson.Add('desc', RequestLine.Description);
                LineJson.Add('qty', RequestLine.Quantity);
                LineJson.Add('uom', RequestLine."Unit of Measure Code");
                LineJson.Add('variant', RequestLine."Variant Code");
                LineJson.Add('location', RequestLine."Location Code");
                LineJson.Add('price', RequestLine."Unit Price");
                LineJson.Add('disc', RequestLine."Line Discount %");
                LineJson.Add('attached', RequestLine."Attached to Line No." <> 0);
                Lines.Add(LineJson);
                if (RequestLine.Type = RequestLine.Type::Item) and (RequestLine."No." <> '') and not ItemNos.Contains(RequestLine."No.") then
                    ItemNos.Add(RequestLine."No.");
            until RequestLine.Next() = 0;

        RequestJson.Add('no', Request."No.");
        RequestJson.Add('salesperson', SalespersonCode);
        RequestJson.Add('salespersonName', Salesperson.Name);
        RequestJson.Add('pin', GNCSalespersonPINMgt.IsSalespersonConfirmed(Request));
        RequestJson.Add('priority', Format(Request."GNC Delivery Priority"));
        RequestJson.Add('lines', Lines);
    end;

    // Règles bonus valables à la date de la commande pour les articles du groupe (lot 5).
    // La quantité minimum est vérifiée dans la page, sur la quantité cumulée.
    local procedure BuildBonusRules(CustomerNo: Code[20]; ItemNos: List of [Code[20]]; OrderDate: Date; var Bonus: JsonArray)
    var
        BonusSetup: Record "GNC Bonus Setup";
        GNCBonusMgt: Codeunit "GNC Bonus Mgt.";
        Rule: JsonObject;
        ItemNo: Code[20];
    begin
        foreach ItemNo in ItemNos do
            if GNCBonusMgt.FindBonusRule(CustomerNo, ItemNo, OrderDate, 999999999, BonusSetup) then begin
                Clear(Rule);
                Rule.Add('item', ItemNo);
                Rule.Add('qty', BonusSetup."Bonus Quantity");
                Rule.Add('min', BonusSetup."Minimum Quantity");
                Rule.Add('add', BonusSetup."Additional Discount %");
                Rule.Add('moh', BonusSetup."MOH Discount %");
                Bonus.Add(Rule);
            end;
    end;

    // Après « Create grouped order » : la commande créée (son Quote No. = 1re demande) et ses demandes
    procedure AddCreatedOrder(FirstRequestNo: Code[20]; var Created: JsonArray)
    var
        SalesHeader: Record "Sales Header";
        GroupedRequestLine: Record "GNC Grouped Request Line";
        CreatedJson: JsonObject;
        RequestNos: List of [Code[20]];
        RequestText: Text;
        RequestNo: Code[20];
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Quote No.", FirstRequestNo);
        if not SalesHeader.FindLast() then
            exit;
        GroupedRequestLine.SetRange("Order No.", SalesHeader."No.");
        if GroupedRequestLine.FindSet() then
            repeat
                if not RequestNos.Contains(GroupedRequestLine."Request No.") then
                    RequestNos.Add(GroupedRequestLine."Request No.");
            until GroupedRequestLine.Next() = 0;
        foreach RequestNo in RequestNos do begin
            if RequestText <> '' then
                RequestText += ', ';
            RequestText += RequestNo;
        end;
        CreatedJson.Add('order', SalesHeader."No.");
        CreatedJson.Add('customer', SalesHeader."Sell-to Customer Name");
        CreatedJson.Add('requests', RequestText);
        Created.Add(CreatedJson);
    end;
}
