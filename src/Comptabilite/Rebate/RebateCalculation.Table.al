// One rebate calculation = one agreement x one period.
// Flow: Calculated -> (Post Provision) Provisioned -> (Validate Final Amount) Validated
//       -> (Create Credit Memo, post it) Credited    or    final amount 0 -> Closed
table 50303 "NAV Rebate Calculation"
{
    Caption = 'Customer Rebate Calculation';
    DataClassification = CustomerContent;
    DrillDownPageId = "NAV Rebate Calculations";
    LookupPageId = "NAV Rebate Calculations";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            TableRelation = "NAV Rebate Agreement";

            trigger OnValidate()
            var
                Agreement: Record "NAV Rebate Agreement";
            begin
                TestStatus(Status::Calculated);
                if Agreement.Get("Agreement No.") then begin
                    "Customer No." := Agreement."Customer No.";
                    "Customer Name" := Agreement."Customer Name";
                    "Rebate Type" := Agreement."Rebate Type";
                    "Rebate %" := Agreement."Rebate %";
                    Description := Agreement.Description;
                end else begin
                    "Customer No." := '';
                    "Customer Name" := '';
                    "Rebate %" := 0;
                end;
                ClearAmounts();
            end;
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            Editable = false;
        }
        field(4; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            Editable = false;
        }
        field(5; "Rebate Type"; Enum "NAV Rebate Type")
        {
            Caption = 'Rebate Type';
            Editable = false;
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(7; "Period Start"; Date)
        {
            Caption = 'Period Start';

            trigger OnValidate()
            begin
                TestStatus(Status::Calculated);
                ClearAmounts();
            end;
        }
        field(8; "Period End"; Date)
        {
            Caption = 'Period End';

            trigger OnValidate()
            begin
                TestStatus(Status::Calculated);
                ClearAmounts();
            end;
        }
        field(9; Status; Enum "NAV Rebate Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(10; "Rebate %"; Decimal)
        {
            Caption = 'Rebate %';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        // ---------- Calculation ----------
        field(20; "Sales Amount (LCY)"; Decimal)
        {
            Caption = 'Sales Amount (LCY)';
            AutoFormatType = 1;
            Editable = false;
        }
        field(21; "Deducted Cr. Memos (LCY)"; Decimal)
        {
            Caption = 'Deducted Credit Memos (LCY)';
            AutoFormatType = 1;
            Editable = false;
        }
        // Specific adjustment identified by the business (+ or -), deducted from the base
        field(22; "Adjustment Amount (LCY)"; Decimal)
        {
            Caption = 'Adjustment Amount (LCY)';
            AutoFormatType = 1;

            trigger OnValidate()
            var
                RebateMgt: Codeunit "NAV Rebate Mgt.";
            begin
                TestStatus(Status::Calculated);
                RebateMgt.UpdateTotals(Rec);
            end;
        }
        field(23; "Rebate Base (LCY)"; Decimal)
        {
            Caption = 'Rebate Base (LCY)';
            AutoFormatType = 1;
            Editable = false;
        }
        field(24; "Calculated Amount (LCY)"; Decimal)
        {
            Caption = 'Calculated Rebate (LCY)';
            AutoFormatType = 1;
            Editable = false;
        }
        field(25; "Calculation Date"; Date)
        {
            Caption = 'Calculation Date';
            Editable = false;
        }
        // Cash Discount: all invoices due in the period were paid within the period
        field(26; "Payment Condition Met"; Boolean)
        {
            Caption = 'Payment Condition Met';
            Editable = false;
        }
        field(27; "Unpaid Due Invoices"; Integer)
        {
            Caption = 'Unpaid Due Invoices';
            Editable = false;
        }
        // ---------- Provision ----------
        field(30; "Provision Amount (LCY)"; Decimal)
        {
            Caption = 'Provision Amount (LCY)';
            AutoFormatType = 1;
            Editable = false;
        }
        // Proposed = Period End; can be changed before posting the provision
        field(31; "Provision Posting Date"; Date)
        {
            Caption = 'Provision Posting Date';

            trigger OnValidate()
            begin
                TestStatus(Status::Calculated);
            end;
        }
        field(32; "Provision Document No."; Code[20])
        {
            Caption = 'Provision Document No.';
            Editable = false;
        }
        // ---------- Final negotiated amount ----------
        field(40; "Final Amount (LCY)"; Decimal)
        {
            Caption = 'Final Negotiated Amount (LCY)';
            AutoFormatType = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                if not (Status in [Status::Calculated, Status::Provisioned]) then
                    FieldError(Status);
            end;
        }
        field(41; "Difference (LCY)"; Decimal)
        {
            Caption = 'Difference vs Provision (LCY)';
            AutoFormatType = 1;
            Editable = false;
        }
        field(42; "Validated By"; Code[50])
        {
            Caption = 'Validated By';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(43; "Validation Date"; Date)
        {
            Caption = 'Validation Date';
            Editable = false;
        }
        field(44; "Negotiation Comment"; Text[250])
        {
            Caption = 'Negotiation Comment';
        }
        // ---------- Credit memo ----------
        field(50; "Credit Memo No."; Code[20])
        {
            Caption = 'Credit Memo No.';
            Editable = false;
            TableRelation = "Sales Header"."No." where("Document Type" = const("Credit Memo"));
        }
        field(51; "Posted Credit Memo No."; Code[20])
        {
            Caption = 'Posted Credit Memo No.';
            Editable = false;
            TableRelation = "Sales Cr.Memo Header";
        }
        field(52; "Credit Memo Posting Date"; Date)
        {
            Caption = 'Credit Memo Posting Date';
            Editable = false;
        }
        field(60; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Agreement; "Agreement No.", "Period Start") { }
        key(Customer; "Customer No.", "Rebate Type", "Period Start") { }
        key(Status; Status) { SumIndexFields = "Calculated Amount (LCY)", "Provision Amount (LCY)", "Final Amount (LCY)"; }
    }

    trigger OnInsert()
    var
        RebateSetup: Record "NAV Rebate Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            RebateSetup.GetSetup();
            RebateSetup.TestField("Calculation Nos.");
            "No. Series" := RebateSetup."Calculation Nos.";
            "No." := NoSeries.GetNextNo("No. Series", WorkDate());
        end;
    end;

    trigger OnDelete()
    var
        CalcLine: Record "NAV Rebate Calc. Line";
    begin
        if Status <> Status::Calculated then
            Error(DeleteErr, "No.", Status);
        CalcLine.SetRange("Calculation No.", "No.");
        CalcLine.DeleteAll();
    end;

    procedure TestStatus(Expected: Enum "NAV Rebate Status")
    begin
        if Status <> Expected then
            Error(StatusErr, "No.", Status, Expected);
    end;

    local procedure ClearAmounts()
    var
        CalcLine: Record "NAV Rebate Calc. Line";
    begin
        "Sales Amount (LCY)" := 0;
        "Deducted Cr. Memos (LCY)" := 0;
        "Rebate Base (LCY)" := 0;
        "Calculated Amount (LCY)" := 0;
        "Calculation Date" := 0D;
        "Payment Condition Met" := false;
        "Unpaid Due Invoices" := 0;
        if "No." <> '' then begin
            CalcLine.SetRange("Calculation No.", "No.");
            CalcLine.DeleteAll();
        end;
    end;

    var
        StatusErr: Label 'Rebate calculation %1 has status %2. This action requires status %3.', Comment = '%1 = no., %2 = current status, %3 = expected status';
        DeleteErr: Label 'Rebate calculation %1 has status %2 and cannot be deleted.', Comment = '%1 = no., %2 = status';
}
