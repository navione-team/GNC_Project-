report 50211 "NAV Stock Coverage"
{
    // Days of stock per item and location: stock / average daily sales of the last
    // N months, with a status (Out of Stock, Below Threshold, OK, No Sales).
    Caption = 'Stock Coverage';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/StockCoverage.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.") where(Type = const(Inventory));
            RequestFilterFields = "No.", "Location Filter", "Inventory Posting Group";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(SubtitleText; SubtitleText) { }

            dataitem(Location; Location)
            {
                DataItemTableView = sorting(Code) where("Use As In-Transit" = const(false));

                column(Cov_Location; Code) { }
                column(Cov_ItemNo; Item."No.") { }
                column(Cov_Description; Item.Description) { }
                column(Cov_StockBase; StockQty) { }
                column(Cov_StockPacks; Item.ToPacks(StockQty)) { }
                column(Cov_SalesQty; SalesQty) { }
                column(Cov_AvgMonthly; AvgMonthlySales) { }
                column(Cov_Days; CoverageDays) { }
                column(Cov_Status; StatusText) { }
                column(Cov_StatusSort; StatusSort) { }

                trigger OnPreDataItem()
                begin
                    if Item.GetFilter("Location Filter") <> '' then
                        SetFilter(Code, Item.GetFilter("Location Filter"));
                end;

                trigger OnAfterGetRecord()
                begin
                    if not CalcCoverage(Item."No.", Code) then
                        CurrReport.Skip();
                    if OnlyAlerts and (StatusSort >= 2) then
                        CurrReport.Skip();
                end;
            }

            trigger OnPreDataItem()
            begin
                if AsOfDate = 0D then
                    AsOfDate := WorkDate();
                if SalesMonths <= 0 then
                    SalesMonths := 3;
                if ThresholdDays <= 0 then
                    ThresholdDays := 30;
                StartDate := CalcDate(StrSubstNo('<-%1M>', SalesMonths), AsOfDate) + 1;
                PeriodDays := AsOfDate - StartDate + 1;
                FilterText := GetFilters();
                SubtitleText := StrSubstNo(SubtitleTxt, AsOfDate, StartDate, ThresholdDays);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(AsOfDateField; AsOfDate)
                    {
                        ApplicationArea = All;
                        Caption = 'As of Date';
                        ToolTip = 'Specifies the date of the stock situation.';
                    }
                    field(SalesMonthsField; SalesMonths)
                    {
                        ApplicationArea = All;
                        Caption = 'Sales History (Months)';
                        MinValue = 1;
                        ToolTip = 'Specifies how many months of sales are used to calculate the average consumption.';
                    }
                    field(ThresholdDaysField; ThresholdDays)
                    {
                        ApplicationArea = All;
                        Caption = 'Alert Threshold (Days)';
                        MinValue = 1;
                        ToolTip = 'Specifies the coverage in days below which the item is flagged.';
                    }
                    field(OnlyAlertsField; OnlyAlerts)
                    {
                        ApplicationArea = All;
                        Caption = 'Only Alerts';
                        ToolTip = 'Specifies that only out-of-stock and below-threshold items are listed.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if AsOfDate = 0D then
                AsOfDate := WorkDate();
            if SalesMonths = 0 then
                SalesMonths := 3;
            if ThresholdDays = 0 then
                ThresholdDays := 30;
        end;
    }

    local procedure CalcCoverage(ItemNo: Code[20]; LocationCode: Code[10]): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        AvgDaily: Decimal;
    begin
        StockQty := Helper.GetStockQty(ItemNo, LocationCode, AsOfDate);

        ItemLedgEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", ItemNo);
        ItemLedgEntry.SetRange("Location Code", LocationCode);
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Sale);
        ItemLedgEntry.SetRange("Posting Date", StartDate, AsOfDate);
        ItemLedgEntry.CalcSums(Quantity);
        SalesQty := -ItemLedgEntry.Quantity;

        if (StockQty <= 0) and (SalesQty <= 0) then
            exit(false);

        AvgDaily := 0;
        if PeriodDays > 0 then
            AvgDaily := SalesQty / PeriodDays;
        AvgMonthlySales := Round(SalesQty / SalesMonths, 0.01);
        CoverageDays := 0;
        if AvgDaily > 0 then
            CoverageDays := Round(StockQty / AvgDaily, 1);

        case true of
            (StockQty <= 0) and (SalesQty > 0):
                begin
                    StatusText := OutOfStockTxt;
                    StatusSort := 0;
                end;
            (SalesQty > 0) and (CoverageDays < ThresholdDays):
                begin
                    StatusText := BelowThresholdTxt;
                    StatusSort := 1;
                end;
            SalesQty > 0:
                begin
                    StatusText := OKTxt;
                    StatusSort := 2;
                end;
            else begin
                StatusText := NoSalesTxt;
                StatusSort := 3;
            end;
        end;
        exit(true);
    end;

    var
        Helper: Codeunit "NAV Report Helper";
        AsOfDate: Date;
        StartDate: Date;
        SalesMonths: Integer;
        ThresholdDays: Integer;
        PeriodDays: Integer;
        StatusSort: Integer;
        OnlyAlerts: Boolean;
        StockQty: Decimal;
        SalesQty: Decimal;
        AvgMonthlySales: Decimal;
        CoverageDays: Decimal;
        StatusText: Text;
        FilterText: Text;
        SubtitleText: Text;
        SubtitleTxt: Label 'Stock as of %1, average sales since %2, alert below %3 days of coverage', Comment = '%1 = date, %2 = start date, %3 = days';
        OutOfStockTxt: Label 'Out of Stock';
        BelowThresholdTxt: Label 'Below Threshold';
        OKTxt: Label 'OK';
        NoSalesTxt: Label 'No Sales';
}
