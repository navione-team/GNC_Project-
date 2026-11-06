// Batch: creates one rebate calculation per active agreement for the period,
// calculates it and, optionally, posts the preliminary provision.
// Typical use: monthly for Cash Discount, at the end of the deal for End of Deal and Core Rebate.
report 50300 "NAV Calculate Customer Rebates"
{
    Caption = 'Calculate Customer Rebates';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Agreement; "NAV Rebate Agreement")
        {
            DataItemTableView = sorting("Customer No.", "Rebate Type", "Starting Date") where(Blocked = const(false));
            RequestFilterFields = "Customer No.", "Rebate Type", "No.";

            trigger OnPreDataItem()
            begin
                if (PeriodStart = 0D) or (PeriodEnd = 0D) then
                    Error(PeriodMissingErr);
                if PeriodEnd < PeriodStart then
                    Error(PeriodErr);
                SetFilter("Starting Date", '..%1', PeriodEnd);
                Window.Open(ProgressTxt);
            end;

            trigger OnAfterGetRecord()
            var
                RebateCalc: Record "NAV Rebate Calculation";
            begin
                if ("Ending Date" <> 0D) and ("Ending Date" < PeriodStart) then
                    CurrReport.Skip();
                if not IsComplete() then begin
                    Incomplete += 1;
                    CurrReport.Skip();
                end;
                Window.Update(1, "No.");
                Window.Update(2, "Customer No.");
                if RebateMgt.ExistsForPeriod("No.", PeriodStart, PeriodEnd) then begin
                    Skipped += 1;
                    CurrReport.Skip();
                end;

                RebateCalc.Init();
                RebateCalc.Insert(true);
                RebateCalc.Validate("Agreement No.", "No.");
                RebateCalc.Validate("Period Start", PeriodStart);
                RebateCalc.Validate("Period End", PeriodEnd);
                if ProvisionDate <> 0D then
                    RebateCalc."Provision Posting Date" := ProvisionDate;
                RebateCalc.Modify();
                RebateMgt.Calculate(RebateCalc);
                Created += 1;
                TotalAmount += RebateCalc."Calculated Amount (LCY)";

                if PostProvision and (RebateCalc."Calculated Amount (LCY)" > 0) then begin
                    RebateMgt.PostProvision(RebateCalc);
                    Provisioned += 1;
                end;
            end;

            trigger OnPostDataItem()
            begin
                Window.Close();
                Message(DoneMsg, Created, TotalAmount, Provisioned, Skipped, Incomplete);
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

                    field(PeriodStartField; PeriodStart)
                    {
                        ApplicationArea = All;
                        Caption = 'Period Start';
                        ToolTip = 'Specifies the first day of the rebate period (for a Cash Discount: the first day of the month).';
                    }
                    field(PeriodEndField; PeriodEnd)
                    {
                        ApplicationArea = All;
                        Caption = 'Period End';
                        ToolTip = 'Specifies the last day of the rebate period (for a Cash Discount: the last day of the month).';
                    }
                    field(PostProvisionField; PostProvision)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Provisions';
                        ToolTip = 'Specifies whether the preliminary provision (Debit Expense / Credit Accrued) is posted right after the calculation.';
                    }
                    field(ProvisionDateField; ProvisionDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Provision Posting Date';
                        ToolTip = 'Specifies the posting date of the provisions. Empty = period end.';
                    }
                }
            }
        }
    }

    var
        RebateMgt: Codeunit "NAV Rebate Mgt.";
        Window: Dialog;
        PeriodStart: Date;
        PeriodEnd: Date;
        ProvisionDate: Date;
        PostProvision: Boolean;
        Created: Integer;
        Provisioned: Integer;
        Skipped: Integer;
        Incomplete: Integer;
        TotalAmount: Decimal;
        PeriodMissingErr: Label 'Enter the period start and the period end.';
        PeriodErr: Label 'The period end must be after the period start.';
        ProgressTxt: Label 'Calculating rebates...\Agreement #1##########\Customer  #2##########', Comment = '#1 = agreement, #2 = customer';
        DoneMsg: Label '%1 rebate calculation(s) created, total calculated rebate %2.\%3 provision(s) posted.\%4 agreement(s) skipped because a calculation already exists for the period.\%5 agreement(s) skipped because the rebate % or the core rebate items are missing.', Comment = '%1 = created, %2 = amount, %3 = provisioned, %4 = skipped, %5 = incomplete';
}
