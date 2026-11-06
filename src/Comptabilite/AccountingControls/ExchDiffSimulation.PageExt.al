pageextension 50320 "NAV Payment Jnl. Exch. Diff." extends "Payment Journal"
{
    layout
    {
        addafter(Amount)
        {
            field(NAVInvoiceRate; InvoiceRate)
            {
                ApplicationArea = All;
                Caption = 'Invoice Exch. Rate';
                DecimalPlaces = 0 : 6;
                Editable = false;
                ToolTip = 'Specifies the exchange rate (LCY for 1 unit of currency) of the applied invoice(s).';
            }
            field(NAVPaymentRate; PaymentRate)
            {
                ApplicationArea = All;
                Caption = 'Payment Exch. Rate';
                DecimalPlaces = 0 : 6;
                Editable = false;
                ToolTip = 'Specifies the exchange rate (LCY for 1 unit of currency) of the payment, at its posting date.';
            }
            field(NAVSimExchDiff; ExchDiffLCY)
            {
                ApplicationArea = All;
                Caption = 'Simulated Exch. Difference (LCY)';
                AutoFormatType = 1;
                Editable = false;
                StyleExpr = ExchDiffStyle;
                ToolTip = 'Specifies the realized exchange difference that the posting will generate on the applied invoice(s). Positive = gain, negative = loss.';
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(NAVSimulateExchDiff)
            {
                ApplicationArea = All;
                Caption = 'Simulate Exchange Differences';
                Image = Currency;
                ToolTip = 'Shows the exchange rate of the applied invoices and the simulated exchange difference of every line of the journal.';

                trigger OnAction()
                var
                    ExchDiffSim: Codeunit "NAV Exch. Diff. Simulation";
                begin
                    CurrPage.SaveRecord();
                    ExchDiffSim.ShowBatchSimulation(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcSimulation();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcSimulation();
    end;

    local procedure CalcSimulation()
    var
        ExchDiffSim: Codeunit "NAV Exch. Diff. Simulation";
        AppliedFCY: Decimal;
    begin
        ExchDiffSim.Simulate(Rec, InvoiceRate, PaymentRate, AppliedFCY, ExchDiffLCY);
        ExchDiffStyle := 'Standard';
        if ExchDiffLCY > 0 then
            ExchDiffStyle := 'Favorable';
        if ExchDiffLCY < 0 then
            ExchDiffStyle := 'Unfavorable';
    end;

    var
        InvoiceRate: Decimal;
        PaymentRate: Decimal;
        ExchDiffLCY: Decimal;
        ExchDiffStyle: Text;
}

pageextension 50321 "NAV Cash Rcpt. Jnl. Exch" extends "Cash Receipt Journal"
{
    layout
    {
        addafter(Amount)
        {
            field(NAVInvoiceRate; InvoiceRate)
            {
                ApplicationArea = All;
                Caption = 'Invoice Exch. Rate';
                DecimalPlaces = 0 : 6;
                Editable = false;
                ToolTip = 'Specifies the exchange rate (LCY for 1 unit of currency) of the applied invoice(s).';
            }
            field(NAVPaymentRate; PaymentRate)
            {
                ApplicationArea = All;
                Caption = 'Receipt Exch. Rate';
                DecimalPlaces = 0 : 6;
                Editable = false;
                ToolTip = 'Specifies the exchange rate (LCY for 1 unit of currency) of the receipt, at its posting date.';
            }
            field(NAVSimExchDiff; ExchDiffLCY)
            {
                ApplicationArea = All;
                Caption = 'Simulated Exch. Difference (LCY)';
                AutoFormatType = 1;
                Editable = false;
                StyleExpr = ExchDiffStyle;
                ToolTip = 'Specifies the realized exchange difference that the posting will generate on the applied invoice(s). Positive = gain, negative = loss.';
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(NAVSimulateExchDiff)
            {
                ApplicationArea = All;
                Caption = 'Simulate Exchange Differences';
                Image = Currency;
                ToolTip = 'Shows the exchange rate of the applied invoices and the simulated exchange difference of every line of the journal.';

                trigger OnAction()
                var
                    ExchDiffSim: Codeunit "NAV Exch. Diff. Simulation";
                begin
                    CurrPage.SaveRecord();
                    ExchDiffSim.ShowBatchSimulation(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcSimulation();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CalcSimulation();
    end;

    local procedure CalcSimulation()
    var
        ExchDiffSim: Codeunit "NAV Exch. Diff. Simulation";
        AppliedFCY: Decimal;
    begin
        ExchDiffSim.Simulate(Rec, InvoiceRate, PaymentRate, AppliedFCY, ExchDiffLCY);
        ExchDiffStyle := 'Standard';
        if ExchDiffLCY > 0 then
            ExchDiffStyle := 'Favorable';
        if ExchDiffLCY < 0 then
            ExchDiffStyle := 'Unfavorable';
    end;

    var
        InvoiceRate: Decimal;
        PaymentRate: Decimal;
        ExchDiffLCY: Decimal;
        ExchDiffStyle: Text;
}
