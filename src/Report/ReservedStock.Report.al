report 50204 "NAV Reserved Stock"
{
    // Quantities reserved for sales orders, by item, with the customer, the order,
    // what the reservation is taken from (stock or purchase order) and its expiry date.
    Caption = 'Reserved Stock';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/ReservedStock.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ReservEntry; "Reservation Entry")
        {
            DataItemTableView = sorting("Item No.") where("Reservation Status" = const(Reservation), "Source Type" = const(37), "Source Subtype" = const(1), Positive = const(false));
            RequestFilterFields = "Item No.", "Location Code";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(Res_ItemNo; "Item No.") { }
            column(Res_Description; ItemDescription) { }
            column(Res_Location; "Location Code") { }
            column(Res_OrderNo; "Source ID") { }
            column(Res_CustomerNo; CustomerNo) { }
            column(Res_CustomerName; CustomerName) { }
            column(Res_Salesperson; SalespersonCode) { }
            column(Res_From; ReservedFrom) { }
            column(Res_Qty; ReservedQty) { }
            column(Res_ReservedOn; Format("Creation Date")) { }
            column(Res_Expiry; Format(ExpiryDate)) { }
            column(Res_DaysLeft; DaysLeftText) { }

            trigger OnPreDataItem()
            begin
                FilterText := ReservEntry.GetFilters();
            end;

            trigger OnAfterGetRecord()
            var
                Item: Record Item;
                SalesHeader: Record "Sales Header";
                SupplyEntry: Record "Reservation Entry";
                ReservationExpiry: Codeunit "NAV Reservation Expiry";
            begin
                ItemDescription := Description;
                if ItemDescription = '' then
                    if Item.Get("Item No.") then
                        ItemDescription := Item.Description;

                CustomerNo := '';
                CustomerName := '';
                SalespersonCode := '';
                if SalesHeader.Get(SalesHeader."Document Type"::Order, "Source ID") then begin
                    CustomerNo := SalesHeader."Sell-to Customer No.";
                    CustomerName := SalesHeader."Sell-to Customer Name";
                    SalespersonCode := SalesHeader."Salesperson Code";
                end;

                ReservedQty := Abs("Quantity (Base)");

                // Supply side of the reservation
                ReservedFrom := '';
                if SupplyEntry.Get("Entry No.", true) then
                    case SupplyEntry."Source Type" of
                        Database::"Item Ledger Entry":
                            ReservedFrom := InventoryTxt;
                        Database::"Purchase Line":
                            ReservedFrom := StrSubstNo(PurchaseTxt, SupplyEntry."Source ID");
                        Database::"Transfer Line":
                            ReservedFrom := StrSubstNo(TransferTxt, SupplyEntry."Source ID");
                        else
                            ReservedFrom := OtherTxt;
                    end;

                ExpiryDate := ReservationExpiry.GetExpiryDate(ReservEntry);
                DaysLeftText := '';
                if ExpiryDate <> 0D then
                    DaysLeftText := Format(ExpiryDate - Today());
            end;
        }
    }

    var
        FilterText: Text;
        ItemDescription: Text[100];
        CustomerNo: Code[20];
        CustomerName: Text[100];
        SalespersonCode: Code[20];
        ReservedFrom: Text;
        ReservedQty: Decimal;
        ExpiryDate: Date;
        DaysLeftText: Text;
        InventoryTxt: Label 'Inventory';
        PurchaseTxt: Label 'Purchase order %1', Comment = '%1 = Order No.';
        TransferTxt: Label 'Transfer order %1', Comment = '%1 = Order No.';
        OtherTxt: Label 'Other supply';
}
