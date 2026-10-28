// Liste des clients : quelques colonnes GNC pour filtrer/trier par classification.
pageextension 90004 "GNC Customer List" extends "Customer List"
{
    layout
    {
        addafter(Name)
        {
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
            field("GNC Region Code"; Rec."GNC Region Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the region of the customer.';
            }
            field("GNC CR No."; Rec."GNC CR No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the commercial registration number of the customer.';
            }
        }
    }

    actions
    {
        addfirst(processing)
        {
            // Fiche client visuelle (page 90095)
            action(GNCCustomer360)
            {
                ApplicationArea = All;
                Caption = 'Customer 360';
                Image = CustomerList;
                ToolTip = 'See the selected customer at a glance: mandatory fields, target, requests won and failed, open orders, salespeople, discounts and bonus.';
                RunObject = page "GNC Customer 360";
                RunPageLink = "No." = field("No.");
            }
        }
        addfirst(Promoted)
        {
            actionref(GNCCustomer360_Promoted; GNCCustomer360)
            {
            }
        }
    }
}
