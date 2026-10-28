# GNC_Project-

Extension Business Central (AL) pour les ventes de **GNC** (distribution pharmaceutique), développée par **Navione**.

- Extension : « Pharma Data Migration » (voir `app.json`), cible BC 24, Cloud.
- Code source : `src/` (un dossier par module : Customer, Salesperson, SalesQuote, SalesOrder, Bonus, RoleCenter…).
- Cahier des besoins : `docs/FRD_Sales_GNC.md`.
- Description détaillée des modules : `docs/Guide-modules-GNC.pdf`.
- Notes du projet, IDs utilisés et avancement : `CLAUDE.md`.

## Compiler
Ouvrir le dossier dans VS Code avec l'extension AL, télécharger les symboles (`AL: Download Symbols`), puis publier vers la sandbox GNCSANDBOX (`.vscode/launch.json`).
