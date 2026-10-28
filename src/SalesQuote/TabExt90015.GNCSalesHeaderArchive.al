// Mêmes champs (mêmes numéros, mêmes types) sur l'archive des documents de vente (table 5107).
// C'est ici que l'historique des ventes ratées est conservé après la clôture du devis.
tableextension 90015 "GNC Sales Header Archive" extends "Sales Header Archive"
{
    fields
    {
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
        field(90003; "GNC Closed"; Boolean)
        {
            Caption = 'Closed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        // Gardé dans l'archive : un devis clôturé puis restauré reste confirmé par PIN
        field(90004; "GNC PIN Salesperson Code"; Code[20])
        {
            Caption = 'PIN Confirmed Salesperson';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
            Editable = false;
        }
        // Lot 7 – gardés dans l'archive (devis archivé Won / restauré)
        field(90005; "GNC Delivery Priority"; Enum "GNC Delivery Priority")
        {
            Caption = 'Delivery Priority';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(90006; "GNC Driver Code"; Code[20])
        {
            Caption = 'Driver Code';
            DataClassification = CustomerContent;
            TableRelation = "GNC Driver".Code;
            Editable = false;
        }
        field(90007; "GNC Priority Sort"; Integer)
        {
            Caption = 'Priority Sort';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
