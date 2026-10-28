// Lot 7 – Écran visuel du plan de livraison (style « professionnel » validé par Haifa le 2026-10-27,
// maquette « GNC Delivery Plan Pro »).
// Affiché en pleine page dans la page 90090. BC envoie les commandes à livrer, les chauffeurs et les
// expéditions du jour (LoadPlan) ; la page JavaScript renvoie les clics (Action).
controladdin "GNC Delivery Plan View"
{
    Scripts = 'src/SalesOrder/DeliveryPlanView/DeliveryPlan.js';
    StartupScript = 'src/SalesOrder/DeliveryPlanView/Startup.js';
    StyleSheets = 'https://fonts.googleapis.com/css2?family=Public+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500&display=swap',
                  'src/SalesOrder/DeliveryPlanView/DeliveryPlan.css';

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
    // Clic : Name = 'setDriver' (Arg1 = n° commande, Arg2 = chauffeur), 'ship', 'open', 'round', 'refresh', 'list'
    event Action(Name: Text; Arg1: Text; Arg2: Text);

    // Données du plan de livraison (JSON)
    procedure LoadPlan(Data: JsonObject);
}
