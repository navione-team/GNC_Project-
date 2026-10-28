// Lot 7 – Écran visuel du plan de livraison, en pleine page (design validé par Haifa le 2026-10-27) :
// chiffres du jour, charge des chauffeurs, commandes groupées par priorité, détail de la commande choisie
// (lignes et stock, chauffeur, contrôles) et expédition. La liste classique reste disponible (page 90077).
page 90090 "GNC Delivery Plan Board"
{
    Caption = 'Delivery Plan';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            usercontrol(Plan; "GNC Delivery Plan View")
            {
                ApplicationArea = All;

                trigger Ready()
                begin
                    IsReady := true;
                    Refresh();
                end;

                trigger Action(Name: Text; Arg1: Text; Arg2: Text)
                begin
                    HandleAction(Name, Arg1, Arg2);
                end;
            }
        }
    }

    var
        IsReady: Boolean;

    local procedure Refresh()
    var
        GNCDeliveryPlanData: Codeunit "GNC Delivery Plan Data";
    begin
        if IsReady then
            CurrPage.Plan.LoadPlan(GNCDeliveryPlanData.BuildPlan());
    end;

    local procedure HandleAction(Name: Text; Arg1: Text; Arg2: Text)
    var
        SalesHeader: Record "Sales Header";
        GNCDeliveryPlanData: Codeunit "GNC Delivery Plan Data";
        GNCDeliveryMgt: Codeunit "GNC Delivery Mgt.";
        GNCDeliveryRound: Page "GNC Delivery Round";
    begin
        case Name of
            'setDriver':
                GNCDeliveryPlanData.SetDriver(Arg1, Arg2);
            'ship':
                if GetOrder(Arg1, SalesHeader) then
                    GNCDeliveryMgt.ShipOrder(SalesHeader);
            'open':
                if GetOrder(Arg1, SalesHeader) then
                    Page.RunModal(Page::"Sales Order", SalesHeader);
            'round':
                begin
                    if GetOrder(Arg1, SalesHeader) then
                        GNCDeliveryRound.SetRound(SalesHeader."GNC Driver Code", SalesHeader."Shipment Date");
                    GNCDeliveryRound.Run();
                end;
            'list':
                Page.Run(Page::"GNC Delivery Plan");
        end;
        Refresh();
    end;

    local procedure GetOrder(OrderNo: Text; var SalesHeader: Record "Sales Header"): Boolean
    begin
        exit(SalesHeader.Get(SalesHeader."Document Type"::Order, CopyStr(OrderNo, 1, MaxStrLen(SalesHeader."No."))));
    end;
}
