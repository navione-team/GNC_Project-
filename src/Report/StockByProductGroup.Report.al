report 50209 "NAV Stock by Product Group"
{
    // Stock in tablets, packs and value by Product Group and Item Family
    // (GNC item fields "Product Group Code" and "Item Family Code").
    Caption = 'Stock by Product Group / Item Family';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/StockByProductGroup.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.") where(Type = const(Inventory));
            RequestFilterFields = "No.", "Product Group Code", "Item Family Code", "Location Filter";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(SubtitleText; StrSubstNo(SubtitleTxt, AsOfDate)) { }
            column(Grp_ProductGroup; "Product Group Code") { }
            column(Grp_ItemFamily; "Item Family Code") { }
            column(Grp_ItemNo; "No.") { }
            column(Grp_Description; Description) { }
            column(Grp_BaseUoM; "Base Unit of Measure") { }
            column(Grp_QtyBase; StockQty) { }
            column(Grp_Packs; Packs) { }
            column(Grp_Value; StockValue) { }

            trigger OnPreDataItem()
            begin
                if AsOfDate = 0D then
                    AsOfDate := WorkDate();
                FilterText := GetFilters();
                SetRange("Date Filter", 0D, AsOfDate);
            end;

            trigger OnAfterGetRecord()
            begin
                CalcFields("Net Change");
                StockQty := "Net Change";
                StockValue := Helper.GetStockValue("No.", GetFilter("Location Filter"), AsOfDate);
                if (StockQty = 0) and (StockValue = 0) then
                    CurrReport.Skip();
                Packs := ToPacks(StockQty);
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
                }
            }
        }

        trigger OnOpenPage()
        begin
            if AsOfDate = 0D then
                AsOfDate := WorkDate();
        end;
    }

    var
        Helper: Codeunit "NAV Report Helper";
        AsOfDate: Date;
        FilterText: Text;
        StockQty: Decimal;
        StockValue: Decimal;
        Packs: Decimal;
        SubtitleTxt: Label 'Stock as of %1', Comment = '%1 = date';
}
