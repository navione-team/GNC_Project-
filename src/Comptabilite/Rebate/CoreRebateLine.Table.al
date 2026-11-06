// Core Rebate: eligible item and fixed rebate amount per unit sold
table 50302 "NAV Core Rebate Line"
{
    Caption = 'Core Rebate Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Agreement No."; Code[20])
        {
            Caption = 'Agreement No.';
            TableRelation = "NAV Rebate Agreement";
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            NotBlank = true;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Item.Get("Item No.") then begin
                    Description := Item.Description;
                    if "Unit of Measure Code" = '' then
                        "Unit of Measure Code" := Item."Base Unit of Measure";
                end else
                    Description := '';
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(4; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
        // Amount in LCY granted for one unit (of the unit of measure above) sold
        field(5; "Amount per Unit"; Decimal)
        {
            Caption = 'Rebate Amount per Unit (LCY)';
            AutoFormatType = 2;
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Agreement No.", "Item No.") { Clustered = true; }
    }

    // Rebate amount for a quantity expressed in base unit of measure
    procedure AmountForBaseQty(QtyBase: Decimal): Decimal
    var
        ItemUoM: Record "Item Unit of Measure";
        QtyPerUoM: Decimal;
    begin
        QtyPerUoM := 1;
        if ItemUoM.Get("Item No.", "Unit of Measure Code") then
            if ItemUoM."Qty. per Unit of Measure" <> 0 then
                QtyPerUoM := ItemUoM."Qty. per Unit of Measure";
        exit(QtyBase / QtyPerUoM * "Amount per Unit");
    end;
}
