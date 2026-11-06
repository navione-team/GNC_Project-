// ======================================================================
// Setup
// ======================================================================
page 50300 "NAV Rebate Setup"
{
    Caption = 'Customer Rebate Setup';
    PageType = Card;
    SourceTable = "NAV Rebate Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Agreement Nos."; Rec."Agreement Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series of the rebate agreements.';
                }
                field("Calculation Nos."; Rec."Calculation Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series of the rebate calculations. The number is also the document no. of the provision entries.';
                }
                field("Source Code"; Rec."Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source code of the provision and reversal entries (for example REBATE).';
                }
                field("Credit Memo Reason Code"; Rec."Credit Memo Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason code put on the final rebate credit memos (the reason code is mandatory on credit memos).';
                }
            }
            group(EndOfDeal)
            {
                Caption = 'End of Deal';

                field("End of Deal Expense Acc."; Rec."End of Deal Expense Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expense account debited by the End of Deal provision.';
                }
                field("End of Deal Accrued Acc."; Rec."End of Deal Accrued Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the accrued account credited by the End of Deal provision and debited by the final credit memo.';
                }
            }
            group(Core)
            {
                Caption = 'Core Rebate';

                field("Core Expense Acc."; Rec."Core Expense Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expense account debited by the Core Rebate provision.';
                }
                field("Core Accrued Acc."; Rec."Core Accrued Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the accrued account credited by the Core Rebate provision and debited by the final credit memo.';
                }
            }
            group(CashDiscount)
            {
                Caption = 'Cash Discount';

                field("Cash Discount Expense Acc."; Rec."Cash Discount Expense Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expense account debited by the Cash Discount provision.';
                }
                field("Cash Discount Accrued Acc."; Rec."Cash Discount Accrued Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the accrued account credited by the Cash Discount provision and debited by the final credit memo.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}

// ======================================================================
// Agreements
// ======================================================================
page 50301 "NAV Rebate Agreements"
{
    Caption = 'Customer Rebate Agreements';
    PageType = List;
    SourceTable = "NAV Rebate Agreement";
    CardPageId = "NAV Rebate Agreement Card";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the agreement number.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Rebate Type"; Rec."Rebate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate type: End of Deal, Core Rebate or Cash Discount.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the agreement.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first day of validity of the agreement.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last day of validity of the agreement. Empty = no end date.';
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate rate (End of Deal and Cash Discount).';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the agreement is no longer used.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CalculateRebates)
            {
                ApplicationArea = All;
                Caption = 'Calculate Rebates';
                Image = CalculateDiscount;
                RunObject = report "NAV Calculate Customer Rebates";
                ToolTip = 'Creates and calculates the rebate calculations of the period for all the active agreements.';
            }
        }
        area(Navigation)
        {
            action(Calculations)
            {
                ApplicationArea = All;
                Caption = 'Rebate Calculations';
                Image = List;
                RunObject = page "NAV Rebate Calculations";
                RunPageLink = "Agreement No." = field("No.");
                ToolTip = 'Shows the rebate calculations of the agreement.';
            }
        }
        area(Promoted)
        {
            actionref(CalculateRebates_Promoted; CalculateRebates) { }
            actionref(Calculations_Promoted; Calculations) { }
        }
    }
}

page 50302 "NAV Rebate Agreement Card"
{
    Caption = 'Customer Rebate Agreement';
    PageType = Card;
    SourceTable = "NAV Rebate Agreement";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the agreement number.';

                    trigger OnAssistEdit()
                    var
                        RebateSetup: Record "NAV Rebate Setup";
                        NoSeries: Codeunit "No. Series";
                    begin
                        RebateSetup.GetSetup();
                        RebateSetup.TestField("Agreement Nos.");
                        if NoSeries.LookupRelatedNoSeries(RebateSetup."Agreement Nos.", xRec."No. Series", Rec."No. Series") then begin
                            Rec."No." := NoSeries.GetNextNo(Rec."No. Series");
                            CurrPage.Update();
                        end;
                    end;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the customer who receives the rebate (bill-to customer of the invoices).';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Rebate Type"; Rec."Rebate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate type. End of Deal: rate on the net sales of the period. Core Rebate: fixed amount per unit of eligible items. Cash Discount: monthly rate on the sales, granted only if the invoices due in the month are paid in the month.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the agreement.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the first day of validity of the agreement.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last day of validity of the agreement. Empty = no end date.';
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    ApplicationArea = All;
                    Editable = Rec."Rebate Type" <> Rec."Rebate Type"::"Core Rebate";
                    ShowMandatory = Rec."Rebate Type" <> Rec."Rebate Type"::"Core Rebate";
                    ToolTip = 'Specifies the rebate rate applied to the net sales of the period (End of Deal and Cash Discount).';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the agreement is no longer used.';
                }
            }
            part(CoreLines; "NAV Core Rebate Lines")
            {
                ApplicationArea = All;
                Caption = 'Core Rebate Items';
                SubPageLink = "Agreement No." = field("No.");
                Visible = Rec."Rebate Type" = Rec."Rebate Type"::"Core Rebate";
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Calculations)
            {
                ApplicationArea = All;
                Caption = 'Rebate Calculations';
                Image = List;
                RunObject = page "NAV Rebate Calculations";
                RunPageLink = "Agreement No." = field("No.");
                ToolTip = 'Shows the rebate calculations of the agreement.';
            }
        }
        area(Promoted)
        {
            actionref(Calculations_Promoted; Calculations) { }
        }
    }
}

