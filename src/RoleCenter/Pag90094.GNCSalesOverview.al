// Vue d'ensemble « Sales Overview » en pleine page (style professionnel validé par Haifa le 2026-10-27) :
// bandeau du jour, objectifs des commerciaux, ventes par mois, chaîne demande → facture, points à traiter,
// demandes gagnées / ratées et motifs. Ouverte depuis la barre de liens de la page d'accueil.
page 90094 "GNC Sales Overview"
{
    Caption = 'Sales Overview';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
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
                        GNCSalesScreensData.OpenView(Arg1, Arg2, '');
                    Refresh();
                end;
            }
        }
    }

    var
        IsReady: Boolean;

    local procedure Refresh()
    var
        GNCSalesScreensData: Codeunit "GNC Sales Screens Data";
    begin
        if IsReady then
            CurrPage.Screen.Render('overview', GNCSalesScreensData.BuildOverview());
    end;
}
