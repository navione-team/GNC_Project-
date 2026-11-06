report 50201 "NAV Landed Cost by Item"
{
    // Actual landed cost per item on the receipts linked to transit folders:
    // purchase cost + item charges (freight, customs, clearing...) posted on the
    // value entries of the folders, with the breakdown by item charge.
    Caption = 'Landed Cost by Item';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/LandedCostByItem.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Date Filter", "Inventory Posting Group";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(Item_No; "No.") { }
            column(Item_Description; Description) { }
            column(Item_BaseUoM; "Base Unit of Measure") { }
            column(Item_Qty; ReceivedQty) { }
            column(Item_PurchCost; PurchaseCost) { }
            column(Item_Charges; ChargesAmount) { }
            column(Item_LandedCost; PurchaseCost + ChargesAmount) { }
            column(Item_UnitPurch; UnitPurchaseCost) { }
            column(Item_UnitLanded; UnitLandedCost) { }
            column(Item_Coef; Coefficient) { }
            column(Item_Folders; FolderCount) { }

            trigger OnPreDataItem()
            begin
                FilterText := Item.GetFilters();
                if TransitFolderFilter <> '' then
                    FilterText := FilterText + ' ' + StrSubstNo(FolderFilterTxt, TransitFolderFilter);
            end;

            trigger OnAfterGetRecord()
            begin
                CalcItem();
                if (ReceivedQty = 0) and (PurchaseCost = 0) and (ChargesAmount = 0) then
                    CurrReport.Skip();
            end;
        }

        // Breakdown of the charges by item charge (all items of the report)
        dataitem(ChargeSummary; Integer)
        {
            DataItemTableView = sorting(Number);

            column(Chg_Code; ChargeCode) { }
            column(Chg_Description; ChargeDescription) { }
            column(Chg_Amount; ChargeTotal) { }
            column(Chg_Pct; ChargePct) { }

            trigger OnPreDataItem()
            begin
                ChargeCodes := ChargeTotals.Keys();
                SetRange(Number, 1, ChargeCodes.Count());
            end;

            trigger OnAfterGetRecord()
            var
                ItemCharge: Record "Item Charge";
                AllCharges: Decimal;
                Amount: Decimal;
            begin
                ChargeCode := CopyStr(ChargeCodes.Get(Number), 1, MaxStrLen(ChargeCode));
                ChargeTotal := ChargeTotals.Get(ChargeCode);
                ChargeDescription := '';
                if ItemCharge.Get(ChargeCode) then
                    ChargeDescription := ItemCharge.Description;
                foreach Amount in ChargeTotals.Values() do
                    AllCharges += Amount;
                ChargePct := 0;
                if AllCharges <> 0 then
                    ChargePct := Round(ChargeTotal / AllCharges * 100, 0.01);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(TransitFolderFilterField; TransitFolderFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Transit Folder Filter';
                        TableRelation = "NAV Transit Folder";
                        ToolTip = 'Specifies the transit folders to include. Empty = all folders.';
                    }
                }
            }
        }
    }

    local procedure CalcItem()
    var
        ValueEntry: Record "Value Entry";
        Folders: List of [Code[20]];
        Amount: Decimal;
    begin
        ReceivedQty := 0;
        PurchaseCost := 0;
        ChargesAmount := 0;

        ValueEntry.SetCurrentKey("Item No.");
        ValueEntry.SetRange("Item No.", Item."No.");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Purchase);
        if Item.GetFilter("Date Filter") <> '' then
            ValueEntry.SetFilter("Posting Date", Item.GetFilter("Date Filter"));
        if TransitFolderFilter <> '' then
            ValueEntry.SetFilter("Transit Folder No.", TransitFolderFilter)
        else
            ValueEntry.SetFilter("Transit Folder No.", '<>%1', '');
        if ValueEntry.FindSet() then
            repeat
                if not Folders.Contains(ValueEntry."Transit Folder No.") then
                    Folders.Add(ValueEntry."Transit Folder No.");
                if ValueEntry."Item Charge No." = '' then begin
                    if ValueEntry."Entry Type" = ValueEntry."Entry Type"::"Direct Cost" then begin
                        ReceivedQty += ValueEntry."Item Ledger Entry Quantity";
                        PurchaseCost += ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)";
                    end;
                end else begin
                    ChargesAmount += ValueEntry."Cost Amount (Actual)";
                    if ChargeTotals.Get(ValueEntry."Item Charge No.", Amount) then
                        ChargeTotals.Set(ValueEntry."Item Charge No.", Amount + ValueEntry."Cost Amount (Actual)")
                    else
                        ChargeTotals.Add(ValueEntry."Item Charge No.", ValueEntry."Cost Amount (Actual)");
                end;
            until ValueEntry.Next() = 0;

        FolderCount := Folders.Count();
        UnitPurchaseCost := 0;
        UnitLandedCost := 0;
        Coefficient := 0;
        if ReceivedQty <> 0 then begin
            UnitPurchaseCost := Round(PurchaseCost / ReceivedQty, 0.00001);
            UnitLandedCost := Round((PurchaseCost + ChargesAmount) / ReceivedQty, 0.00001);
        end;
        if PurchaseCost <> 0 then
            Coefficient := Round((PurchaseCost + ChargesAmount) / PurchaseCost, 0.0001);
    end;

    var
        ChargeTotals: Dictionary of [Code[20], Decimal];
        ChargeCodes: List of [Code[20]];
        TransitFolderFilter: Text;
        FilterText: Text;
        ChargeCode: Code[20];
        ChargeDescription: Text[100];
        ReceivedQty: Decimal;
        PurchaseCost: Decimal;
        ChargesAmount: Decimal;
        UnitPurchaseCost: Decimal;
        UnitLandedCost: Decimal;
        Coefficient: Decimal;
        ChargeTotal: Decimal;
        ChargePct: Decimal;
        FolderCount: Integer;
        FolderFilterTxt: Label 'Transit Folder: %1', Comment = '%1 = filter';
}
