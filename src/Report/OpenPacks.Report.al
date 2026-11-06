report 50210 "NAV Open Packs"
{
    // Items whose stock at a location is not a whole number of packs:
    // full packs + loose tablets (opened boxes), to be sold first.
    Caption = 'Open Packs (Loose Tablets)';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/OpenPacks.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.") where(Type = const(Inventory), "Pack Unit of Measure" = filter(<> ''));
            RequestFilterFields = "No.", "Location Filter";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }

            dataitem(Location; Location)
            {
                DataItemTableView = sorting(Code) where("Use As In-Transit" = const(false));

                column(Opn_Location; Code) { }
                column(Opn_ItemNo; Item."No.") { }
                column(Opn_Description; Item.Description) { }
                column(Opn_PackUoM; Item."Pack Unit of Measure") { }
                column(Opn_PerPack; PackQty) { }
                column(Opn_StockBase; StockQty) { }
                column(Opn_FullPacks; FullPacks) { }
                column(Opn_Loose; LooseQty) { }

                trigger OnPreDataItem()
                begin
                    if Item.GetFilter("Location Filter") <> '' then
                        SetFilter(Code, Item.GetFilter("Location Filter"));
                end;

                trigger OnAfterGetRecord()
                begin
                    StockQty := Helper.GetStockQty(Item."No.", Code, WorkDate());
                    if StockQty <= 0 then
                        CurrReport.Skip();
                    FullPacks := Round(StockQty / PackQty, 1, '<');
                    LooseQty := StockQty - FullPacks * PackQty;
                    if LooseQty <= 0 then
                        CurrReport.Skip();
                end;
            }

            trigger OnPreDataItem()
            begin
                FilterText := GetFilters();
            end;

            trigger OnAfterGetRecord()
            begin
                PackQty := GetPackQtyPerUoM();
                if PackQty <= 1 then
                    CurrReport.Skip();
            end;
        }
    }

    var
        Helper: Codeunit "NAV Report Helper";
        FilterText: Text;
        PackQty: Decimal;
        StockQty: Decimal;
        FullPacks: Decimal;
        LooseQty: Decimal;
}
