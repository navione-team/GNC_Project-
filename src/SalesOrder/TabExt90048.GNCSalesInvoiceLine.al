// Mêmes champs que sur "Sales Line" (tableextension 90045), mêmes numéros :
// recopiés automatiquement à la validation de la facture (InitFromSalesLine → TransferFields).
tableextension 90048 "GNC Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(90005; "GNC Request No."; Code[20])
        {
            Caption = 'Request No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(90006; "GNC Salesperson Code"; Code[20])
        {
            Caption = 'Line Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
            Editable = false;
        }
        // Lot 4 : détail par demande, retrouvé par la commande d'origine (table 90058)
        field(90007; "GNC Grouped Requests"; Integer)
        {
            Caption = 'Grouped Requests';
            FieldClass = FlowField;
            CalcFormula = count("GNC Grouped Request Line" where("Order No." = field("Order No."), "Order Line No." = field("Order Line No.")));
            Editable = false;
        }
        // Lot 5 : ligne bonus (gratuite)
        field(90008; "GNC Bonus Line"; Boolean)
        {
            Caption = 'Bonus Line';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
