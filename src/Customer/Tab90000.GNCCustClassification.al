// Table de paramétrage des classifications client (Type, Area, Line, BU, Division, Region).
// Clé = Type + Code : le même code peut exister dans deux listes différentes.
table 90000 "GNC Cust. Classification"
{
    Caption = 'Customer Classification';
    DataClassification = CustomerContent;
    LookupPageId = "GNC Cust. Classifications";
    DrillDownPageId = "GNC Cust. Classifications";

    fields
    {
        field(1; Type; Enum "GNC Classification Type")
        {
            Caption = 'Type';
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(PK; Type, "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Colonnes affichées dans la liste déroulante des champs de la fiche client
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }
}
