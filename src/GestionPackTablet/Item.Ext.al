tableextension 50240 "NAV Item Tablet Pack" extends Item
{
    fields
    {
        // Unit used to display and steer the inventory in packs (PACK, BOX...)
        field(50240; "Pack Unit of Measure"; Code[10])
        {
            Caption = 'Pack Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("No."));

            trigger OnValidate()
            begin
                if ("Pack Unit of Measure" <> '') and ("Pack Unit of Measure" = "Base Unit of Measure") then
                    Error(PackIsBaseErr, "Pack Unit of Measure");
            end;
        }
        field(50241; "Tablet Price Method"; Enum "NAV Tablet Price Method")
        {
            Caption = 'Tablet Price Method';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Tablet Price Method" = "Tablet Price Method"::Independent then
                    "Tablet Price Markup %" := 0
                else
                    TestField("Pack Unit of Measure");
            end;
        }
        field(50242; "Tablet Price Markup %"; Decimal)
        {
            Caption = 'Tablet Price Markup %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = -100;

            trigger OnValidate()
            begin
                if "Tablet Price Markup %" <> 0 then
                    TestField("Tablet Price Method", "Tablet Price Method"::"From Pack Price");
            end;
        }
        field(50243; "Tablet Rounding Method"; Enum "NAV Tablet Rounding Method")
        {
            Caption = 'Tablet Rounding Method';
            DataClassification = CustomerContent;
        }
    }

    // Number of base units (tablets) in one pack, 0 when no pack unit is defined
    procedure GetPackQtyPerUoM(): Decimal
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if "Pack Unit of Measure" = '' then
            exit(0);
        if not ItemUnitOfMeasure.Get("No.", "Pack Unit of Measure") then
            exit(0);
        exit(ItemUnitOfMeasure."Qty. per Unit of Measure");
    end;

    // Converts a quantity in base unit (tablets) into packs
    procedure ToPacks(BaseQty: Decimal): Decimal
    var
        PackQty: Decimal;
    begin
        PackQty := GetPackQtyPerUoM();
        if PackQty = 0 then
            exit(0);
        exit(Round(BaseQty / PackQty, 0.00001));
    end;

    // Rounding method of the item, or the default of Inventory Setup
    procedure GetTabletRoundingMethod(): Enum "NAV Tablet Rounding Method"
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if "Tablet Rounding Method" <> "Tablet Rounding Method"::"Use Default" then
            exit("Tablet Rounding Method");
        InventorySetup.Get();
        if InventorySetup."Default Tablet Rounding" = InventorySetup."Default Tablet Rounding"::"Use Default" then
            exit("Tablet Rounding Method"::Nearest);
        exit(InventorySetup."Default Tablet Rounding");
    end;

    var
        PackIsBaseErr: Label 'The pack unit of measure %1 cannot be the base unit of measure of the item.', Comment = '%1 = Unit of Measure Code';
}

tableextension 50241 "NAV Item Unit of Measure" extends "Item Unit of Measure"
{
    fields
    {
        // The quantity entered in this unit must be a whole number (e.g. TABLET)
        field(50240; "Whole Quantity Only"; Boolean)
        {
            Caption = 'Whole Quantity Only';
            DataClassification = CustomerContent;
        }
    }
}

tableextension 50242 "NAV Inventory Setup Tablet" extends "Inventory Setup"
{
    fields
    {
        field(50240; "Default Tablet Rounding"; Enum "NAV Tablet Rounding Method")
        {
            Caption = 'Default Tablet Rounding Method';
            DataClassification = CustomerContent;
            InitValue = Nearest;
        }
        // Status given to a new batch when it is received (Available, or Quarantine for a quality check)
        field(50250; "Default Lot Status at Receipt"; Enum "NAV Lot Status")
        {
            Caption = 'Default Lot Status at Receipt';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Default Lot Status at Receipt" in ["Default Lot Status at Receipt"::Blocked, "Default Lot Status at Receipt"::Expired] then
                    FieldError("Default Lot Status at Receipt");
            end;
        }
        // Rule 17: reason code mandatory on adjustments of batch-tracked items
        field(50251; "Lot Adjmt. Reason Mandatory"; Boolean)
        {
            Caption = 'Reason Code Mandatory on Lot Adjustments';
            DataClassification = CustomerContent;
        }
    }
}

tableextension 50243 "NAV Sales Setup Tablet" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50240; "Check Tablet Availability"; Boolean)
        {
            Caption = 'Check Availability on Release';
            DataClassification = CustomerContent;
        }
    }
}
