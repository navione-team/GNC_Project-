// Mêmes champs que sur "Sales Line" (tableextension 90045), mêmes numéros :
// recopiés automatiquement à la validation de l'avoir (InitFromSalesLine → TransferFields).
// Un avoir créé par "Copy Document" depuis une facture reprend aussi ces valeurs.
tableextension 90049 "GNC Sales Cr.Memo Line" extends "Sales Cr.Memo Line"
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
        // Lot 5 : ligne bonus (gratuite)
        field(90008; "GNC Bonus Line"; Boolean)
        {
            Caption = 'Bonus Line';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
