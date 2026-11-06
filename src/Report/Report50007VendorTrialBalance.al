report 50007 "Vendor Trial Balance NAVIONE"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/RDLC/Vendor Trial Balance.rdl';
    CaptionML = ENU = 'Vendor Trial Balance';

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Search Name", "Date Filter";

            column(FORMAT_TODAY_0_4_; FORMAT(TODAY, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(STRSUBSTNO_Text003_USERID_; STRSUBSTNO(Text003, USERID))
            {
            }
            column(STRSUBSTNO_Text004_PreviousStartDate_; STRSUBSTNO(Text004, PreviousStartDate))
            {
            }
            column(STRSUBSTNO_Text005_CurrReport_PAGENO_; STRSUBSTNO(Text005, CurrReport.PAGENO))
            {
            }
            column(PageCaption; STRSUBSTNO(Text005, ' '))
            {
            }
            column(PrintedByCaption; STRSUBSTNO(Text003, ''))
            {
            }
            column(Vendor_TABLECAPTION__________Filter; Vendor.TABLECAPTION + ': ' + Filter)
            {
            }
            column("Filter"; Filter)
            {
            }
            column(Vendor__No__; "No.")
            {
            }
            column(Vendor_Name; Name)
            {
            }
            column(PreviousDebitAmountLCY_PreviousCreditAmountLCY; PreviousDebitAmountLCY - PreviousCreditAmountLCY)
            {
            }
            column(PreviousCreditAmountLCY_PreviousDebitAmountLCY; PreviousCreditAmountLCY - PreviousDebitAmountLCY)
            {
            }
            column(PeriodDebitAmountLCY; PeriodDebitAmountLCY)
            {
            }
            column(PeriodCreditAmountLCY; PeriodCreditAmountLCY)
            {
            }
            column(PreviousDebitAmountLCY_PeriodDebitAmountLCY___PreviousCreditAmountLCY_PeriodCreditAmountLCY_; (PreviousDebitAmountLCY + PeriodDebitAmountLCY) - (PreviousCreditAmountLCY + PeriodCreditAmountLCY))
            {
            }
            column(PreviousCreditAmountLCY_PeriodCreditAmountLCY___PreviousDebitAmountLCY_PeriodDebitAmountLCY_; (PreviousCreditAmountLCY + PeriodCreditAmountLCY) - (PreviousDebitAmountLCY + PeriodDebitAmountLCY))
            {
            }
            column(PreviousDebitAmountLCY_PreviousCreditAmountLCY_Control1120069; PreviousDebitAmountLCY - PreviousCreditAmountLCY)
            {
            }
            column(PreviousCreditAmountLCY_PreviousDebitAmountLCY_Control1120072; PreviousCreditAmountLCY - PreviousDebitAmountLCY)
            {
            }
            column(PeriodDebitAmountLCY_Control1120075; PeriodDebitAmountLCY)
            {
            }
            column(PeriodCreditAmountLCY_Control1120078; PeriodCreditAmountLCY)
            {
            }
            column(PreviousDebitAmountLCY_PeriodDebitAmountLCY___PreviousCreditAmountLCY_PeriodCreditAmountLCY__Control1120081; (PreviousDebitAmountLCY + PeriodDebitAmountLCY) - (PreviousCreditAmountLCY + PeriodCreditAmountLCY))
            {
            }
            column(PreviousCreditAmountLCY_PeriodCreditAmountLCY___PreviousDebitAmountLCY_PeriodDebitAmountLCY__Control1120084; (PreviousCreditAmountLCY + PeriodCreditAmountLCY) - (PreviousDebitAmountLCY + PeriodDebitAmountLCY))
            {
            }
            column(Vendor_Trial_BalanceCaption; Vendor_Trial_BalanceCaptionLbl)
            {
            }
            column(R; No_CaptionLbl)
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(Balance_at_Starting_DateCaption; Balance_at_Starting_DateCaptionLbl)
            {
            }
            column(Balance_Date_RangeCaption; Balance_Date_RangeCaptionLbl)
            {
            }
            column(Balance_at_Ending_dateCaption; Balance_at_Ending_dateCaptionLbl)
            {
            }
            column(DebitCaption; DebitCaptionLbl)
            {
            }
            column(CreditCaption; CreditCaptionLbl)
            {
            }
            column(DebitCaption_Control1120030; DebitCaption_Control1120030Lbl)
            {
            }
            column(CreditCaption_Control1120032; CreditCaption_Control1120032Lbl)
            {
            }
            column(DebitCaption_Control1120034; DebitCaption_Control1120034Lbl)
            {
            }
            column(CreditCaption_Control1120036; CreditCaption_Control1120036Lbl)
            {
            }
            column(Grand_totalCaption; Grand_totalCaptionLbl)
            {
            }
            column(Picture; InfoCompany.Picture)
            {
            }
            column(Name; InfoCompany.Name)
            {
            }
            trigger OnAfterGetRecord();
            begin
                PreviousDebitAmountLCY := 0;
                PreviousCreditAmountLCY := 0;
                PeriodDebitAmountLCY := 0;
                PeriodCreditAmountLCY := 0;
                VendLedgEntry.SETCURRENTKEY("Vendor No.", "Posting Date", "Entry Type", "Initial Entry Global Dim. 1", "Initial Entry Global Dim. 2", "Currency Code");
                VendLedgEntry.SETRANGE("Vendor No.", "No.");
                IF Vendor.GETFILTER("Global Dimension 1 Filter") <> '' THEN VendLedgEntry.SETRANGE("Initial Entry Global Dim. 1", Vendor.GETFILTER("Global Dimension 1 Filter"));
                IF Vendor.GETFILTER("Global Dimension 2 Filter") <> '' THEN VendLedgEntry.SETRANGE("Initial Entry Global Dim. 2", Vendor.GETFILTER("Global Dimension 2 Filter"));
                IF Vendor.GETFILTER("Currency Filter") <> '' THEN VendLedgEntry.SETRANGE("Currency Code", Vendor.GETFILTER("Currency Filter"));
                VendLedgEntry.SETRANGE("Posting Date", 0D, PreviousEndDate);
                VendLedgEntry.SETFILTER("Entry Type", '<>%1', VendLedgEntry."Entry Type"::Application);
                IF VendLedgEntry.FINDSET THEN
                    REPEAT
                        PreviousDebitAmountLCY += VendLedgEntry."Debit Amount (LCY)";
                        PreviousCreditAmountLCY += VendLedgEntry."Credit Amount (LCY)";
                    UNTIL VendLedgEntry.NEXT = 0;
                VendLedgEntry.SETRANGE("Posting Date", StartDate, EndDate);
                IF VendLedgEntry.FINDSET THEN
                    REPEAT
                        PeriodDebitAmountLCY += VendLedgEntry."Debit Amount (LCY)";
                        PeriodCreditAmountLCY += VendLedgEntry."Credit Amount (LCY)";
                    UNTIL VendLedgEntry.NEXT = 0;
                IF NOT PrintVendWithoutBalance AND (PeriodDebitAmountLCY = 0) AND (PeriodCreditAmountLCY = 0) THEN CurrReport.SKIP;
            end;

            trigger OnPreDataItem();
            begin
                IF GETFILTER("Date Filter") = '' THEN ERROR(Text001, FIELDCAPTION("Date Filter"));
                IF COPYSTR(GETFILTER("Date Filter"), 1, 1) = '.' THEN ERROR(Text002);
                StartDate := GETRANGEMIN("Date Filter");
                PreviousEndDate := CLOSINGDATE(StartDate - 1);
                FiltreDateCalc.CreateFiscalYearFilter(TextDate, TextDate, StartDate, 0);
                TextDate := CONVERTSTR(TextDate, '.', ',');
                FiltreDateCalc.VerifiyDateFilter(TextDate);
                TextDate := COPYSTR(TextDate, 1, 8);
                EVALUATE(PreviousStartDate, TextDate);
                IF COPYSTR(GETFILTER("Date Filter"), STRLEN(GETFILTER("Date Filter")), 1) = '.' THEN
                    EndDate := 0D
                ELSE
                    EndDate := GETRANGEMAX("Date Filter");
                CurrReport.CREATETOTALS(PreviousDebitAmountLCY, PreviousCreditAmountLCY, PeriodDebitAmountLCY, PeriodCreditAmountLCY);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    CaptionML = ENU = 'Options';

                    field(PrintVendorsWithoutBalance; PrintVendWithoutBalance)
                    {
                        CaptionML = ENU = 'Print Vendors without Balance';
                        MultiLine = true;
                        ApplicationArea = all;
                    }
                }
            }
        }
        actions
        {
        }
    }
    labels
    {
    }
    trigger OnPreReport();
    begin
        Filter := Vendor.GETFILTERS;
        InfoCompany.Get();
        InfoCompany.CalcFields(Picture);
    end;

    var
        Text001: TextConst ENU = 'You must fill in the %1 field.';
        Text002: TextConst ENU = 'You must specify a Starting Date.';
        Text003: TextConst ENU = 'Printed by %1';
        Text004: TextConst ENU = 'Fiscal Year Start Date : %1';
        Text005: TextConst ENU = 'Page %1';
        VendLedgEntry: Record "Detailed Vendor Ledg. Entry";
        FiltreDateCalc: Codeunit "ST DateFilter-Calc Delta";
        InfoCompany: Record "Company Information";
        StartDate: Date;
        EndDate: Date;
        PreviousStartDate: Date;
        PreviousEndDate: Date;
        TextDate: Text;
        PrintVendWithoutBalance: Boolean;
        "Filter": Text;
        PreviousDebitAmountLCY: Decimal;
        PreviousCreditAmountLCY: Decimal;
        PeriodDebitAmountLCY: Decimal;
        PeriodCreditAmountLCY: Decimal;
        Vendor_Trial_BalanceCaptionLbl: TextConst ENU = 'Vendor Trial Balance';
        No_CaptionLbl: TextConst ENU = 'No.';
        NameCaptionLbl: TextConst ENU = 'Name';
        Balance_at_Starting_DateCaptionLbl: TextConst ENU = 'Balance at Starting Date';
        Balance_Date_RangeCaptionLbl: TextConst ENU = 'Balance Date Range';
        Balance_at_Ending_dateCaptionLbl: TextConst ENU = 'Balance at Ending date';
        DebitCaptionLbl: TextConst ENU = 'Debit';
        CreditCaptionLbl: TextConst ENU = 'Credit';
        DebitCaption_Control1120030Lbl: TextConst ENU = 'Debit';
        CreditCaption_Control1120032Lbl: TextConst ENU = 'Credit';
        DebitCaption_Control1120034Lbl: TextConst ENU = 'Debit';
        CreditCaption_Control1120036Lbl: TextConst ENU = 'Credit';
        Grand_totalCaptionLbl: TextConst ENU = 'Grand total';
}
