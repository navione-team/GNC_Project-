report 50214 "NAV Landed Cost Variance"
{
    // Per transit folder and item charge: estimated amount (folder line), accrued at
    // receipt, actual amount invoiced (item charge value entries) and the variance.
    Caption = 'Landed Cost Variance';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/LandedCostVariance.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(TransitFolder; "NAV Transit Folder")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", Status, "Vendor No.", "Document Date";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }

            dataitem(FolderLine; "NAV Transit Folder Line")
            {
                DataItemLink = "Folder No." = field("No.");
                DataItemTableView = sorting("Folder No.", "Line No.");

                column(Var_FolderNo; TransitFolder."No.") { }
                column(Var_FolderVendor; TransitFolder."Vendor Name") { }
                column(Var_ChargeNo; "Item Charge No.") { }
                column(Var_Description; Description) { }
                column(Var_CalcType; Format("Calculation Type")) { }
                column(Var_VendorName; "Vendor Name") { }
                column(Var_Estimated; Amount) { }
                column(Var_Accrued; "Accrued Amount (LCY)") { }
                column(Var_Actual; ActualAmount) { }
                column(Var_Variance; ActualAmount - Amount) { }
                column(Var_VariancePct; VariancePct) { }

                trigger OnAfterGetRecord()
                var
                    ValueEntry: Record "Value Entry";
                begin
                    CalcFields("Accrued Amount (LCY)");
                    ValueEntry.SetRange("Transit Folder No.", "Folder No.");
                    ValueEntry.SetRange("Item Charge No.", "Item Charge No.");
                    ValueEntry.CalcSums("Cost Amount (Actual)");
                    ActualAmount := ValueEntry."Cost Amount (Actual)";
                    if OnlyInvoiced and (ActualAmount = 0) then
                        CurrReport.Skip();
                    VariancePct := 0;
                    if Amount <> 0 then
                        VariancePct := Round((ActualAmount - Amount) / Amount * 100, 0.01);
                end;
            }

            trigger OnPreDataItem()
            begin
                FilterText := GetFilters();
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

                    field(OnlyInvoicedField; OnlyInvoiced)
                    {
                        ApplicationArea = All;
                        Caption = 'Only Invoiced Charges';
                        ToolTip = 'Specifies that only charges already invoiced (actual amount not zero) are listed.';
                    }
                }
            }
        }
    }

    var
        FilterText: Text;
        ActualAmount: Decimal;
        VariancePct: Decimal;
        OnlyInvoiced: Boolean;
}
