report 50206 "NAV Batch Recall"
{
    // Full traceability of one batch for a recall: receipts (vendor), current stock
    // by location, and every delivery to customers.
    Caption = 'Batch Recall / Traceability';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/BatchRecall.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Header; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(Hdr_ItemNo; ItemNo) { }
            column(Hdr_Description; Helper.GetItemDescription(ItemNo)) { }
            column(Hdr_LotNo; LotNo) { }
            column(Hdr_Expiry; Format(ExpirationDate)) { }
            column(Hdr_MfgDate; Format(ManufacturingDate)) { }
            column(Hdr_Status; Helper.GetLotStatusText(ItemNo, '', LotNo, ExpirationDate, WorkDate())) { }
            column(Hdr_Received; TotalReceived) { }
            column(Hdr_Delivered; TotalDelivered) { }
            column(Hdr_InStock; TotalInStock) { }
            column(Hdr_Customers; CustomerCount) { }

            trigger OnPreDataItem()
            begin
                if (ItemNo = '') or (LotNo = '') then
                    Error(ItemLotRequiredErr);
                FilterText := StrSubstNo(FilterTxt, ItemNo, LotNo);
                CalcHeader();
            end;
        }

        // Receipts of the batch (from vendors)
        dataitem(Receipt; "Item Ledger Entry")
        {
            DataItemTableView = sorting("Item No.", "Posting Date") where("Entry Type" = const(Purchase), Positive = const(true));

            column(Rcv_Date; Format("Posting Date")) { }
            column(Rcv_DocNo; "Document No.") { }
            column(Rcv_VendorNo; "Source No.") { }
            column(Rcv_VendorName; Helper.GetVendorName("Source No.")) { }
            column(Rcv_Location; "Location Code") { }
            column(Rcv_Qty; Quantity) { }

            trigger OnPreDataItem()
            begin
                SetRange("Item No.", ItemNo);
                SetRange("Lot No.", LotNo);
            end;
        }

        // Current stock of the batch
        dataitem(Stock; "Item Ledger Entry")
        {
            DataItemTableView = sorting("Item No.", Open, "Variant Code", Positive, "Location Code") where(Open = const(true), Positive = const(true));

            column(Stk_Location; "Location Code") { }
            column(Stk_EntryType; Format("Entry Type")) { }
            column(Stk_DocNo; "Document No.") { }
            column(Stk_Qty; "Remaining Quantity") { }

            trigger OnPreDataItem()
            begin
                SetRange("Item No.", ItemNo);
                SetRange("Lot No.", LotNo);
            end;
        }

        // Deliveries to customers
        dataitem(Delivery; "Item Ledger Entry")
        {
            DataItemTableView = sorting("Item No.", "Posting Date") where("Entry Type" = const(Sale));

            column(Shp_Date; Format("Posting Date")) { }
            column(Shp_DocNo; "Document No.") { }
            column(Shp_CustomerNo; "Source No.") { }
            column(Shp_CustomerName; Helper.GetCustomerName("Source No.")) { }
            column(Shp_Location; "Location Code") { }
            column(Shp_Qty; -Quantity) { }

            trigger OnPreDataItem()
            begin
                SetRange("Item No.", ItemNo);
                SetRange("Lot No.", LotNo);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Batch';

                    field(ItemNoField; ItemNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Item No.';
                        TableRelation = Item;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the item of the batch to trace.';
                    }
                    field(LotNoField; LotNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Batch No. (Lot No.)';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the batch to trace.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            LotNoInfo: Record "Lot No. Information";
                        begin
                            LotNoInfo.SetRange("Item No.", ItemNo);
                            if Page.RunModal(0, LotNoInfo) = Action::LookupOK then begin
                                Text := LotNoInfo."Lot No.";
                                exit(true);
                            end;
                        end;
                    }
                }
            }
        }
    }

    local procedure CalcHeader()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        LotNoInfo: Record "Lot No. Information";
        Customers: List of [Code[20]];
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", ItemNo);
        ItemLedgEntry.SetRange("Lot No.", LotNo);
        ExpirationDate := 0D;
        ManufacturingDate := 0D;
        if ItemLedgEntry.FindSet() then
            repeat
                if (ExpirationDate = 0D) and (ItemLedgEntry."Expiration Date" <> 0D) then
                    ExpirationDate := ItemLedgEntry."Expiration Date";
                if (ManufacturingDate = 0D) and (ItemLedgEntry."Warranty Date" <> 0D) then
                    ManufacturingDate := ItemLedgEntry."Warranty Date";
                if (ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Purchase) and ItemLedgEntry.Positive then
                    TotalReceived += ItemLedgEntry.Quantity;
                if ItemLedgEntry."Entry Type" = ItemLedgEntry."Entry Type"::Sale then begin
                    TotalDelivered -= ItemLedgEntry.Quantity;
                    if not Customers.Contains(ItemLedgEntry."Source No.") then
                        Customers.Add(ItemLedgEntry."Source No.");
                end;
                if ItemLedgEntry.Open and ItemLedgEntry.Positive then
                    TotalInStock += ItemLedgEntry."Remaining Quantity";
            until ItemLedgEntry.Next() = 0;
        CustomerCount := Customers.Count();
        if LotNoInfo.Get(ItemNo, '', LotNo) then
            if LotNoInfo."Manufacturing Date" <> 0D then
                ManufacturingDate := LotNoInfo."Manufacturing Date";
    end;

    var
        Helper: Codeunit "NAV Report Helper";
        ItemNo: Code[20];
        LotNo: Code[50];
        ExpirationDate: Date;
        ManufacturingDate: Date;
        TotalReceived: Decimal;
        TotalDelivered: Decimal;
        TotalInStock: Decimal;
        CustomerCount: Integer;
        FilterText: Text;
        ItemLotRequiredErr: Label 'Enter the item number and the batch number to trace.';
        FilterTxt: Label 'Item %1, batch %2', Comment = '%1 = Item No., %2 = Lot No.';
}
