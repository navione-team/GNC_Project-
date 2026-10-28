// Table technique des "cues" (tuiles chiffrées) de la page d'accueil GNC.
// Elle ne contient qu'un seul enregistrement vide : les chiffres sont des FlowFields
// (comptages calculés à l'affichage), rien n'est stocké.
table 90006 "GNC Sales Cue"
{
    Caption = 'GNC Sales Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            AllowInCustomizations = Never;
        }
        // --- Clients incomplets : champs obligatoires du FRD (§ 9.1) non remplis ---
        field(10; "Cust. Missing CR No."; Integer)
        {
            Caption = 'Missing CR No.';
            FieldClass = FlowField;
            CalcFormula = count(Customer where("GNC CR No." = const('')));
            Editable = false;
            ToolTip = 'Specifies the number of customers without a CR number. These customers cannot be used on sales documents.';
        }
        field(11; "Cust. Missing GLN"; Integer)
        {
            // Tuile retirée : GLN n'est plus obligatoire (décision du 2026-10-17).
            // Le champ est marqué obsolète au lieu d'être supprimé, car la table est déjà publiée.
            Caption = 'Missing GLN';
            FieldClass = FlowField;
            CalcFormula = count(Customer where(GLN = const('')));
            Editable = false;
            ToolTip = 'Specifies the number of customers without a GLN.';
            ObsoleteState = Pending;
            ObsoleteReason = 'GLN is optional for GNC. The tile is no longer displayed.';
        }
        field(12; "Cust. Missing Phone No."; Integer)
        {
            Caption = 'Missing Phone No.';
            FieldClass = FlowField;
            CalcFormula = count(Customer where("Phone No." = const('')));
            Editable = false;
            ToolTip = 'Specifies the number of customers without a phone number. These customers cannot be used on sales documents.';
        }
        // --- Documents de vente en cours (non validés) ---
        field(20; "Sales Quotes - Open"; Integer)
        {
            // Chez GNC, les devis s'appellent "Request Collection"
            Caption = 'Requests - Open';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const(Quote), Status = const(Open)));
            Editable = false;
            ToolTip = 'Specifies the number of open customer requests (sales quotes) not yet approved.';
        }
        // Lot 4 : demandes approuvées en attente de regroupement (écran "Requests to Group")
        field(25; "Requests to Group"; Integer)
        {
            Caption = 'Requests to Group';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const(Quote), Status = const(Released), "GNC Closed" = const(false)));
            Editable = false;
            ToolTip = 'Specifies the number of approved customer requests waiting to be grouped into sales orders.';
        }
        field(21; "Sales Orders - Open"; Integer)
        {
            Caption = 'Sales Orders - Open';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const(Order), Status = const(Open)));
            Editable = false;
            ToolTip = 'Specifies the number of sales orders that are not yet released.';
        }
        field(22; "Sales Orders - Released"; Integer)
        {
            Caption = 'Sales Orders - Released';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const(Order), Status = const(Released)));
            Editable = false;
            ToolTip = 'Specifies the number of released sales orders that are not yet fully posted.';
        }
        field(23; "Sales Invoices - Unposted"; Integer)
        {
            Caption = 'Sales Invoices - Unposted';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const(Invoice)));
            Editable = false;
            ToolTip = 'Specifies the number of sales invoices that are not yet posted.';
        }
        field(24; "Sales Cr. Memos - Unposted"; Integer)
        {
            Caption = 'Sales Credit Memos - Unposted';
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const("Credit Memo")));
            Editable = false;
            ToolTip = 'Specifies the number of sales credit memos that are not yet posted.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
