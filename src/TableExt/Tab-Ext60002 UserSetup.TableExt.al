tableextension 60002 UserSetup extends "User Setup" //91
{
    fields
    {
        field(50017; "Approbateur 1"; Code[50])
        {
            Caption = 'Administrator';
            DataClassification = ToBeClassified;
            Description = 'Mehdi.Haddad DELTASOFT 12-03-2019';
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
            end;
            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
            end;
        }
        field(50018; "Accounting Approbator"; Boolean)
        {
            Caption = 'Accounting Administrator';
            DataClassification = ToBeClassified;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
            end;
            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
            end;
        }
        field(50019; "Approbateur CMDA"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Mehdi.Haddad DELTASOFT 18-03-2019';
        }
        field(50020; "Création Article"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Mehdi.Haddad DELTASOFT 18-03-2019';
        }
        field(50021; "Création Fournisseur"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Mehdi.Haddad DELTASOFT 24-05-2019';
        }
        field(50022; "Approbateur Remb. Anticipé"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA HJ 01-07-2020';
        }
        field(50023; "Droit RH"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Delta Achour 27/07/2018 RH';
        }
        field(50024; "Assiduité"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Delta Achour 27/07/2018 RH';
        }
        field(50025; Formation; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Delta Achour 27/07/2018 RH';
        }
        field(50026; "Médicaux"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Delta Achour 27/07/2018 RH';
        }
        field(50027; "Tranche Double"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Delta Achour 22/12/2018 ULC';
        }
        field(50028; "Delete Prêt"; Boolean)
        {
            Caption = 'Supression Prêt';
            DataClassification = ToBeClassified;
            Description = 'Delta Achour 22/12/2018 ULC';
        }
        field(50029; "Annuler Récéption Achat"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Mehdi.Haddad Deltasoft 16/04/2019';
        }
        field(50030; "Annuler Commande Vente"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Mehdi.Haddad Deltasoft 16/04/2019';
        }
        field(50031; "Livrer Seulement"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Mehdi.Haddad DELTASOFT 24-05-2019';
        }
        field(50032; "Afficher Tout CMDA"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Mehdi.Haddad DELTASOFT 24-05-2019';
        }
        field(50033; "Afficher Tout Fournisseur"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Mehdi.Haddad DELTASOFT 24-05-2019';
        }
        field(50034; "Approbateur Niveau 2"; Code[50])
        {
            Caption = 'Approbateur 2';
            DataClassification = ToBeClassified;
            Description = 'HJ DELTA 19-06-2019';
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
            end;
            trigger OnValidate()
            var
                UserMgt: Codeunit "User Management";
            begin
            end;
        }
        field(50035; "Droit Refus DA"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'HJ DELTA 19-06-2019';
        }
        field(50036; "Solder/Annuler Prêt"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'Delta Achour 27/06/2019';
        }
        field(50038; "Service Conçerné"; Option)
        {
            DataClassification = ToBeClassified;
            Description = 'HJ DELTA 16-09-2019';
            OptionMembers = " ", Technique, Informatique, RH, Transport, DG, "Transport Sfax", Investissement, DAF, "Intérimaires", "Last Mile";
        }
        field(50301; "Can Create Tickets"; Boolean)
        {
            Caption = 'Can Create Tickets';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(50302; "Can Assign Tickets"; Boolean)
        {
            Caption = 'Can Assign Tickets';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(50303; "Can Close Tickets"; Boolean)
        {
            Caption = 'Can Close Tickets';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(50304; "Can Reopen Tickets"; Boolean)
        {
            Caption = 'Can Reopen Tickets';
            InitValue = false;
            DataClassification = CustomerContent;
        }
        field(50305; "Max Concurrent Tickets"; Integer)
        {
            Caption = 'Max Concurrent Tickets';
            DataClassification = CustomerContent;
        }
        field(50306; "Receive Ticket Notifications"; Boolean)
        {
            Caption = 'Receive Ticket Notifications';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(60000; "Modifier Prix"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Allow Change Price';
        }
        field(60001; "Annuler Mission"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA MN 16/10/2019';
        }
        field(60002; "Administrateur Mission"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA MN 16/10/2019';
        }
        field(60003; "Valider Matériel"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA MN 16/10/2019 PARC AUTO';
        }
        field(60004; "Notification Changement Prix"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA HJ 11-12-2019';
        }
        field(60005; "Vue Mission"; Option)
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA HJ 23-12-2019';
            OptionMembers = Utilisateur, Site, Tout;
        }
        field(60006; "Vue Matériel"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Utilisateur, Site, Tout;
        }
        field(60007; "Vue Réparation"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Utilisateur, Site, Tout;
        }
        field(60008; "Modifié Fiche de Paie"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA HJ 27-05-2020';
        }
        field(60009; "Imprimer Fiche De Paie"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA HJ 03-06-2020';
        }
        field(60010; "Matricule Employé"; Code[20])
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA HJ 03-06-2020';
            TableRelation = Employee;
        }
        field(60011; "Filtre Service"; Text[60])
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA HJ 03-06-2020';
        }
        field(60012; "Chef Magasin"; Boolean)
        {
            DataClassification = ToBeClassified;
            Description = 'DELTA HJ 24-07-2020';
        }
        field(60013; "Mail Envoyé"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60014; "Approuver Paiement"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60015; "Magasin par Defaut"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(60017; "Magasin Achat par Defaut"; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(60018; "Max Discount"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(60019; "Allow Discount"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60020; "Approbateur DA"; Boolean)
        {
            Caption = 'Approbateur';
            DataClassification = ToBeClassified;
        }
        field(60021; "Default Location"; code[20])
        {
            TableRelation = Location;
            DataClassification = ToBeClassified;
        }
        field(60022; "Default Bank Account"; code[20])
        {
            TableRelation = "Bank Account";
            DataClassification = ToBeClassified;
        }
        field(60023; POS; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60024; "Tiers Administrator"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60025; "Direct Reception Denied"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(60026; Commercial; code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Salesperson/Purchaser";
        }
        field(70001; "CEO Approve"; Boolean)
        {
            Caption = 'CEO Approve';
        }
        field(70003; "Account Approve"; Boolean)
        {
            Caption = 'Account Approve';
        }
        field(70004; "Manager Approve"; Boolean)
        {
            Caption = 'Manager Approve';
        }
        field(70005; "HR Approve"; Boolean)
        {
            Caption = 'HR Approve';
        }
    }
}
