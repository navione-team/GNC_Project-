// FRD 11.3: when settling a foreign currency invoice, show the rate of the invoice and
// simulate the exchange difference resulting from the rate of the payment date.
//   Applied FCY      = part of the invoice settled by the payment line
//   Invoice LCY      = Applied FCY at the invoice rate   (Original Currency Factor)
//   Payment LCY      = Applied FCY at the payment rate   (Currency Factor of the line)
//   Vendor payment   : gain = Invoice LCY - Payment LCY  (paying less LCY than booked)
//   Customer receipt : gain = Payment LCY - Invoice LCY  (receiving more LCY than booked)
// Positive result = realized gain, negative = realized loss. Nothing is posted.
codeunit 50320 "NAV Exch. Diff. Simulation"
{
    procedure Simulate(GenJnlLine: Record "Gen. Journal Line"; var InvoiceRate: Decimal; var PaymentRate: Decimal; var AppliedFCY: Decimal; var ExchDiffLCY: Decimal): Boolean
    var
        CustNo: Code[20];
        VendNo: Code[20];
    begin
        InvoiceRate := 0;
        PaymentRate := 0;
        AppliedFCY := 0;
        ExchDiffLCY := 0;
        if (GenJnlLine."Currency Code" = '') or (GenJnlLine."Currency Factor" = 0) or (GenJnlLine.Amount = 0) then
            exit(false);
        if (GenJnlLine."Applies-to Doc. No." = '') and (GenJnlLine."Applies-to ID" = '') then
            exit(false);

        case true of
            GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor:
                VendNo := GenJnlLine."Account No.";
            GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Vendor:
                VendNo := GenJnlLine."Bal. Account No.";
            GenJnlLine."Account Type" = GenJnlLine."Account Type"::Customer:
                CustNo := GenJnlLine."Account No.";
            GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Customer:
                CustNo := GenJnlLine."Bal. Account No.";
        end;
        PaymentRate := RateOf(GenJnlLine."Currency Factor");

        if VendNo <> '' then
            exit(SimulateVendor(GenJnlLine, VendNo, InvoiceRate, AppliedFCY, ExchDiffLCY));
        if CustNo <> '' then
            exit(SimulateCustomer(GenJnlLine, CustNo, InvoiceRate, AppliedFCY, ExchDiffLCY));
        exit(false);
    end;

    local procedure SimulateVendor(GenJnlLine: Record "Gen. Journal Line"; VendNo: Code[20]; var InvoiceRate: Decimal; var AppliedFCY: Decimal; var ExchDiffLCY: Decimal): Boolean
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        ToApply: Decimal;
        Remaining: Decimal;
        Part: Decimal;
        InvoiceLCY: Decimal;
        PaymentLCY: Decimal;
    begin
        Remaining := Abs(GenJnlLine.Amount);
        VendLedgEntry.SetRange("Vendor No.", VendNo);
        VendLedgEntry.SetRange(Open, true);
        VendLedgEntry.SetRange("Currency Code", GenJnlLine."Currency Code");
        if GenJnlLine."Applies-to Doc. No." <> '' then begin
            VendLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
            VendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
        end else
            VendLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
        if not VendLedgEntry.FindSet() then
            exit(false);
        repeat
            VendLedgEntry.CalcFields("Remaining Amount");
            if GenJnlLine."Applies-to ID" <> '' then
                ToApply := Abs(VendLedgEntry."Amount to Apply")
            else
                ToApply := Abs(VendLedgEntry."Remaining Amount");
            Part := ToApply;
            if Part > Remaining then
                Part := Remaining;
            if (Part > 0) and (VendLedgEntry."Original Currency Factor" <> 0) then begin
                AppliedFCY += Part;
                InvoiceLCY += Part / VendLedgEntry."Original Currency Factor";
                PaymentLCY += Part / GenJnlLine."Currency Factor";
                Remaining -= Part;
            end;
        until (VendLedgEntry.Next() = 0) or (Remaining <= 0);
        if AppliedFCY = 0 then
            exit(false);
        InvoiceRate := Round(InvoiceLCY / AppliedFCY, 0.000001);
        ExchDiffLCY := Round(InvoiceLCY - PaymentLCY);
        exit(true);
    end;

    local procedure SimulateCustomer(GenJnlLine: Record "Gen. Journal Line"; CustNo: Code[20]; var InvoiceRate: Decimal; var AppliedFCY: Decimal; var ExchDiffLCY: Decimal): Boolean
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        ToApply: Decimal;
        Remaining: Decimal;
        Part: Decimal;
        InvoiceLCY: Decimal;
        PaymentLCY: Decimal;
    begin
        Remaining := Abs(GenJnlLine.Amount);
        CustLedgEntry.SetRange("Customer No.", CustNo);
        CustLedgEntry.SetRange(Open, true);
        CustLedgEntry.SetRange("Currency Code", GenJnlLine."Currency Code");
        if GenJnlLine."Applies-to Doc. No." <> '' then begin
            CustLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
            CustLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
        end else
            CustLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
        if not CustLedgEntry.FindSet() then
            exit(false);
        repeat
            CustLedgEntry.CalcFields("Remaining Amount");
            if GenJnlLine."Applies-to ID" <> '' then
                ToApply := Abs(CustLedgEntry."Amount to Apply")
            else
                ToApply := Abs(CustLedgEntry."Remaining Amount");
            Part := ToApply;
            if Part > Remaining then
                Part := Remaining;
            if (Part > 0) and (CustLedgEntry."Original Currency Factor" <> 0) then begin
                AppliedFCY += Part;
                InvoiceLCY += Part / CustLedgEntry."Original Currency Factor";
                PaymentLCY += Part / GenJnlLine."Currency Factor";
                Remaining -= Part;
            end;
        until (CustLedgEntry.Next() = 0) or (Remaining <= 0);
        if AppliedFCY = 0 then
            exit(false);
        InvoiceRate := Round(InvoiceLCY / AppliedFCY, 0.000001);
        ExchDiffLCY := Round(PaymentLCY - InvoiceLCY);
        exit(true);
    end;

    // Exchange rate shown as LCY for 1 unit of foreign currency
    local procedure RateOf(CurrencyFactor: Decimal): Decimal
    begin
        if CurrencyFactor = 0 then
            exit(0);
        exit(Round(1 / CurrencyFactor, 0.000001));
    end;

    // Message with the simulation of every line of the journal batch
    procedure ShowBatchSimulation(GenJnlLine: Record "Gen. Journal Line")
    var
        Line: Record "Gen. Journal Line";
        InvoiceRate: Decimal;
        PaymentRate: Decimal;
        AppliedFCY: Decimal;
        ExchDiff: Decimal;
        Total: Decimal;
        Details: TextBuilder;
        NoOfLines: Integer;
    begin
        Line.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        Line.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        if Line.FindSet() then
            repeat
                if Simulate(Line, InvoiceRate, PaymentRate, AppliedFCY, ExchDiff) then begin
                    NoOfLines += 1;
                    Total += ExchDiff;
                    Details.AppendLine(StrSubstNo(LineTxt, Line."Document No.", Line."Account No.", Line."Applies-to Doc. No." + Line."Applies-to ID",
                        AppliedFCY, Line."Currency Code", InvoiceRate, PaymentRate, ExchDiff));
                end;
            until Line.Next() = 0;
        if NoOfLines = 0 then
            Message(NothingMsg)
        else
            Message(SummaryMsg, Details.ToText(), Total);
    end;

    var
        LineTxt: Label '%1 %2 applied to %3: %4 %5, invoice rate %6, payment rate %7, difference %8', Comment = '%1 = doc no., %2 = account, %3 = applied doc, %4 = amount, %5 = currency, %6 = invoice rate, %7 = payment rate, %8 = difference';
        SummaryMsg: Label '%1\Total simulated exchange difference (LCY): %2\(positive = gain, negative = loss)', Comment = '%1 = details, %2 = total';
        NothingMsg: Label 'No foreign currency line applied to an open invoice in this journal.';
}
