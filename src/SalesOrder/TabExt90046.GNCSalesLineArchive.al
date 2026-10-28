// Mêmes champs que sur "Sales Line" (tableextension 90045), mêmes numéros :
// le standard les recopie dans l'archive (devis et commandes archivés) par TransferFields.
tableextension 90046 "GNC Sales Line Archive" extends "Sales Line Archive"
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
        field(90008; "GNC Bonus Line"; Boolean)
        {
            Caption = 'Bonus Line';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
