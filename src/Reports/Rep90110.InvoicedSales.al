// Lot 8 – factures et avoirs validés.
report 90110 "GNC Invoiced Sales"
{
    Caption = 'Invoiced Sales';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/RDL/InvoicedSales.rdl';
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
            column(Rep_DocumentNo; "Code") { }
            column(Rep_Date; "Document Date") { }
            column(Rep_CustomerNo; "Customer No.") { }
            column(Rep_CustomerName; Description) { }
            column(Rep_Salesperson; "Salesperson Code") { }
            column(Rep_Status; Status) { }
            column(Rep_Amount; "Amount 1") { }
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

                    field(FromDate; FromDate)
                    {
                        ApplicationArea = All;
                        Caption = 'From Date';
                        ToolTip = 'Specifies the first date of the report.';
                    }
                    field(ToDate; ToDate)
                    {
                        ApplicationArea = All;
                        Caption = 'To Date';
                        ToolTip = 'Specifies the last date of the report.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            FromDate := DMY2Date(1, 1, Date2DMY(WorkDate(), 3));
            ToDate := DMY2Date(31, 12, Date2DMY(WorkDate(), 3));
        end;
    }

    trigger OnPreReport()
    var
        GNCSalesReportData: Codeunit "GNC Sales Report Data";
    begin
        if ToDate = 0D then
            ToDate := DMY2Date(31, 12, 9999);
        FilterText := StrSubstNo(PeriodTxt, FromDate, ToDate);
        GNCSalesReportData.FillInvoicedSales(Buffer, FromDate, ToDate);
    end;

    var
        FilterText: Text;
        FromDate: Date;
        ToDate: Date;
        PeriodTxt: Label 'Period: %1..%2', Comment = '%1 = from date, %2 = to date';
}