codeunit 50240 "NAV Tablet Sales Line"
{
    // Business rules on sales lines (base unit of measure = TABLET):
    //  - Rules 2 and 4: a quantity entered in a "Whole Quantity Only" unit (TABLET)
    //    must be a whole number.
    //  - Rule 3: when a quantity entered in another unit (PACK) gives a decimal
    //    number of tablets, the configured rounding rule is applied.
    //  - Rule 11: the tablet price can be calculated from the pack price.

    // ---------------------------------------------------------------
    // Quantity checks (before the standard validation, so that the
    // standard rounding does not hide a decimal quantity)
    // ---------------------------------------------------------------
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Quantity', false, false)]
    local procedure CheckTabletQuantityOnBeforeValidateQuantity(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CheckAndRoundQuantity(Rec);
    end;

    procedure CheckAndRoundQuantity(var SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        LineUnit: Record "Item Unit of Measure";
        BaseUnit: Record "Item Unit of Measure";
        QtyPerUoM: Decimal;
        TabletQty: Decimal;
        RoundedTabletQty: Decimal;
        NewQuantity: Decimal;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        if (SalesLine."No." = '') or (SalesLine.Quantity = 0) then
            exit;
        if not Item.Get(SalesLine."No.") then
            exit;

        // Rules 2 and 4: whole quantity in a whole-quantity unit
        if LineUnit.Get(SalesLine."No.", SalesLine."Unit of Measure Code") then
            if LineUnit."Whole Quantity Only" then begin
                if SalesLine.Quantity <> Round(SalesLine.Quantity, 1) then
                    Error(WholeQuantityErr, SalesLine."Unit of Measure Code", SalesLine.Quantity, SalesLine."No.");
                exit;
            end;

        // Rule 3: quantity entered in another unit, converted into tablets
        if not BaseUnit.Get(SalesLine."No.", Item."Base Unit of Measure") then
            exit;
        if not BaseUnit."Whole Quantity Only" then
            exit;
        QtyPerUoM := LineUnit."Qty. per Unit of Measure";
        if QtyPerUoM = 0 then
            exit;

        TabletQty := SalesLine.Quantity * QtyPerUoM;
        if Abs(TabletQty - Round(TabletQty, 1)) <= 0.001 then
            exit; // already a whole number of tablets

        RoundedTabletQty := RoundTablets(TabletQty, Item.GetTabletRoundingMethod());
        if RoundedTabletQty = 0 then
            Error(RoundedToZeroErr, SalesLine.Quantity, SalesLine."Unit of Measure Code", TabletQty, Item."Base Unit of Measure");

        NewQuantity := Round(RoundedTabletQty / QtyPerUoM, 0.00001);
        if GuiAllowed() then
            Message(RoundedMsg,
                SalesLine.Quantity, SalesLine."Unit of Measure Code", TabletQty, Item."Base Unit of Measure",
                RoundedTabletQty, Item.GetTabletRoundingMethod(), NewQuantity);
        SalesLine.Quantity := NewQuantity;
    end;

    procedure RoundTablets(TabletQty: Decimal; RoundingMethod: Enum "NAV Tablet Rounding Method"): Decimal
    begin
        case RoundingMethod of
            RoundingMethod::Up:
                exit(Round(TabletQty, 1, '>'));
            RoundingMethod::Down:
                exit(Round(TabletQty, 1, '<'));
            else
                exit(Round(TabletQty, 1, '='));
        end;
    end;

    // ---------------------------------------------------------------
    // Rule 11: tablet price calculated from the pack price
    // ---------------------------------------------------------------
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterUpdateUnitPrice', '', false, false)]
    local procedure ApplyTabletPriceOnAfterUpdateUnitPrice(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CurrFieldNo: Integer)
    var
        Item: Record Item;
        TempPackLine: Record "Sales Line" temporary;
        PackQty: Decimal;
        TabletPrice: Decimal;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        if SalesLine."No." = '' then
            exit;
        if not Item.Get(SalesLine."No.") then
            exit;
        if Item."Tablet Price Method" <> Item."Tablet Price Method"::"From Pack Price" then
            exit;
        // Only for lines entered in the base unit (TABLET)
        if SalesLine."Unit of Measure Code" <> Item."Base Unit of Measure" then
            exit;
        PackQty := Item.GetPackQtyPerUoM();
        if PackQty = 0 then
            exit;

        // Standard price of one pack for the same customer, date, currency...
        TempPackLine := SalesLine;
        TempPackLine."Unit of Measure Code" := Item."Pack Unit of Measure";
        TempPackLine."Qty. per Unit of Measure" := PackQty;
        TempPackLine.Quantity := 1;
        TempPackLine."Quantity (Base)" := PackQty;
        TempPackLine.UpdateUnitPrice(CalledByFieldNo);
        if TempPackLine."Unit Price" = 0 then
            exit;

        TabletPrice := TempPackLine."Unit Price" / PackQty * (1 + Item."Tablet Price Markup %" / 100);
        TabletPrice := Round(TabletPrice, GetUnitAmountRoundingPrecision(SalesLine."Currency Code"));
        if TabletPrice <> SalesLine."Unit Price" then
            SalesLine.Validate("Unit Price", TabletPrice);
    end;

    local procedure GetUnitAmountRoundingPrecision(CurrencyCode: Code[10]): Decimal
    var
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
    begin
        if CurrencyCode <> '' then
            if Currency.Get(CurrencyCode) then
                if Currency."Unit-Amount Rounding Precision" <> 0 then
                    exit(Currency."Unit-Amount Rounding Precision");
        GLSetup.Get();
        if GLSetup."Unit-Amount Rounding Precision" <> 0 then
            exit(GLSetup."Unit-Amount Rounding Precision");
        exit(0.00001);
    end;

    var
        WholeQuantityErr: Label 'Tablet quantity must be a whole number. You entered %2 %1 for item %3; a fraction of a %1 cannot be sold.', Comment = '%1 = Unit of Measure, %2 = Quantity, %3 = Item No.';
        RoundedToZeroErr: Label '%1 %2 corresponds to %3 %4, which is rounded to zero. Enter a larger quantity.', Comment = '%1 = Quantity, %2 = Unit, %3 = Tablet quantity, %4 = Base unit';
        RoundedMsg: Label '%1 %2 corresponds to %3 %4. The quantity is rounded to %5 %4 (rounding method: %6), so the line quantity becomes %7 %2.', Comment = '%1 = Entered quantity, %2 = Unit, %3 = Tablet quantity, %4 = Base unit, %5 = Rounded tablet quantity, %6 = Rounding method, %7 = New quantity';
}
