report 50215 "NAV Vendor Performance"
{
    // Per vendor, on the receipts of the period: number of receipts and lines, on-time
    // rate (posting date <= expected receipt date), average delay, average lead time
    // (order date -> receipt), fill rate (received / received + overdue outstanding),
    // quantity declared damaged on its receipts, and open overdue lines.
    Caption = 'Vendor Performance';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/VendorPerformance.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Date Filter", "Vendor Posting Group";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(Vpf_VendorNo; "No.") { }
            column(Vpf_VendorName; Name) { }
            column(Vpf_Receipts; ReceiptCount) { }
            column(Vpf_Lines; LineCount) { }
            column(Vpf_OnTimePct; OnTimePct) { }
            column(Vpf_AvgDelay; AvgDelay) { }
            column(Vpf_AvgLeadTime; AvgLeadTime) { }
            column(Vpf_FillRatePct; FillRatePct) { }
            column(Vpf_DamagedQty; DamagedQty) { }
            column(Vpf_OverdueLines; OverdueLines) { }

            trigger OnPreDataItem()
            begin
                FilterText := GetFilters();
                if GetFilter("Date Filter") = '' then
                    SetRange("Date Filter", CalcDate('<-1Y>', WorkDate()), WorkDate());
            end;

            trigger OnAfterGetRecord()
            begin
                CalcVendor();
                if (LineCount = 0) and (OverdueLines = 0) then
                    CurrReport.Skip();
            end;
        }
    }

    local procedure CalcVendor()
    var
        RcptHeader: Record "Purch. Rcpt. Header";
        RcptLine: Record "Purch. Rcpt. Line";
        PurchLine: Record "Purchase Line";
        PostedDamageTrf: Record "NAV Posted Damage Transfer";
        PostedDamageLine: Record "NAV Posted Damage Trf. Line";
        OnTimeLines: Integer;
        LateLines: Integer;
        TotalDelay: Integer;
        TotalLeadTime: Integer;
        ReceivedQty: Decimal;
        OverdueQty: Decimal;
    begin
        ReceiptCount := 0;
        LineCount := 0;
        DamagedQty := 0;
        OverdueLines := 0;

        RcptHeader.SetRange("Buy-from Vendor No.", Vendor."No.");
        RcptHeader.SetFilter("Posting Date", Vendor.GetFilter("Date Filter"));
        if RcptHeader.FindSet() then
            repeat
                ReceiptCount += 1;
                if RcptHeader."Order Date" <> 0D then
                    TotalLeadTime += RcptHeader."Posting Date" - RcptHeader."Order Date";

                RcptLine.SetRange("Document No.", RcptHeader."No.");
                RcptLine.SetRange(Type, RcptLine.Type::Item);
                RcptLine.SetFilter(Quantity, '>0');
                RcptLine.SetRange(Correction, false);
                if RcptLine.FindSet() then
                    repeat
                        LineCount += 1;
                        ReceivedQty += RcptLine."Quantity (Base)";
                        if (RcptLine."Expected Receipt Date" = 0D) or (RcptHeader."Posting Date" <= RcptLine."Expected Receipt Date") then
                            OnTimeLines += 1
                        else begin
                            LateLines += 1;
                            TotalDelay += RcptHeader."Posting Date" - RcptLine."Expected Receipt Date";
                        end;
                    until RcptLine.Next() = 0;

                // Products declared damaged with the receipt as related document
                PostedDamageTrf.SetRange("Related Document No.", RcptHeader."No.");
                if PostedDamageTrf.FindSet() then
                    repeat
                        PostedDamageLine.SetRange("Document No.", PostedDamageTrf."No.");
                        PostedDamageLine.CalcSums("Quantity (Base)");
                        DamagedQty += PostedDamageLine."Quantity (Base)";
                    until PostedDamageTrf.Next() = 0;
            until RcptHeader.Next() = 0;

        // Open order lines already overdue
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange("Buy-from Vendor No.", Vendor."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetFilter("Outstanding Qty. (Base)", '>0');
        PurchLine.SetFilter("Expected Receipt Date", '<>%1&<%2', 0D, WorkDate());
        OverdueLines := PurchLine.Count();
        PurchLine.CalcSums("Outstanding Qty. (Base)");
        OverdueQty := PurchLine."Outstanding Qty. (Base)";

        OnTimePct := 0;
        if LineCount <> 0 then
            OnTimePct := Round(OnTimeLines / LineCount * 100, 0.1);
        AvgDelay := 0;
        if LateLines <> 0 then
            AvgDelay := Round(TotalDelay / LateLines, 0.1);
        AvgLeadTime := 0;
        if ReceiptCount <> 0 then
            AvgLeadTime := Round(TotalLeadTime / ReceiptCount, 0.1);
        FillRatePct := 0;
        if ReceivedQty + OverdueQty <> 0 then
            FillRatePct := Round(ReceivedQty / (ReceivedQty + OverdueQty) * 100, 0.1);
    end;

    var
        FilterText: Text;
        ReceiptCount: Integer;
        LineCount: Integer;
        OverdueLines: Integer;
        OnTimePct: Decimal;
        AvgDelay: Decimal;
        AvgLeadTime: Decimal;
        FillRatePct: Decimal;
        DamagedQty: Decimal;
}
