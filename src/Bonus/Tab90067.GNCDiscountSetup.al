// Lot 6 – Taux de remise GNC (FRD « Discount Management », REQ-DB-001 à 003 + catégorie).
// Une ligne = un taux pour : un client (vide = tous les clients) et un article, une catégorie
// ou tous les articles. Proposé automatiquement sur les lignes de demande / commande (codeunit 90069).
// S'il n'y a aucune règle GNC, la remise standard BC (Price Lists) est gardée.
table 90067 "GNC Discount Setup"
{
    Caption = 'Discount Setup';
    DataClassification = CustomerContent;
    LookupPageId = "GNC Discount Setup";
    DrillDownPageId = "GNC Discount Setup";

    fields
    {
        // Vide = tous les clients
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(2; Type; Enum "GNC Discount Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                // Changer de type rend le numéro saisi incohérent : on le vide
                if Type <> xRec.Type then
                    "No." := '';
            end;
        }
        // Article ou catégorie selon le Type ; vide pour "All Items"
        field(3; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if (Type = const(Item)) Item."No."
            else
            if (Type = const("Item Category")) "Item Category".Code;
        }
        // Vide = valable depuis toujours
        field(4; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        // Vide = sans fin
        field(5; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
        }
        field(6; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
        }
        // Champs calculés pour l'affichage
        field(10; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Customer No.", Type, "No.", "Starting Date")
        {
            Clustered = true;
        }
    }

    var
        NoRequiredErr: Label 'Enter the item or item category number.';
        NoNotAllowedErr: Label 'The number must be empty when the type is All Items.';
        CustomerRequiredErr: Label 'A discount for all items must be for a specific customer.';
        DatesErr: Label 'The ending date must be after the starting date.';

    trigger OnInsert()
    begin
        CheckRule();
    end;

    trigger OnModify()
    begin
        CheckRule();
    end;

    trigger OnRename()
    begin
        CheckRule();
    end;

    local procedure CheckRule()
    begin
        if Type = Type::"All Items" then begin
            if "No." <> '' then
                Error(NoNotAllowedErr);
            if "Customer No." = '' then
                Error(CustomerRequiredErr);
        end else
            if "No." = '' then
                Error(NoRequiredErr);
        if ("Starting Date" <> 0D) and ("Ending Date" <> 0D) and ("Ending Date" < "Starting Date") then
            Error(DatesErr);
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
