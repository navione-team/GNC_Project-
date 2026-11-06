report 50213 "NAV Transit Folder Status"
{
    // Import folders: vendor, ETA, arrival, status, linked orders, estimated charges,
    // accrued charges and invoiced charges, with the delay against the ETA.
    Caption = 'Transit Folder Status';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/TransitFolderStatus.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(TransitFolder; "NAV Transit Folder")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", Status, "Vendor No.", "Expected Arrival Date";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(Tfs_No; "No.") { }
            column(Tfs_Status; Format(Status)) { }
            column(Tfs_VendorNo; "Vendor No.") { }
            column(Tfs_VendorName; "Vendor Name") { }
            column(Tfs_BL; "Bill of Lading No.") { }
            column(Tfs_ETA; Format("Expected Arrival Date")) { }
            column(Tfs_Arrival; Format("Actual Arrival Date")) { }
            column(Tfs_DaysLate; DaysLateText) { }
            column(Tfs_Orders; "No. of Orders") { }
            column(Tfs_BaseAmount; "Base Amount (LCY)") { }
            column(Tfs_Estimated; "Total Charges (LCY)") { }
            column(Tfs_Accrued; AccruedAmount) { }
            column(Tfs_Invoiced; InvoicedCharges) { }

            trigger OnPreDataItem()
            begin
                FilterText := GetFilters();
            end;

            trigger OnAfterGetRecord()
            var
                AccrualEntry: Record "NAV Transit Folder Accrual";
                ValueEntry: Record "Value Entry";
                ArrivalDate: Date;
            begin
                CalcFields("Total Charges (LCY)", "No. of Orders");

                AccrualEntry.SetRange("Folder No.", "No.");
                AccrualEntry.SetRange("Entry Type", AccrualEntry."Entry Type"::Accrual);
                AccrualEntry.CalcSums("Amount (LCY)");
                AccruedAmount := AccrualEntry."Amount (LCY)";

                ValueEntry.SetRange("Transit Folder No.", "No.");
                ValueEntry.SetFilter("Item Charge No.", '<>%1', '');
                ValueEntry.CalcSums("Cost Amount (Actual)");
                InvoicedCharges := ValueEntry."Cost Amount (Actual)";

                DaysLateText := '';
                if "Expected Arrival Date" <> 0D then begin
                    ArrivalDate := "Actual Arrival Date";
                    if ArrivalDate = 0D then
                        ArrivalDate := WorkDate();
                    if ArrivalDate > "Expected Arrival Date" then
                        DaysLateText := Format(ArrivalDate - "Expected Arrival Date");
                end;
            end;
        }
    }

    var
        FilterText: Text;
        DaysLateText: Text;
        AccruedAmount: Decimal;
        InvoicedCharges: Decimal;
}
