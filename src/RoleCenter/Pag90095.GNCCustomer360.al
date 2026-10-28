// Fiche client visuelle « Customer 360 » en pleine page (style professionnel validé par Haifa le 2026-10-27) :
// contrôles des champs obligatoires, objectif, commandes, demandes gagnées / ratées, solde, ventes par mois,
// commerciaux, remises et bonus, dernières factures. Ouverte depuis la fiche ou la liste des clients.
page 90095 "GNC Customer 360"
{
    Caption = 'Customer 360';
    PageType = Card;
    SourceTable = Customer;
    ApplicationArea = All;
    Editable = false;
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
                        GNCSalesScreensData.OpenView(Arg1, Arg2, Rec."No.");
                    Refresh();
                end;
            }
        }
    }

    var
        IsReady: Boolean;

    // Flèches suivant / précédent de la page : on redessine pour le nouveau client
    trigger OnAfterGetCurrRecord()
    begin
        Refresh();
    end;

    local procedure Refresh()
    var
        GNCSalesScreensData: Codeunit "GNC Sales Screens Data";
    begin
        if IsReady and (Rec."No." <> '') then
            CurrPage.Screen.Render('customer', GNCSalesScreensData.BuildCustomer360(Rec));
    end;
}
