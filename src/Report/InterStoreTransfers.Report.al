report 50212 "NAV Inter-Store Transfers"
{
    // 1. Transfers shipped between stores in the period.
    // 2. Quantities currently in transit (shipped, not received yet).
    Caption = 'Inter-Store Transfers';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/InterStoreTransfers.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ShipmentHeader; "Transfer Shipment Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "Posting Date", "Transfer-from Code", "Transfer-to Code";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }

            dataitem(ShipmentLine; "Transfer Shipment Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.") where(Quantity = filter(<> 0));

                column(Trf_Date; Format(ShipmentHeader."Posting Date")) { }
                column(Trf_DocNo; ShipmentHeader."No.") { }
                column(Trf_OrderNo; ShipmentHeader."Transfer Order No.") { }
                column(Trf_From; ShipmentHeader."Transfer-from Code") { }
                column(Trf_To; ShipmentHeader."Transfer-to Code") { }
                column(Trf_ItemNo; "Item No.") { }
                column(Trf_Description; Description) { }
                column(Trf_Qty; Quantity) { }
                column(Trf_UoM; "Unit of Measure Code") { }
                column(Trf_QtyBase; "Quantity (Base)") { }
            }

            trigger OnPreDataItem()
            begin
                FilterText := GetFilters();
            end;
        }

        dataitem(InTransitLine; "Transfer Line")
        {
            DataItemTableView = sorting("Document No.", "Line No.") where("Derived From Line No." = const(0), "Qty. in Transit" = filter(> 0));

            column(Tns_OrderNo; "Document No.") { }
            column(Tns_From; "Transfer-from Code") { }
            column(Tns_To; "Transfer-to Code") { }
            column(Tns_ItemNo; "Item No.") { }
            column(Tns_Description; Description) { }
            column(Tns_ShipmentDate; Format("Shipment Date")) { }
            column(Tns_ReceiptDate; Format("Receipt Date")) { }
            column(Tns_QtyInTransit; "Qty. in Transit") { }
            column(Tns_UoM; "Unit of Measure Code") { }

            trigger OnPreDataItem()
            begin
                if ShipmentHeader.GetFilter("Transfer-from Code") <> '' then
                    SetFilter("Transfer-from Code", ShipmentHeader.GetFilter("Transfer-from Code"));
                if ShipmentHeader.GetFilter("Transfer-to Code") <> '' then
                    SetFilter("Transfer-to Code", ShipmentHeader.GetFilter("Transfer-to Code"));
            end;
        }
    }

    var
        FilterText: Text;
}
