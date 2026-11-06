// Rebate agreement of a customer: one rebate type, a validity period and a rate
// (End of Deal / Cash Discount) or a fixed amount per unit sold by item (Core Rebate).
table 50301 "NAV Rebate Agreement"
{
    Caption = 'Customer Rebate Agreement';
    DataClassification = CustomerContent;
    DrillDownPageId = "NAV Rebate Agreements";
    LookupPageId = "NAV Rebate Agreements";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                NoSeries: Codeunit "No. Series";
            begin
                if "No." <> xRec."No." then begin
                    RebateSetup.GetSetup();
                    NoSeries.TestManual(RebateSetup."Agreement Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                CheckNotUsed();
                if Customer.Get("Customer No.") then
                    "Customer Name" := Customer.Name
                else
                    "Customer Name" := '';
                CheckOverlap();
            end;
        }
        field(3; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            Editable = false;
        }
        field(4; "Rebate Type"; Enum "NAV Rebate Type")
        {
            Caption = 'Rebate Type';

            trigger OnValidate()
            begin
                CheckNotUsed();
                if "Rebate Type" = "Rebate Type"::"Core Rebate" then
                    "Rebate %" := 0;
                CheckOverlap();
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(6; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                CheckDates();
                CheckOverlap();
            end;
        }
        field(7; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                CheckDates();
                CheckOverlap();
            end;
        }
        // End of Deal and Cash Discount: rate applied to the net sales of the period
        field(8; "Rebate %"; Decimal)
        {
            Caption = 'Rebate %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;

            trigger OnValidate()
            begin
                if ("Rebate %" <> 0) and ("Rebate Type" = "Rebate Type"::"Core Rebate") then
                    Error(CoreRateErr);
            end;
        }
        field(9; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(10; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(11; "No. of Calculations"; Integer)
        {
            Caption = 'No. of Calculations';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NAV Rebate Calculation" where("Agreement No." = field("No.")));
        }
        field(12; "No. of Core Lines"; Integer)
        {
            Caption = 'No. of Core Rebate Lines';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("NAV Core Rebate Line" where("Agreement No." = field("No.")));
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Customer; "Customer No.", "Rebate Type", "Starting Date") { }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            RebateSetup.GetSetup();
            RebateSetup.TestField("Agreement Nos.");
            "No. Series" := RebateSetup."Agreement Nos.";
            "No." := NoSeries.GetNextNo("No. Series", WorkDate());
        end;
    end;

    trigger OnDelete()
    var
        CoreLine: Record "NAV Core Rebate Line";
    begin
        CalcFields("No. of Calculations");
        if "No. of Calculations" <> 0 then
            Error(DeleteUsedErr, "No.");
        CoreLine.SetRange("Agreement No.", "No.");
        CoreLine.DeleteAll();
    end;

    procedure CheckActive(PeriodStart: Date; PeriodEnd: Date)
    begin
        TestField(Blocked, false);
        TestField("Customer No.");
        TestField("Starting Date");
        if ("Starting Date" > PeriodEnd) or (("Ending Date" <> 0D) and ("Ending Date" < PeriodStart)) then
            Error(OutOfPeriodErr, "No.", PeriodStart, PeriodEnd);
        if "Rebate Type" = "Rebate Type"::"Core Rebate" then begin
            CalcFields("No. of Core Lines");
            if "No. of Core Lines" = 0 then
                Error(NoCoreLinesErr, "No.");
        end else
            TestField("Rebate %");
    end;

    // Used by the batch: agreements without rate or core lines are skipped instead of stopping the batch
    procedure IsComplete(): Boolean
    begin
        if Blocked or ("Customer No." = '') or ("Starting Date" = 0D) then
            exit(false);
        if "Rebate Type" = "Rebate Type"::"Core Rebate" then begin
            CalcFields("No. of Core Lines");
            exit("No. of Core Lines" <> 0);
        end;
        exit("Rebate %" <> 0);
    end;

    local procedure CheckDates()
    begin
        if ("Starting Date" <> 0D) and ("Ending Date" <> 0D) and ("Ending Date" < "Starting Date") then
            Error(DatesErr);
    end;

    local procedure CheckNotUsed()
    begin
        if (xRec."No." = '') or (CurrFieldNo = 0) then
            exit;
        CalcFields("No. of Calculations");
        if "No. of Calculations" <> 0 then
            Error(ChangeUsedErr, "No.");
    end;

    // One agreement per customer and rebate type for a given date
    local procedure CheckOverlap()
    var
        Other: Record "NAV Rebate Agreement";
        EndDate: Date;
    begin
        if ("Customer No." = '') or ("Starting Date" = 0D) then
            exit;
        Other.SetRange("Customer No.", "Customer No.");
        Other.SetRange("Rebate Type", "Rebate Type");
        Other.SetFilter("No.", '<>%1', "No.");
        Other.SetRange(Blocked, false);
        if Other.FindSet() then
            repeat
                EndDate := Other."Ending Date";
                if EndDate = 0D then
                    EndDate := DMY2Date(31, 12, 9999);
                if (Other."Starting Date" <= MaxDate("Ending Date")) and (EndDate >= "Starting Date") then
                    Error(OverlapErr, Other."No.", "Customer No.", "Rebate Type");
            until Other.Next() = 0;
    end;

    local procedure MaxDate(D: Date): Date
    begin
        if D = 0D then
            exit(DMY2Date(31, 12, 9999));
        exit(D);
    end;

    var
        RebateSetup: Record "NAV Rebate Setup";
        DatesErr: Label 'The ending date must be after the starting date.';
        CoreRateErr: Label 'A Core Rebate uses a fixed amount per unit on the core rebate lines, not a rebate %.';
        OverlapErr: Label 'Agreement %1 already covers this period for customer %2 and rebate type %3.', Comment = '%1 = agreement, %2 = customer, %3 = type';
        DeleteUsedErr: Label 'Agreement %1 cannot be deleted because rebate calculations exist for it. Block it instead.', Comment = '%1 = agreement';
        ChangeUsedErr: Label 'Agreement %1 already has rebate calculations: the customer and the rebate type cannot be changed.', Comment = '%1 = agreement';
        OutOfPeriodErr: Label 'Agreement %1 is not valid for the period %2..%3.', Comment = '%1 = agreement, %2 = start, %3 = end';
        NoCoreLinesErr: Label 'Agreement %1 has no core rebate lines (eligible items and amount per unit).', Comment = '%1 = agreement';
}
