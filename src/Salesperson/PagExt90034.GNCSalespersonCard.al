// Fiche commercial (standard "Salesperson/Purchaser Card") : champs PIN, Type et Sub-Type,
// accès à ses objectifs annuels et à ses affectations clients/produits.
pageextension 90034 "GNC Salesperson Card" extends "Salesperson/Purchaser Card"
{
    layout
    {
        addafter(Name)
        {
            // PIN personnel, saisi par le commercial sur la Request Collection (masqué à l'écran)
            field("GNC PIN"; Rec."GNC PIN")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the personal PIN of the salesperson. The salesperson enters it on sales quotes (Request Collection) to identify themselves. Each PIN must be unique.';
            }
            // Type de commercial : Private / Government
            field("GNC Type"; Rec."GNC Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the salesperson works for the private sector or the government sector.';
            }
            // Sous-type : la liste ne propose que les sous-types du Type choisi (table GNC Salesperson Sub-Type)
            field("GNC Sub-Type Code"; Rec."GNC Sub-Type Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sub-type of the salesperson. Only the sub-types of the selected type are proposed (Private: Pharma, OTC, Medical Device; Government: Institution, Tender, Medical Device).';
            }
        }
    }

    actions
    {
        addlast("&Salesperson")
        {
            action(GNCAnnualTargets)
            {
                ApplicationArea = All;
                Caption = 'Annual Targets';
                Image = TargetSetup;
                ToolTip = 'View or edit the annual sales targets of the sales representative, with actual sales and achievement %.';
                RunObject = page "GNC Salesperson Targets";
                RunPageLink = "Salesperson Code" = field(Code);
            }
            action(GNCCustomerAssignments)
            {
                ApplicationArea = All;
                Caption = 'Customer Assignments';
                Image = Customer;
                ToolTip = 'View the customers, items and item categories assigned to the sales representative.';
                RunObject = page "GNC Cust. Salesperson Assign.";
                RunPageLink = "Salesperson Code" = field(Code);
            }
        }
        addlast(Category_Category5)
        {
            actionref(GNCAnnualTargets_Promoted; GNCAnnualTargets)
            {
            }
            actionref(GNCCustomerAssignments_Promoted; GNCCustomerAssignments)
            {
            }
        }
    }
}
