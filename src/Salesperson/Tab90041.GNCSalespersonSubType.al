// Liste paramétrable des sous-types de commerciaux, rattachés à un Type (Private / Government).
// Le champ "Sub-Type" de la fiche commercial ne propose que les sous-types de son Type
// (TableRelation filtrée), comme le demande le tableau du FRD :
// - Private Sector : Pharma, OTC, Medical Device
// - Government     : Institution, Tender, Medical Device
// "Medical Device" existe dans les deux types : la clé est donc (Type, Code).
table 90041 "GNC Salesperson Sub-Type"
{
    Caption = 'Salesperson Sub-Type';
    DataClassification = CustomerContent;
    LookupPageId = "GNC Salesperson Sub-Types";
    DrillDownPageId = "GNC Salesperson Sub-Types";

    fields
    {
        field(1; Type; Enum "GNC Sector")
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
        fieldgroup(DropDown; "Code", Description)
        {
        }
    }

    // Crée les sous-types du FRD s'ils n'existent pas encore (appelée à l'ouverture de la page)
    procedure InsertDefaultSubTypes()
    begin
        InsertSubType(Type::Private, 'PHARMA', 'Pharma');
        InsertSubType(Type::Private, 'OTC', 'OTC');
        InsertSubType(Type::Private, 'MEDICAL DEVICE', 'Medical Device');
        InsertSubType(Type::Government, 'INSTITUTION', 'Institution');
        InsertSubType(Type::Government, 'TENDER', 'Tender');
        InsertSubType(Type::Government, 'MEDICAL DEVICE', 'Medical Device');
    end;

    local procedure InsertSubType(NewType: Enum "GNC Sector"; NewCode: Code[20]; NewDescription: Text[100])
    var
        SubType: Record "GNC Salesperson Sub-Type";
    begin
        if SubType.Get(NewType, NewCode) then
            exit;
        SubType.Init();
        SubType.Type := NewType;
        SubType.Code := NewCode;
        SubType.Description := NewDescription;
        SubType.Insert();
    end;
}
