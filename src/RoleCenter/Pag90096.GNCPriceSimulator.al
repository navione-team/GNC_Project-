// « Price Simulator » en pleine page (style professionnel validé par Haifa le 2026-10-27) : pour un client,
// un article, une quantité et une date, montre quelle règle de remise gagne, la règle bonus, la remise MOH
// et le montant de la ligne. Ne crée aucun document : sert à expliquer et vérifier le paramétrage.
page 90096 "GNC Price Simulator"
{
    Caption = 'Price Simulator';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Simulation)
            {
                Caption = 'Simulation';

                field(CustomerNo; CustomerNo)
                {
                    Caption = 'Customer No.';
                    TableRelation = Customer."No.";
                    ToolTip = 'Specifies the customer of the simulated line.';

                    trigger OnValidate()
                    begin
                        Refresh();
                    end;
                }
                field(ItemNo; ItemNo)
                {
                    Caption = 'Item No.';
                    TableRelation = Item."No.";
                    ToolTip = 'Specifies the item of the simulated line.';

                    trigger OnValidate()
                    begin
                        Refresh();
                    end;
                }
                field(Quantity; Quantity)
                {
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                    MinValue = 0;
                    ToolTip = 'Specifies the ordered quantity. The bonus applies only from its minimum quantity.';

                    trigger OnValidate()
                    begin
                        Refresh();
                    end;
                }
                field(SimulationDate; SimulationDate)
                {
                    Caption = 'Order Date';
                    ToolTip = 'Specifies the date used to find the rules that are valid (starting and ending dates).';

                    trigger OnValidate()
                    begin
                        Refresh();
                    end;
                }
            }
            group(Result)
            {
                ShowCaption = false;

                usercontrol(Screen; "GNC Sales Screens View")
                {
                    ApplicationArea = All;

                    trigger Ready()
                    begin
                        IsReady := true;
                        Refresh();
                    end;

                    trigger Action(Name: Text; Arg1: Text; Arg2: Text)
                    var
                        GNCSalesScreensData: Codeunit "GNC Sales Screens Data";
                    begin
                        if Name = 'open' then
                            GNCSalesScreensData.OpenView(Arg1, Arg2, CustomerNo);
                        Refresh();
                    end;
                }
            }
        }
    }

    var
        CustomerNo: Code[20];
        ItemNo: Code[20];
        Quantity: Decimal;
        SimulationDate: Date;
        IsReady: Boolean;

    trigger OnOpenPage()
    begin
        if Quantity = 0 then
            Quantity := 100;
        if SimulationDate = 0D then
            SimulationDate := WorkDate();
    end;

    local procedure Refresh()
    var
        GNCSalesScreensData: Codeunit "GNC Sales Screens Data";
    begin
        if IsReady then
            CurrPage.Screen.Render('simulator', GNCSalesScreensData.BuildSimulator(CustomerNo, ItemNo, Quantity, SimulationDate));
    end;
}
