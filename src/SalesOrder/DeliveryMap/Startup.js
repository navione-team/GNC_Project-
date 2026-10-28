// Lot 7 – démarrage du control add-in "GNC Delivery Map" : construit l'écran puis prévient BC.
GNCDeliveryMap.init(document.getElementById("controlAddIn"));
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlReady", []);
