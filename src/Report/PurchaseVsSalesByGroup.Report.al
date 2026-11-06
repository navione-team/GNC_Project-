report 50218 "NAV Purchase vs Sales by Group"
{
    // Quantities and amounts purchased and sold in the period, per item, grouped by
    // Product Group and Item Family (GNC item fields).
    Caption = 'Purchase vs Sales by Product Group';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/PurchaseVsSalesByGroup.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Date Filter", "Product Group Code", "Item Family Code", "Location Filter";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(Pvs_ProductGroup; "Product Group Code") { }
            column(Pvs_ItemFamily; "Item Family Code") { }
            column(Pvs_ItemNo; "No.") { }
            column(Pvs_Description; Description) { }
            column(Pvs_BaseUoM; "Base Unit of Measure") { }
            column(Pvs_PurchQty; PurchQty) { }
            column(Pvs_PurchAmount; PurchAmount) { }
            column(Pvs_SalesQty; SalesQty) { }
            column(Pvs_SalesAmount; SalesAmount) { }
            column(Pvs_NetQty; PurchQty - SalesQty) { }

            trigger OnPreDataItem()
            begin
                FilterText := GetFilters();
            end;

            trigger OnAfterGetRecord()
            var
                ValueEntry: Record "Value Entry";
            begin
                ValueEntry.SetCurrentKey("Item No.");
                ValueEntry.SetRange("Item No.", "No.");
                if GetFilter("Date Filter") <> '' then
                    ValueEntry.SetFilter("Posting Date", GetFilter("Date Filter"));
                if GetFilter("Location Filter") <> '' then
                    ValueEntry.SetFilter("Location Code", GetFilter("Location Filter"));

                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
                ValueEntry.CalcSums("Invoiced Quantity", "Cost Amount (Actual)");
                PurchQty := ValueEntry."Invoiced Quantity";
                PurchAmount := ValueEntry."Cost Amount (Actual)";

                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
                ValueEntry.CalcSums("Invoiced Quantity", "Sales Amount (Actual)");
                SalesQty := -ValueEntry."Invoiced Quantity";
                SalesAmount := ValueEntry."Sales Amount (Actual)";

                if (PurchQty = 0) and (SalesQty = 0) and (PurchAmount = 0) and (SalesAmount = 0) then
                    CurrReport.Skip();
            end;
        }
    }

    var
        FilterText: Text;
        PurchQty: Decimal;
        PurchAmount: Decimal;
        SalesQty: Decimal;
        SalesAmount: Decimal;
}
