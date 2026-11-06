table 50201 "NAV Transit Folder Line"
{
    Caption = 'Transit Folder Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Folder No."; Code[20])
        {
            Caption = 'Folder No.';
            TableRelation = "NAV Transit Folder";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Item Charge No."; Code[20])
        {
            Caption = 'Item Charge No.';
            TableRelation = "Item Charge";

            trigger OnValidate()
            var
                ItemCharge: Record "Item Charge";
            begin
                TestStatusOpen();
                TestField("Charge Order No.", '');

                if "Item Charge No." = '' then begin
                    Description := '';
                    Percent := 0;
                    Amount := 0;
                    exit;
                end;

                ItemCharge.Get("Item Charge No.");
                Description := ItemCharge.Description;
                "Calculation Type" := ItemCharge."Calculation Type";
                Percent := ItemCharge."Default Percent";
                Amount := ItemCharge."Default Amount";
                if ItemCharge."Default Vendor No." <> '' then
                    Validate("Vendor No.", ItemCharge."Default Vendor No.");
                CalcAmount();
            end;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; "Calculation Type"; Enum "NAV Charge Calc. Type")
        {
            Caption = 'Calculation Type';

            trigger OnValidate()
            begin
                TestStatusOpen();
                TestField("Charge Order No.", '');
                if "Calculation Type" = "Calculation Type"::"By Amount" then
                    Percent := 0;
                CalcAmount();
            end;
        }
        field(6; Percent; Decimal)
        {
            Caption = '%';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;

            trigger OnValidate()
            begin
                TestStatusOpen();
                TestField("Charge Order No.", '');
                TestField("Calculation Type", "Calculation Type"::"By Percent");
                CalcAmount();
            end;
        }
        field(7; Amount; Decimal)
        {
            Caption = 'Amount (LCY)';
            AutoFormatType = 1;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestStatusOpen();
                TestField("Charge Order No.", '');
                TestField("Calculation Type", "Calculation Type"::"By Amount");
            end;
        }
        field(8; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                TestField("Charge Order No.", '');
                if "Vendor No." = '' then begin
                    "Vendor Name" := '';
                    exit;
                end;
                Vendor.Get("Vendor No.");
                "Vendor Name" := Vendor.Name;
            end;
        }
        field(9; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            Editable = false;
        }
        field(10; "Charge Order No."; Code[20])
        {
            Caption = 'Charge Order No.';
            Editable = false;
        }
        field(11; "Charge Order Line No."; Integer)
        {
            Caption = 'Charge Order Line No.';
            Editable = false;
        }
        field(12; "Accrued Amount (LCY)"; Decimal)
        {
            Caption = 'Accrued Amount (LCY)';
            AutoFormatType = 1;
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("NAV Transit Folder Accrual"."Amount (LCY)" where("Folder No." = field("Folder No."),
                                                                                "Folder Line No." = field("Line No."),
                                                                                "Entry Type" = const(Accrual)));
        }
        field(13; "Open Accrual (LCY)"; Decimal)
        {
            Caption = 'Open Accrual (LCY)';
            AutoFormatType = 1;
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("NAV Transit Folder Accrual"."Amount (LCY)" where("Folder No." = field("Folder No."),
                                                                                "Folder Line No." = field("Line No.")));
        }
        field(14; "Accrual Closed"; Boolean)
        {
            Caption = 'Accrual Closed';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Folder No.", "Line No.")
        {
            Clustered = true;
        }
        key(Vendor; "Folder No.", "Vendor No.") { }
    }

    trigger OnInsert()
    begin
        TestStatusOpen();
    end;

    trigger OnDelete()
    begin
        TestStatusOpen();
        TestField("Charge Order No.", '');
    end;

    procedure CalcAmount()
    var
        TransitFolder: Record "NAV Transit Folder";
    begin
        if "Calculation Type" <> "Calculation Type"::"By Percent" then
            exit;
        if not TransitFolder.Get("Folder No.") then begin
            Amount := 0;
            exit;
        end;
        Amount := Round(TransitFolder."Base Amount (LCY)" * Percent / 100);
    end;

    local procedure TestStatusOpen()
    var
        TransitFolder: Record "NAV Transit Folder";
    begin
        // The folder may not exist in the database yet (default charges inserted during OnInsert)
        if TransitFolder.Get("Folder No.") then
            TransitFolder.TestField(Status, TransitFolder.Status::Open);
    end;
}
