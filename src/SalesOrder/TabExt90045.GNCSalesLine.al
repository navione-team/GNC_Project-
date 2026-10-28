// Traçabilité par ligne (FRD 1.5, REQ-SR-006, REQ-SO-007) sur la table standard 37 "Sales Line".
// Les MÊMES numéros de champ existent sur les lignes archivées (90046), expédiées (90047),
// facturées (90048) et d'avoir (90049) : le standard les recopie par TransferFields.
// Remplis par le codeunit 90054 (Make Order) ; jamais saisis à la main pour une ligne venue d'une demande.
tableextension 90045 "GNC Sales Line" extends "Sales Line"
{
    fields
    {
        // N° de la Request Collection (devis) d'où vient la ligne. Vide = ligne ajoutée à la main.
        field(90005; "GNC Request No."; Code[20])
        {
            Caption = 'Request No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        // Commercial qui a collecté la demande (confirmé par son PIN).
        // Ligne ajoutée à la main : commercial de l'en-tête par défaut (codeunit 90054), modifiable.
        field(90006; "GNC Salesperson Code"; Code[20])
        {
            Caption = 'Line Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;

            trigger OnValidate()
            begin
                // Une ligne venue d'une demande garde le commercial qui l'a collectée
                if "GNC Request No." <> '' then
                    Error(SalespersonFromRequestErr, "GNC Request No.");
            end;
        }
        // Lot 4 : nombre de demandes à l'origine de la ligne de commande (2 et plus = ligne cumulée).
        // Calculé (FlowField), cliquer dessus ouvre le détail (table 90058).
        field(90007; "GNC Grouped Requests"; Integer)
        {
            Caption = 'Grouped Requests';
            FieldClass = FlowField;
            CalcFormula = count("GNC Grouped Request Line" where("Order No." = field("Document No."), "Order Line No." = field("Line No.")));
            Editable = false;
        }
        // Lot 5 : ligne gratuite ajoutée automatiquement (règle Bonus Setup, codeunit 90062).
        // Rattachée à sa ligne commandée par le champ standard "Attached to Line No.".
        field(90008; "GNC Bonus Line"; Boolean)
        {
            Caption = 'Bonus Line';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    var
        SalespersonFromRequestErr: Label 'The salesperson of this line comes from request %1 and cannot be changed.', Comment = '%1 = request (quote) number';
}
