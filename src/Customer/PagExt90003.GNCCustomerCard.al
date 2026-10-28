// Fiche client : onglet GNC avec les nouveaux champs, champs obligatoires signalés
// par un astérisque rouge, et action vers les objectifs annuels.
pageextension 90003 "GNC Customer Card" extends "Customer Card"
{
    layout
    {
        // ShowMandatory affiche seulement l'astérisque ; le contrôle réel est dans le codeunit 90005
        modify(Name)
        {
            ShowMandatory = true;
        }
        modify("Phone No.")
        {
            ShowMandatory = true;
        }
        addafter(General)
        {
            group(GNCClassification)
            {
                Caption = 'GNC Classification';

                field("GNC Customer Type"; Rec."GNC Customer Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the customer.';
                }
                field("GNC Sector"; Rec."GNC Sector")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the customer belongs to the private or the government sector.';
                }
                field("GNC Area Code"; Rec."GNC Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the area of the customer.';
                }
                field("GNC Line Code"; Rec."GNC Line Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line of the customer.';
                }
                field("GNC Business Unit Code"; Rec."GNC Business Unit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the business unit of the customer.';
                }
                field("GNC Division Code"; Rec."GNC Division Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the division of the customer.';
                }
                field("GNC Region Code"; Rec."GNC Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the region of the customer.';
                }
                field("GNC CR No."; Rec."GNC CR No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the commercial registration number of the customer. It is required before the customer can be used on a sales document.';
                }
                field("GNC Contact Phone No."; Rec."GNC Contact Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the phone number of the contact person.';
                }
                field("GNC Contact E-Mail"; Rec."GNC Contact E-Mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the e-mail address of the contact person.';
                }
                field("GNC Observation"; Rec."GNC Observation")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies observations about the customer.';
                }
                // Lot 7 – carte de la tournée de livraison
                field("GNC Latitude"; Rec."GNC Latitude")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GPS latitude of the delivery address (for example 24.711667 for Riyadh). Used to show the customer on the delivery round map.';
                }
                field("GNC Longitude"; Rec."GNC Longitude")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the GPS longitude of the delivery address (for example 46.674167 for Riyadh). Used to show the customer on the delivery round map.';
                }
            }
        }
    }

    actions
    {
        addlast("&Customer")
        {
            // Fiche client visuelle (page 90095)
            action(GNCCustomer360)
            {
                ApplicationArea = All;
                Caption = 'Customer 360';
                Image = CustomerList;
                ToolTip = 'See the customer at a glance: mandatory fields, target, requests won and failed, open orders, salespeople, discounts and bonus.';
                RunObject = page "GNC Customer 360";
                RunPageLink = "No." = field("No.");
            }
            action(GNCAnnualTargets)
            {
                ApplicationArea = All;
                Caption = 'Annual Targets';
                Image = TargetSetup;
                ToolTip = 'View or edit the annual sales targets of the customer, with actual sales and achievement %.';
                RunObject = page "GNC Customer Targets";
                RunPageLink = "Customer No." = field("No.");
            }
            // Historique des ventes ratées (FRD § 9.1) : devis clôturés en "Failed", lus dans les archives
            action(GNCFailedSales)
            {
                ApplicationArea = All;
                Caption = 'Failed Sales';
                Image = History;
                ToolTip = 'View the quotes of the customer that were closed as failed sales, with the reason.';
                RunObject = page "Sales Quote Archives";
                RunPageView = where("GNC Quote Status" = const(Failed));
                RunPageLink = "Sell-to Customer No." = field("No.");
            }
            // Commerciaux responsables de ce client, par article ou catégorie (exigence 1.7)
            action(GNCSalespersonAssignments)
            {
                ApplicationArea = All;
                Caption = 'Salesperson Assignments';
                Image = SalesPerson;
                ToolTip = 'View or edit which sales representative is responsible for which item or item category for this customer.';
                RunObject = page "GNC Cust. Salesperson Assign.";
                RunPageLink = "Customer No." = field("No.");
            }
        }
        addlast(Category_Category9)
        {
            actionref(GNCCustomer360_Promoted; GNCCustomer360)
            {
            }
            actionref(GNCAnnualTargets_Promoted; GNCAnnualTargets)
            {
            }
            actionref(GNCFailedSales_Promoted; GNCFailedSales)
            {
            }
            actionref(GNCSalespersonAssignments_Promoted; GNCSalespersonAssignments)
            {
            }
        }
    }
}
