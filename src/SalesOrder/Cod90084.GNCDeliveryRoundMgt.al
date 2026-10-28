// Lot 7 – Tournée de livraison = les commandes du plan de livraison (Released, pas complètement expédiées)
// d'un même chauffeur pour une même date d'expédition. Prépare les données envoyées à la carte
// (control add-in "GNC Delivery Map") et enregistre l'ordre des arrêts choisi sur la carte.
codeunit 90084 "GNC Delivery Round Mgt."
{
    var
        DefaultWarehouseNameTxt: Label 'GNC Warehouse';
        SequenceSavedMsg: Label 'The stop sequence of %1 order(s) has been saved.', Comment = '%1 = number of orders';

    // Commandes de la tournée
    procedure SetRoundFilters(var SalesHeader: Record "Sales Header"; DriverCode: Code[20]; RoundDate: Date)
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
        SalesHeader.SetRange("Completely Shipped", false);
        SalesHeader.SetRange("GNC Driver Code", DriverCode);
        SalesHeader.SetRange("Shipment Date", RoundDate);
    end;

    // Données JSON de la tournée pour la carte
    procedure BuildRoundData(DriverCode: Code[20]; RoundDate: Date) Data: JsonObject
    var
        Driver: Record "GNC Driver";
        GNCSalesSetup: Record "GNC Sales Setup";
        SalesHeader: Record "Sales Header";
        Warehouse: JsonObject;
        Stops: JsonArray;
        StartTime: Time;
        Speed: Decimal;
    begin
        GNCSalesSetup.GetSetup();
        if Driver.Get(DriverCode) then;

        Data.Add('driverName', Driver.Name);
        Data.Add('vehicle', Driver.Vehicle);
        Data.Add('capacity', Driver."Vehicle Capacity");
        Data.Add('refrigerated', Driver.Refrigerated);
        Data.Add('date', Format(RoundDate));

        // Départ : heure du paramétrage, 06:30 par défaut
        StartTime := GNCSalesSetup."Round Start Time";
        if StartTime = 0T then
            StartTime := 063000T;
        Data.Add('startMinutes', (StartTime - 000000T) div 60000);
        Speed := GNCSalesSetup."Average Speed (km/h)";
        if Speed <= 0 then
            Speed := 28;
        Data.Add('speed', Speed);

        // Dépôt : position du paramétrage, 2nd Industrial City (Riyad) par défaut
        Warehouse.Add('name', DefaultWarehouseNameTxt);
        if (GNCSalesSetup."Warehouse Latitude" = 0) and (GNCSalesSetup."Warehouse Longitude" = 0) then begin
            Warehouse.Add('lat', 24.5860);
            Warehouse.Add('lng', 46.8560);
        end else begin
            Warehouse.Add('lat', GNCSalesSetup."Warehouse Latitude");
            Warehouse.Add('lng', GNCSalesSetup."Warehouse Longitude");
        end;
        Data.Add('warehouse', Warehouse);

        SetRoundFilters(SalesHeader, DriverCode, RoundDate);
        if DriverCode <> '' then
            if SalesHeader.FindSet() then
                repeat
                    Stops.Add(BuildStop(SalesHeader));
                until SalesHeader.Next() = 0;
        Data.Add('stops', Stops);
    end;

    local procedure BuildStop(SalesHeader: Record "Sales Header") Stop: JsonObject
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        Latitude: Decimal;
        Longitude: Decimal;
        Units: Decimal;
        ColdUnits: Decimal;
    begin
        // Position : adresse de livraison si elle a une position, sinon la fiche client
        if SalesHeader."Ship-to Code" <> '' then
            if ShipToAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code") then begin
                Latitude := ShipToAddress."GNC Latitude";
                Longitude := ShipToAddress."GNC Longitude";
            end;
        if (Latitude = 0) and (Longitude = 0) then
            if Customer.Get(SalesHeader."Sell-to Customer No.") then begin
                Latitude := Customer."GNC Latitude";
                Longitude := Customer."GNC Longitude";
            end;

        // Quantités à livrer (articles) et part « froid »
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                Units += SalesLine."Outstanding Quantity";
                if Item.Get(SalesLine."No.") then
                    if Item."GNC Cold Chain" then
                        ColdUnits += SalesLine."Outstanding Quantity";
            until SalesLine.Next() = 0;

        Stop.Add('orderNo', SalesHeader."No.");
        Stop.Add('customer', SalesHeader."Ship-to Name");
        Stop.Add('address', SalesHeader."Ship-to Address");
        Stop.Add('city', SalesHeader."Ship-to City");
        Stop.Add('priority', Format(SalesHeader."GNC Delivery Priority"));
        Stop.Add('lat', Latitude);
        Stop.Add('lng', Longitude);
        Stop.Add('units', Units);
        Stop.Add('coldUnits', ColdUnits);
        Stop.Add('stopNo', SalesHeader."GNC Stop No.");
    end;

    // Ordre choisi sur la carte : "101033,101032,..." → Stop No. 1, 2, ... sur les commandes
    procedure SaveSequence(OrderNos: Text)
    var
        SalesHeader: Record "Sales Header";
        OrderNo: Text;
        StopNo: Integer;
    begin
        foreach OrderNo in OrderNos.Split(',') do
            if OrderNo <> '' then
                if SalesHeader.Get(SalesHeader."Document Type"::Order, CopyStr(OrderNo, 1, MaxStrLen(SalesHeader."No."))) then begin
                    StopNo += 1;
                    SalesHeader."GNC Stop No." := StopNo;
                    SalesHeader.Modify();
                end;
        Message(SequenceSavedMsg, StopNo);
    end;
}
