report 50202 "NAV Non-Moving Stock"
{
    // Stock (item x location) with no movement - neither receipt nor issue -
    // since a number of days before the "as of" date, with quantity and value.
    Caption = 'Non-Moving Stock';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/NonMovingStock.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.") where(Type = const(Inventory));
            RequestFilterFields = "No.", "Location Filter", "Inventory Posting Group", "Item Category Code";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(AsOfDateText; Format(AsOfDate)) { }
            column(DaysText; Format(DaysWithoutMovement)) { }

            dataitem(Location; Location)
            {
                DataItemTableView = sorting(Code) where("Use As In-Transit" = const(false));

                column(Loc_Code; Code) { }
                column(Loc_Name; Name) { }
                column(Line_ItemNo; Item."No.") { }
                column(Line_Description; Item.Description) { }
                column(Line_BaseUoM; Item."Base Unit of Measure") { }
                column(Line_Qty; StockQty) { }
                column(Line_Value; StockValue) { }
                column(Line_LastReceipt; Format(LastReceiptDate)) { }
                column(Line_LastIssue; Format(LastIssueDate)) { }
                column(Line_Days; DaysSinceMovement) { }

                trigger OnPreDataItem()
                begin
                    if Item.GetFilter("Location Filter") <> '' then
                        SetFilter(Code, Item.GetFilter("Location Filter"));
                end;

                trigger OnAfterGetRecord()
                begin
                    if not CalcLine(Item."No.", Code) then
                        CurrReport.Skip();
                end;
            }

            trigger OnPreDataItem()
            begin
                if AsOfDate = 0D then
                    AsOfDate := WorkDate();
                if DaysWithoutMovement <= 0 then
                    DaysWithoutMovement := 90;
                CutOffDate := AsOfDate - DaysWithoutMovement;
                FilterText := Item.GetFilters();
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
                    field(DaysField; DaysWithoutMovement)
                    {
                        ApplicationArea = All;
                        Caption = 'Days Without Movement';
                        MinValue = 1;
                        ToolTip = 'Specifies how many days without any receipt or issue make a stock non-moving.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if AsOfDate = 0D then
                AsOfDate := WorkDate();
            if DaysWithoutMovement = 0 then
                DaysWithoutMovement := 90;
        end;
    }

    // Returns true when the item has stock at the location and no movement since the cut-off date
    local procedure CalcLine(ItemNo: Code[20]; LocationCode: Code[10]): Boolean
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        LastMovement: Date;
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", ItemNo);
        ItemLedgEntry.SetRange("Location Code", LocationCode);
        ItemLedgEntry.SetRange("Posting Date", 0D, AsOfDate);
        ItemLedgEntry.CalcSums(Quantity);
        StockQty := ItemLedgEntry.Quantity;
        if StockQty <= 0 then
            exit(false);

        LastReceiptDate := 0D;
        LastIssueDate := 0D;
        ItemLedgEntry.SetRange(Positive, true);
        if ItemLedgEntry.FindLast() then
            LastReceiptDate := ItemLedgEntry."Posting Date";
        ItemLedgEntry.SetRange(Positive, false);
        if ItemLedgEntry.FindLast() then
            LastIssueDate := ItemLedgEntry."Posting Date";

        LastMovement := LastReceiptDate;
        if LastIssueDate > LastMovement then
            LastMovement := LastIssueDate;
        if LastMovement > CutOffDate then
            exit(false);
        DaysSinceMovement := AsOfDate - LastMovement;

        ValueEntry.SetCurrentKey("Item No.");
        ValueEntry.SetRange("Item No.", ItemNo);
        ValueEntry.SetRange("Location Code", LocationCode);
        ValueEntry.SetRange("Valuation Date", 0D, AsOfDate);
        ValueEntry.CalcSums("Cost Amount (Actual)", "Cost Amount (Expected)");
        StockValue := ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)";
        exit(true);
    end;

    var
        AsOfDate: Date;
        CutOffDate: Date;
        LastReceiptDate: Date;
        LastIssueDate: Date;
        DaysWithoutMovement: Integer;
        DaysSinceMovement: Integer;
        StockQty: Decimal;
        StockValue: Decimal;
        FilterText: Text;
}
