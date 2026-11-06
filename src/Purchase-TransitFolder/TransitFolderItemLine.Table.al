// Landed cost simulation per item of the folder
table 50202 "NAV Transit Folder Item Line"
{
    Caption = 'Transit Folder Item Line';
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
        field(3; Source; Option)
        {
            Caption = 'Source';
            OptionMembers = "Order","Receipt";
            OptionCaption = 'Order,Receipt';
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(5; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
        }
        field(6; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = Item;
        }
        field(7; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("No."));
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(10; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(11; "Unit Cost (LCY)"; Decimal)
        {
            Caption = 'Unit Cost (LCY)';
            AutoFormatType = 2;
        }
        field(12; "Line Amount (LCY)"; Decimal)
        {
            Caption = 'Line Amount Excl. VAT (LCY)';
            AutoFormatType = 1;
        }
        field(13; "Allocation %"; Decimal)
        {
            Caption = 'Allocation %';
            DecimalPlaces = 0 : 5;
        }
        field(14; "Charges Amount (LCY)"; Decimal)
        {
            Caption = 'Landed Charges (LCY)';
            AutoFormatType = 1;
        }
        field(15; "Unit Charges (LCY)"; Decimal)
        {
            Caption = 'Unit Landed Charges (LCY)';
            AutoFormatType = 2;
        }
        field(16; "Landed Unit Cost (LCY)"; Decimal)
        {
            Caption = 'Landed Unit Cost (LCY)';
            AutoFormatType = 2;
        }
        field(17; "Landed Amount (LCY)"; Decimal)
        {
            Caption = 'Landed Amount (LCY)';
            AutoFormatType = 1;
        }
        field(18; "Landed Cost Coefficient"; Decimal)
        {
            Caption = 'Landed Cost Coefficient';
            DecimalPlaces = 0 : 5;
        }
        // ---------- Sales price simulation (rules of the item card) ----------
        field(19; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
        }
        field(20; "Price/Profit Calculation"; Option)
        {
            Caption = 'Price/Profit Calculation';
            OptionMembers = "Profit=Price-Cost","Price=Cost+Profit","No Relationship";
            OptionCaption = 'Profit=Price-Cost,Price=Cost+Profit,No Relationship';
        }
        field(21; "Item Profit %"; Decimal)
        {
            Caption = 'Item Profit %';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Current Unit Price"; Decimal)
        {
            Caption = 'Current Unit Price';
            AutoFormatType = 2;
        }
        field(23; "Simulated Unit Price"; Decimal)
        {
            Caption = 'Simulated Unit Price';
            AutoFormatType = 2;
        }
        field(24; "Simulated Unit Profit"; Decimal)
        {
            Caption = 'Simulated Unit Profit';
            AutoFormatType = 2;
        }
        field(25; "Simulated Profit %"; Decimal)
        {
            Caption = 'Simulated Profit %';
            DecimalPlaces = 0 : 2;
        }
        field(26; "Simulated Sales Amount"; Decimal)
        {
            Caption = 'Simulated Sales Amount';
            AutoFormatType = 1;
        }
        field(27; "Sim. Unit Price (Base UoM)"; Decimal)
        {
            Caption = 'Simulated Unit Price (Base UoM)';
            AutoFormatType = 2;
        }
    }

    keys
    {
        key(PK; "Folder No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Line Amount (LCY)", "Charges Amount (LCY)", "Landed Amount (LCY)";
        }
        key(Item; "Folder No.", "No.") { }
    }

    procedure UpdateCosts()
    begin
        if Quantity <> 0 then begin
            "Unit Cost (LCY)" := Round("Line Amount (LCY)" / Quantity, 0.00001);
            "Unit Charges (LCY)" := Round("Charges Amount (LCY)" / Quantity, 0.00001);
        end else begin
            "Unit Cost (LCY)" := 0;
            "Unit Charges (LCY)" := 0;
        end;
        "Landed Unit Cost (LCY)" := "Unit Cost (LCY)" + "Unit Charges (LCY)";
        "Landed Amount (LCY)" := "Line Amount (LCY)" + "Charges Amount (LCY)";
        if "Line Amount (LCY)" <> 0 then
            "Landed Cost Coefficient" := Round("Landed Amount (LCY)" / "Line Amount (LCY)", 0.00001)
        else
            "Landed Cost Coefficient" := 0;
        SimulateSalesPrice();
    end;

    // Simulated sales price, using the rules of the item card:
    //  - Price=Cost+Profit : Price = Landed Cost / (1 - Profit % / 100)   (same formula as the item card)
    //  - Profit=Price-Cost : Price = current unit price, the profit is recalculated on the landed cost
    //  - No Relationship   : Price = current unit price, the profit is shown for information
    // The item unit price is per base unit (TABLET); it is converted to the unit of the line (e.g. PACK).
    procedure SimulateSalesPrice()
    var
        Item: Record Item;
        ItemUoM: Record "Item Unit of Measure";
        GLSetup: Record "General Ledger Setup";
        LandedCostBase: Decimal;
        PriceBase: Decimal;
    begin
        "Simulated Unit Price" := 0;
        "Sim. Unit Price (Base UoM)" := 0;
        "Simulated Unit Profit" := 0;
        "Simulated Profit %" := 0;
        "Simulated Sales Amount" := 0;
        "Current Unit Price" := 0;
        if not Item.Get("No.") then
            exit;
        GLSetup.Get();

        "Qty. per Unit of Measure" := 1;
        if ("Unit of Measure Code" <> '') and ItemUoM.Get("No.", "Unit of Measure Code") then
            if ItemUoM."Qty. per Unit of Measure" <> 0 then
                "Qty. per Unit of Measure" := ItemUoM."Qty. per Unit of Measure";

        "Price/Profit Calculation" := Item."Price/Profit Calculation";
        "Item Profit %" := Item."Profit %";
        LandedCostBase := "Landed Unit Cost (LCY)" / "Qty. per Unit of Measure";

        case Item."Price/Profit Calculation" of
            Item."Price/Profit Calculation"::"Price=Cost+Profit":
                if Item."Profit %" < 100 then
                    PriceBase := LandedCostBase / (1 - Item."Profit %" / 100)
                else
                    PriceBase := Item."Unit Price";
            else
                PriceBase := Item."Unit Price";
        end;

        "Sim. Unit Price (Base UoM)" := Round(PriceBase, GLSetup."Unit-Amount Rounding Precision");
        "Simulated Unit Price" := Round(PriceBase * "Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision");
        "Current Unit Price" := Round(Item."Unit Price" * "Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision");
        "Simulated Unit Profit" := "Simulated Unit Price" - "Landed Unit Cost (LCY)";
        if "Simulated Unit Price" <> 0 then
            "Simulated Profit %" := Round("Simulated Unit Profit" / "Simulated Unit Price" * 100, 0.01);
        "Simulated Sales Amount" := Round("Simulated Unit Price" * Quantity, GLSetup."Amount Rounding Precision");
    end;
}
