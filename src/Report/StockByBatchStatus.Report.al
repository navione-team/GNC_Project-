report 50207 "NAV Stock by Batch Status"
{
    // Stock of every batch with its status (Available, Quarantine, Blocked, Expired),
    // by location, in tablets, packs and value, grouped by status.
    Caption = 'Stock by Batch Status';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/StockByBatchStatus.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ItemLedgEntry; "Item Ledger Entry")
        {
            DataItemTableView = sorting("Item No.", Open, "Variant Code", Positive, "Location Code") where(Open = const(true), Positive = const(true));
            RequestFilterFields = "Item No.", "Location Code";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(Bat_Status; StatusText) { }
            column(Bat_Location; "Location Code") { }
            column(Bat_ItemNo; "Item No.") { }
            column(Bat_Description; ItemDescription) { }
            column(Bat_LotNo; "Lot No.") { }
            column(Bat_Expiry; Format("Expiration Date")) { }
            column(Bat_QtyBase; "Remaining Quantity") { }
            column(Bat_Packs; Packs) { }
            column(Bat_Value; RemainingValue) { }

            trigger OnPreDataItem()
            begin
                SetFilter("Lot No.", '<>%1', '');
                FilterText := GetFilters();
            end;

            trigger OnAfterGetRecord()
            begin
                StatusText := Helper.GetLotStatusText("Item No.", "Variant Code", "Lot No.", "Expiration Date", WorkDate());
                if OnlyRestricted and (StatusText = AvailableTxt) then
                    CurrReport.Skip();
                ItemDescription := Helper.GetItemDescription("Item No.");
                Packs := Helper.ToPacks("Item No.", "Remaining Quantity");
                RemainingValue := Helper.GetRemainingValue(ItemLedgEntry);
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

                    field(OnlyRestrictedField; OnlyRestricted)
                    {
                        ApplicationArea = All;
                        Caption = 'Only Quarantine, Blocked and Expired';
                        ToolTip = 'Specifies that available batches are not listed.';
                    }
                }
            }
        }
    }

    trigger OnInitReport()
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        AvailableTxt := Format(LotNoInfo."Lot Status"::Available);
    end;

    var
        Helper: Codeunit "NAV Report Helper";
        OnlyRestricted: Boolean;
        AvailableTxt: Text;
        StatusText: Text;
        FilterText: Text;
        ItemDescription: Text[100];
        Packs: Decimal;
        RemainingValue: Decimal;
}
