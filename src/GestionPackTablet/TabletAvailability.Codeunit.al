codeunit 50241 "NAV Tablet Availability"
{
    // Rule 16: a sales order (or invoice) cannot be released when it asks for more
    // tablets than available.
    // Available = inventory on hand (location / variant)
    //             - quantity of expired, quarantined and blocked batches
    //             - outstanding quantity of the other RELEASED sales orders.
    // Posting is also protected by the standard "Prevent Negative Inventory".

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    local procedure CheckAvailabilityOnBeforeRelease(var SalesHeader: Record "Sales Header")
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice]) then
            exit;
        SalesSetup.Get();
        if not SalesSetup."Check Tablet Availability" then
            exit;
        CheckSalesDocument(SalesHeader);
    end;

    procedure CheckSalesDocument(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        Requested: Dictionary of [Text, Decimal];
        LineKey: Text;
        ErrorText: Text;
        Qty: Decimal;
    begin
        // Requested quantity (base = tablets) per item / variant / location
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("Drop Shipment", false);
        SalesLine.SetFilter("Outstanding Qty. (Base)", '>0');
        if not SalesLine.FindSet() then
            exit;
        repeat
            LineKey := BuildKey(SalesLine."No.", SalesLine."Variant Code", SalesLine."Location Code");
            if Requested.Get(LineKey, Qty) then
                Requested.Set(LineKey, Qty + SalesLine."Outstanding Qty. (Base)")
            else
                Requested.Add(LineKey, SalesLine."Outstanding Qty. (Base)");
        until SalesLine.Next() = 0;

        foreach LineKey in Requested.Keys() do
            CheckKey(LineKey, Requested.Get(LineKey), SalesHeader, ErrorText);

        if ErrorText <> '' then
            Error(NotAvailableErr, SalesHeader."No.", ErrorText);
    end;

    local procedure CheckKey(LineKey: Text; RequestedQty: Decimal; SalesHeader: Record "Sales Header"; var ErrorText: Text)
    var
        Item: Record Item;
        Parts: List of [Text];
        ItemNo: Code[20];
        VariantCode: Code[10];
        LocationCode: Code[10];
        AvailableQty: Decimal;
        LotManagement: Codeunit "NAV Lot Management";
    begin
        Parts := LineKey.Split('|');
        ItemNo := CopyStr(Parts.Get(1), 1, MaxStrLen(ItemNo));
        VariantCode := CopyStr(Parts.Get(2), 1, MaxStrLen(VariantCode));
        LocationCode := CopyStr(Parts.Get(3), 1, MaxStrLen(LocationCode));

        if not Item.Get(ItemNo) then
            exit;
        if Item.Type <> Item.Type::Inventory then
            exit;

        Item.SetRange("Location Filter", LocationCode);
        Item.SetRange("Variant Filter", VariantCode);
        Item.CalcFields(Inventory);
        // Rule 19: expired, quarantined and blocked batches are not available
        AvailableQty := Item.Inventory
            - LotManagement.GetUnusableQty(ItemNo, VariantCode, LocationCode)
            - GetOtherReleasedQty(ItemNo, VariantCode, LocationCode, SalesHeader);

        if RequestedQty <= AvailableQty then
            exit;

        if ErrorText <> '' then
            ErrorText += '\';
        if Item.GetPackQtyPerUoM() <> 0 then
            ErrorText += StrSubstNo(ItemLineWithPackTxt,
                ItemNo, Item.Description, RequestedQty, Item."Base Unit of Measure", Item.ToPacks(RequestedQty),
                Item."Pack Unit of Measure", AvailableQty, Item.ToPacks(AvailableQty), LocationCode)
        else
            ErrorText += StrSubstNo(ItemLineTxt,
                ItemNo, Item.Description, RequestedQty, Item."Base Unit of Measure", AvailableQty, LocationCode);
    end;

    // Outstanding base quantity of the other released sales orders
    local procedure GetOtherReleasedQty(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; SalesHeader: Record "Sales Header"): Decimal
    var
        OtherLine: Record "Sales Line";
        OtherHeader: Record "Sales Header";
        Total: Decimal;
    begin
        OtherLine.SetRange("Document Type", OtherLine."Document Type"::Order);
        OtherLine.SetRange(Type, OtherLine.Type::Item);
        OtherLine.SetRange("No.", ItemNo);
        OtherLine.SetRange("Variant Code", VariantCode);
        OtherLine.SetRange("Location Code", LocationCode);
        OtherLine.SetRange("Drop Shipment", false);
        OtherLine.SetFilter("Outstanding Qty. (Base)", '>0');
        if OtherLine.FindSet() then
            repeat
                if not ((OtherLine."Document Type" = SalesHeader."Document Type") and (OtherLine."Document No." = SalesHeader."No.")) then
                    if OtherHeader.Get(OtherLine."Document Type", OtherLine."Document No.") then
                        if OtherHeader.Status = OtherHeader.Status::Released then
                            Total += OtherLine."Outstanding Qty. (Base)";
            until OtherLine.Next() = 0;
        exit(Total);
    end;

    local procedure BuildKey(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]): Text
    begin
        exit(ItemNo + '|' + VariantCode + '|' + LocationCode);
    end;

    var
        NotAvailableErr: Label 'Sales document %1 cannot be released because the available inventory is not sufficient:\%2', Comment = '%1 = Document No., %2 = list of items';
        ItemLineWithPackTxt: Label '- %1 %2: requested %3 %4 (%5 %6), available %7 %4 (%8 %6) at location ''%9''', Comment = '%1 = Item No., %2 = Description, %3 = Requested qty, %4 = Base unit, %5 = Requested packs, %6 = Pack unit, %7 = Available qty, %8 = Available packs, %9 = Location';
        ItemLineTxt: Label '- %1 %2: requested %3 %4, available %5 %4 at location ''%6''', Comment = '%1 = Item No., %2 = Description, %3 = Requested qty, %4 = Base unit, %5 = Available qty, %6 = Location';
}
