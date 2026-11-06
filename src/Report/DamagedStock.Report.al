report 50203 "NAV Damaged Stock"
{
    // 1. Current stock in the damaged bins of each location, with its value.
    // 2. Damage transfers posted in the period (date, reason, user, batch, bins).
    Caption = 'Damaged Stock';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/DamagedStock.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Location; Location)
        {
            DataItemTableView = sorting(Code) where("Use As In-Transit" = const(false));
            RequestFilterFields = Code;

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(ShowHistory; ShowHistoryInt) { }

            dataitem(BinContent; "Bin Content")
            {
                DataItemLink = "Location Code" = field(Code);
                DataItemTableView = sorting("Location Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code");

                column(Bin_Location; "Location Code") { }
                column(Bin_Zone; "Zone Code") { }
                column(Bin_Code; "Bin Code") { }
                column(Bin_ItemNo; "Item No.") { }
                column(Bin_Description; ItemDescription) { }
                column(Bin_UoM; "Unit of Measure Code") { }
                column(Bin_Qty; Quantity) { }
                column(Bin_QtyBase; "Quantity (Base)") { }
                column(Bin_UnitCost; UnitCost) { }
                column(Bin_Value; StockValue) { }

                trigger OnAfterGetRecord()
                var
                    Item: Record Item;
                begin
                    if not Location.IsDamagedBin("Bin Code") then
                        CurrReport.Skip();
                    CalcFields(Quantity, "Quantity (Base)");
                    if "Quantity (Base)" = 0 then
                        CurrReport.Skip();
                    ItemDescription := '';
                    UnitCost := 0;
                    if Item.Get("Item No.") then begin
                        ItemDescription := Item.Description;
                        UnitCost := Item."Unit Cost";
                    end;
                    StockValue := Round("Quantity (Base)" * UnitCost);
                end;
            }

            trigger OnPreDataItem()
            begin
                FilterText := Location.GetFilters();
                if PostedTransfer.GetFilters() <> '' then
                    FilterText := FilterText + ' ' + PostedTransfer.GetFilters();
                if ShowHistory then
                    ShowHistoryInt := 1
                else
                    ShowHistoryInt := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                if ("Damaged Zone Code" = '') and ("Damaged Bin Code" = '') then
                    CurrReport.Skip();
            end;
        }

        dataitem(PostedTransfer; "NAV Posted Damage Transfer")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "Damage Date", "Reason Code", "Location Code";

            dataitem(PostedLine; "NAV Posted Damage Trf. Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");

                column(Hist_DocNo; PostedTransfer."No.") { }
                column(Hist_Date; Format(PostedTransfer."Damage Date")) { }
                column(Hist_Location; PostedTransfer."Location Code") { }
                column(Hist_Reason; PostedTransfer."Reason Code") { }
                column(Hist_User; PostedTransfer."Responsible User ID") { }
                column(Hist_RelatedDoc; PostedTransfer."Related Document No.") { }
                column(Hist_ItemNo; "Item No.") { }
                column(Hist_Description; Description) { }
                column(Hist_LotNo; "Lot No.") { }
                column(Hist_Expiry; Format("Expiration Date")) { }
                column(Hist_QtyBase; "Quantity (Base)") { }
                column(Hist_FromBin; "From Bin Code") { }
                column(Hist_ToBin; "To Bin Code") { }
            }

            trigger OnPreDataItem()
            begin
                if not ShowHistory then
                    CurrReport.Break();
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

                    field(ShowHistoryField; ShowHistory)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Damage Transfer History';
                        ToolTip = 'Specifies that the damage transfers posted in the period (Damage Date filter) are listed after the current damaged stock.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            ShowHistory := true;
        end;
    }

    var
        FilterText: Text;
        ItemDescription: Text[100];
        UnitCost: Decimal;
        StockValue: Decimal;
        ShowHistory: Boolean;
        ShowHistoryInt: Integer;
}
