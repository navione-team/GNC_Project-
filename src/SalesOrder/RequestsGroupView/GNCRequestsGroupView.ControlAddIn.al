// Lot 4 – Écran visuel « Requests to Group » (style professionnel validé par Haifa le 2026-10-27,
// maquette « GNC Requests to Group »). Affiché en pleine page dans la page 90092.
// BC envoie les demandes approuvées, déjà réparties en groupes avec la même règle que le regroupement
// (codeunit 90056) ; la page JavaScript calcule l'aperçu de la commande et renvoie les clics (Action).
controladdin "GNC Requests Group View"
{
    Scripts = 'src/SalesOrder/RequestsGroupView/RequestsGroup.js';
    StartupScript = 'src/SalesOrder/RequestsGroupView/Startup.js';
    StyleSheets = 'https://fonts.googleapis.com/css2?family=Public+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500&display=swap',
                  'src/SalesOrder/RequestsGroupView/RequestsGroup.css';

    RequestedHeight = 900;
    MinimumHeight = 500;
    RequestedWidth = 1300;
    MinimumWidth = 360;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    // La page JavaScript est prête : BC peut envoyer les données
    event Ready();
    // Clic : 'create' (Arg1 = n° d'une demande confirmée du groupe), 'createAll', 'openRequest', 'openOrder',
    // 'setup', 'delivery', 'refresh'
    event Action(Name: Text; Arg1: Text; Arg2: Text);

    // Données de l'écran (JSON)
    procedure LoadGroups(Data: JsonObject);
}
