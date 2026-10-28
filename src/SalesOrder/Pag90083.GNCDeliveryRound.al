// Lot 7 – Écran "Delivery Round" : la tournée d'un chauffeur pour une date, sur une vraie carte
// (control add-in "GNC Delivery Map", OpenStreetMap). Ordre des arrêts : urgences d'abord, puis le plus court.
// Ouvert depuis la page d'accueil ou depuis le plan de livraison (chauffeur et date de la commande choisie).
page 90083 "GNC Delivery Round"
{
    Caption = 'Delivery Round';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Round)
            {
                Caption = 'Round';

                field(DriverCode; DriverCode)
                {
                    Caption = 'Driver';
                    TableRelation = "GNC Driver".Code where(Blocked = const(false));
                    ToolTip = 'Specifies the driver of the round. The round contains the released orders of this driver for the date.';

                    trigger OnValidate()
                    begin
                        UpdateDriverInfo();
                        LoadMap();
                    end;
                }
                field(RoundDate; RoundDate)
                {
                    Caption = 'Shipment Date';
                    ToolTip = 'Specifies the shipment date of the orders in the round.';

                    trigger OnValidate()
                    begin
                        LoadMap();
                    end;
                }
                field(DriverInfo; DriverInfo)
                {
                    Caption = 'Driver and Vehicle';
                    Editable = false;
                    ToolTip = 'Specifies the name, phone and vehicle of the driver.';
                }
            }
            group(MapGroup)
            {
                ShowCaption = false;

                usercontrol(DeliveryMap; "GNC Delivery Map")
                {
                    ApplicationArea = All;

                    trigger ControlReady()
                    begin
                        MapReady := true;
                        LoadMap();
                    end;

                    trigger OpenOrder(OrderNo: Text)
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        if SalesHeader.Get(SalesHeader."Document Type"::Order, CopyStr(OrderNo, 1, MaxStrLen(SalesHeader."No."))) then
                            Page.Run(Page::"Sales Order", SalesHeader);
                    end;

                    trigger SaveSequence(OrderNos: Text)
                    var
                        GNCDeliveryRoundMgt: Codeunit "GNC Delivery Round Mgt.";
                    begin
                        GNCDeliveryRoundMgt.SaveSequence(OrderNos);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Reload the orders of the round (for example after assigning a driver in the delivery plan).';

                trigger OnAction()
                begin
                    LoadMap();
                end;
            }
            // Ajoute une commande du plan de livraison (sans chauffeur, même date) à cette tournée
            action(AddOrder)
            {
                Caption = 'Add Order';
                Image = Add;
                ToolTip = 'Select a released order of the same shipment date that has no driver yet, and add it to this round.';

                trigger OnAction()
                begin
                    AddOrderToRound();
                end;
            }
            action(DeliveryPlan)
            {
                Caption = 'Delivery Plan';
                Image = List;
                RunObject = page "GNC Delivery Plan";
                ToolTip = 'Open the delivery plan to assign drivers and post the shipments.';
            }
        }
        area(Promoted)
        {
            actionref(Refresh_Promoted; Refresh)
            {
            }
            actionref(AddOrder_Promoted; AddOrder)
            {
            }
            actionref(DeliveryPlan_Promoted; DeliveryPlan)
            {
            }
        }
    }

    var
        DriverCode: Code[20];
        RoundDate: Date;
        DriverInfo: Text;
        MapReady: Boolean;
        SelectDriverErr: Label 'Select the driver of the round first.';

    trigger OnOpenPage()
    begin
        if RoundDate = 0D then
            RoundDate := WorkDate();
        UpdateDriverInfo();
    end;

    // Appelé par le plan de livraison avant d'ouvrir la page
    procedure SetRound(NewDriverCode: Code[20]; NewRoundDate: Date)
    begin
        DriverCode := NewDriverCode;
        RoundDate := NewRoundDate;
    end;

    local procedure UpdateDriverInfo()
    var
        Driver: Record "GNC Driver";
    begin
        DriverInfo := '';
        if Driver.Get(DriverCode) then
            DriverInfo := StrSubstNo('%1 · %2 · %3', Driver.Name, Driver."Phone No.", Driver.Vehicle);
    end;

    local procedure LoadMap()
    var
        GNCDeliveryRoundMgt: Codeunit "GNC Delivery Round Mgt.";
    begin
        if not MapReady then
            exit;
        CurrPage.DeliveryMap.LoadRound(GNCDeliveryRoundMgt.BuildRoundData(DriverCode, RoundDate));
    end;

    local procedure AddOrderToRound()
    var
        SalesHeader: Record "Sales Header";
        GNCDeliveryRoundMgt: Codeunit "GNC Delivery Round Mgt.";
    begin
        if DriverCode = '' then
            Error(SelectDriverErr);
        GNCDeliveryRoundMgt.SetRoundFilters(SalesHeader, '', RoundDate);
        if Page.RunModal(Page::"GNC Delivery Plan", SalesHeader) = Action::LookupOK then begin
            SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.");
            SalesHeader."GNC Driver Code" := DriverCode;
            SalesHeader."GNC Stop No." := 0;
            SalesHeader.Modify();
            LoadMap();
        end;
    end;
}
