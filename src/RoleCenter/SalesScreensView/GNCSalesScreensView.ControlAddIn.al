// Écrans visuels GNC en style professionnel (maquettes validées par Haifa le 2026-10-27, « GNC Sales Screens ») :
// un seul control add-in pour 3 vues : 'overview' (Sales Overview, page 90094), 'customer' (Customer 360, page 90095)
// et 'simulator' (Price Simulator, page 90096). Toujours affiché en pleine page, jamais dans la page d'accueil.
controladdin "GNC Sales Screens View"
{
    Scripts = 'src/RoleCenter/SalesScreensView/SalesScreens.js';
    StartupScript = 'src/RoleCenter/SalesScreensView/Startup.js';
    StyleSheets = 'https://fonts.googleapis.com/css2?family=Public+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500&display=swap',
                  'src/RoleCenter/SalesScreensView/SalesScreens.css';

    RequestedHeight = 900;
    MinimumHeight = 400;
    RequestedWidth = 1300;
    MinimumWidth = 360;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    // La page JavaScript est prête : BC peut envoyer les données
    event Ready();
    // Clic : Name = 'open' (Arg1 = écran à ouvrir, Arg2 = n° de document) ou 'refresh'
    event Action(Name: Text; Arg1: Text; Arg2: Text);

    // Dessine la vue View avec les données Data
    procedure Render(View: Text; Data: JsonObject);
}
