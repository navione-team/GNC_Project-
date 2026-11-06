table 50270 "NAV Damage Transfer Header"
{
    Caption = 'Damage Transfer Header';
    DataClassification = CustomerContent;
    LookupPageId = "NAV Damage Transfers";
    DrillDownPageId = "NAV Damage Transfers";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));

            trigger OnValidate()
            var
                DamageLine: Record "NAV Damage Transfer Line";
            begin
                if "Location Code" = xRec."Location Code" then
                    exit;
                DamageLine.SetRange("Document No.", "No.");
                if not DamageLine.IsEmpty() then
                    Error(LinesExistErr, FieldCaption("Location Code"));
            end;
        }
        field(3; "Damage Date"; Date)
        {
            Caption = 'Damage Date';

            trigger OnValidate()
            begin
                if "Damage Date" > Today() then
                    Error(DamageDateFutureErr);
            end;
        }
        field(4; "Reason Code"; Code[10])
        {
            Caption = 'Damage Reason Code';
            TableRelation = "Reason Code";
        }
        field(5; "Responsible User ID"; Code[50])
        {
            Caption = 'Responsible User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "User Setup";
        }
        field(6; "Related Document No."; Code[35])
        {
            Caption = 'Related Document No.';
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        InventorySetup: Record "Inventory Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            InventorySetup.Get();
            InventorySetup.TestField("Damage Transfer Nos.");
            "No. Series" := InventorySetup."Damage Transfer Nos.";
            "No." := NoSeries.GetNextNo("No. Series", WorkDate());
        end;
        if "Damage Date" = 0D then
            "Damage Date" := WorkDate();
        if "Responsible User ID" = '' then
            "Responsible User ID" := CopyStr(UserId(), 1, MaxStrLen("Responsible User ID"));
    end;

    trigger OnDelete()
    var
        DamageLine: Record "NAV Damage Transfer Line";
    begin
        DamageLine.SetRange("Document No.", "No.");
        DamageLine.DeleteAll();
    end;

    var
        LinesExistErr: Label 'You cannot change the %1 because the document has lines.', Comment = '%1 = field caption';
        DamageDateFutureErr: Label 'The damage date cannot be later than today.';
}

