// Lot 8 – réalisé comparé à l'objectif annuel par commercial (REQ-SR-007).
report 90111 "GNC Salesperson Achievement"
{
    Caption = 'Salesperson Achievement';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/RDL/SalespersonAchievement.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Buffer; "GNC Sales Report Buffer")
        {
            UseTemporary = true;
            DataItemTableView = sorting("Entry No.");

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(Rep_Code; "Code") { }
            column(Rep_Name; Description) { }
            column(Rep_Type; Status) { }
            column(Rep_Target; "Amount 1") { }
            column(Rep_Actual; "Amount 2") { }
            column(Rep_Pct; "Amount 3") { }
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

                    field(ReportYear; ReportYear)
                    {
                        ApplicationArea = All;
                        Caption = 'Year';
                        ToolTip = 'Specifies the year of the targets and the actual sales.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            ReportYear := Date2DMY(WorkDate(), 3);
        end;
    }

    trigger OnPreReport()
    var
        GNCSalesReportData: Codeunit "GNC Sales Report Data";
    begin
        if ReportYear = 0 then
            ReportYear := Date2DMY(WorkDate(), 3);
        FilterText := StrSubstNo(YearTxt, ReportYear);
        GNCSalesReportData.FillSalespersonAchievement(Buffer, ReportYear);
    end;

    var
        FilterText: Text;
        ReportYear: Integer;
        YearTxt: Label 'Year: %1', Comment = '%1 = year';
}