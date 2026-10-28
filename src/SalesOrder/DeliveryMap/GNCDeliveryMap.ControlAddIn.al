// Lot 7 – Carte de la tournée de livraison (control add-in JavaScript affiché dans la page 90083).
// Carte réelle OpenStreetMap avec la bibliothèque Leaflet (chargée depuis unpkg, besoin d'internet).
// BC envoie la tournée (LoadRound) ; la page JavaScript calcule l'ordre des arrêts (urgences d'abord,
// puis le plus court) et renvoie à BC l'ordre choisi (SaveSequence) ou la commande à ouvrir (OpenOrder).
controladdin "GNC Delivery Map"
{
    Scripts = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.js',
              'src/SalesOrder/DeliveryMap/DeliveryMap.js';
    StartupScript = 'src/SalesOrder/DeliveryMap/Startup.js';
    StyleSheets = 'https://unpkg.com/leaflet@1.9.4/dist/leaflet.css',
                  'src/SalesOrder/DeliveryMap/DeliveryMap.css';

    RequestedHeight = 760;
    MinimumHeight = 560;
    RequestedWidth = 1100;
    MinimumWidth = 360;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;

    // La page JavaScript est prête : BC peut envoyer la tournée
    event ControlReady();
    // L'utilisateur veut ouvrir une commande
    event OpenOrder(OrderNo: Text);
    // L'utilisateur enregistre l'ordre des arrêts : n° de commandes séparés par des virgules
    event SaveSequence(OrderNos: Text);

    // Données de la tournée (chauffeur, dépôt, arrêts) au format JSON
    procedure LoadRound(Data: JsonObject);
}
