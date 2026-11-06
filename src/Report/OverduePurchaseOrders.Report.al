report 50216 "NAV Overdue Purchase Orders"
{
    // Purchase order lines not (fully) received after their expected receipt date,
    // with the delay in days, by vendor.
    Caption = 'Overdue Purchase Orders';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/OverduePurchaseOrders.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(PurchLine; "Purchase Line")
        {
            DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where("Document Type" = const(Order), Type = const(Item), "Outstanding Quantity" = filter(> 0));
            RequestFilterFields = "Buy-from Vendor No.", "No.", "Location Code";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(SubtitleText; StrSubstNo(SubtitleTxt, AsOfDate)) { }
            column(Ovd_VendorNo; "Buy-from Vendor No.") { }
            column(Ovd_VendorName; VendorName) { }
            column(Ovd_OrderNo; "Document No.") { }
            column(Ovd_ItemNo; "No.") { }
            column(Ovd_Description; Description) { }
            column(Ovd_Location; "Location Code") { }
            column(Ovd_Expected; Format("Expected Receipt Date")) { }
            column(Ovd_DaysLate; AsOfDate - "Expected Receipt Date") { }
            column(Ovd_Outstanding; "Outstanding Quantity") { }
            column(Ovd_UoM; "Unit of Measure Code") { }
            column(Ovd_AmountLCY; "Outstanding Amount (LCY)") { }
            column(Ovd_TransitFolder; "Transit Folder No.") { }

            trigger OnPreDataItem()
            begin
                if AsOfDate = 0D then
                    AsOfDate := WorkDate();
                SetFilter("Expected Receipt Date", '<>%1&<%2', 0D, AsOfDate);
                FilterText := GetFilters();
            end;

            trigger OnAfterGetRecord()
            var
                Helper: Codeunit "NAV Report Helper";
            begin
                VendorName := Helper.GetVendorName("Buy-from Vendor No.");
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
                        ToolTip = 'Specifies the reference date: lines expected before this date and not received are listed.';
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
        AsOfDate: Date;
        FilterText: Text;
        VendorName: Text[100];
        SubtitleTxt: Label 'Open purchase order lines expected before %1', Comment = '%1 = date';
}
