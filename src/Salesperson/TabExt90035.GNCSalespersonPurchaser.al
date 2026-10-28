// Champs GNC sur la table standard 13 "Salesperson/Purchaser" : PIN, Type et Sub-Type.
// PIN : code personnel du commercial (le "PWD" demandé par le chef de projet).
// Il le saisit sur la Request Collection (devis) pour s'identifier : ce n'est pas
// un mot de passe de connexion à BC, seulement une identification sur le document.
tableextension 90035 "GNC Salesperson/Purchaser" extends "Salesperson/Purchaser"
{
    fields
    {
        field(90000; "GNC PIN"; Text[20])
        {
            Caption = 'PIN';
            DataClassification = CustomerContent;
            // Masqué à l'écran (points) comme un mot de passe
            ExtendedDatatype = Masked;

            trigger OnValidate()
            var
                OtherSalesperson: Record "Salesperson/Purchaser";
                PINAlreadyUsedErr: Label 'This PIN is already used by another salesperson. Enter a different PIN.';
            begin
                // Un PIN doit identifier un seul commercial : on refuse les doublons
                if "GNC PIN" = '' then
                    exit;
                OtherSalesperson.SetFilter(Code, '<>%1', Code);
                OtherSalesperson.SetRange("GNC PIN", "GNC PIN");
                if not OtherSalesperson.IsEmpty() then
                    Error(PINAlreadyUsedErr);
            end;
        }
        // Type de commercial (FRD REQ-SR-002, valeurs données par le chef de projet) :
        // Private Sector / Government. Même enum que le secteur du client (GNC Sector).
        field(90001; "GNC Type"; Enum "GNC Sector")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SubType: Record "GNC Salesperson Sub-Type";
            begin
                // Si le sous-type n'existe pas pour le nouveau type, on le vide
                if "GNC Sub-Type Code" <> '' then
                    if not SubType.Get("GNC Type", "GNC Sub-Type Code") then
                        "GNC Sub-Type Code" := '';
            end;
        }
        // ANCIEN champ sous-type (enum), remplacé par "GNC Sub-Type Code" en 1.0.0.11 :
        // une liste enum ne peut pas être filtrée selon le Type. Déjà publié dans la sandbox,
        // il ne peut pas être supprimé directement : il est marqué obsolète et n'est plus affiché.
        field(90002; "GNC Sub-Type"; Enum "GNC Salesperson Sub-Type")
        {
            Caption = 'Sub-Type (old)';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by field GNC Sub-Type Code (table GNC Salesperson Sub-Type), filtered by type.';
        }
        // Sous-type (tableau du FRD) : ne propose que les sous-types du Type du commercial
        field(90003; "GNC Sub-Type Code"; Code[20])
        {
            Caption = 'Sub-Type';
            DataClassification = CustomerContent;
            TableRelation = "GNC Salesperson Sub-Type".Code where(Type = field("GNC Type"));
        }
    }
}
