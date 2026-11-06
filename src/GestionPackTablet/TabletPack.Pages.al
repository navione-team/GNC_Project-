pageextension 50240 "NAV Item Card Tablet Pack" extends "Item Card"
{
    layout
    {
        addafter("Base Unit of Measure")
        {
            field("Pack Unit of Measure"; Rec."Pack Unit of Measure")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the unit used to display and steer the inventory in packs (for example PACK). The base unit of measure stays the tablet.';
            }
            field("Tablet Rounding Method"; Rec."Tablet Rounding Method")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how a quantity converted into tablets is rounded when it has decimals. Use Default applies the method of the Inventory Setup.';
            }
        }
        addafter(Inventory)
        {
            field(NAVInventoryPacks; InventoryPacks)
            {
                ApplicationArea = All;
                Caption = 'Inventory (Packs)';
                DecimalPlaces = 0 : 5;
                Editable = false;
                ToolTip = 'Specifies the inventory converted into packs (inventory in tablets divided by the number of tablets per pack).';
            }
        }
        addafter("Unit Cost")
        {
            field(NAVUnitCostPack; UnitCostPack)
            {
                ApplicationArea = All;
                Caption = 'Unit Cost (Pack)';
                AutoFormatType = 2;
                Editable = false;
                ToolTip = 'Specifies the unit cost of one pack (unit cost per tablet multiplied by the number of tablets per pack).';
            }
        }
        addafter("Unit Price")
        {
            field("Tablet Price Method"; Rec."Tablet Price Method")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the tablet price is entered in the price lists (Independent) or calculated from the pack price (From Pack Price).';
            }
            field("Tablet Price Markup %"; Rec."Tablet Price Markup %")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the markup applied to the tablet price calculated from the pack price (pack price / tablets per pack x (1 + markup %)).';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CalcPackValues();
    end;

    local procedure CalcPackValues()
    begin
        Rec.CalcFields(Inventory);
        InventoryPacks := Rec.ToPacks(Rec.Inventory);
        UnitCostPack := Rec."Unit Cost" * Rec.GetPackQtyPerUoM();
    end;

    var
        InventoryPacks: Decimal;
        UnitCostPack: Decimal;
}

pageextension 50241 "NAV Item List Tablet Pack" extends "Item List"
{
    layout
    {
        addafter("Base Unit of Measure")
        {
            field("Pack Unit of Measure"; Rec."Pack Unit of Measure")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the unit used to display the inventory in packs.';
            }
            field(NAVInventoryPacks; InventoryPacks)
            {
                ApplicationArea = All;
                Caption = 'Inventory (Packs)';
                DecimalPlaces = 0 : 5;
                Editable = false;
                ToolTip = 'Specifies the inventory converted into packs.';
            }
            field(NAVUnitCostPack; UnitCostPack)
            {
                ApplicationArea = All;
                Caption = 'Unit Cost (Pack)';
                AutoFormatType = 2;
                Editable = false;
                ToolTip = 'Specifies the unit cost of one pack.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields(Inventory);
        InventoryPacks := Rec.ToPacks(Rec.Inventory);
        UnitCostPack := Rec."Unit Cost" * Rec.GetPackQtyPerUoM();
    end;

    var
        InventoryPacks: Decimal;
        UnitCostPack: Decimal;
}

pageextension 50242 "NAV Item Units of Measure" extends "Item Units of Measure"
{
    layout
    {
        addafter("Qty. per Unit of Measure")
        {
            field("Whole Quantity Only"; Rec."Whole Quantity Only")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that a quantity entered in this unit must be a whole number (for example TABLET: a fraction of a tablet cannot be sold).';
            }
        }
    }
}

pageextension 50243 "NAV Inventory Setup Tablet" extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            field("Default Tablet Rounding"; Rec."Default Tablet Rounding")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the default rounding method applied when a quantity converted into tablets has decimals (Nearest, Up or Down). It can be changed per item.';
            }
            field("Default Lot Status at Receipt"; Rec."Default Lot Status at Receipt")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the status given to a new batch when it is received: Available, or Quarantine when a quality check is required before sale.';
            }
            field("Lot Adjmt. Reason Mandatory"; Rec."Lot Adjmt. Reason Mandatory")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that a reason code is mandatory on positive and negative adjustments of batch-tracked items.';
            }
        }
    }
}

pageextension 50244 "NAV Sales Setup Tablet" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(General)
        {
            field("Check Tablet Availability"; Rec."Check Tablet Availability")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that a sales order or invoice cannot be released when the requested quantity exceeds the available inventory (inventory on hand minus the other released sales orders).';
            }
        }
    }
}

pageextension 50245 "NAV Sales Order Subform TP" extends "Sales Order Subform"
{
    layout
    {
        addafter("Unit of Measure Code")
        {
            field(NAVAvailablePacks; AvailablePacks)
            {
                ApplicationArea = All;
                Caption = 'Available (Packs)';
                DecimalPlaces = 0 : 5;
                Editable = false;
                ToolTip = 'Specifies the inventory of the item at the location of the line, converted into packs.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        AvailablePacks := TabletPackDisplay.GetAvailablePacks(Rec);
    end;

    var
        TabletPackDisplay: Codeunit "NAV Tablet Pack Display";
        AvailablePacks: Decimal;
}

pageextension 50246 "NAV Sales Inv. Subform TP" extends "Sales Invoice Subform"
{
    layout
    {
        addafter("Unit of Measure Code")
        {
            field(NAVAvailablePacks; AvailablePacks)
            {
                ApplicationArea = All;
                Caption = 'Available (Packs)';
                DecimalPlaces = 0 : 5;
                Editable = false;
                ToolTip = 'Specifies the inventory of the item at the location of the line, converted into packs.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        AvailablePacks := TabletPackDisplay.GetAvailablePacks(Rec);
    end;

    var
        TabletPackDisplay: Codeunit "NAV Tablet Pack Display";
        AvailablePacks: Decimal;
}
