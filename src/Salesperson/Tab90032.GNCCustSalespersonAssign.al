// Affectation Client – Commercial – Produit (FRD exigence 1.7 "New menu", REQ-SR-003).
// Pour un client, indique quel commercial est responsable de quel article ou catégorie.
// Elle servira à l'étape 3 pour proposer automatiquement le commercial sur la demande client.
table 90032 "GNC Cust. Salesperson Assign."
{
    Caption = 'Customer Salesperson Assignment';
    DataClassification = CustomerContent;
    LookupPageId = "GNC Cust. Salesperson Assign.";
    DrillDownPageId = "GNC Cust. Salesperson Assign.";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            NotBlank = true;
            TableRelation = Customer."No.";
        }
        field(2; Type; Enum "GNC Assignment Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                // Changer de type rend le numéro saisi incohérent : on le vide
                if Type <> xRec.Type then
                    "No." := '';
            end;
        }
        // Article ou catégorie selon le Type (relation conditionnelle)
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            TableRelation = if (Type = const(Item)) Item."No."
            else
            if (Type = const("Item Category")) "Item Category".Code;
        }
        field(4; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser".Code;
        }
        // Champs calculés (FlowFields) pour l'affichage, non stockés
        field(10; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(11; "Salesperson Name"; Text[50])
        {
            Caption = 'Salesperson Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Salesperson/Purchaser".Name where(Code = field("Salesperson Code")));
            Editable = false;
        }
    }

    keys
    {
        // Un seul commercial par client et par article (ou catégorie)
        key(PK; "Customer No.", Type, "No.")
        {
            Clustered = true;
        }
        key(Salesperson; "Salesperson Code")
        {
        }
    }

    trigger OnInsert()
    begin
        TestField("Salesperson Code");
    end;

    trigger OnModify()
    begin
        TestField("Salesperson Code");
    end;

    // Description de l'article ou de la catégorie, pour l'affichage dans la page
    procedure GetProductDescription(): Text[100]
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
    begin
        case Type of
            Type::Item:
                if Item.Get("No.") then
                    exit(Item.Description);
            Type::"Item Category":
                if ItemCategory.Get("No.") then
                    exit(ItemCategory.Description);
        end;
        exit('');
    end;
}