page 50303 "NAV Core Rebate Lines"
{
    Caption = 'Core Rebate Items';
    PageType = ListPart;
    SourceTable = "NAV Core Rebate Line";
    AutoSplitKey = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the eligible item.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item description.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure of the amount per unit (for example PACK). Quantities sold in another unit are converted.';
                }
                field("Amount per Unit"; Rec."Amount per Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the fixed rebate amount granted for one unit sold.';
                }
            }
        }
    }
}

// ======================================================================
// Calculations
// ======================================================================
page 50304 "NAV Rebate Calculations"
{
    Caption = 'Customer Rebate Calculations';
    PageType = List;
    SourceTable = "NAV Rebate Calculation";
    CardPageId = "NAV Rebate Calculation Card";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    SourceTableView = sorting("No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculation number.';
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate agreement.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Rebate Type"; Rec."Rebate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate type.';
                }
                field("Period Start"; Rec."Period Start")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the first day of the period.';
                }
                field("Period End"; Rec."Period End")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last day of the period.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the status: Calculated, Provisioned, Validated, Credited or Closed.';
                }
                field("Rebate Base (LCY)"; Rec."Rebate Base (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate base at the last calculation.';
                }
                field("Calculated Amount (LCY)"; Rec."Calculated Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the preliminary rebate amount at the last calculation.';
                }
                field("Provision Amount (LCY)"; Rec."Provision Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provision posted.';
                }
                field("Final Amount (LCY)"; Rec."Final Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the final amount negotiated with the customer.';
                }
                field("Posted Credit Memo No."; Rec."Posted Credit Memo No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posted rebate credit memo.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CalculateRebates)
            {
                ApplicationArea = All;
                Caption = 'Calculate Rebates';
                Image = CalculateDiscount;
                RunObject = report "NAV Calculate Customer Rebates";
                ToolTip = 'Creates and calculates the rebate calculations of the period for all the active agreements.';
            }
        }
        area(Promoted)
        {
            actionref(CalculateRebates_Promoted; CalculateRebates) { }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StatusStyle := GetStatusStyle(Rec.Status);
    end;

    var
        StatusStyle: Text;

    local procedure GetStatusStyle(Status: Enum "NAV Rebate Status"): Text
    begin
        case Status of
            Status::Calculated:
                exit('Standard');
            Status::Provisioned:
                exit('Ambiguous');
            Status::Validated:
                exit('StrongAccent');
            Status::Credited:
                exit('Favorable');
            Status::Closed:
                exit('Subordinate');
        end;
    end;
}

