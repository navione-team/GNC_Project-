// Paramètres ventes GNC (un seul enregistrement, comme "Sales & Receivables Setup").
// Principe : chaque choix métier incertain devient un paramètre ici, pour que le chef de projet
// puisse le corriger par paramétrage, sans redéveloppement. Les autres lots y ajouteront leurs champs.
table 90037 "GNC Sales Setup"
{
    Caption = 'GNC Sales Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            AllowInCustomizations = Never;
        }
        // Oui : au Make Order, le devis est toujours archivé avec le statut Won,
        // quel que soit le paramètre standard "Archive Quotes" (Sales & Receivables Setup).
        field(10; "Archive Quote on Make Order"; Boolean)
        {
            Caption = 'Archive Quote on Make Order';
            InitValue = true;
        }
        // OBSOLÈTE depuis 1.0.0.12 : contrôle "doublon" client + commercial retiré car il contredit
        // le FRD (plusieurs demandes du même client sont normales et seront regroupées).
        // Déjà publié : ne peut pas être supprimé, il n'est plus utilisé ni affiché.
        field(11; "Duplicate Request Check"; Enum "GNC Duplicate Check")
        {
            Caption = 'Duplicate Request Check (old)';
            InitValue = Warn;
            ObsoleteState = Pending;
            ObsoleteReason = 'Check removed: several requests for the same customer are normal and are grouped into one order (FRD 1.4).';
        }
        // Lot 4 : quelles demandes approuvées sont regroupées dans une même commande (codeunit 90056)
        field(12; "Request Grouping"; Enum "GNC Request Grouping")
        {
            Caption = 'Request Grouping';
        }
        // Lot 4 : même article (+ même commercial, unité, magasin, prix, remise) dans plusieurs
        // demandes regroupées → une seule ligne cumulée ; le détail par demande reste dans la table 90058.
        // Non = une ligne par ligne de demande. Champ "Merge" à l'envers ("Do Not") pour que la
        // valeur par défaut (Non = cumul) s'applique aussi à l'enregistrement déjà existant.
        field(13; "Do Not Merge Identical Lines"; Boolean)
        {
            Caption = 'Do Not Merge Identical Lines';
        }
        // Lot 6 : quelle remise GNC (GNC Discount Setup) gagne quand plusieurs règles s'appliquent (FRD règle 17)
        field(14; "Discount Priority"; Enum "GNC Discount Priority")
        {
            Caption = 'Discount Priority';
        }
        // Lot 6 : Oui = une remise saisie à la main au-dessus de la remise proposée est limitée par
        // le "Max Line Discount %" de l'utilisateur (User Setup). Non par défaut : rien ne change tant
        // que les maximums des utilisateurs ne sont pas renseignés.
        field(15; "Control Manual Discount"; Boolean)
        {
            Caption = 'Control Manual Discount';
        }
        // Lot 7 : Non (défaut) = chauffeur obligatoire pour expédier une commande (codeunit 90078).
        // Champ à l'envers ("Optional") pour que la valeur par défaut s'applique à l'enregistrement existant.
        field(16; "Driver Optional on Shipment"; Boolean)
        {
            Caption = 'Driver Optional on Shipment';
        }
        // Lot 7 – carte de la tournée (page 90083) : point de départ et de retour des chauffeurs.
        // 0 = position par défaut (2nd Industrial City, Riyad) dans le codeunit 90084.
        field(17; "Warehouse Latitude"; Decimal)
        {
            Caption = 'Warehouse Latitude';
            DecimalPlaces = 6 : 6;
            MinValue = -90;
            MaxValue = 90;
        }
        field(18; "Warehouse Longitude"; Decimal)
        {
            Caption = 'Warehouse Longitude';
            DecimalPlaces = 6 : 6;
            MinValue = -180;
            MaxValue = 180;
        }
        // Heure de départ des tournées (vide = 06:30)
        field(19; "Round Start Time"; Time)
        {
            Caption = 'Round Start Time';
        }
        // Vitesse moyenne en ville pour estimer les heures d'arrivée (0 = 28 km/h)
        field(20; "Average Speed (km/h)"; Decimal)
        {
            Caption = 'Average Speed (km/h)';
            DecimalPlaces = 0 : 1;
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    // Lit les paramètres. S'ils n'ont jamais été enregistrés, on garde les valeurs
    // par défaut (InitValue) sans créer l'enregistrement.
    procedure GetSetup()
    begin
        if not Get() then
            Init();
    end;
}
