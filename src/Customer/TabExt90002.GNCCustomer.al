// Champs GNC ajoutés à la table standard Customer (18) - FRD exigence 1.1.
// Name, Phone No., GLN, E-Mail, Contact, Location, Country existent déjà en standard.
tableextension 90002 "GNC Customer" extends Customer
{
    fields
    {
        // Classifications : chaque champ ne propose que les codes de sa propre liste (filtre sur Type)
        field(90000; "GNC Customer Type"; Code[20])
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            TableRelation = "GNC Cust. Classification".Code where(Type = const("Customer Type"));
        }
        field(90001; "GNC Area Code"; Code[20])
        {
            Caption = 'Area Code';
            DataClassification = CustomerContent;
            TableRelation = "GNC Cust. Classification".Code where(Type = const("Area"));
        }
        field(90002; "GNC Line Code"; Code[20])
        {
            Caption = 'Line Code';
            DataClassification = CustomerContent;
            TableRelation = "GNC Cust. Classification".Code where(Type = const("Line"));
        }
        field(90003; "GNC Sector"; Enum "GNC Sector")
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }
        field(90004; "GNC Business Unit Code"; Code[20])
        {
            Caption = 'Business Unit Code';
            DataClassification = CustomerContent;
            TableRelation = "GNC Cust. Classification".Code where(Type = const("Business Unit"));
        }
        field(90005; "GNC Division Code"; Code[20])
        {
            Caption = 'Division Code';
            DataClassification = CustomerContent;
            TableRelation = "GNC Cust. Classification".Code where(Type = const("Division"));
        }
        field(90006; "GNC Region Code"; Code[20])
        {
            Caption = 'Region Code';
            DataClassification = CustomerContent;
            TableRelation = "GNC Cust. Classification".Code where(Type = const("Region"));
        }
        // Numéro du registre de commerce (obligatoire pour vendre, voir codeunit 90005)
        field(90007; "GNC CR No."; Code[30])
        {
            Caption = 'CR No.';
            DataClassification = CustomerContent;
        }
        field(90008; "GNC Observation"; Text[250])
        {
            Caption = 'Observation';
            DataClassification = CustomerContent;
        }
        // Coordonnées de la personne de contact (en plus du téléphone/e-mail de la société)
        field(90009; "GNC Contact Phone No."; Text[30])
        {
            Caption = 'Contact Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
        field(90010; "GNC Contact E-Mail"; Text[80])
        {
            Caption = 'Contact E-Mail';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                // Refuse une adresse e-mail mal formée (même contrôle que le champ standard E-Mail)
                if "GNC Contact E-Mail" <> '' then
                    MailManagement.CheckValidEmailAddresses("GNC Contact E-Mail");
            end;
        }
        // Lot 7 – Position GPS de livraison (carte de la tournée, page 90083). Mêmes n° sur Ship-to Address (90080).
        field(90011; "GNC Latitude"; Decimal)
        {
            Caption = 'Latitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 6 : 6;
            MinValue = -90;
            MaxValue = 90;
        }
        field(90012; "GNC Longitude"; Decimal)
        {
            Caption = 'Longitude';
            DataClassification = CustomerContent;
            DecimalPlaces = 6 : 6;
            MinValue = -180;
            MaxValue = 180;
        }
    }
}