page 50305 "NAV Rebate Calculation Card"
{
    Caption = 'Customer Rebate Calculation';
    PageType = Card;
    SourceTable = "NAV Rebate Calculation";
    DataCaptionFields = "No.", "Customer Name";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = IsCalculated;

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the calculation number. It is also the document no. of the provision entries.';
                }
                field("Agreement No."; Rec."Agreement No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the rebate agreement.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Rebate Type"; Rec."Rebate Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate type.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description.';
                }
                field("Period Start"; Rec."Period Start")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the first day of the period.';
                }
                field("Period End"; Rec."Period End")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the last day of the period.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status: Calculated, Provisioned, Validated, Credited or Closed.';
                }
            }
            group(Calculation)
            {
                Caption = 'Calculation';

                field("Calculation Date"; Rec."Calculation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the rebate was last calculated.';
                }
                field("Sales Amount (LCY)"; Rec."Sales Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the invoiced amount excluding VAT of the period.';
                }
                field("Deducted Cr. Memos (LCY)"; Rec."Deducted Cr. Memos (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the credit memos deducted from the base (the credit memos with Include ticked on the lines).';
                }
                field("Adjustment Amount (LCY)"; Rec."Adjustment Amount (LCY)")
                {
                    ApplicationArea = All;
                    Editable = IsCalculated and (Rec."Rebate Type" <> Rec."Rebate Type"::"Core Rebate");
                    ToolTip = 'Specifies a specific adjustment identified by the business, deducted from the rebate base (negative = added).';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Rebate Base (LCY)"; Rec."Rebate Base (LCY)")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the rebate base = sales - deducted credit memos - adjustment.';
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate rate of the agreement.';
                }
                field("Payment Condition Met"; Rec."Payment Condition Met")
                {
                    ApplicationArea = All;
                    Visible = IsCashDiscount;
                    ToolTip = 'Specifies whether all the invoices due in the month were paid within the month. If not, the cash discount is 0.';
                }
                field("Unpaid Due Invoices"; Rec."Unpaid Due Invoices")
                {
                    ApplicationArea = All;
                    Visible = IsCashDiscount;
                    ToolTip = 'Specifies the number of invoices due in the month that were not paid within the month.';
                }
                field("Calculated Amount (LCY)"; Rec."Calculated Amount (LCY)")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the preliminary rebate amount. Click Calculate again after changing the lines to refresh it.';
                }
            }
            part(Lines; "NAV Rebate Calc. Lines")
            {
                ApplicationArea = All;
                Caption = 'Rebate Base Details';
                SubPageLink = "Calculation No." = field("No.");
                Editable = IsCalculated;
                UpdatePropagation = Both;
            }
            group(Provision)
            {
                Caption = 'Provision';

                field("Provision Posting Date"; Rec."Provision Posting Date")
                {
                    ApplicationArea = All;
                    Editable = IsCalculated;
                    ToolTip = 'Specifies the posting date of the provision (proposed: period end).';
                }
                field("Provision Amount (LCY)"; Rec."Provision Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the provision posted (Debit Expense / Credit Accrued).';
                }
                field("Provision Document No."; Rec."Provision Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document no. of the provision entries.';
                }
            }
            group(Final)
            {
                Caption = 'Final Settlement';

                field("Final Amount (LCY)"; Rec."Final Amount (LCY)")
                {
                    ApplicationArea = All;
                    Editable = IsProvisioned;
                    Style = Strong;
                    ToolTip = 'Specifies the final amount negotiated and confirmed with the customer.';
                }
                field("Negotiation Comment"; Rec."Negotiation Comment")
                {
                    ApplicationArea = All;
                    Editable = IsCalculated or IsProvisioned;
                    MultiLine = true;
                    ToolTip = 'Specifies a comment on the negotiation with the customer.';
                }
                field("Difference (LCY)"; Rec."Difference (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies final amount - provision. Positive: additional expense on the credit memo. Negative: provision reversed.';
                }
                field("Validated By"; Rec."Validated By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who validated the final amount.';
                }
                field("Validation Date"; Rec."Validation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the final amount was validated.';
                }
                field("Credit Memo No."; Rec."Credit Memo No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate credit memo created (not posted yet).';

                    trigger OnDrillDown()
                    begin
                        OpenCreditMemo();
                    end;
                }
                field("Posted Credit Memo No."; Rec."Posted Credit Memo No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posted rebate credit memo.';

                    trigger OnDrillDown()
                    var
                        CrMemoHeader: Record "Sales Cr.Memo Header";
                    begin
                        if CrMemoHeader.Get(Rec."Posted Credit Memo No.") then
                            Page.Run(Page::"Posted Sales Credit Memo", CrMemoHeader);
                    end;
                }
                field("Credit Memo Posting Date"; Rec."Credit Memo Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posting date of the rebate credit memo.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Calculate)
            {
                ApplicationArea = All;
                Caption = 'Calculate';
                Image = Calculate;
                Enabled = IsCalculated;
                ToolTip = 'Calculates the rebate base and the preliminary rebate from the posted invoices and credit memos of the period. Excluded credit memos are reset.';

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    RebateMgt.Calculate(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(UpdateTotals)
            {
                ApplicationArea = All;
                Caption = 'Update Totals';
                Image = Refresh;
                Enabled = IsCalculated;
                ToolTip = 'Updates the totals after including or excluding credit memos on the lines, without recalculating the lines.';

                trigger OnAction()
                begin
                    RebateMgt.UpdateTotals(Rec);
                    Rec.Modify();
                    CurrPage.Update(false);
                end;
            }
            action(PostProvision)
            {
                ApplicationArea = All;
                Caption = 'Post Provision';
                Image = Post;
                Enabled = IsCalculated;
                ToolTip = 'Posts the preliminary provision: Debit the expense account / Credit the accrued account of the rebate type.';

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    RebateMgt.UpdateTotals(Rec);
                    if not Confirm(PostProvisionQst, false, Rec."Calculated Amount (LCY)", Rec."Provision Posting Date") then
                        exit;
                    RebateMgt.PostProvision(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ValidateFinal)
            {
                ApplicationArea = All;
                Caption = 'Validate Final Amount';
                Image = Approve;
                Enabled = IsProvisioned;
                ToolTip = 'Confirms the final amount negotiated with the customer. If it is lower than the provision, the excess provision is reversed. If it is 0, the calculation is closed.';

                trigger OnAction()
                var
                    Question: Text;
                begin
                    CurrPage.SaveRecord();
                    if Rec."Final Amount (LCY)" < Rec."Provision Amount (LCY)" then
                        Question := StrSubstNo(ValidateLowerQst, Rec."Final Amount (LCY)", Rec."Provision Amount (LCY)" - Rec."Final Amount (LCY)")
                    else
                        Question := StrSubstNo(ValidateQst, Rec."Final Amount (LCY)", Rec."Provision Amount (LCY)");
                    if not Confirm(Question, false) then
                        exit;
                    RebateMgt.ValidateFinalAmount(Rec, WorkDate());
                    CurrPage.Update(false);
                end;
            }
            action(CreateCreditMemo)
            {
                ApplicationArea = All;
                Caption = 'Create Credit Memo';
                Image = CreditMemo;
                Enabled = IsValidated;
                ToolTip = 'Creates the final financial credit memo of the customer: Debit Accrued (up to the provision), Debit Expense (additional amount), Credit Customer.';

                trigger OnAction()
                begin
                    RebateMgt.CreateCreditMemo(Rec, WorkDate());
                    CurrPage.Update(false);
                    OpenCreditMemo();
                end;
            }
        }
        area(Navigation)
        {
            action(GLEntries)
            {
                ApplicationArea = All;
                Caption = 'G/L Entries';
                Image = GLRegisters;
                ToolTip = 'Shows the provision and reversal entries of the calculation.';

                trigger OnAction()
                var
                    GLEntry: Record "G/L Entry";
                begin
                    GLEntry.SetRange("Document No.", Rec."No.");
                    Page.Run(Page::"General Ledger Entries", GLEntry);
                end;
            }
            action(Agreement)
            {
                ApplicationArea = All;
                Caption = 'Agreement';
                Image = Agreement;
                RunObject = page "NAV Rebate Agreement Card";
                RunPageLink = "No." = field("Agreement No.");
                ToolTip = 'Opens the rebate agreement.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Calculate_Promoted; Calculate) { }
                actionref(UpdateTotals_Promoted; UpdateTotals) { }
                actionref(PostProvision_Promoted; PostProvision) { }
                actionref(ValidateFinal_Promoted; ValidateFinal) { }
                actionref(CreateCreditMemo_Promoted; CreateCreditMemo) { }
            }
            group(Category_Navigate)
            {
                Caption = 'Related';

                actionref(GLEntries_Promoted; GLEntries) { }
                actionref(Agreement_Promoted; Agreement) { }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsCalculated := Rec.Status = Rec.Status::Calculated;
        IsProvisioned := Rec.Status = Rec.Status::Provisioned;
        IsValidated := Rec.Status = Rec.Status::Validated;
        IsCashDiscount := Rec."Rebate Type" = Rec."Rebate Type"::"Cash Discount";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsCalculated := true;
        IsProvisioned := false;
        IsValidated := false;
    end;

    local procedure OpenCreditMemo()
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", Rec."Credit Memo No.") then
            Page.Run(Page::"Sales Credit Memo", SalesHeader);
    end;

    var
        RebateMgt: Codeunit "NAV Rebate Mgt.";
        IsCalculated: Boolean;
        IsProvisioned: Boolean;
        IsValidated: Boolean;
        IsCashDiscount: Boolean;
        PostProvisionQst: Label 'Post a provision of %1 on %2?', Comment = '%1 = amount, %2 = date';
        ValidateQst: Label 'Validate the final amount of %1 (provision %2)?', Comment = '%1 = final amount, %2 = provision';
        ValidateLowerQst: Label 'Validate the final amount of %1?\The excess provision of %2 will be reversed.', Comment = '%1 = final amount, %2 = reversed amount';
}

page 50306 "NAV Rebate Calc. Lines"
{
    Caption = 'Rebate Base Details';
    PageType = ListPart;
    SourceTable = "NAV Rebate Calc. Line";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of document: invoice or credit memo.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posted document.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posting date of the document.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the eligible item (Core Rebate).';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity sold in base unit of measure (Core Rebate).';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount excluding VAT in local currency.';
                }
                field("Rebate Amount (LCY)"; Rec."Rebate Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rebate of the line (Core Rebate: quantity x amount per unit).';
                }
                field(Include; Rec.Include)
                {
                    ApplicationArea = All;
                    Editable = Rec."Document Type" = Rec."Document Type"::"Credit Memo";
                    ToolTip = 'Specifies whether the credit memo is deducted from the rebate base. Untick to exclude it, then click Update Totals.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the due date of the invoice.';
                }
                field("Closed at Date"; Rec."Closed at Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the invoice was fully paid.';
                }
                field("Paid in Period"; Rec."Paid in Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the invoice was fully paid at the latest on the last day of the period.';
                }
            }
        }
    }
}
