codeunit 50300 "NAV Rebate Mgt."
{
    // ======================================================================
    // 1. Calculation
    // ======================================================================
    procedure Calculate(var RebateCalc: Record "NAV Rebate Calculation")
    var
        Agreement: Record "NAV Rebate Agreement";
        StartDate: Date;
        EndDate: Date;
    begin
        RebateCalc.TestStatus(RebateCalc.Status::Calculated);
        RebateCalc.TestField("Agreement No.");
        RebateCalc.TestField("Period Start");
        RebateCalc.TestField("Period End");
        if RebateCalc."Period End" < RebateCalc."Period Start" then
            Error(PeriodErr);
        Agreement.Get(RebateCalc."Agreement No.");
        Agreement.CheckActive(RebateCalc."Period Start", RebateCalc."Period End");
        CheckNoOtherCalculation(RebateCalc);
        if (RebateCalc."Rebate Type" = RebateCalc."Rebate Type"::"Core Rebate") and (RebateCalc."Adjustment Amount (LCY)" <> 0) then
            Error(CoreAdjustmentErr);

        // Only the part of the period covered by the agreement is taken into account
        StartDate := RebateCalc."Period Start";
        if Agreement."Starting Date" > StartDate then
            StartDate := Agreement."Starting Date";
        EndDate := RebateCalc."Period End";
        if (Agreement."Ending Date" <> 0D) and (Agreement."Ending Date" < EndDate) then
            EndDate := Agreement."Ending Date";

        RebateCalc."Rebate %" := Agreement."Rebate %";
        DeleteLines(RebateCalc);
        case RebateCalc."Rebate Type" of
            RebateCalc."Rebate Type"::"End of Deal",
            RebateCalc."Rebate Type"::"Cash Discount":
                InsertDocumentLines(RebateCalc, StartDate, EndDate);
            RebateCalc."Rebate Type"::"Core Rebate":
                InsertCoreLines(RebateCalc, StartDate, EndDate);
        end;
        if RebateCalc."Rebate Type" = RebateCalc."Rebate Type"::"Cash Discount" then
            CheckCashDiscountCondition(RebateCalc);

        RebateCalc."Calculation Date" := Today();
        if RebateCalc."Provision Posting Date" = 0D then
            RebateCalc."Provision Posting Date" := RebateCalc."Period End";
        UpdateTotals(RebateCalc);
        RebateCalc.Modify();
    end;

    // End of Deal / Cash Discount: one line per invoice and credit memo of the period
    // (customer ledger entries of the bill-to customer, Sales (LCY) = amount excl. VAT)
    local procedure InsertDocumentLines(var RebateCalc: Record "NAV Rebate Calculation"; StartDate: Date; EndDate: Date)
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        CalcLine: Record "NAV Rebate Calc. Line";
        LineNo: Integer;
    begin
        CustLedgEntry.SetCurrentKey("Customer No.", "Posting Date");
        CustLedgEntry.SetRange("Customer No.", RebateCalc."Customer No.");
        CustLedgEntry.SetRange("Posting Date", StartDate, EndDate);
        CustLedgEntry.SetFilter("Document Type", '%1|%2', CustLedgEntry."Document Type"::Invoice, CustLedgEntry."Document Type"::"Credit Memo");
        CustLedgEntry.SetRange(Reversed, false);
        if CustLedgEntry.FindSet() then
            repeat
                if (CustLedgEntry."Sales (LCY)" <> 0) and not IsRebateCreditMemo(CustLedgEntry) then begin
                    LineNo += 10000;
                    CalcLine.Init();
                    CalcLine."Calculation No." := RebateCalc."No.";
                    CalcLine."Line No." := LineNo;
                    if CustLedgEntry."Document Type" = CustLedgEntry."Document Type"::Invoice then
                        CalcLine."Document Type" := CalcLine."Document Type"::Invoice
                    else
                        CalcLine."Document Type" := CalcLine."Document Type"::"Credit Memo";
                    CalcLine."Document No." := CustLedgEntry."Document No.";
                    CalcLine."Posting Date" := CustLedgEntry."Posting Date";
                    CalcLine.Description := CustLedgEntry.Description;
                    CalcLine."Amount (LCY)" := CustLedgEntry."Sales (LCY)";
                    CalcLine."Due Date" := CustLedgEntry."Due Date";
                    if not CustLedgEntry.Open then
                        CalcLine."Closed at Date" := CustLedgEntry."Closed at Date";
                    CalcLine."Paid in Period" := (not CustLedgEntry.Open) and (CustLedgEntry."Closed at Date" <= RebateCalc."Period End");
                    CalcLine.Include := true;
                    CalcLine.Insert();
                end;
            until CustLedgEntry.Next() = 0;
    end;

    // Core Rebate: one line per posted invoice / credit memo line of an eligible item
    local procedure InsertCoreLines(var RebateCalc: Record "NAV Rebate Calculation"; StartDate: Date; EndDate: Date)
    var
        CoreLine: Record "NAV Core Rebate Line";
        InvLine: Record "Sales Invoice Line";
        CrMemoLine: Record "Sales Cr.Memo Line";
        InvHeader: Record "Sales Invoice Header";
        CrMemoHeader: Record "Sales Cr.Memo Header";
        LineNo: Integer;
    begin
        CoreLine.SetRange("Agreement No.", RebateCalc."Agreement No.");
        if not CoreLine.FindSet() then
            exit;
        repeat
            InvLine.Reset();
            InvLine.SetRange("Bill-to Customer No.", RebateCalc."Customer No.");
            InvLine.SetRange(Type, InvLine.Type::Item);
            InvLine.SetRange("No.", CoreLine."Item No.");
            InvLine.SetRange("Posting Date", StartDate, EndDate);
            InvLine.SetFilter(Quantity, '<>0');
            if InvLine.FindSet() then
                repeat
                    if InvHeader."No." <> InvLine."Document No." then
                        InvHeader.Get(InvLine."Document No.");
                    InsertCoreLine(RebateCalc, LineNo, CoreLine, Enum::"NAV Rebate Source Doc. Type"::Invoice,
                        InvLine."Document No.", InvLine."Posting Date", InvLine.Description,
                        InvLine."Quantity (Base)", ToLCY(InvLine.Amount, InvHeader."Currency Code", InvHeader."Currency Factor"));
                until InvLine.Next() = 0;

            CrMemoLine.Reset();
            CrMemoLine.SetRange("Bill-to Customer No.", RebateCalc."Customer No.");
            CrMemoLine.SetRange(Type, CrMemoLine.Type::Item);
            CrMemoLine.SetRange("No.", CoreLine."Item No.");
            CrMemoLine.SetRange("Posting Date", StartDate, EndDate);
            CrMemoLine.SetFilter(Quantity, '<>0');
            if CrMemoLine.FindSet() then
                repeat
                    if CrMemoHeader."No." <> CrMemoLine."Document No." then
                        CrMemoHeader.Get(CrMemoLine."Document No.");
                    InsertCoreLine(RebateCalc, LineNo, CoreLine, Enum::"NAV Rebate Source Doc. Type"::"Credit Memo",
                        CrMemoLine."Document No.", CrMemoLine."Posting Date", CrMemoLine.Description,
                        -CrMemoLine."Quantity (Base)", -ToLCY(CrMemoLine.Amount, CrMemoHeader."Currency Code", CrMemoHeader."Currency Factor"));
                until CrMemoLine.Next() = 0;
        until CoreLine.Next() = 0;
    end;

    local procedure InsertCoreLine(RebateCalc: Record "NAV Rebate Calculation"; var LineNo: Integer; CoreLine: Record "NAV Core Rebate Line"; DocType: Enum "NAV Rebate Source Doc. Type"; DocNo: Code[20]; PostingDate: Date; LineDescription: Text[100]; QtyBase: Decimal; AmountLCY: Decimal)
    var
        CalcLine: Record "NAV Rebate Calc. Line";
    begin
        LineNo += 10000;
        CalcLine.Init();
        CalcLine."Calculation No." := RebateCalc."No.";
        CalcLine."Line No." := LineNo;
        CalcLine."Document Type" := DocType;
        CalcLine."Document No." := DocNo;
        CalcLine."Posting Date" := PostingDate;
        CalcLine."Item No." := CoreLine."Item No.";
        CalcLine.Description := LineDescription;
        CalcLine."Quantity (Base)" := QtyBase;
        CalcLine."Amount (LCY)" := AmountLCY;
        CalcLine."Rebate Amount (LCY)" := Round(CoreLine.AmountForBaseQty(QtyBase));
        CalcLine.Include := true;
        CalcLine.Insert();
    end;

    // Cash Discount: granted only if every invoice of the customer due in the period
    // (whatever its posting date) was fully paid at the latest on the last day of the period
    local procedure CheckCashDiscountCondition(var RebateCalc: Record "NAV Rebate Calculation")
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        RebateCalc."Unpaid Due Invoices" := 0;
        CustLedgEntry.SetRange("Customer No.", RebateCalc."Customer No.");
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.SetRange("Due Date", RebateCalc."Period Start", RebateCalc."Period End");
        CustLedgEntry.SetRange(Reversed, false);
        if CustLedgEntry.FindSet() then
            repeat
                if CustLedgEntry.Open or (CustLedgEntry."Closed at Date" > RebateCalc."Period End") then
                    RebateCalc."Unpaid Due Invoices" += 1;
            until CustLedgEntry.Next() = 0;
        RebateCalc."Payment Condition Met" := RebateCalc."Unpaid Due Invoices" = 0;
    end;

    procedure UpdateTotals(var RebateCalc: Record "NAV Rebate Calculation")
    var
        CalcLine: Record "NAV Rebate Calc. Line";
        GLSetup: Record "General Ledger Setup";
        Amount: Decimal;
    begin
        GLSetup.Get();
        CalcLine.SetCurrentKey("Calculation No.", "Document Type", Include);
        CalcLine.SetRange("Calculation No.", RebateCalc."No.");
        CalcLine.SetRange("Document Type", CalcLine."Document Type"::Invoice);
        CalcLine.CalcSums("Amount (LCY)", "Rebate Amount (LCY)");
        RebateCalc."Sales Amount (LCY)" := CalcLine."Amount (LCY)";
        Amount := CalcLine."Rebate Amount (LCY)";

        CalcLine.SetRange("Document Type", CalcLine."Document Type"::"Credit Memo");
        CalcLine.SetRange(Include, true);
        CalcLine.CalcSums("Amount (LCY)", "Rebate Amount (LCY)");
        RebateCalc."Deducted Cr. Memos (LCY)" := -CalcLine."Amount (LCY)";
        Amount += CalcLine."Rebate Amount (LCY)";

        RebateCalc."Rebate Base (LCY)" := RebateCalc."Sales Amount (LCY)" - RebateCalc."Deducted Cr. Memos (LCY)" - RebateCalc."Adjustment Amount (LCY)";
        case RebateCalc."Rebate Type" of
            RebateCalc."Rebate Type"::"End of Deal":
                Amount := RebateCalc."Rebate Base (LCY)" * RebateCalc."Rebate %" / 100;
            RebateCalc."Rebate Type"::"Cash Discount":
                if RebateCalc."Payment Condition Met" then
                    Amount := RebateCalc."Rebate Base (LCY)" * RebateCalc."Rebate %" / 100
                else
                    Amount := 0;
        // Core Rebate: sum of the amounts per unit of the lines
        end;
        if Amount < 0 then
            Amount := 0;
        RebateCalc."Calculated Amount (LCY)" := Round(Amount, GLSetup."Amount Rounding Precision");
    end;

    local procedure CheckNoOtherCalculation(RebateCalc: Record "NAV Rebate Calculation")
    var
        Other: Record "NAV Rebate Calculation";
    begin
        Other.SetRange("Agreement No.", RebateCalc."Agreement No.");
        Other.SetFilter("No.", '<>%1', RebateCalc."No.");
        Other.SetFilter("Period Start", '..%1', RebateCalc."Period End");
        Other.SetFilter("Period End", '%1..', RebateCalc."Period Start");
        if Other.FindFirst() then
            Error(DuplicateErr, Other."No.", RebateCalc."Agreement No.", Other."Period Start", Other."Period End");
    end;

    procedure ExistsForPeriod(AgreementNo: Code[20]; PeriodStart: Date; PeriodEnd: Date): Boolean
    var
        Other: Record "NAV Rebate Calculation";
    begin
        Other.SetRange("Agreement No.", AgreementNo);
        Other.SetFilter("Period Start", '..%1', PeriodEnd);
        Other.SetFilter("Period End", '%1..', PeriodStart);
        exit(not Other.IsEmpty());
    end;

    // The rebate credit memos themselves must not reduce the base of the next rebates
    local procedure IsRebateCreditMemo(CustLedgEntry: Record "Cust. Ledger Entry"): Boolean
    var
        Other: Record "NAV Rebate Calculation";
    begin
        if CustLedgEntry."Document Type" <> CustLedgEntry."Document Type"::"Credit Memo" then
            exit(false);
        Other.SetRange("Posted Credit Memo No.", CustLedgEntry."Document No.");
        exit(not Other.IsEmpty());
    end;

    local procedure DeleteLines(RebateCalc: Record "NAV Rebate Calculation")
    var
        CalcLine: Record "NAV Rebate Calc. Line";
    begin
        CalcLine.SetRange("Calculation No.", RebateCalc."No.");
        CalcLine.DeleteAll();
    end;

    local procedure ToLCY(Amount: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal): Decimal
    begin
        if (CurrencyCode = '') or (CurrencyFactor = 0) then
            exit(Amount);
        exit(Round(Amount / CurrencyFactor));
    end;

    // ======================================================================
    // 2. Preliminary provision   Debit Expense / Credit Accrued
    // ======================================================================
    procedure PostProvision(var RebateCalc: Record "NAV Rebate Calculation")
    var
        RebateSetup: Record "NAV Rebate Setup";
        ExpenseAcc: Code[20];
        AccruedAcc: Code[20];
    begin
        RebateCalc.TestStatus(RebateCalc.Status::Calculated);
        RebateCalc.TestField("Calculation Date");
        RebateCalc.TestField("Provision Posting Date");
        UpdateTotals(RebateCalc);
        if RebateCalc."Calculated Amount (LCY)" <= 0 then
            Error(NothingToProvisionErr, RebateCalc."No.");
        RebateSetup.Get();
        RebateSetup.GetAccounts(RebateCalc."Rebate Type", ExpenseAcc, AccruedAcc);

        PostGLEntry(RebateCalc, RebateCalc."Provision Posting Date", ExpenseAcc, AccruedAcc,
            RebateCalc."Calculated Amount (LCY)",
            CopyStr(StrSubstNo(ProvisionTxt, RebateCalc."Rebate Type", RebateCalc."Customer No.", RebateCalc."Period Start", RebateCalc."Period End"), 1, 100));

        RebateCalc."Provision Amount (LCY)" := RebateCalc."Calculated Amount (LCY)";
        RebateCalc."Provision Document No." := RebateCalc."No.";
        RebateCalc.Status := RebateCalc.Status::Provisioned;
        RebateCalc.Modify();
    end;

    // ======================================================================
    // 3. Final negotiated amount
    //    Final < provision : the excess provision is reversed (Debit Accrued / Credit Expense)
    //    Final = 0         : provision fully reversed, calculation closed, no credit memo
    // ======================================================================
    procedure ValidateFinalAmount(var RebateCalc: Record "NAV Rebate Calculation"; PostingDate: Date)
    var
        RebateSetup: Record "NAV Rebate Setup";
        ExpenseAcc: Code[20];
        AccruedAcc: Code[20];
        ReverseAmount: Decimal;
    begin
        RebateCalc.TestStatus(RebateCalc.Status::Provisioned);
        if PostingDate = 0D then
            PostingDate := WorkDate();
        RebateSetup.Get();
        RebateSetup.GetAccounts(RebateCalc."Rebate Type", ExpenseAcc, AccruedAcc);

        RebateCalc."Difference (LCY)" := RebateCalc."Final Amount (LCY)" - RebateCalc."Provision Amount (LCY)";
        ReverseAmount := -RebateCalc."Difference (LCY)";
        if ReverseAmount > 0 then
            PostGLEntry(RebateCalc, PostingDate, AccruedAcc, ExpenseAcc, ReverseAmount,
                CopyStr(StrSubstNo(ReversalTxt, RebateCalc."Rebate Type", RebateCalc."Customer No."), 1, 100));

        RebateCalc."Validated By" := CopyStr(UserId(), 1, MaxStrLen(RebateCalc."Validated By"));
        RebateCalc."Validation Date" := PostingDate;
        if RebateCalc."Final Amount (LCY)" = 0 then
            RebateCalc.Status := RebateCalc.Status::Closed
        else
            RebateCalc.Status := RebateCalc.Status::Validated;
        RebateCalc.Modify();
    end;

    // ======================================================================
    // 4. Final financial credit memo
    //    Debit Accrued  (up to the provision)
    //    Debit Expense  (final - provision, if positive)
    //    Credit Customer
    // ======================================================================
    procedure CreateCreditMemo(var RebateCalc: Record "NAV Rebate Calculation"; PostingDate: Date): Code[20]
    var
        RebateSetup: Record "NAV Rebate Setup";
        SalesHeader: Record "Sales Header";
        ExpenseAcc: Code[20];
        AccruedAcc: Code[20];
        AccruedPart: Decimal;
        ExpensePart: Decimal;
        LineNo: Integer;
    begin
        RebateCalc.TestStatus(RebateCalc.Status::Validated);
        RebateCalc.TestField("Final Amount (LCY)");
        if RebateCalc."Credit Memo No." <> '' then
            if SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", RebateCalc."Credit Memo No.") then
                Error(CreditMemoExistsErr, RebateCalc."Credit Memo No.", RebateCalc."No.");
        if PostingDate = 0D then
            PostingDate := WorkDate();
        RebateSetup.Get();
        RebateSetup.GetAccounts(RebateCalc."Rebate Type", ExpenseAcc, AccruedAcc);

        AccruedPart := RebateCalc."Final Amount (LCY)";
        if AccruedPart > RebateCalc."Provision Amount (LCY)" then
            AccruedPart := RebateCalc."Provision Amount (LCY)";
        ExpensePart := RebateCalc."Final Amount (LCY)" - AccruedPart;

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", RebateCalc."Customer No.");
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Document Date", PostingDate);
        SalesHeader.Validate("Prices Including VAT", false);
        if RebateSetup."Credit Memo Reason Code" <> '' then
            SalesHeader.Validate("Reason Code", RebateSetup."Credit Memo Reason Code");
        SalesHeader."External Document No." := RebateCalc."No.";
        SalesHeader."Your Reference" := CopyStr(StrSubstNo(YourRefTxt, RebateCalc."Rebate Type", RebateCalc."Period Start", RebateCalc."Period End"), 1, MaxStrLen(SalesHeader."Your Reference"));
        SalesHeader.Modify(true);

        if AccruedPart > 0 then
            InsertCreditMemoLine(SalesHeader, LineNo, AccruedAcc, AccruedPart,
                CopyStr(StrSubstNo(CrMemoLineTxt, RebateCalc."Rebate Type", RebateCalc."Period Start", RebateCalc."Period End"), 1, 100));
        if ExpensePart > 0 then
            InsertCreditMemoLine(SalesHeader, LineNo, ExpenseAcc, ExpensePart,
                CopyStr(StrSubstNo(CrMemoExtraLineTxt, RebateCalc."Rebate Type"), 1, 100));

        RebateCalc."Credit Memo No." := SalesHeader."No.";
        RebateCalc.Modify();
        exit(SalesHeader."No.");
    end;

    local procedure InsertCreditMemoLine(SalesHeader: Record "Sales Header"; var LineNo: Integer; GLAccNo: Code[20]; AmountLCY: Decimal; LineDescription: Text[100])
    var
        SalesLine: Record "Sales Line";
        CurrExchRate: Record "Currency Exchange Rate";
        UnitPrice: Decimal;
    begin
        UnitPrice := AmountLCY;
        if SalesHeader."Currency Code" <> '' then
            UnitPrice := Round(CurrExchRate.ExchangeAmtLCYToFCY(SalesHeader."Posting Date", SalesHeader."Currency Code", AmountLCY, SalesHeader."Currency Factor"));
        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", GLAccNo);
        SalesLine.Description := LineDescription;
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
    end;

    // ======================================================================
    // G/L posting without VAT, with the default dimensions of the customer
    // ======================================================================
    local procedure PostGLEntry(RebateCalc: Record "NAV Rebate Calculation"; PostingDate: Date; DebitAcc: Code[20]; CreditAcc: Code[20]; Amount: Decimal; EntryDescription: Text[100])
    var
        RebateSetup: Record "NAV Rebate Setup";
        GenJnlLine: Record "Gen. Journal Line";
        DimMgt: Codeunit DimensionManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        GlobalDim1: Code[20];
        GlobalDim2: Code[20];
    begin
        RebateSetup.Get();
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Document Date" := PostingDate;
        GenJnlLine."Document No." := RebateCalc."No.";
        GenJnlLine."External Document No." := RebateCalc."Agreement No.";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine.Validate("Account No.", DebitAcc);
        ClearPostingGroups(GenJnlLine);
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
        GenJnlLine.Validate("Bal. Account No.", CreditAcc);
        ClearBalPostingGroups(GenJnlLine);
        GenJnlLine.Validate(Amount, Amount);
        GenJnlLine.Description := EntryDescription;
        GenJnlLine."Source Code" := RebateSetup."Source Code";
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Customer;
        GenJnlLine."Source No." := RebateCalc."Customer No.";
        GenJnlLine."System-Created Entry" := true;

        DimMgt.AddDimSource(DefaultDimSource, Database::Customer, RebateCalc."Customer No.");
        GenJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(DefaultDimSource, RebateSetup."Source Code", GlobalDim1, GlobalDim2, 0, 0);
        GenJnlLine."Shortcut Dimension 1 Code" := GlobalDim1;
        GenJnlLine."Shortcut Dimension 2 Code" := GlobalDim2;

        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure ClearPostingGroups(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine."Gen. Posting Type" := GenJnlLine."Gen. Posting Type"::" ";
        GenJnlLine."Gen. Bus. Posting Group" := '';
        GenJnlLine."Gen. Prod. Posting Group" := '';
        GenJnlLine."VAT Bus. Posting Group" := '';
        GenJnlLine."VAT Prod. Posting Group" := '';
    end;

    local procedure ClearBalPostingGroups(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine."Bal. Gen. Posting Type" := GenJnlLine."Bal. Gen. Posting Type"::" ";
        GenJnlLine."Bal. Gen. Bus. Posting Group" := '';
        GenJnlLine."Bal. Gen. Prod. Posting Group" := '';
        GenJnlLine."Bal. VAT Bus. Posting Group" := '';
        GenJnlLine."Bal. VAT Prod. Posting Group" := '';
    end;

    // ======================================================================
    // 5. Posted credit memo -> calculation Credited
    // ======================================================================
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesCrMemoHdrNo: Code[20]; PreviewMode: Boolean)
    var
        RebateCalc: Record "NAV Rebate Calculation";
        CrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if PreviewMode or (SalesCrMemoHdrNo = '') then
            exit;
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::"Credit Memo" then
            exit;
        RebateCalc.SetRange("Credit Memo No.", SalesHeader."No.");
        RebateCalc.SetRange(Status, RebateCalc.Status::Validated);
        if not RebateCalc.FindFirst() then
            exit;
        if CrMemoHeader.Get(SalesCrMemoHdrNo) then
            RebateCalc."Credit Memo Posting Date" := CrMemoHeader."Posting Date";
        RebateCalc."Posted Credit Memo No." := SalesCrMemoHdrNo;
        RebateCalc.Status := RebateCalc.Status::Credited;
        RebateCalc.Modify();
    end;

    var
        PeriodErr: Label 'The period end must be after the period start.';
        CoreAdjustmentErr: Label 'The adjustment amount is not used for a Core Rebate (the rebate is a fixed amount per unit sold). Exclude the credit memos instead.';
        DuplicateErr: Label 'Rebate calculation %1 already exists for agreement %2 on the period %3..%4.', Comment = '%1 = calculation, %2 = agreement, %3 = start, %4 = end';
        NothingToProvisionErr: Label 'The calculated rebate of %1 is zero: there is nothing to provision.', Comment = '%1 = calculation';
        ProvisionTxt: Label 'Provision %1 %2 %3..%4', Comment = '%1 = rebate type, %2 = customer, %3 = start, %4 = end';
        ReversalTxt: Label 'Provision reversal %1 %2', Comment = '%1 = rebate type, %2 = customer';
        CreditMemoExistsErr: Label 'Credit memo %1 already exists for rebate calculation %2.', Comment = '%1 = credit memo, %2 = calculation';
        YourRefTxt: Label 'Rebate %1 %2..%3', Comment = '%1 = type, %2 = start, %3 = end';
        CrMemoLineTxt: Label '%1 rebate %2..%3', Comment = '%1 = type, %2 = start, %3 = end';
        CrMemoExtraLineTxt: Label '%1 rebate - additional amount', Comment = '%1 = type';
}