table 50271 "NAV Damage Transfer Line"
{
    Caption = 'Damage Transfer Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "NAV Damage Transfer Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Editable = false;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item where(Type = const(Inventory));

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "Item No." = '' then begin
                    Description := '';
                    "Unit of Measure Code" := '';
                    exit;
                end;
                Item.Get("Item No.");
                Description := Item.Description;
                Validate("Unit of Measure Code", Item."Base Unit of Measure");
                "Lot No." := '';
                "Expiration Date" := 0D;
            end;
        }
        field(5; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));

            trigger OnValidate()
            var
                ItemUnitOfMeasure: Record "Item Unit of Measure";
            begin
                "Qty. per Unit of Measure" := 1;
                if ItemUnitOfMeasure.Get("Item No.", "Unit of Measure Code") then
                    "Qty. per Unit of Measure" := ItemUnitOfMeasure."Qty. per Unit of Measure";
                Validate(Quantity);
            end;
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Damaged Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                "Quantity (Base)" := Round(Quantity * "Qty. per Unit of Measure", 0.00001);
            end;
        }
        field(13; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(14; "Quantity (Base)"; Decimal)
        {
            Caption = 'Damaged Quantity (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(9; "From Bin Code"; Code[20])
        {
            Caption = 'From Bin Code';
            TableRelation = "Bin Content"."Bin Code" where("Location Code" = field("Location Code"),
                                                          "Item No." = field("Item No."),
                                                          "Variant Code" = field("Variant Code"));

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                if "From Bin Code" = '' then
                    exit;
                if Location.Get("Location Code") then
                    if Location.IsDamagedBin("From Bin Code") then
                        Error(FromDamagedErr, "From Bin Code");
            end;
        }
        field(10; "To Bin Code"; Code[20])
        {
            Caption = 'To Bin Code (Damaged)';
            TableRelation = Bin.Code where("Location Code" = field("Location Code"));

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                if "To Bin Code" = '' then
                    exit;
                Location.Get("Location Code");
                if not Location.IsDamagedBin("To Bin Code") then
                    Error(ToNotDamagedErr, "To Bin Code", "Location Code");
            end;
        }
        field(11; "Lot No."; Code[50])
        {
            Caption = 'Batch No. (Lot No.)';

            trigger OnValidate()
            begin
                "Expiration Date" := GetLotExpirationDate();
            end;

            trigger OnLookup()
            begin
                LookupLotNo();
            end;
        }
        field(12; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        DamageHeader: Record "NAV Damage Transfer Header";
        Location: Record Location;
    begin
        DamageHeader.Get("Document No.");
        DamageHeader.TestField("Location Code");
        "Location Code" := DamageHeader."Location Code";
        if "To Bin Code" = '' then
            if Location.Get("Location Code") then
                "To Bin Code" := Location."Damaged Bin Code";
    end;

    procedure GetLotExpirationDate(): Date
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        if "Lot No." = '' then
            exit(0D);
        ItemLedgEntry.SetCurrentKey("Item No.", "Variant Code", "Lot No.");
        ItemLedgEntry.SetRange("Item No.", "Item No.");
        ItemLedgEntry.SetRange("Variant Code", "Variant Code");
        ItemLedgEntry.SetRange("Lot No.", "Lot No.");
        ItemLedgEntry.SetFilter("Expiration Date", '<>%1', 0D);
        if ItemLedgEntry.FindFirst() then
            exit(ItemLedgEntry."Expiration Date");
        exit(0D);
    end;

    // Lots present in the source bin
    local procedure LookupLotNo()
    var
        WarehouseEntry: Record "Warehouse Entry";
        TempLotInfo: Record "Lot No. Information" temporary;
    begin
        WarehouseEntry.SetCurrentKey("Item No.", "Bin Code", "Location Code", "Variant Code");
        WarehouseEntry.SetRange("Item No.", "Item No.");
        WarehouseEntry.SetRange("Location Code", "Location Code");
        WarehouseEntry.SetRange("Variant Code", "Variant Code");
        if "From Bin Code" <> '' then
            WarehouseEntry.SetRange("Bin Code", "From Bin Code");
        WarehouseEntry.SetFilter("Lot No.", '<>%1', '');
        if WarehouseEntry.FindSet() then
            repeat
                if not TempLotInfo.Get("Item No.", "Variant Code", WarehouseEntry."Lot No.") then begin
                    TempLotInfo.Init();
                    TempLotInfo."Item No." := "Item No.";
                    TempLotInfo."Variant Code" := "Variant Code";
                    TempLotInfo."Lot No." := WarehouseEntry."Lot No.";
                    TempLotInfo.Insert();
                end;
            until WarehouseEntry.Next() = 0;
        if Page.RunModal(0, TempLotInfo) = Action::LookupOK then
            Validate("Lot No.", TempLotInfo."Lot No.");
    end;

    var
        FromDamagedErr: Label 'Bin %1 is a damaged bin. Choose the bin where the damaged product is stored now.', Comment = '%1 = Bin Code';
        ToNotDamagedErr: Label 'Bin %1 is not a damaged bin of location %2 (see Damaged Zone Code and Damaged Bin Code on the location).', Comment = '%1 = Bin Code, %2 = Location Code';
}

table 50272 "NAV Posted Damage Transfer"
{
    Caption = 'Posted Damage Transfer';
    DataClassification = CustomerContent;
    LookupPageId = "NAV Posted Damage Transfers";
    DrillDownPageId = "NAV Posted Damage Transfers";

    fields
    {
        field(1; "No."; Code[20]) { Caption = 'No.'; }
        field(2; "Location Code"; Code[10]) { Caption = 'Location Code'; TableRelation = Location; }
        field(3; "Damage Date"; Date) { Caption = 'Damage Date'; }
        field(4; "Reason Code"; Code[10]) { Caption = 'Damage Reason Code'; TableRelation = "Reason Code"; }
        field(5; "Responsible User ID"; Code[50]) { Caption = 'Responsible User ID'; DataClassification = EndUserIdentifiableInformation; }
        field(6; "Related Document No."; Code[35]) { Caption = 'Related Document No.'; }
        field(7; Description; Text[100]) { Caption = 'Description'; }
        field(8; "No. Series"; Code[20]) { Caption = 'No. Series'; }
        field(20; "Registering Date"; Date) { Caption = 'Registering Date'; }
        field(21; "Posted By"; Code[50]) { Caption = 'Posted By'; DataClassification = EndUserIdentifiableInformation; }
        field(22; "Posted At"; DateTime) { Caption = 'Posted At'; }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}

table 50273 "NAV Posted Damage Trf. Line"
{
    Caption = 'Posted Damage Transfer Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Document No."; Code[20]) { Caption = 'Document No.'; }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(3; "Location Code"; Code[10]) { Caption = 'Location Code'; }
        field(4; "Item No."; Code[20]) { Caption = 'Item No.'; TableRelation = Item; }
        field(5; "Variant Code"; Code[10]) { Caption = 'Variant Code'; }
        field(6; Description; Text[100]) { Caption = 'Description'; }
        field(7; "Unit of Measure Code"; Code[10]) { Caption = 'Unit of Measure Code'; }
        field(8; Quantity; Decimal) { Caption = 'Damaged Quantity'; DecimalPlaces = 0 : 5; }
        field(13; "Qty. per Unit of Measure"; Decimal) { Caption = 'Qty. per Unit of Measure'; DecimalPlaces = 0 : 5; }
        field(14; "Quantity (Base)"; Decimal) { Caption = 'Damaged Quantity (Base)'; DecimalPlaces = 0 : 5; }
        field(9; "From Bin Code"; Code[20]) { Caption = 'From Bin Code'; }
        field(10; "To Bin Code"; Code[20]) { Caption = 'To Bin Code (Damaged)'; }
        field(11; "Lot No."; Code[50]) { Caption = 'Batch No. (Lot No.)'; }
        field(12; "Expiration Date"; Date) { Caption = 'Expiration Date'; }
        field(20; "From Zone Code"; Code[10]) { Caption = 'From Zone Code'; }
        field(21; "To Zone Code"; Code[10]) { Caption = 'To Zone Code'; }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Item; "Item No.", "Lot No.") { }
    }
}
