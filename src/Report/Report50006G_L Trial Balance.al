report 50006 "G/L Trial Balance NAVIONE"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/RDLC/GLTrialBalance2.rdl';
    Caption = 'G/L Trial Balance';

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Date Filter";
            column(TodayFormatted; FORMAT(TODAY, 0, 4))
            {
            }
            column(CompanyName; COMPANYNAME)
            {
            }
            column(PreviousStartDateText; STRSUBSTNO(Text004, PreviousStartDate))
            {
            }
            column(PageCaption; STRSUBSTNO(Text005, ''))
            {
            }
            column(UserCaption; STRSUBSTNO(Text003, ''))
            {
            }
            column(GLAccTableCaptionFilter; "G/L Account".TABLECAPTION)
            {
            }
            column("Filter"; Filter)
            {
            }
            column(FiscalYearStatusText; FiscalYearStatusText)
            {
            }
            column(SimulationEntriesCaption; SimulationEntriesCaptionLbl)
            {
            }
            column(GLEntryFilter; "G/L Account"."Budget Filter")
            {
            }
            column(No_GLAcc; "No.")
            {
            }
            column(Name_GLAcc; Name)
            {
            }
            column(GLAcc2DebitAmtCreditAmt; GLAccount2."Debit Amount" - GLAccount2."Credit Amount")
            {
                AutoFormatExpression = GeneralLedgerSetup."LCY Code";
                AutoFormatType = 1;
            }
            column(GLAcc2CreditAmtDebitAmt; GLAccount2."Credit Amount" - GLAccount2."Debit Amount")
            {
            }
            column(DebitAmt_GLAcc; "Debit Amount")
            {
            }
            column(CreditAmt_GLAcc; "Credit Amount")
            {
            }
            column(BalAtEndingDateDebitCaption; GLAccount2."Debit Amount" + "Debit Amount" - GLAccount2."Credit Amount" - "Credit Amount")
            {
            }
            column(BalAtEndingDateCreditCaption; GLAccount2."Credit Amount" + "Credit Amount" - GLAccount2."Debit Amount" - "Debit Amount")
            {
            }
            column(TLAccType; TLAccountType)
            {
            }
            column(GLTrialBalCaption; GLTrialBalCaptionLbl)
            {
            }
            column(NoCaption; NoCaptionLbl)
            {
            }
            column(NameCaption; NameCaptionLbl)
            {
            }
            column(BalAtStartingDateCaption; BalAtStartingDateCaptionLbl)
            {
            }
            column(BalDateRangeCaption; BalDateRangeCaptionLbl)
            {
            }
            column(BalAtEndingdateCaption; BalAtEndingdateCaptionLbl)
            {
            }
            column(DebitCaption; DebitCaptionLbl)
            {
            }
            column(CreditCaption; CreditCaptionLbl)
            {
            }
            column(TypeAccount; TestValAmount)
            {
            }
            column(TotalMouvDebit; TotalMouvDebit)
            {
            }
            column(TotalMouvCredit; TotalMouvCredit)
            {
            }
            column(TotalDebit; SoldeDebit)
            {
            }
            column(TotalCredit; SoldeCredit)
            {
            }
            column(TotBalanceDebit; TotBalanceDebit)
            {
            }
            column(TotBalanceCredit; TotBalanceCredit)
            {
            }
            column(CompanyAdr; CompanyInfo.Address)
            {
            }
            column(CompanyCode; CompanyInfo."Post Code")
            {
            }
            column(CompanyCity; CompanyInfo.City)
            {
            }
            column(CompanyFax; CompanyInfo."Fax No.")
            {
            }
            column(CompanyPhone; CompanyInfo."Phone No.")
            {
            }
            column(CompanyVAT; CompanyInfo."VAT Registration No.")
            {
            }
            column(TotBilanDebit; TotBilanDebit)
            {
            }
            column(TotBilanCredit; TotBilanCredit)
            {
            }
            column(TotCompteBilanDebit; TotCompteBilanDebit)
            {
            }
            column(TotCompteBilanCredit; TotCompteBilanCredit)
            {
            }
            column(TotMovBilanDebit; TotMovBilanDebit)
            {
            }
            column(TotMovBilanCredit; TotMovBilanCredit)
            {
            }
            column(TotalSoldeBilanDebit; TotalSoldeBilanDebit)
            {
            }
            column(TotalSoldeBilanCredit; TotalSoldeBilanCredit)
            {
            }
            column(TotGestionDebit; TotGestionDebit)
            {
            }
            column(TotGestionCredit; TotGestionCredit)
            {
            }
            column(TotMovGestionDebit; TotMovGestionDebit)
            {
            }
            column(TotMovGestionCredit; TotMovGestionCredit)
            {
            }
            column(TotalSoldeGestionDebit; TotalSoldeGestionDebit)
            {
            }
            column(TotalSoldeGestionCredit; TotalSoldeGestionCredit)
            {
            }
            column(AccountType; GLAccount2."Account Type")
            {
            }

            trigger OnAfterGetRecord()
            begin
                /*
                GLAccount2.COPY("G/L Account");
                WITH GLAccount2 DO BEGIN
                  IF "Income/Balance" = 0 THEN BEGIN
                    SETRANGE("Date Filter",PreviousStartDate,PreviousEndDate);
                    CALCFIELDS("Debit Amount","Credit Amount");
                  END ELSE BEGIN
                    SETRANGE("Date Filter",0D,PreviousEndDate);
                    CALCFIELDS("Debit Amount","Credit Amount");
                  END;
                END;
                
                IF NOT ImprNonMvt AND
                   (GLAccount2."Debit Amount" = 0) AND
                   ("Debit Amount" = 0) AND
                   (GLAccount2."Credit Amount" = 0) AND
                   ("Credit Amount" = 0)
                THEN
                  CurrReport.SKIP;
                
                TLAccountType := "G/L Account"."Account Type";
                
                IF TLAccountType = 0 THEN
                BEGIN
                  IF (GLAccount2."Debit Amount" - GLAccount2."Credit Amount") > 0 THEN
                    TotalMouvDebit := (GLAccount2."Debit Amount" - GLAccount2."Credit Amount")
                  ELSE
                    TotalMouvDebit := 0;
                  IF (GLAccount2."Credit Amount" - GLAccount2."Debit Amount") > 0 THEN
                    TotalMouvCredit := GLAccount2."Credit Amount" - GLAccount2."Debit Amount"
                  ELSE
                    TotalMouvCredit := 0;
                  IF "Debit Amount" > 0 THEN
                    SoldeDebit := "Debit Amount"
                  ELSE
                    SoldeDebit := 0;
                  IF "Credit Amount" > 0 THEN
                    SoldeCredit := "Credit Amount"
                  ELSE
                    SoldeCredit := 0;
                  IF (GLAccount2."Debit Amount" + "Debit Amount" - GLAccount2."Credit Amount" - "Credit Amount") > 0 THEN
                    TotBalanceDebit := GLAccount2."Debit Amount" + "Debit Amount" - GLAccount2."Credit Amount" - "Credit Amount"
                  ELSE
                    TotBalanceDebit := 0;
                  IF (GLAccount2."Credit Amount" + "Credit Amount" - GLAccount2."Debit Amount" - "Debit Amount") > 0 THEN
                    TotBalanceCredit := GLAccount2."Credit Amount" + "Credit Amount" - GLAccount2."Debit Amount" - "Debit Amount"
                  ELSE
                    TotBalanceCredit := 0;
                END ELSE
                BEGIN
                    TotalMouvDebit := 0;
                    TotalMouvCredit := 0;
                    SoldeDebit := 0;
                    SoldeCredit := 0;
                    TotBalanceDebit := 0;
                    TotBalanceCredit := 0;
                END;   */

                GLAccount2.COPY("G/L Account");
                WITH GLAccount2 DO BEGIN
                    IF "Income/Balance" = 0 THEN BEGIN
                        SETRANGE("Date Filter", PreviousStartDate, PreviousEndDate);
                        CALCFIELDS("Debit Amount", "Credit Amount");
                    END ELSE BEGIN
                        SETRANGE("Date Filter", 0D, PreviousEndDate);
                        CALCFIELDS("Debit Amount", "Credit Amount");
                    END;
                END;

                IF NOT ImprNonMvt AND
                   (GLAccount2."Debit Amount" = 0) AND
                   ("Debit Amount" = 0) AND
                   (GLAccount2."Credit Amount" = 0) AND
                   ("Credit Amount" = 0)
                THEN
                    CurrReport.SKIP;

                TLAccountType := "G/L Account"."Account Type";

                IF TLAccountType = 0 THEN BEGIN
                    IF (GLAccount2."Debit Amount" - GLAccount2."Credit Amount") > 0 THEN
                        TotalMouvDebit := (GLAccount2."Debit Amount" - GLAccount2."Credit Amount")
                    ELSE
                        TotalMouvDebit := 0;
                    IF (GLAccount2."Credit Amount" - GLAccount2."Debit Amount") > 0 THEN
                        TotalMouvCredit := GLAccount2."Credit Amount" - GLAccount2."Debit Amount"
                    ELSE
                        TotalMouvCredit := 0;
                    IF "Debit Amount" > 0 THEN
                        SoldeDebit := "Debit Amount"
                    ELSE
                        SoldeDebit := 0;
                    IF "Credit Amount" > 0 THEN
                        SoldeCredit := "Credit Amount"
                    ELSE
                        SoldeCredit := 0;
                    IF (GLAccount2."Debit Amount" + "Debit Amount" - GLAccount2."Credit Amount" - "Credit Amount") > 0 THEN
                        TotBalanceDebit := GLAccount2."Debit Amount" + "Debit Amount" - GLAccount2."Credit Amount" - "Credit Amount"
                    ELSE
                        TotBalanceDebit := 0;
                    IF (GLAccount2."Credit Amount" + "Credit Amount" - GLAccount2."Debit Amount" - "Debit Amount") > 0 THEN
                        TotBalanceCredit := GLAccount2."Credit Amount" + "Credit Amount" - GLAccount2."Debit Amount" - "Debit Amount"
                    ELSE
                        TotBalanceCredit := 0;
                END ELSE BEGIN
                    TotalMouvDebit := 0;
                    TotalMouvCredit := 0;
                    SoldeDebit := 0;
                    SoldeCredit := 0;
                    TotBalanceDebit := 0;
                    TotBalanceCredit := 0;
                END;

                //>>DELTA 02 SN (24/09/2016) - Calcul Compte Bilan + Compte Gestion

                // Calcul Compte Bilan
                IF (GLAccount2."Account Type" = 0) AND (GLAccount2."Income/Balance" = 1)
                THEN BEGIN
                    IF (GLAccount2."Debit Amount" + "Debit Amount" - GLAccount2."Credit Amount" - "Credit Amount") > 0 THEN
                        TotBilanDebit := GLAccount2."Debit Amount" + "Debit Amount" - GLAccount2."Credit Amount" - "Credit Amount"
                    ELSE
                        TotBilanDebit := 0;
                    IF (GLAccount2."Credit Amount" + "Credit Amount" - GLAccount2."Debit Amount" - "Debit Amount") > 0 THEN
                        TotBilanCredit := GLAccount2."Credit Amount" + "Credit Amount" - GLAccount2."Debit Amount" - "Debit Amount"
                    ELSE
                        TotBilanCredit := 0;
                    IF "Debit Amount" > 0 THEN
                        TotMovBilanDebit := "Debit Amount"
                    ELSE
                        TotMovBilanDebit := 0;
                    IF "Credit Amount" > 0 THEN
                        TotMovBilanCredit := "Credit Amount"
                    ELSE
                        TotMovBilanCredit := 0;
                    IF (GLAccount2."Debit Amount" + "Debit Amount" - GLAccount2."Credit Amount" - "Credit Amount") > 0 THEN
                        TotalSoldeBilanDebit := (GLAccount2."Debit Amount" - GLAccount2."Credit Amount")
                    ELSE
                        TotalSoldeBilanDebit := 0;
                    IF (GLAccount2."Credit Amount" + "Credit Amount" - GLAccount2."Debit Amount" - "Debit Amount") > 0 THEN
                        TotalSoldeBilanCredit := GLAccount2."Credit Amount" - GLAccount2."Debit Amount"
                    ELSE
                        TotalSoldeBilanCredit := 0;
                END ELSE BEGIN
                    TotBilanDebit := 0;
                    TotBilanCredit := 0;
                    TotMovBilanDebit := 0;
                    TotMovBilanCredit := 0;
                    TotalSoldeBilanDebit := 0;
                    TotalSoldeBilanCredit := 0;
                END;

                //Calcul Compte Gestion

                IF ("G/L Account"."Account Type" = 0) AND ("G/L Account"."Income/Balance" = 0)
                THEN BEGIN
                    IF ("Debit Amount" - "Credit Amount") > 0 THEN
                        TotGestionDebit := GLAccount2."Debit Amount" + "Debit Amount" - GLAccount2."Credit Amount" - "Credit Amount"
                    ELSE
                        TotGestionDebit := 0;
                    IF ("Credit Amount" - "Debit Amount") > 0 THEN
                        TotGestionCredit := GLAccount2."Credit Amount" + "Credit Amount" - GLAccount2."Debit Amount" - "Debit Amount"
                    ELSE
                        TotGestionCredit := 0;
                    IF "Debit Amount" > 0 THEN
                        TotMovGestionDebit := "Debit Amount"
                    ELSE
                        TotMovGestionDebit := 0;
                    IF "Credit Amount" > 0 THEN
                        TotMovGestionCredit := "Credit Amount"
                    ELSE
                        TotMovGestionCredit := 0;
                    IF ("Debit Amount" - "Credit Amount") > 0 THEN
                        TotalSoldeGestionDebit := (GLAccount2."Debit Amount" - GLAccount2."Credit Amount")
                    ELSE
                        TotalSoldeGestionDebit := 0;
                    IF ("Credit Amount" - "Debit Amount") > 0 THEN
                        TotalSoldeGestionCredit := GLAccount2."Credit Amount" - GLAccount2."Debit Amount"
                    ELSE
                        TotalSoldeGestionCredit := 0;
                END ELSE BEGIN
                    TotGestionDebit := 0;
                    TotGestionCredit := 0;
                    TotMovGestionDebit := 0;
                    TotMovGestionCredit := 0;
                    TotalSoldeGestionDebit := 0;
                    TotalSoldeGestionCredit := 0;
                END;


            end;

            trigger OnPreDataItem()
            begin
                /*IF GETFILTER("Date Filter") = '' THEN
                  ERROR(Text001,FIELDCAPTION("Date Filter"));
                IF COPYSTR(GETFILTER("Date Filter"),1,1) = '.' THEN
                  ERROR(Text002);
                StartDate := GETRANGEMIN("Date Filter");
                PreviousEndDate := CLOSINGDATE(StartDate - 1);
                FiltreDateCalc.CreateFiscalYearFilter(TextDate,TextDate,StartDate,0);
                TextDate := CONVERTSTR(TextDate,'.',',');
                FiltreDateCalc.VerifiyDateFilter(TextDate);
                TextDate := COPYSTR(TextDate,1,8);
                EVALUATE(PreviousStartDate,TextDate);
                IF COPYSTR(GETFILTER("Date Filter"),STRLEN(GETFILTER("Date Filter")),1) = '.' THEN
                  EndDate := 0D
                ELSE
                  EndDate := GETRANGEMAX("Date Filter");
                FiscalYearStatusText := STRSUBSTNO(Text007,FYFiscalClose.CheckFiscalYearStatus(GETFILTER("Date Filter")));
                                           */
                IF GETFILTER("Date Filter") = '' THEN
                    ERROR(Text001, FIELDCAPTION("Date Filter"));
                IF COPYSTR(GETFILTER("Date Filter"), 1, 1) = '.' THEN
                    ERROR(Text002);
                StartDate := GETRANGEMIN("Date Filter");
                PreviousEndDate := CLOSINGDATE(StartDate - 1);
                FiltreDateCalc.CreateFiscalYearFilter(TextDate, TextDate, StartDate, 0);
                TextDate := CONVERTSTR(TextDate, '.', ',');
                // FiltreDateCalc.VerifiyDateFilter(TextDate);
                TextDate := COPYSTR(TextDate, 1, 8);
                EVALUATE(PreviousStartDate, TextDate);
                IF COPYSTR(GETFILTER("Date Filter"), STRLEN(GETFILTER("Date Filter")), 1) = '.' THEN
                    EndDate := 0D
                ELSE
                    EndDate := GETRANGEMAX("Date Filter");
                //   FiscalYearStatusText := STRSUBSTNO(Text007, FYFiscalClose.CheckFiscalYearStatus(GETFILTER("Date Filter")));

                //TotalMouvDebit := 0;

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
                    Caption = 'Options';
                    field(PrintGLAccsWithoutBalance; ImprNonMvt)
                    {
                        Caption = 'Print G/L Accs. without balance';
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

    trigger OnInitReport()
    begin
        CompanyInfo.GET;
    end;

    trigger OnPreReport()
    begin
        Filter := "G/L Account".GETFILTERS;
        GeneralLedgerSetup.Get();

    end;

    var
        Text001: Label 'You must fill in the %1 field.';
        Text002: Label 'You must specify a Starting Date.';
        Text003: Label 'Printed by %1';
        Text004: Label 'Fiscal Year Start Date : %1';
        Text005: Label 'Page %1';
        GLAccount2: Record 15;
        FiltreDateCalc: Codeunit "DateFilter-Calc";
        TotCompteBilanDebit: Decimal;
        TotCompteBilanCredit: Decimal;
        TotBilanDebit: Decimal;
        TotBilanCredit: Decimal;
        GLAccount4: Record 15;
        TotMovBilanDebit: Decimal;
        TotMovBilanCredit: Decimal;
        GLAccount5: Record 15;
        TotalSoldeBilanDebit: Decimal;
        TotalSoldeBilanCredit: Decimal;
        TotGestionDebit: Decimal;
        TotGestionCredit: Decimal;
        TotMovGestionDebit: Decimal;
        TotMovGestionCredit: Decimal;
        TotalSoldeGestionDebit: Decimal;
        TotalSoldeGestionCredit: Decimal;
        DebitCourant: Decimal;
        StartDate: Date;
        EndDate: Date;
        PreviousStartDate: Date;
        PreviousEndDate: Date;
        TextDate: Text[30];
        ImprNonMvt: Boolean;
        "Filter": Text[250];
        FiscalYearStatusText: Text[80];
        FYFiscalClose: Codeunit "Fiscal Year-Close";
        Text007: Label 'Fiscal-Year Status: %1';
        TLAccountType: Integer;
        SimulationEntriesCaptionLbl: Label 'This report includes simulation entries.';
        GLTrialBalCaptionLbl: Label 'G/L Trial Balance';
        NoCaptionLbl: Label 'No.';
        NameCaptionLbl: Label 'Name';
        BalAtStartingDateCaptionLbl: Label 'Balance at Starting Date';
        BalDateRangeCaptionLbl: Label 'Balance Date Range';
        BalAtEndingdateCaptionLbl: Label 'Balance at Ending date';
        DebitCaptionLbl: Label 'Debit';
        CreditCaptionLbl: Label 'Credit';
        TotalMouvDebit: Decimal;
        TotalMouvCredit: Decimal;
        TOTAL: Decimal;
        SoldeDebit: Decimal;
        SoldeCredit: Decimal;
        TestValAmount: Boolean;
        GLAccount3: Record 15;
        CompanyInfo: Record 79;
        TotBalanceDebit: Decimal;
        TotBalanceCredit: Decimal;
        GeneralLedgerSetup: Record "General Ledger Setup";
}

