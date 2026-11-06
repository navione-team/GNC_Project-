page 50203 "NAV Transit Folder Item Lines"
{
    Caption = 'Items / Landed Cost Simulation';
    PageType = ListPart;
    SourceTable = "NAV Transit Folder Item Line";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Source; Rec.Source)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source of the line: open order, or receipt of a completed order.';
                    Visible = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source order (or receipt).';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item description.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure.';
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the purchase unit cost excluding VAT in local currency.';
                }
                field("Line Amount (LCY)"; Rec."Line Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line amount excluding VAT in local currency.';
                }
                field("Allocation %"; Rec."Allocation %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the share of the line in the total amount excluding VAT (charge allocation key).';
                }
                field("Charges Amount (LCY)"; Rec."Charges Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the landed charges allocated to the line.';
                }
                field("Unit Charges (LCY)"; Rec."Unit Charges (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the landed charges per unit.';
                }
                field("Landed Unit Cost (LCY)"; Rec."Landed Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the landed unit cost = item unit cost + unit landed charges.';
                }
                field("Landed Amount (LCY)"; Rec."Landed Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total landed cost of the line.';
                }
                field("Landed Cost Coefficient"; Rec."Landed Cost Coefficient")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the landed cost coefficient = landed cost / purchase cost.';
                }
                field("Price/Profit Calculation"; Rec."Price/Profit Calculation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price/profit rule of the item card used for the simulation.';
                }
                field("Item Profit %"; Rec."Item Profit %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the profit % of the item card.';
                }
                field("Current Unit Price"; Rec."Current Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current unit price of the item card, converted to the unit of measure of the line.';
                }
                field("Simulated Unit Price"; Rec."Simulated Unit Price")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    ToolTip = 'Specifies the simulated sales price per unit of measure of the line. Price=Cost+Profit: landed cost / (1 - profit %). Other rules: current unit price of the item.';
                }
                field("Sim. Unit Price (Base UoM)"; Rec."Sim. Unit Price (Base UoM)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the simulated sales price per base unit of measure (tablet).';
                }
                field("Simulated Unit Profit"; Rec."Simulated Unit Profit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the simulated profit per unit = simulated unit price - landed unit cost.';
                }
                field("Simulated Profit %"; Rec."Simulated Profit %")
                {
                    ApplicationArea = All;
                    StyleExpr = ProfitStyle;
                    ToolTip = 'Specifies the simulated profit % = (price - landed cost) / price x 100.';
                }
                field("Simulated Sales Amount"; Rec."Simulated Sales Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the simulated sales amount of the line = quantity x simulated unit price.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."Simulated Unit Profit" < 0 then
            ProfitStyle := 'Unfavorable'
        else
            ProfitStyle := 'Standard';
    end;

    var
        ProfitStyle: Text;
}
