// Lot 7 – Données de l'écran visuel du plan de livraison (page 90090, control add-in "GNC Delivery Plan View").
// Mêmes commandes que la liste "Delivery Plan" (90077) : Released, pas complètement expédiées.
// Pour chaque commande : lignes à expédier avec le stock du magasin, froid, bonus, demandes d'origine.
codeunit 90091 "GNC Delivery Plan Data"
{
    procedure BuildPlan() Data: JsonObject
    var
        Driver: Record "GNC Driver";
        SalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        GNCDeliveryMgt: Codeunit "GNC Delivery Mgt.";
        GNCUserLocationMgt: Codeunit "GNC User Location Mgt.";
        Drivers: JsonArray;
        Orders: JsonArray;
        Shipped: JsonArray;
        DriverJson: JsonObject;
        ShippedJson: JsonObject;
        ShippedCount: Integer;
    begin
        Data.Add('dateText', Format(WorkDate(), 0, '<Weekday Text> <Day> <Month Text> <Year4>'));
        Data.Add('location', GNCUserLocationMgt.GetUserLocation());

        // Chauffeurs actifs
        Driver.SetRange(Blocked, false);
        if Driver.FindSet() then
            repeat
                Clear(DriverJson);
                DriverJson.Add('code', Driver.Code);
                DriverJson.Add('name', Driver.Name);
                DriverJson.Add('vehicle', Driver.Vehicle);
                DriverJson.Add('fridge', Driver.Refrigerated);
                DriverJson.Add('cap', Driver."Vehicle Capacity");
                Drivers.Add(DriverJson);
            until Driver.Next() = 0;
        Data.Add('drivers', Drivers);

        // Commandes à livrer, les plus urgentes d'abord
        GNCDeliveryMgt.FixOldPrioritySort();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
        SalesHeader.SetRange("Completely Shipped", false);
        SalesHeader.SetCurrentKey("GNC Priority Sort");
        if SalesHeader.FindSet() then
            repeat
                Orders.Add(BuildOrder(SalesHeader));
            until SalesHeader.Next() = 0;
        Data.Add('orders', Orders);

        // Expéditions enregistrées aujourd'hui (date de travail), les 10 dernières
        SalesShipmentHeader.SetRange("Posting Date", WorkDate());
        SalesShipmentHeader.Ascending(false);
        if SalesShipmentHeader.FindSet() then
            repeat
                SalesShipmentHeader.CalcFields("GNC Driver Name");
                Clear(ShippedJson);
                ShippedJson.Add('no', SalesShipmentHeader."No.");
                ShippedJson.Add('customer', SalesShipmentHeader."Sell-to Customer Name");
                ShippedJson.Add('driver', SalesShipmentHeader."GNC Driver Name");
                Shipped.Add(ShippedJson);
                ShippedCount += 1;
            until (SalesShipmentHeader.Next() = 0) or (ShippedCount = 10);
        Data.Add('shipped', Shipped);
    end;

    local procedure BuildOrder(SalesHeader: Record "Sales Header") OrderJson: JsonObject
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
        Item: Record Item;
        GNCDeliveryMgt: Codeunit "GNC Delivery Mgt.";
        Lines: JsonArray;
        LineJson: JsonObject;
        RequestNos: List of [Code[20]];
        RequestText: Text;
        RequestNo: Code[20];
        Phone: Text;
        StockStyle: Text;
        Units: Decimal;
        HasCold: Boolean;
        HasBonus: Boolean;
    begin
        SalesHeader.CalcFields("Amount Including VAT");

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("Outstanding Quantity", '>0');
        if SalesLine.FindSet() then
            repeat
                Clear(LineJson);
                LineJson.Add('item', SalesLine."No.");
                LineJson.Add('desc', SalesLine.Description);
                LineJson.Add('qty', SalesLine."Outstanding Quantity");
                LineJson.Add('bonus', SalesLine."GNC Bonus Line");
                if Item.Get(SalesLine."No.") then begin
                    LineJson.Add('cold', Item."GNC Cold Chain");
                    HasCold := HasCold or Item."GNC Cold Chain";
                    // Stock du magasin de la ligne (vide pour un article sans stock, ex. service)
                    if Item.Type = Item.Type::Inventory then begin
                        Item.SetRange("Location Filter", SalesLine."Location Code");
                        Item.SetRange("Variant Filter", SalesLine."Variant Code");
                        Item.CalcFields(Inventory);
                        LineJson.Add('stock', Item.Inventory);
                    end;
                end;
                Lines.Add(LineJson);
                Units += SalesLine."Outstanding Quantity";
                HasBonus := HasBonus or SalesLine."GNC Bonus Line";
                if (SalesLine."GNC Request No." <> '') and not RequestNos.Contains(SalesLine."GNC Request No.") then
                    RequestNos.Add(SalesLine."GNC Request No.");
            until SalesLine.Next() = 0;
        foreach RequestNo in RequestNos do begin
            if RequestText <> '' then
                RequestText += ', ';
            RequestText += RequestNo;
        end;

        // Téléphone de livraison : adresse de livraison, sinon fiche client
        Phone := SalesHeader."Ship-to Phone No.";
        if Phone = '' then
            if Customer.Get(SalesHeader."Sell-to Customer No.") then
                Phone := Customer."Phone No.";

        OrderJson.Add('no', SalesHeader."No.");
        OrderJson.Add('customer', SalesHeader."Ship-to Name");
        OrderJson.Add('address', SalesHeader."Ship-to Address");
        OrderJson.Add('city', SalesHeader."Ship-to City");
        OrderJson.Add('phone', Phone);
        OrderJson.Add('priority', Format(SalesHeader."GNC Delivery Priority"));
        OrderJson.Add('driver', SalesHeader."GNC Driver Code");
        OrderJson.Add('stop', SalesHeader."GNC Stop No.");
        OrderJson.Add('requests', RequestText);
        OrderJson.Add('salesperson', SalesHeader."Salesperson Code");
        OrderJson.Add('amount', SalesHeader."Amount Including VAT");
        OrderJson.Add('units', Units);
        OrderJson.Add('cold', HasCold);
        OrderJson.Add('bonus', HasBonus);
        OrderJson.Add('stock', GNCDeliveryMgt.GetStockStatus(SalesHeader, StockStyle));
        OrderJson.Add('lines', Lines);
    end;

    // Chauffeur choisi dans l'écran (vide = retirer le chauffeur)
    procedure SetDriver(OrderNo: Text; DriverCode: Text)
    var
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, CopyStr(OrderNo, 1, MaxStrLen(SalesHeader."No."))) then
            exit;
        SalesHeader.Validate("GNC Driver Code", CopyStr(DriverCode, 1, MaxStrLen(SalesHeader."GNC Driver Code")));
        SalesHeader."GNC Stop No." := 0; // nouvelle tournée : l'ordre des arrêts est à refaire
        SalesHeader.Modify();
    end;
}
