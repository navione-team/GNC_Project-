// Démarrage du control add-in "GNC Sales Screens View" : construit l'écran puis prévient BC.
GNCSalesScreens.init(document.getElementById("controlAddIn"));
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready", []);
