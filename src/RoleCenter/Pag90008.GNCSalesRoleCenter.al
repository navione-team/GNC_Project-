// Page d'accueil (Role Center) GNC : seulement les menus et tuiles utiles aux ventes GNC.
// Elle est rattachée au profil "GNC SALES" (fichier Profile.GNCSales.al) ;
// l'utilisateur la choisit dans Mes paramètres > Rôle.
page 90008 "GNC Sales Role Center"
{
    Caption = 'GNC Sales';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            // Bandeau d'accueil GNC (salutation, urgences, demandes, ventes du mois)
            part(Headline; "GNC Sales Headline")
            {
                ApplicationArea = All;
            }
            // Tuiles en couleur, montants et « Go to »
            part(Activities; "GNC Sales Activities")
            {
                ApplicationArea = All;
            }
            // Deux petites listes
            part(UrgentDeliveries; "GNC Urgent Deliveries Part")
            {
                ApplicationArea = All;
            }
            part(WaitingRequests; "GNC Waiting Requests Part")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Barre de navigation sous le nom de la société (liens directs)
        area(Embedding)
        {
            // Vue d'ensemble visuelle, pleine page (page 90094)
            action(SalesOverview)
            {
                ApplicationArea = All;
                Caption = 'Sales Overview';
                RunObject = page "GNC Sales Overview";
                ToolTip = 'See today''s figures, the salesperson targets, the monthly sales and what needs attention on one screen.';
            }
            action(Customers)
            {
                ApplicationArea = All;
                Caption = 'Customers';
                Image = Customer;
                RunObject = page "Customer List";
                ToolTip = 'View or edit the customers.';
            }
            // Les devis sont appelés "Request Collection" chez GNC (demandes clients collectées par les commerciaux)
            action(SalesQuotes)
            {
                ApplicationArea = All;
                Caption = 'Request Collection';
                RunObject = page "Sales Quotes";
                ToolTip = 'View the customer requests collected by the sales representatives (sales quotes).';
            }
            // Lot 4 : demandes approuvées à regrouper en commandes
            action(RequestsToGroup)
            {
                ApplicationArea = All;
                Caption = 'Requests to Group';
                // Écran visuel (design validé) ; la liste classique s'ouvre avec son bouton "List view"
                RunObject = page "GNC Requests to Group Board";
                ToolTip = 'Group the approved customer requests into one sales order per customer.';
            }
            action(SalesOrders)
            {
                ApplicationArea = All;
                Caption = 'Sales Orders';
                Image = Order;
                RunObject = page "Sales Order List";
                ToolTip = 'View the sales orders.';
            }
            // Lot 7 : plan de livraison / interface magasin
            action(DeliveryPlan)
            {
                ApplicationArea = All;
                Caption = 'Delivery Plan';
                // Écran visuel (design validé) ; la liste classique s'ouvre avec son bouton "List view"
                RunObject = page "GNC Delivery Plan Board";
                ToolTip = 'View the released sales orders to deliver, the most urgent first, assign the drivers and post the shipments.';
            }
            action(DeliveryRound)
            {
                ApplicationArea = All;
                Caption = 'Delivery Round';
                RunObject = page "GNC Delivery Round";
                ToolTip = 'Show the round of a driver on a map with the optimised stop sequence.';
            }
            action(Drivers)
            {
                ApplicationArea = All;
                Caption = 'Drivers';
                RunObject = page "GNC Drivers";
                ToolTip = 'Set up the drivers.';
            }
            action(SalesInvoices)
            {
                ApplicationArea = All;
                Caption = 'Sales Invoices';
                RunObject = page "Sales Invoice List";
                ToolTip = 'View the sales invoices that are not yet posted.';
            }
            action(SalesCreditMemos)
            {
                ApplicationArea = All;
                Caption = 'Sales Credit Memos';
                RunObject = page "Sales Credit Memos";
                ToolTip = 'View the sales credit memos that are not yet posted.';
            }
            action(Items)
            {
                ApplicationArea = All;
                Caption = 'Items';
                Image = Item;
                RunObject = page "Item List";
                ToolTip = 'View or edit the items.';
            }
            action(CustomerTargets)
            {
                ApplicationArea = All;
                Caption = 'Customer Targets';
                RunObject = page "GNC Customer Targets";
                ToolTip = 'View the annual sales targets of the customers with actual sales and achievement %.';
            }
            // Étape 2 – Commerciaux
            action(Salespersons)
            {
                ApplicationArea = All;
                Caption = 'Salespeople';
                Image = SalesPerson;
                RunObject = page "Salespersons/Purchasers";
                ToolTip = 'View or edit the sales representatives.';
            }
            action(SalespersonTargets)
            {
                ApplicationArea = All;
                Caption = 'Salesperson Targets';
                RunObject = page "GNC Salesperson Targets";
                ToolTip = 'View the annual sales targets of the sales representatives with actual sales and achievement %.';
            }
            action(SalespersonAssignments)
            {
                ApplicationArea = All;
                Caption = 'Salesperson Assignments';
                RunObject = page "GNC Cust. Salesperson Assign.";
                ToolTip = 'View or edit which sales representative is responsible for which item or item category for each customer.';
            }
            // Lot 5 : quantités gratuites par client et article
            action(BonusSetup)
            {
                ApplicationArea = All;
                Caption = 'Bonus Setup';
                RunObject = page "GNC Bonus Setup";
                ToolTip = 'Set up the free bonus quantity and the additional discount by customer and item.';
            }
            // Simulateur des remises, bonus et MOH (page 90096)
            action(PriceSimulator)
            {
                ApplicationArea = All;
                Caption = 'Price Simulator';
                RunObject = page "GNC Price Simulator";
                ToolTip = 'Check which discount, bonus and MOH discount apply for a customer, an item and a quantity.';
            }
            // Lot 6 : taux de remise par client / article / catégorie
            action(DiscountSetup)
            {
                ApplicationArea = All;
                Caption = 'Discount Setup';
                RunObject = page "GNC Discount Setup";
                ToolTip = 'Set up the line discount % by customer, item, item category or customer and item.';
            }
        }
        // Menus déroulants en haut de la page
        area(Sections)
        {
            group(PostedDocuments)
            {
                Caption = 'Posted Documents';

                action(PostedSalesShipments)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Shipments';
                    RunObject = page "Posted Sales Shipments";
                    ToolTip = 'View the posted sales shipments.';
                }
                action(PostedSalesInvoices)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Invoices';
                    RunObject = page "Posted Sales Invoices";
                    ToolTip = 'View the posted sales invoices.';
                }
                action(PostedSalesCreditMemos)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Sales Credit Memos';
                    RunObject = page "Posted Sales Credit Memos";
                    ToolTip = 'View the posted sales credit memos.';
                }
                // Devis clôturés (Failed) ou transformés en commande (Won)
                action(SalesQuoteArchives)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Quote Archives';
                    RunObject = page "Sales Quote Archives";
                    ToolTip = 'View the archived sales quotes, including quotes closed as failed sales.';
                }
            }
            group(GNCSetup)
            {
                Caption = 'Setup';

                action(CustomerClassifications)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Classifications';
                    RunObject = page "GNC Cust. Classifications";
                    ToolTip = 'Set up the customer types, areas, lines, business units, divisions and regions.';
                }
                action(FailedSaleReasons)
                {
                    ApplicationArea = All;
                    Caption = 'Failed Sale Reasons';
                    RunObject = page "GNC Failed Sale Reasons";
                    ToolTip = 'Set up the reasons used when a quote is closed as a failed sale.';
                }
                action(SalespersonSubTypes)
                {
                    ApplicationArea = All;
                    Caption = 'Salesperson Sub-Types';
                    RunObject = page "GNC Salesperson Sub-Types";
                    ToolTip = 'Set up the salesperson sub-types for each type (Private: Pharma, OTC, Medical Device; Government: Institution, Tender, Medical Device).';
                }
                // Paramètres ventes GNC (choix modifiables sans redéveloppement)
                action(GNCSalesSetup)
                {
                    ApplicationArea = All;
                    Caption = 'GNC Sales Setup';
                    RunObject = page "GNC Sales Setup";
                    ToolTip = 'Set up the GNC sales parameters.';
                }
            }
        }
        // Bouton "+ Nouveau"
        area(Creation)
        {
            action(NewCustomer)
            {
                ApplicationArea = All;
                Caption = 'Customer';
                Image = Customer;
                RunObject = page "Customer Card";
                RunPageMode = Create;
                ToolTip = 'Create a new customer.';
            }
            action(NewSalesQuote)
            {
                ApplicationArea = All;
                Caption = 'Request Collection';
                Image = Document;
                RunObject = page "Sales Quote";
                RunPageMode = Create;
                ToolTip = 'Create a new customer request (sales quote).';
            }
            action(NewSalesOrder)
            {
                ApplicationArea = All;
                Caption = 'Sales Order';
                Image = Document;
                RunObject = page "Sales Order";
                RunPageMode = Create;
                ToolTip = 'Create a new sales order.';
            }
        }
    }
}
