// Simple bank facility: initial entry at the facility date, repayment + bank commission at the due date.
//   Initial  : Debit Bank Account            / Credit Bank Facility Account   (amount)
//   Maturity : Debit Bank Facility Account   (amount)
//              Debit Bank Commission Account (commission)
//              Credit Bank Account           (amount + commission)
table 50311 "NAV Bank Facility"
{
    Caption = 'Bank Facility';
    DataClassification = CustomerContent;
    DrillDownPageId = "NAV Bank Facilities";
    LookupPageId = "NAV Bank Facilities";

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
                    Setup.GetSetup();
                    NoSeries.TestManual(Setup."Facility Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = "Bank Account";

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
            begin
                TestStatusDraft();
                if BankAccount.Get("Bank Account No.") then begin
                    "Bank Name" := BankAccount.Name;
                    "Currency Code" := BankAccount."Currency Code";
                end else begin
                    "Bank Name" := '';
                    "Currency Code" := '';
                end;
            end;
        }
        field(4; "Bank Name"; Text[100])
        {
            Caption = 'Bank Name';
            Editable = false;
        }
        field(5; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            Editable = false;
        }
        field(6; "Facility Date"; Date)
        {
            Caption = 'Facility Date';

            trigger OnValidate()
            begin
                TestStatusDraft();
                CheckDates();
            end;
        }
        field(7; "Due Date"; Date)
        {
            Caption = 'Due Date';

            trigger OnValidate()
            begin
                if not (Status in [Status::Draft, Status::Open]) then
                    FieldError(Status);
                CheckDates();
            end;
        }
        field(8; Amount; Decimal)
        {
            Caption = 'Facility Amount';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
            MinValue = 0;

            trigger OnValidate()
            begin
                TestStatusDraft();
                CalcCommission();
            end;
        }
        // Account credited by the initial entry and debited at the due date
        field(9; "Facility Account No."; Code[20])
        {
            Caption = 'Bank Facility Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));

            trigger OnValidate()
            begin
                TestStatusDraft();
            end;
        }
        field(10; "Commission Account No."; Code[20])
        {
            Caption = 'Bank Commission Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));

            trigger OnValidate()
            begin
                TestNotMatured();
            end;
        }
        // Commission either calculated (Amount x %) or entered directly
        field(11; "Commission %"; Decimal)
        {
            Caption = 'Commission %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestNotMatured();
                CalcCommission();
            end;
        }
        field(12; "Commission Amount"; Decimal)
        {
            Caption = 'Commission Amount';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
            MinValue = 0;

            trigger OnValidate()
            begin
                TestNotMatured();
                if ("Commission %" <> 0) and (Amount <> 0) then
                    if "Commission Amount" <> Round(Amount * "Commission %" / 100) then
                        "Commission %" := 0;
            end;
        }
        field(13; Status; Enum "NAV Bank Facility Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(14; "Bank Reference"; Code[35])
        {
            Caption = 'Bank Reference';
        }
        // ---------- Traceability ----------
        field(20; "Initial Posting Date"; Date)
        {
            Caption = 'Initial Entry Posting Date';
            Editable = false;
        }
        field(21; "Maturity Posting Date"; Date)
        {
            Caption = 'Maturity Entry Posting Date';
            Editable = false;
        }
        field(22; "Maturity Generated"; Boolean)
        {
            Caption = 'Maturity Entry Generated';
            Editable = false;
        }
        field(23; "Maturity Total"; Decimal)
        {
            Caption = 'Total Repaid (incl. Commission)';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
            Editable = false;
        }
        field(24; "Initial Bank Entry No."; Integer)
        {
            Caption = 'Initial Bank Ledger Entry No.';
            Editable = false;
            TableRelation = "Bank Account Ledger Entry";
        }
        field(25; "Maturity Bank Entry No."; Integer)
        {
            Caption = 'Maturity Bank Ledger Entry No.';
            Editable = false;
            TableRelation = "Bank Account Ledger Entry";
        }
        field(30; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "No.") { Clustered = true; }
        key(Due; Status, "Due Date") { SumIndexFields = Amount; }
        key(Bank; "Bank Account No.", "Facility Date") { }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        Setup.GetSetup();
        if "No." = '' then begin
            Setup.TestField("Facility Nos.");
            "No. Series" := Setup."Facility Nos.";
            "No." := NoSeries.GetNextNo("No. Series", WorkDate());
        end;
        if "Facility Account No." = '' then
            "Facility Account No." := Setup."Default Facility Account";
        if "Commission Account No." = '' then
            "Commission Account No." := Setup."Default Commission Account";
        if "Commission %" = 0 then
            "Commission %" := Setup."Default Commission %";
        if "Facility Date" = 0D then
            "Facility Date" := WorkDate();
    end;

    trigger OnDelete()
    begin
        if Status <> Status::Draft then
            Error(DeleteErr, "No.", Status);
    end;

    procedure TestStatusDraft()
    begin
        if Status <> Status::Draft then
            Error(DraftErr, "No.", Status);
    end;

    local procedure TestNotMatured()
    begin
        if Status in [Status::Matured, Status::Processed] then
            Error(MaturedErr, "No.");
    end;

    local procedure CheckDates()
    begin
        if ("Facility Date" <> 0D) and ("Due Date" <> 0D) and ("Due Date" < "Facility Date") then
            Error(DatesErr);
    end;

    local procedure CalcCommission()
    begin
        if "Commission %" <> 0 then
            "Commission Amount" := Round(Amount * "Commission %" / 100);
    end;

    var
        Setup: Record "NAV Bank Facility Setup";
        DatesErr: Label 'The due date must be on or after the facility date.';
        DraftErr: Label 'Bank facility %1 has status %2. Only a Draft facility can be changed.', Comment = '%1 = no., %2 = status';
        MaturedErr: Label 'The maturity entry of bank facility %1 has already been generated. The commission can no longer be changed.', Comment = '%1 = no.';
        DeleteErr: Label 'Bank facility %1 has status %2 and cannot be deleted.', Comment = '%1 = no., %2 = status';
}
