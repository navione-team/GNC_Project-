// Lot 5 – Bonus Setup (FRD « Discount & Bonus », REQ-DB-004/005) : quantité gratuite par client et article.
// À la création de la commande depuis une demande (Make Order ou regroupement), le codeunit 90062
// ajoute une ligne bonus (même article, quantité bonus, remise 100 %) et ajoute le % de remise
// additionnelle à la remise de la ligne commandée.
// Choix validés par Haifa (2026-10-27, à confirmer par le manager) : quantité fixe par ligne commandée,
// quantité minimum facultative, dates de validité facultatives, remise additionnelle = addition simple.
table 90060 "GNC Bonus Setup"
{
    Caption = 'Bonus Setup';
    DataClassification = CustomerContent;
    LookupPageId = "GNC Bonus Setup";
    DrillDownPageId = "GNC Bonus Setup";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            NotBlank = true;
            TableRelation = Customer."No.";
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item."No.";
        }
        // Vide = valable depuis toujours
        field(3; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                CheckDates();
            end;
        }
        // Vide = sans fin
        field(4; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                CheckDates();
            end;
        }
        // Quantité gratuite, dans l'unité de la ligne commandée
        field(5; "Bonus Quantity"; Decimal)
        {
            Caption = 'Bonus Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        // 0 = bonus quelle que soit la quantité commandée
        field(6; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Ordered Quantity';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        // FRD : « Additional discount must be added to the principal discount if exist »
        field(7; "Additional Discount %"; Decimal)
        {
            Caption = 'Additional Discount %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            MaxValue = 100;
        }
        // FRD : « MOH discount (linked to the bonus) » = remise imposée par le ministère de la Santé.
        // Souvenir de Haifa (2026-10-27, à confirmer) : taux fixe, seulement pour les clients Government
        // (champ "GNC Sector" de la fiche client) ; additionné aux autres remises (10 % + MOH + additionnelle).
        field(8; "MOH Discount %"; Decimal)
        {
            Caption = 'MOH Discount %';
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
        field(11; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Customer No.", "Item No.", "Starting Date")
        {
            Clustered = true;
        }
    }

    var
        DatesErr: Label 'The ending date must be after the starting date.';
        NothingToGrantErr: Label 'Enter a bonus quantity, an additional discount % or an MOH discount %.';

    trigger OnInsert()
    begin
        CheckRule();
    end;

    trigger OnModify()
    begin
        CheckRule();
    end;

    local procedure CheckDates()
    begin
        if ("Starting Date" <> 0D) and ("Ending Date" <> 0D) and ("Ending Date" < "Starting Date") then
            Error(DatesErr);
    end;

    // Une règle doit donner quelque chose : une quantité gratuite et/ou une remise
    local procedure CheckRule()
    begin
        if ("Bonus Quantity" = 0) and ("Additional Discount %" = 0) and ("MOH Discount %" = 0) then
            Error(NothingToGrantErr);
    end;
}
