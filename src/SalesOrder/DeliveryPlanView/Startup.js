// Lot 7 – démarrage de l'écran du plan de livraison : construit l'écran puis prévient BC.
GNCDeliveryPlan.init(document.getElementById("controlAddIn"));
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready", []);
