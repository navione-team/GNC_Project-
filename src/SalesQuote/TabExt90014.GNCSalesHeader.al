// Champs GNC sur l'en-tête de vente (table standard 36 "Sales Header").
// Les MÊMES numéros de champ existent sur "Sales Header Archive" (tableextension 90015) :
// le standard copie les valeurs dans l'archive par TransferFields (numéro par numéro).
tableextension 90014 "GNC Sales Header" extends "Sales Header"
{
    fields
    {
        // Rempli uniquement par le code (Clôturer / transformation en commande), pas à la main
        field(90000; "GNC Quote Status"; Enum "GNC Quote Status")
        {
            Caption = 'Quote Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(90001; "GNC Failed Reason Code"; Code[10])
        {
            Caption = 'Failed Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "GNC Failed Sale Reason";
            Editable = false;
        }
        field(90002; "GNC Failed Comment"; Text[250])
        {
            Caption = 'Failed Comment';
            DataClassification = CustomerContent;
            Editable = false;
        }
        // Booléen demandé par le chef de projet : Oui = devis clôturé (vente ratée)
        field(90003; "GNC Closed"; Boolean)
        {
            Caption = 'Closed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        // Commercial identifié par son PIN sur le devis (codeunit 90036).
        // Sert à vérifier que le Salesperson Code n'a pas changé depuis la saisie du PIN.
        field(90004; "GNC PIN Salesperson Code"; Code[20])
        {
            Caption = 'PIN Confirmed Salesperson';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
            Editable = false;
        }
        // Lot 7 – Priorité de livraison : choisie par le commercial sur la demande (devis),
        // recopiée par Make Order (copie standard de l'en-tête) ; au regroupement, la plus urgente gagne.
        // Recopiée aussi sur l'expédition enregistrée (mêmes numéros de champ, tableextension 90074).
        field(90005; "GNC Delivery Priority"; Enum "GNC Delivery Priority")
        {
            Caption = 'Delivery Priority';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GNCDeliveryMgt: Codeunit "GNC Delivery Mgt.";
            begin
                "GNC Priority Sort" := GNCDeliveryMgt.GetPrioritySort("GNC Delivery Priority");
            end;
        }
        // Lot 7 – Chauffeur, choisi dans le plan de livraison (page 90077) ou sur la commande
        field(90006; "GNC Driver Code"; Code[20])
        {
            Caption = 'Driver Code';
            DataClassification = CustomerContent;
            TableRelation = "GNC Driver".Code where(Blocked = const(false));
        }
        // Lot 7 – Ordre de tri du plan de livraison : 1 = Very Urgent, 2 = Urgent, 3 = Normal
        // (permet de trier « plus urgent d'abord »). Rempli par le code.
        field(90007; "GNC Priority Sort"; Integer)
        {
            Caption = 'Priority Sort';
            DataClassification = CustomerContent;
            Editable = false;
            InitValue = 3;
        }
        field(90008; "GNC Driver Name"; Text[100])
        {
            Caption = 'Driver Name';
            FieldClass = FlowField;
            CalcFormula = lookup("GNC Driver".Name where("Code" = field("GNC Driver Code")));
            Editable = false;
        }
        // Lot 7 – N° d'arrêt dans la tournée du chauffeur (enregistré depuis la carte, page 90083)
        field(90009; "GNC Stop No."; Integer)
        {
            Caption = 'Stop No.';
            DataClassification = CustomerContent;
            Editable = false;
            BlankZero = true;
        }
    }

    keys
    {
        // Lot 7 – tri du plan de livraison (une clé d'extension ne peut contenir que des champs GNC :
        // à priorité égale, l'ordre est celui du n° de commande, la plus ancienne d'abord)
        key(GNCDeliveryPlan; "GNC Priority Sort")
        {
        }
    }
}
