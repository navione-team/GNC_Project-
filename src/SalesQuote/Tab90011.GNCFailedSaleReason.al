// Liste des motifs de vente ratée (ex. PRICE = prix trop élevé, STOCK = rupture...).
// Paramétrée par GNC ; un motif est obligatoire pour clôturer un devis.
table 90011 "GNC Failed Sale Reason"
{
    Caption = 'Failed Sale Reason';
    DataClassification = CustomerContent;
    LookupPageId = "GNC Failed Sale Reasons";
    DrillDownPageId = "GNC Failed Sale Reasons";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
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
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }
}
