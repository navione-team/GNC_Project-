codeunit 50290 "NAV Report Helper"
{
    // Shared calculations for the GNC purchase and stock reports.

    // Remaining value (LCY) of an open item ledger entry
    procedure GetRemainingValue(var ItemLedgEntry: Record "Item Ledger Entry"): Decimal
    begin
        if ItemLedgEntry.Quantity = 0 then
            exit(0);
        ItemLedgEntry.CalcFields("Cost Amount (Actual)", "Cost Amount (Expected)");
        exit(Round((ItemLedgEntry."Cost Amount (Actual)" + ItemLedgEntry."Cost Amount (Expected)") *
            ItemLedgEntry."Remaining Quantity" / ItemLedgEntry.Quantity));
    end;

    // Base quantity (tablets) converted into packs; 0 when the item has no pack unit
    procedure ToPacks(ItemNo: Code[20]; BaseQty: Decimal): Decimal
    var
        Item: Record Item;
    begin
        if not Item.Get(ItemNo) then
            exit(0);
        exit(Item.ToPacks(BaseQty));
    end;

    // Batch status: Lot Status of the batch card; an Available batch past its expiry date is shown as Expired
    procedure GetLotStatusText(ItemNo: Code[20]; VariantCode: Code[10]; LotNo: Code[50]; ExpirationDate: Date; AsOfDate: Date): Text
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        if LotNoInfo.Get(ItemNo, VariantCode, LotNo) then begin
            if (LotNoInfo."Lot Status" = LotNoInfo."Lot Status"::Available) and IsExpired(ExpirationDate, AsOfDate) then
                exit(Format(LotNoInfo."Lot Status"::Expired));
            exit(Format(LotNoInfo."Lot Status"));
        end;
        if IsExpired(ExpirationDate, AsOfDate) then
            exit(Format(LotNoInfo."Lot Status"::Expired));
        exit(Format(LotNoInfo."Lot Status"::Available));
    end;

    procedure IsExpired(ExpirationDate: Date; AsOfDate: Date): Boolean
    begin
        exit((ExpirationDate <> 0D) and (ExpirationDate <= AsOfDate));
    end;

    // Stock (base) of an item at a location on a date
    procedure GetStockQty(ItemNo: Code[20]; LocationCode: Code[10]; AsOfDate: Date): Decimal
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", ItemNo);
        ItemLedgEntry.SetRange("Location Code", LocationCode);
        ItemLedgEntry.SetRange("Posting Date", 0D, AsOfDate);
        ItemLedgEntry.CalcSums(Quantity);
        exit(ItemLedgEntry.Quantity);
    end;

    // Stock value (LCY) of an item, optionally at one location, on a date
    procedure GetStockValue(ItemNo: Code[20]; LocationFilter: Text; AsOfDate: Date): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetCurrentKey("Item No.");
        ValueEntry.SetRange("Item No.", ItemNo);
        if LocationFilter <> '' then
            ValueEntry.SetFilter("Location Code", LocationFilter);
        ValueEntry.SetRange("Valuation Date", 0D, AsOfDate);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Cost Amount (Expected)");
        exit(ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)");
    end;

    procedure GetCustomerName(CustomerNo: Code[20]): Text[100]
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then
            exit(Customer.Name);
        exit('');
    end;

    procedure GetVendorName(VendorNo: Code[20]): Text[100]
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(VendorNo) then
            exit(Vendor.Name);
        exit('');
    end;

    procedure GetItemDescription(ItemNo: Code[20]): Text[100]
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then
            exit(Item.Description);
        exit('');
    end;
}
