report 50217 "NAV Purchase Price Trend"
{
    // Purchase unit cost (LCY, per base unit) of every invoiced line per item, with
    // per item the first and last cost of the period, min, max and the change in %.
    Caption = 'Purchase Price Trend';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/PurchasePriceTrend.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Date Filter", "Item Category Code";

            column(CompanyName; CompanyProperty.DisplayName()) { }
            column(ReportFilters; FilterText) { }
            column(Prc_ItemNo; "No.") { }
            column(Prc_ItemDescription; Description) { }
            column(Prc_BaseUoM; "Base Unit of Measure") { }
            column(Prc_FirstCost; FirstCost) { }
            column(Prc_LastCost; LastCost) { }
            column(Prc_MinCost; MinCost) { }
            column(Prc_MaxCost; MaxCost) { }
            column(Prc_ChangePct; ChangePct) { }

            dataitem(InvLine; "Purch. Inv. Line")
            {
                DataItemLink = "No." = field("No.");
                DataItemTableView = where(Type = const(Item), Quantity = filter(<> 0));

                column(Lin_Date; Format("Posting Date")) { }
                column(Lin_DateSort; Format("Posting Date", 0, '<Year4><Month,2><Day,2>')) { }
                column(Lin_InvoiceNo; "Document No.") { }
                column(Lin_VendorNo; "Buy-from Vendor No.") { }
                column(Lin_VendorName; Helper.GetVendorName("Buy-from Vendor No.")) { }
                column(Lin_QtyBase; "Quantity (Base)") { }
                column(Lin_UnitCostBase; UnitCostBase(InvLine)) { }

                trigger OnPreDataItem()
                begin
                    ApplyLineFilters(InvLine);
                end;
            }

            trigger OnPreDataItem()
            begin
                FilterText := GetFilters();
                if VendorFilter <> '' then
                    FilterText := FilterText + ' ' + StrSubstNo(VendorFilterTxt, VendorFilter);
            end;

            trigger OnAfterGetRecord()
            var
                Line: Record "Purch. Inv. Line";
                Cost: Decimal;
                FirstDate: Date;
                LastDate: Date;
                Found: Boolean;
            begin
                FirstCost := 0;
                LastCost := 0;
                MinCost := 0;
                MaxCost := 0;
                ChangePct := 0;
                Line.SetRange("No.", "No.");
                Line.SetRange(Type, Line.Type::Item);
                Line.SetFilter(Quantity, '<>0');
                ApplyLineFilters(Line);
                if Line.FindSet() then
                    repeat
                        Cost := UnitCostBase(Line);
                        if not Found then begin
                            Found := true;
                            FirstDate := Line."Posting Date";
                            LastDate := Line."Posting Date";
                            FirstCost := Cost;
                            LastCost := Cost;
                            MinCost := Cost;
                            MaxCost := Cost;
                        end else begin
                            if Line."Posting Date" < FirstDate then begin
                                FirstDate := Line."Posting Date";
                                FirstCost := Cost;
                            end;
                            if Line."Posting Date" >= LastDate then begin
                                LastDate := Line."Posting Date";
                                LastCost := Cost;
                            end;
                            if Cost < MinCost then
                                MinCost := Cost;
                            if Cost > MaxCost then
                                MaxCost := Cost;
                        end;
                    until Line.Next() = 0;
                if not Found then
                    CurrReport.Skip();
                if FirstCost <> 0 then
                    ChangePct := Round((LastCost - FirstCost) / FirstCost * 100, 0.01);
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

                    field(VendorFilterField; VendorFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor Filter';
                        TableRelation = Vendor;
                        ToolTip = 'Specifies the vendors whose invoices are included. Empty = all vendors.';
                    }
                }
            }
        }
    }

    local procedure ApplyLineFilters(var Line: Record "Purch. Inv. Line")
    begin
        if Item.GetFilter("Date Filter") <> '' then
            Line.SetFilter("Posting Date", Item.GetFilter("Date Filter"));
        if VendorFilter <> '' then
            Line.SetFilter("Buy-from Vendor No.", VendorFilter);
    end;

    // Unit cost in LCY per base unit: Unit Cost (LCY) of the line / qty per unit of measure
    local procedure UnitCostBase(Line: Record "Purch. Inv. Line"): Decimal
    begin
        if Line."Qty. per Unit of Measure" = 0 then
            exit(Line."Unit Cost (LCY)");
        exit(Round(Line."Unit Cost (LCY)" / Line."Qty. per Unit of Measure", 0.00001));
    end;

    var
        Helper: Codeunit "NAV Report Helper";
        VendorFilter: Text;
        FilterText: Text;
        FirstCost: Decimal;
        LastCost: Decimal;
        MinCost: Decimal;
        MaxCost: Decimal;
        ChangePct: Decimal;
        VendorFilterTxt: Label 'Vendor: %1', Comment = '%1 = filter';
}
