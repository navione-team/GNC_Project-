// Règles de la Request Collection (devis) liées au commercial identifié par son PIN.
// Hypothèses de travail (CLAUDE.md, à valider par le chef de projet) :
// - Portefeuille d'un commercial = clients qui l'ont comme Salesperson Code sur leur fiche
//   + clients présents pour lui dans la table d'affectation 90032.
//   Si le commercial n'a AUCUN client dans son portefeuille, pas de restriction (paramétrage pas encore fait).
// - Articles autorisés = affectations du couple client + commercial (table 90032) :
//   article affecté directement (Type = Item) ou article dont la catégorie est affectée (Type = Item Category).
//   S'il n'y a aucune affectation pour ce couple, pas de restriction.
// Aucune modification du code standard : uniquement des event subscribers.
codeunit 90043 "GNC Request Collection Mgt."
{
    var
        CustomerNotInPortfolioErr: Label 'Customer %1 is not in the portfolio of salesperson %2.', Comment = '%1 = customer no., %2 = salesperson code';
        ItemNotAllowedErr: Label 'Item %1 (category %2) is not assigned to salesperson %3 for customer %4. Check the salesperson assignments.', Comment = '%1 = item no., %2 = item category, %3 = salesperson code, %4 = customer no.';

    // ---------- Clients ----------

    // Filtre sur "No." des clients du portefeuille, ex. 'C00010'|'20000'. Vide = pas de portefeuille.
    procedure GetPortfolioFilter(SalespersonCode: Code[20]): Text
    var
        Customer: Record Customer;
        Assignment: Record "GNC Cust. Salesperson Assign.";
        CustomerNos: List of [Code[20]];
        CustomerNo: Code[20];
        PortfolioFilter: Text;
    begin
        if SalespersonCode = '' then
            exit('');

        // 1. Clients dont la fiche porte ce commercial
        Customer.SetRange("Salesperson Code", SalespersonCode);
        if Customer.FindSet() then
            repeat
                CustomerNos.Add(Customer."No.");
            until Customer.Next() = 0;

        // 2. Clients affectés à ce commercial dans la table d'affectation (sans doublon)
        Assignment.SetRange("Salesperson Code", SalespersonCode);
        if Assignment.FindSet() then
            repeat
                if not CustomerNos.Contains(Assignment."Customer No.") then
                    CustomerNos.Add(Assignment."Customer No.");
            until Assignment.Next() = 0;

        foreach CustomerNo in CustomerNos do
            AddToFilter(PortfolioFilter, CustomerNo);
        exit(PortfolioFilter);
    end;

    procedure IsCustomerInPortfolio(SalespersonCode: Code[20]; CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        Assignment: Record "GNC Cust. Salesperson Assign.";
    begin
        // Commercial sans portefeuille : pas de restriction
        if GetPortfolioFilter(SalespersonCode) = '' then
            exit(true);

        if Customer.Get(CustomerNo) then
            if Customer."Salesperson Code" = SalespersonCode then
                exit(true);
        Assignment.SetRange("Customer No.", CustomerNo);
        Assignment.SetRange("Salesperson Code", SalespersonCode);
        exit(not Assignment.IsEmpty());
    end;

    procedure CheckCustomerInPortfolio(SalesHeader: Record "Sales Header"; SalespersonCode: Code[20])
    begin
        if (SalesHeader."Sell-to Customer No." = '') or (SalespersonCode = '') then
            exit;
        if not IsCustomerInPortfolio(SalespersonCode, SalesHeader."Sell-to Customer No.") then
            Error(CustomerNotInPortfolioErr, SalesHeader."Sell-to Customer No.", SalespersonCode);
    end;

    // Liste des clients ("Select from full list" des champs Customer No. / Customer Name du devis) :
    // en BC 28 elle ouvre directement la page standard "Customer Lookup".
    // Si une fiche devis avec un commercial identifié par PIN est ouverte (codeunit 90044),
    // on ne montre que les clients de son portefeuille. FilterGroup 2 : l'utilisateur ne peut pas retirer ce filtre.
    // Limite : la petite liste rapide sous le champ (5 lignes) n'est pas filtrable ; le contrôle à la saisie protège.
    [EventSubscriber(ObjectType::Page, Page::"Customer Lookup", 'OnOpenPageEvent', '', false, false)]
    local procedure FilterCustomersOnOpenCustomerLookup(var Rec: Record Customer)
    var
        GNCRequestContext: Codeunit "GNC Request Context";
        PortfolioFilter: Text;
    begin
        // Le contexte n'est rempli que si une fiche devis est ouverte (pageextension 90016)
        PortfolioFilter := GetPortfolioFilter(GNCRequestContext.GetSalesperson());
        if PortfolioFilter = '' then
            exit;
        Rec.FilterGroup(2);
        Rec.SetFilter("No.", PortfolioFilter);
        Rec.FilterGroup(0);
    end;

    // Saisie du client sur un devis déjà confirmé par PIN :
    // 1. le client doit être dans le portefeuille du commercial ;
    // 2. le standard vient de remplacer le Salesperson Code par celui du client :
    //    on remet le commercial identifié par son PIN (c'est lui qui a collecté la demande).
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Sell-to Customer No.', false, false)]
    local procedure KeepPINSalespersonOnAfterValidateSellToCustomer(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    begin
        if Rec."Document Type" <> Rec."Document Type"::Quote then
            exit;
        if (Rec."GNC PIN Salesperson Code" = '') or (Rec."Sell-to Customer No." = '') then
            exit;

        CheckCustomerInPortfolio(Rec, Rec."GNC PIN Salesperson Code");
        if Rec."Salesperson Code" <> Rec."GNC PIN Salesperson Code" then
            Rec.Validate("Salesperson Code", Rec."GNC PIN Salesperson Code");
    end;

    // ---------- Articles ----------

    // Article saisi sur une ligne de devis : il doit être affecté au couple client + commercial
    // (directement ou par sa catégorie), sauf si ce couple n'a aucune affectation.
    // SalespersonCode est passé à part : à la saisie du PIN, le nouveau commercial
    // n'est pas encore enregistré sur l'en-tête.
    procedure CheckItemAllowed(SalesHeader: Record "Sales Header"; SalespersonCode: Code[20]; SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        Assignment: Record "GNC Cust. Salesperson Assign.";
    begin
        if (SalesLine.Type <> SalesLine.Type::Item) or (SalesLine."No." = '') then
            exit;
        if (SalespersonCode = '') or (SalesHeader."Sell-to Customer No." = '') then
            exit;

        Assignment.SetRange("Customer No.", SalesHeader."Sell-to Customer No.");
        Assignment.SetRange("Salesperson Code", SalespersonCode);
        if Assignment.IsEmpty() then
            exit; // aucune affectation pour ce couple : pas de restriction

        // Article affecté directement ?
        Assignment.SetRange(Type, Assignment.Type::Item);
        Assignment.SetRange("No.", SalesLine."No.");
        if not Assignment.IsEmpty() then
            exit;

        // Catégorie de l'article affectée ?
        Item.Get(SalesLine."No.");
        if Item."Item Category Code" <> '' then begin
            Assignment.SetRange(Type, Assignment.Type::"Item Category");
            Assignment.SetRange("No.", Item."Item Category Code");
            if not Assignment.IsEmpty() then
                exit;
        end;

        Error(ItemNotAllowedErr, SalesLine."No.", Item."Item Category Code", SalespersonCode, SalesHeader."Sell-to Customer No.");
    end;

    // Liste des articles ("No." des lignes du devis) : en BC 28 elle ouvre directement la page
    // standard "Item Lookup". Si le devis ouvert a un commercial (PIN) et un client avec des
    // affectations, on ne montre que les articles affectés (directement ou par catégorie).
    [EventSubscriber(ObjectType::Page, Page::"Item Lookup", 'OnOpenPageEvent', '', false, false)]
    local procedure FilterItemsOnOpenItemLookup(var Rec: Record Item)
    var
        GNCRequestContext: Codeunit "GNC Request Context";
        Assignment: Record "GNC Cust. Salesperson Assign.";
        CategoryItem: Record Item;
        ItemFilter: Text;
        CategoryFilter: Text;
    begin
        if (GNCRequestContext.GetSalesperson() = '') or (GNCRequestContext.GetCustomer() = '') then
            exit;

        Assignment.SetRange("Customer No.", GNCRequestContext.GetCustomer());
        Assignment.SetRange("Salesperson Code", GNCRequestContext.GetSalesperson());
        if not Assignment.FindSet() then
            exit; // aucune affectation : pas de filtre

        // Sépare les articles affectés directement et les catégories affectées
        repeat
            case Assignment.Type of
                Assignment.Type::Item:
                    AddToFilter(ItemFilter, Assignment."No.");
                Assignment.Type::"Item Category":
                    AddToFilter(CategoryFilter, Assignment."No.");
            end;
        until Assignment.Next() = 0;

        Rec.FilterGroup(2);
        if ItemFilter = '' then
            // Seulement des catégories : filtre direct sur la catégorie
            Rec.SetFilter("Item Category Code", CategoryFilter)
        else begin
            // Articles (et éventuellement catégories) : on ajoute les articles des catégories à la liste
            if CategoryFilter <> '' then begin
                CategoryItem.SetFilter("Item Category Code", CategoryFilter);
                if CategoryItem.FindSet() then
                    repeat
                        AddToFilter(ItemFilter, CategoryItem."No.");
                    until CategoryItem.Next() = 0;
            end;
            Rec.SetFilter("No.", ItemFilter);
        end;
        Rec.FilterGroup(0);
    end;

    // Ajoute une valeur à un filtre "A"|"B" (entre apostrophes pour les caractères spéciaux)
    local procedure AddToFilter(var FilterText: Text; Value: Code[20])
    begin
        if FilterText <> '' then
            FilterText += '|';
        FilterText += '''' + Value + '''';
    end;

    // Contrôle de toutes les lignes déjà saisies (utilisé à la saisie du PIN)
    procedure CheckAllItemsAllowed(SalesHeader: Record "Sales Header"; SalespersonCode: Code[20])
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                CheckItemAllowed(SalesHeader, SalespersonCode, SalesLine);
            until SalesLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure CheckItemOnAfterValidateNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        if Rec."Document Type" <> Rec."Document Type"::Quote then
            exit;
        if not SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            exit;
        CheckItemAllowed(SalesHeader, SalesHeader."GNC PIN Salesperson Code", Rec);
    end;
}
