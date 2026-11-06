report 50208 "NAV Expired Stock Destruction"
{
    // Expired batches still in stock, by location, with quantity and value,
    // and a signature block for the destruction committee.
    Caption = 'Expired Stock for Destruction';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/ExpiredStockDestruction.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ItemLedgEntry; "Item Ledger Entry")
        {
            DataItemTableView = sorting("Item No.", Open, "Variant Code", Positive, "Location Code") where(Open = const(true), Positive = const(true));
            RequestFilterFields = "Location Code", "Item No.";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(SubtitleText; StrSubstNo(SubtitleTxt, AsOfDate)) { }
            column(Des_Location; "Location Code") { }
            column(Des_ItemNo; "Item No.") { }
            column(Des_Description; ItemDescription) { }
            column(Des_LotNo; "Lot No.") { }
            column(Des_Expiry; Format("Expiration Date")) { }
            column(Des_DaysExpired; AsOfDate - "Expiration Date") { }
            column(Des_QtyBase; "Remaining Quantity") { }
            column(Des_Packs; Packs) { }
            column(Des_Value; RemainingValue) { }

            trigger OnPreDataItem()
            begin
                if AsOfDate = 0D then
                    AsOfDate := WorkDate();
                SetFilter("Lot No.", '<>%1', '');
                SetFilter("Expiration Date", '<>%1&..%2', 0D, AsOfDate);
                FilterText := GetFilters();
            end;

            trigger OnAfterGetRecord()
            begin
                ItemDescription := Helper.GetItemDescription("Item No.");
                Packs := Helper.ToPacks("Item No.", "Remaining Quantity");
                RemainingValue := Helper.GetRemainingValue(ItemLedgEntry);
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
                    Caption = 'Options';

                    field(AsOfDateField; AsOfDate)
                    {
                        ApplicationArea = All;
                        Caption = 'As of Date';
                        ToolTip = 'Specifies the reference date: batches with an expiry date on or before this date are listed.';
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
        ItemDescription: Text[100];
        Packs: Decimal;
        RemainingValue: Decimal;
        SubtitleTxt: Label 'Expired stock as of %1 proposed for destruction', Comment = '%1 = date';
}
