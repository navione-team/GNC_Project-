report 50205 "NAV Near-Expiry Stock"
{
    // Batches in stock that expire within N days (or are already expired), by location,
    // in tablets, packs and value, grouped by expiry bucket.
    Caption = 'Near-Expiry Stock';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/NearExpiryStock.rdl';
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
            column(SubtitleText; SubtitleText) { }
            column(Exp_Bucket; BucketText) { }
            column(Exp_BucketSort; BucketSort) { }
            column(Exp_Location; "Location Code") { }
            column(Exp_ItemNo; "Item No.") { }
            column(Exp_Description; ItemDescription) { }
            column(Exp_LotNo; "Lot No.") { }
            column(Exp_Expiry; Format("Expiration Date")) { }
            column(Exp_DaysLeft; DaysLeft) { }
            column(Exp_Status; StatusText) { }
            column(Exp_QtyBase; "Remaining Quantity") { }
            column(Exp_Packs; Packs) { }
            column(Exp_Value; RemainingValue) { }

            trigger OnPreDataItem()
            begin
                if AsOfDate = 0D then
                    AsOfDate := WorkDate();
                if DaysAhead <= 0 then
                    DaysAhead := 90;
                SetFilter("Lot No.", '<>%1', '');
                SetFilter("Expiration Date", '<>%1&..%2', 0D, AsOfDate + DaysAhead);
                FilterText := GetFilters();
                SubtitleText := StrSubstNo(SubtitleTxt, AsOfDate, DaysAhead);
            end;

            trigger OnAfterGetRecord()
            begin
                ItemDescription := Helper.GetItemDescription("Item No.");
                DaysLeft := "Expiration Date" - AsOfDate;
                case true of
                    DaysLeft <= 0:
                        begin
                            BucketText := ExpiredTxt;
                            BucketSort := 0;
                        end;
                    DaysLeft <= 30:
                        begin
                            BucketText := Bucket30Txt;
                            BucketSort := 1;
                        end;
                    DaysLeft <= 60:
                        begin
                            BucketText := Bucket60Txt;
                            BucketSort := 2;
                        end;
                    else begin
                        BucketText := StrSubstNo(BucketMoreTxt, DaysAhead);
                        BucketSort := 3;
                    end;
                end;
                StatusText := Helper.GetLotStatusText("Item No.", "Variant Code", "Lot No.", "Expiration Date", AsOfDate);
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

                    field(AsOfDateField; AsOfDate)
                    {
                        ApplicationArea = All;
                        Caption = 'As of Date';
                        ToolTip = 'Specifies the reference date.';
                    }
                    field(DaysAheadField; DaysAhead)
                    {
                        ApplicationArea = All;
                        Caption = 'Expiring Within (Days)';
                        MinValue = 1;
                        ToolTip = 'Specifies the horizon: batches expiring within this number of days are listed, as well as batches already expired.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if AsOfDate = 0D then
                AsOfDate := WorkDate();
            if DaysAhead = 0 then
                DaysAhead := 90;
        end;
    }

    var
        Helper: Codeunit "NAV Report Helper";
        AsOfDate: Date;
        DaysAhead: Integer;
        DaysLeft: Integer;
        BucketSort: Integer;
        BucketText: Text;
        StatusText: Text;
        FilterText: Text;
        SubtitleText: Text;
        ItemDescription: Text[100];
        Packs: Decimal;
        RemainingValue: Decimal;
        SubtitleTxt: Label 'Stock as of %1 expiring within %2 days, and expired stock', Comment = '%1 = date, %2 = days';
        ExpiredTxt: Label 'Expired';
        Bucket30Txt: Label 'Expires in 1 to 30 days';
        Bucket60Txt: Label 'Expires in 31 to 60 days';
        BucketMoreTxt: Label 'Expires in 61 to %1 days', Comment = '%1 = days';
}
