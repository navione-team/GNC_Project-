// Lot 4 – démarrage de l'écran Requests to Group : construit l'écran puis prévient BC.
GNCRequestsGroup.init(document.getElementById("controlAddIn"));
Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("Ready", []);
