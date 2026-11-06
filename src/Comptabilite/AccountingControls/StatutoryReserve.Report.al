// FRD 5.4 closing matrix: Statutory Reserve 10% of the net profit, until the reserve reaches 30% of the capital.
// Run AFTER Close Income Statement. Creates (does not post) the journal lines:
//   Debit  Retained Earnings (3200)
//   Credit Statutory Reserve (3400)
// on the closing date of the fiscal year, for review and posting by the accountant.
report 50320 "NAV Calc. Statutory Reserve"
{
    Caption = 'Calculate Statutory Reserve';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Tasks;

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

                    field(FiscalYearEndField; FiscalYearEnd)
                    {
                        ApplicationArea = All;
                        Caption = 'Fiscal Year Ending Date';
                        ToolTip = 'Specifies the last day of the closed fiscal year, e.g. 31/12/2026. The lines are dated on the closing date of that day.';

                        trigger OnValidate()
                        begin
                            SetFiscalYearStart();
                        end;
                    }
                    field(FiscalYearStartField; FiscalYearStart)
                    {
                        ApplicationArea = All;
                        Caption = 'Fiscal Year Starting Date';
                        Editable = false;
                        ToolTip = 'Specifies the first day of the fiscal year, from the accounting periods.';
                    }
                    field(TemplateField; JnlTemplateName)
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Template Name';
                        TableRelation = "Gen. Journal Template" where(Type = const(General), Recurring = const(false));
                        ToolTip = 'Specifies the general journal template where the lines are created.';
                    }
                    field(BatchField; JnlBatchName)
                    {
                        ApplicationArea = All;
                        Caption = 'Journal Batch Name';
                        ToolTip = 'Specifies the general journal batch where the lines are created.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GenJnlBatch: Record "Gen. Journal Batch";
                        begin
                            GenJnlBatch.SetRange("Journal Template Name", JnlTemplateName);
                            if Page.RunModal(0, GenJnlBatch) = Action::LookupOK then begin
                                Text := GenJnlBatch.Name;
                                exit(true);
                            end;
                        end;
                    }
                    field(DocNoField; DocumentNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the document no. of the reserve entry, e.g. RES-2026.';
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        Setup.Get();
        Setup.TestField("Reserve Account No.");
        Setup.TestField("Retained Earnings Account No.");
        Setup.TestField("Capital Account Filter");
        Setup.TestField("Reserve %");
        if FiscalYearEnd = 0D then
            Error(DateMissingErr);
        SetFiscalYearStart();
        if JnlTemplateName = '' then
            Error(JournalMissingErr);
        if JnlBatchName = '' then
            Error(JournalMissingErr);
        if DocumentNo = '' then
            Error(DocNoMissingErr);
        CheckNotAlreadyPosted();
    end;

    trigger OnPostReport()
    var
        NetProfit: Decimal;
        Capital: Decimal;
        CurrentReserve: Decimal;
        Ceiling: Decimal;
        Reserve: Decimal;
    begin
        NetProfit := GetNetProfit();
        Capital := -GetBalance(Setup."Capital Account Filter", ClosingDate(FiscalYearEnd));
        CurrentReserve := -GetBalance(Setup."Reserve Account No.", ClosingDate(FiscalYearEnd));
        Ceiling := Round(Capital * Setup."Max. % of Capital" / 100);

        if NetProfit <= 0 then begin
            Message(NoProfitMsg, FiscalYearStart, FiscalYearEnd, NetProfit);
            exit;
        end;
        if (Setup."Max. % of Capital" <> 0) and (CurrentReserve >= Ceiling) then begin
            Message(CeilingReachedMsg, CurrentReserve, Ceiling, Setup."Max. % of Capital");
            exit;
        end;

        Reserve := Round(NetProfit * Setup."Reserve %" / 100);
        if (Setup."Max. % of Capital" <> 0) and (CurrentReserve + Reserve > Ceiling) then
            Reserve := Ceiling - CurrentReserve;

        InsertLines(Reserve);
        Message(DoneMsg, NetProfit, Setup."Reserve %", CurrentReserve, Ceiling, Reserve, JnlTemplateName, JnlBatchName);
    end;

    // Net profit of the year = - net change of the income statement accounts,
    // normal dates only (the closing entries posted on the closing date are excluded)
    local procedure GetNetProfit(): Decimal
    var
        GLAccount: Record "G/L Account";
        Total: Decimal;
    begin
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Income Statement");
        GLAccount.SetRange("Date Filter", FiscalYearStart, FiscalYearEnd);
        if GLAccount.FindSet() then
            repeat
                GLAccount.CalcFields("Net Change");
                Total += GLAccount."Net Change";
            until GLAccount.Next() = 0;
        exit(-Total);
    end;

    local procedure GetBalance(AccountFilter: Text; AtDate: Date): Decimal
    var
        GLAccount: Record "G/L Account";
        Total: Decimal;
    begin
        GLAccount.SetFilter("No.", AccountFilter);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Date Filter", 0D, AtDate);
        if GLAccount.FindSet() then
            repeat
                GLAccount.CalcFields("Balance at Date");
                Total += GLAccount."Balance at Date";
            until GLAccount.Next() = 0;
        exit(Total);
    end;

    local procedure CheckNotAlreadyPosted()
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", Setup."Reserve Account No.");
        GLEntry.SetRange("Posting Date", ClosingDate(FiscalYearEnd));
        if not GLEntry.IsEmpty() then
            Error(AlreadyPostedErr, ClosingDate(FiscalYearEnd));
    end;

    local procedure InsertLines(Reserve: Decimal)
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        LineNo: Integer;
    begin
        GenJnlTemplate.Get(JnlTemplateName);
        GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
        GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
        if GenJnlLine.FindLast() then
            LineNo := GenJnlLine."Line No.";
        InsertLine(GenJnlTemplate, LineNo, Setup."Retained Earnings Account No.", Reserve);
        InsertLine(GenJnlTemplate, LineNo, Setup."Reserve Account No.", -Reserve);
    end;

    local procedure InsertLine(GenJnlTemplate: Record "Gen. Journal Template"; var LineNo: Integer; AccountNo: Code[20]; LineAmount: Decimal)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        LineNo += 10000;
        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := JnlTemplateName;
        GenJnlLine."Journal Batch Name" := JnlBatchName;
        GenJnlLine."Line No." := LineNo;
        GenJnlLine.Validate("Posting Date", ClosingDate(FiscalYearEnd));
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
        GenJnlLine.Validate("Account No.", AccountNo);
        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
        GenJnlLine."Gen. Bus. Posting Group" := '';
        GenJnlLine."Gen. Prod. Posting Group" := '';
        GenJnlLine."VAT Bus. Posting Group" := '';
        GenJnlLine."VAT Prod. Posting Group" := '';
        GenJnlLine.Validate(Amount, LineAmount);
        GenJnlLine.Description := CopyStr(StrSubstNo(DescriptionTxt, Date2DMY(FiscalYearEnd, 3)), 1, MaxStrLen(GenJnlLine.Description));
        GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
        GenJnlLine.Insert(true);
    end;

    local procedure SetFiscalYearStart()
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        FiscalYearStart := 0D;
        if FiscalYearEnd = 0D then
            exit;
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.SetFilter("Starting Date", '..%1', FiscalYearEnd);
        if AccountingPeriod.FindLast() then
            FiscalYearStart := AccountingPeriod."Starting Date"
        else
            FiscalYearStart := DMY2Date(1, 1, Date2DMY(FiscalYearEnd, 3));
    end;

    var
        Setup: Record "NAV Statutory Reserve Setup";
        FiscalYearStart: Date;
        FiscalYearEnd: Date;
        JnlTemplateName: Code[10];
        JnlBatchName: Code[10];
        DocumentNo: Code[20];
        DateMissingErr: Label 'Enter the fiscal year ending date.';
        JournalMissingErr: Label 'Enter the journal template and batch where the reserve lines are created.';
        DocNoMissingErr: Label 'Enter the document no. of the reserve entry.';
        AlreadyPostedErr: Label 'A statutory reserve entry already exists on %1.', Comment = '%1 = closing date';
        NoProfitMsg: Label 'The fiscal year %1..%2 has no net profit (%3). No statutory reserve is created.', Comment = '%1 = start, %2 = end, %3 = result';
        CeilingReachedMsg: Label 'The statutory reserve (%1) has already reached its ceiling (%2 = %3 % of the capital). No statutory reserve is created.', Comment = '%1 = reserve, %2 = ceiling, %3 = %';
        DoneMsg: Label 'Net profit: %1\Reserve rate: %2 %\Current reserve: %3, ceiling: %4\Statutory reserve created: %5\\The lines are in journal %6 %7: review and post them.', Comment = '%1 = profit, %2 = %, %3 = current, %4 = ceiling, %5 = reserve, %6 = template, %7 = batch';
        DescriptionTxt: Label 'Statutory reserve %1', Comment = '%1 = year';
}
