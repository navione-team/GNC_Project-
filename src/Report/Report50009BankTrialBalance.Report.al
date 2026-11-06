report 50009 "Bank Account Trial Bal NAVIONE"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/RDLC/Bank Account Trial Balance.rdl';
    CaptionML = ENU = 'Bank Account Trial Balance';

    dataset
    {
        dataitem("Bank Account"; 270)
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
            column(STRSUBSTNO_Text005_____; STRSUBSTNO(Text005, ' '))
            {
            }
            column(PrintedByCaption; STRSUBSTNO(Text003, ''))
            {
            }
            column(Bank_Account__TABLECAPTION__________Filter; "Bank Account".TABLECAPTION + ': ' + Filter)
            {
            }
            column("Filter"; Filter)
            {
            }
            column(AfficherfiltreDate; AfficherfiltreDate)
            {
            }
            column(AfficherDate; AfficherDate)
            {
            }
            column(AfficherUtilisateur; AfficherUtilisateur)
            {
            }
            column(Bank_Account__No__; "No.")
            {
            }
            column(Bank_Account_Name; Name)
            {
            }
            column(BankAccount2__Debit_Amount__LCY_____BankAccount2__Credit_Amount__LCY__; BankAccount2."Debit Amount (LCY)" - BankAccount2."Credit Amount (LCY)")
            {
            }
            column(BankAccount2__Credit_Amount__LCY_____BankAccount2__Debit_Amount__LCY__; BankAccount2."Credit Amount (LCY)" - BankAccount2."Debit Amount (LCY)")
            {
            }
            column(Bank_Account__Debit_Amount__LCY__; "Debit Amount (LCY)")
            {
                AutoFormatExpression = GeneralLedgerSetup."LCY Code";
                AutoFormatType = 1;
            }
            column(Bank_Account__Credit_Amount__LCY__; "Credit Amount (LCY)")
            {
                AutoFormatExpression = GeneralLedgerSetup."LCY Code";
                AutoFormatType = 1;
            }
            column(BankAccount2__Debit_Amount__LCY______Debit_Amount__LCY_____BankAccount2__Credit_Amount__LCY______Credit_Amount__LCY__; BankAccount2."Debit Amount (LCY)" + "Debit Amount (LCY)" - BankAccount2."Credit Amount (LCY)" - "Credit Amount (LCY)")
            {
            }
            column(BankAccount2__Credit_Amount__LCY______Credit_Amount__LCY_____BankAccount2__Debit_Amount__LCY______Debit_Amount__LCY__; BankAccount2."Credit Amount (LCY)" + "Credit Amount (LCY)" - BankAccount2."Debit Amount (LCY)" - "Debit Amount (LCY)")
            {
            }
            column(BankAccount2__Debit_Amount__LCY_____BankAccount2__Credit_Amount__LCY___Control1120069; BankAccount2."Debit Amount (LCY)" - BankAccount2."Credit Amount (LCY)")
            {
            }
            column(BankAccount2__Credit_Amount__LCY_____BankAccount2__Debit_Amount__LCY___Control1120072; BankAccount2."Credit Amount (LCY)" - BankAccount2."Debit Amount (LCY)")
            {
            }
            column(Bank_Account__Debit_Amount__LCY___Control1120075; "Debit Amount (LCY)")
            {
            }
            column(Bank_Account__Credit_Amount__LCY___Control1120078; "Credit Amount (LCY)")
            {
            }
            column(DataItem1120081; BankAccount2."Debit Amount (LCY)" + "Debit Amount (LCY)" - BankAccount2."Credit Amount (LCY)" - "Credit Amount (LCY)")
            {
            }
            column(DataItem1120084; BankAccount2."Credit Amount (LCY)" + "Credit Amount (LCY)" - BankAccount2."Debit Amount (LCY)" - "Debit Amount (LCY)")
            {
            }
            column(Bank_Account_Trial_BalanceCaption; Bank_Account_Trial_BalanceCaptionLbl)
            {
            }
            column(No_Caption; No_CaptionLbl)
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
            column(Picture; RecGCompanyInfo.Picture)
            {
            }
            column(RecGCompanyInfoCity; RecGCompanyInfo.City)
            {
            }
            column(Phone; RecGCompanyInfo."Phone No.")
            {
            }
            column(Fax; RecGCompanyInfo."Fax No.")
            {
            }
            column(MatriculeFiscal; RecGCompanyInfo."VAT Registration No.")
            {
            }
            column(TxtAdresse; TXTADRESSE)
            {
            }
            column(Account; Account)
            {
            }
            trigger OnAfterGetRecord();
            begin
                BankAccount2 := "Bank Account";
                WITH BankAccount2 DO BEGIN
                    SETRANGE("Date Filter", 0D, PreviousEndDate);
                    CALCFIELDS("Debit Amount (LCY)", "Credit Amount (LCY)");
                END;
                /*IF NOT PrintBanksWithoutBalance AND
                   (BankAccount2."Debit Amount (LCY)" = 0) AND
                   ("Debit Amount (LCY)" = 0) AND
                   (BankAccount2."Credit Amount (LCY)" = 0) AND
                   ("Credit Amount (LCY)" = 0)
                THEN
                  CurrReport.SKIP;*/
                //MD
                IF NOT PrintBanksWithoutBalance AND NOT (PrintBanksWithTransactions) AND (BankAccount2."Debit Amount (LCY)" = 0) AND ("Debit Amount (LCY)" = 0) AND (BankAccount2."Credit Amount (LCY)" = 0) AND ("Credit Amount (LCY)" = 0) THEN CurrReport.SKIP;
                IF NOT PrintBanksWithoutBalance AND (PrintBanksWithTransactions) AND ("Debit Amount (LCY)" = 0) AND ("Credit Amount (LCY)" = 0) THEN CurrReport.SKIP;
                //MD
                BankAccountPostingGroup.RESET;
                BankAccountPostingGroup.SetRange(Code, "Bank Account"."Bank Acc. Posting Group");
                if BankAccountPostingGroup.FindFirst() then Account := BankAccountPostingGroup."G/L Account No.";
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
                CurrReport.CREATETOTALS(BankAccount2."Debit Amount (LCY)", BankAccount2."Credit Amount (LCY)");
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

                    field(PrintBanksWithoutBalance; PrintBanksWithoutBalance)
                    {
                        CaptionML = ENU = 'Print Banks without Balance';
                        ApplicationArea = all;
                    }
                    field(PrintBanksWithTransactions; PrintBanksWithTransactions)
                    {
                        CaptionML = ENU = 'Print Banks With Transactions';
                        ApplicationArea = all;
                    }
                    field("Afficher fitres"; AfficherfiltreDate)
                    {
                        CaptionML = ENU = 'Show date filter';
                        ApplicationArea = all;
                    }
                    field("Afficher date"; AfficherDate)
                    {
                        CaptionML = ENU = 'Show date';
                        ApplicationArea = all;
                    }
                    field("Afficher fitre date"; AfficherUtilisateur)
                    {
                        CaptionML = ENU = 'Show User';
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
    trigger OnInitReport();
    begin
        //>>DELTA SN
        GeneralLedgerSetup.Get();
        RecGCompanyInfo.GET;
        RecGCompanyInfo.CALCFIELDS(Picture);
        TXTADRESSE := RecGCompanyInfo.Address + ' ' + RecGCompanyInfo.City + ' ' + RecGCompanyInfo."Post Code";
        //>>DELTA SN
    end;

    trigger OnPreReport();
    begin
        Filter := "Bank Account".GETFILTERS;
    end;

    var
        Text001: TextConst ENU = 'You must fill in the %1 field.';
        Text002: TextConst ENU = 'You must specify a Starting Date.';
        Text003: TextConst ENU = 'Printed by %1';
        Text004: TextConst ENU = 'Fiscal Year Start Date : %1';
        Text005: TextConst ENU = 'Page %1';
        BankAccount2: Record "Bank Account";
        FiltreDateCalc: Codeunit "ST DateFilter-Calc Delta";
        StartDate: Date;
        PreviousStartDate: Date;
        PreviousEndDate: Date;
        TextDate: Text;
        PrintBanksWithoutBalance: Boolean;
        "Filter": Text;
        Bank_Account_Trial_BalanceCaptionLbl: TextConst ENU = 'Bank Account Trial Balance';
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
        RecGCompanyInfo: Record "Company Information";
        PrintBanksWithTransactions: Boolean;
        GeneralLedgerSetup: Record "General Ledger Setup";
        AfficherfiltreDate: Boolean;
        AfficherDate: Boolean;
        AfficherUtilisateur: Boolean;
        TXTADRESSE: Text;
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        Account: Code[20];
}
