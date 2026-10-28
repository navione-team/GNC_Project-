// Lot 4 – Écran visuel « Requests to Group », en pleine page (style professionnel validé par Haifa le 2026-10-27) :
// synthèse, règle de regroupement, groupes client (+ jour), demandes avec leur PIN, aperçu de la commande
// (lignes cumulées, bonus), contrôles et création de la commande. Le bouton « Create grouped order »
// appelle le vrai regroupement (codeunit 90056). La liste classique reste disponible (page 90055).
page 90092 "GNC Requests to Group Board"
{
    Caption = 'Requests to Group';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            usercontrol(Groups; "GNC Requests Group View")
            {
                ApplicationArea = All;

                trigger Ready()
                begin
                    IsReady := true;
                    Refresh();
                end;

                trigger Action(Name: Text; Arg1: Text; Arg2: Text)
                begin
                    HandleAction(Name, Arg1);
                end;
            }
        }
    }

    var
        Created: JsonArray; // commandes créées depuis l'ouverture de l'écran
        IsReady: Boolean;

    local procedure Refresh()
    var
        GNCRequestsGroupData: Codeunit "GNC Requests Group Data";
    begin
        if IsReady then
            CurrPage.Groups.LoadGroups(GNCRequestsGroupData.BuildGroups(Created));
    end;

    local procedure HandleAction(Name: Text; Arg1: Text)
    var
        Request: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        GNCRequestGroupingMgt: Codeunit "GNC Request Grouping Mgt.";
        GNCRequestsGroupData: Codeunit "GNC Requests Group Data";
    begin
        case Name of
            'create':
                if Request.Get(Request."Document Type"::Quote, CopyStr(Arg1, 1, MaxStrLen(Request."No."))) then begin
                    GNCRequestGroupingMgt.GroupRequestsOf(Request);
                    GNCRequestsGroupData.AddCreatedOrder(CopyStr(Arg1, 1, MaxStrLen(Request."No.")), Created);
                end;
            'createAll':
                GNCRequestGroupingMgt.GroupAllRequests();
            'openRequest':
                if Request.Get(Request."Document Type"::Quote, CopyStr(Arg1, 1, MaxStrLen(Request."No."))) then
                    Page.RunModal(Page::"Sales Quote", Request);
            'openOrder':
                if SalesHeader.Get(SalesHeader."Document Type"::Order, CopyStr(Arg1, 1, MaxStrLen(SalesHeader."No."))) then
                    Page.RunModal(Page::"Sales Order", SalesHeader);
            'setup':
                Page.RunModal(Page::"GNC Sales Setup");
            'list':
                Page.Run(Page::"GNC Requests to Group");
        end;
        Refresh();
    end;
}
