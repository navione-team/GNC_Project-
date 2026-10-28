// Lot 7 – Chauffeurs (hyp. 10) : choisis par commande dans le plan de livraison (page 90077),
// recopiés sur l'expédition enregistrée.
table 90072 "GNC Driver"
{
    Caption = 'Driver';
    DataClassification = CustomerContent;
    LookupPageId = "GNC Drivers";
    DrillDownPageId = "GNC Drivers";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            ExtendedDatatype = PhoneNo;
        }
        // Véhicule : texte libre (immatriculation, type...)
        field(4; Vehicle; Text[50])
        {
            Caption = 'Vehicle';
        }
        // Chauffeur qui ne travaille plus : ne peut plus être choisi
        field(5; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        // Capacité du véhicule en cartons (unités commandées) : 0 = non contrôlée sur la carte de la tournée
        field(6; "Vehicle Capacity"; Decimal)
        {
            Caption = 'Vehicle Capacity (Units)';
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }
        // Véhicule frigorifique : obligatoire pour les commandes avec des articles "Cold Chain"
        field(7; Refrigerated; Boolean)
        {
            Caption = 'Refrigerated Vehicle';
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Name, "Phone No.", Vehicle)
        {
        }
    }
}
