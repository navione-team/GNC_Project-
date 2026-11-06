// Objectif annuel de chiffre d'affaires par commercial (FRD REQ-SR-004, REQ-SR-007).
// Le réalisé n'est pas stocké : il est calculé à partir des écritures client.
table 90028 "GNC Salesperson Target"
{
    Caption = 'Salesperson Target';
    DataClassification = CustomerContent;
    LookupPageId = "GNC Salesperson Targets";
    DrillDownPageId = "GNC Salesperson Targets";

    fields
    {
        field(1; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            NotBlank = true;
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(2; Year; Integer)
        {
            Caption = 'Year';
            MinValue = 2000;
            MaxValue = 2999;
            BlankZero = true;
        }
        field(3; "Target Amount (LCY)"; Decimal)
        {
            Caption = 'Target Amount (LCY)';
            AutoFormatType = 1;
            MinValue = 0;
        }
        // Champ calculé (FlowField) : nom du commercial, non stocké
        field(10; "Salesperson Name"; Text[50])
        {
            Caption = 'Salesperson Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Salesperson/Purchaser".Name where(Code = field("Salesperson Code")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Salesperson Code", Year)
        {
            Clustered = true;
        }
    }

    // Ventes réalisées (HT, devise société) du commercial sur l'année, factures - avoirs,
    // PAR LIGNE : une commande groupée crédite chaque commercial de ses propres lignes (FRD 1.5).
    procedure GetActualSalesLCY(): Decimal
    var
        GNCSalesReportData: Codeunit "GNC Sales Report Data";
    begin
        if ("Salesperson Code" = '') or (Year = 0) then
            exit(0);
        exit(GNCSalesReportData.GetSalespersonSalesLCY("Salesperson Code", DMY2Date(1, 1, Year), DMY2Date(31, 12, Year)));
    end;

    // Pourcentage de réalisation = réalisé / objectif x 100 (0 si pas d'objectif)
    procedure GetAchievementPct(): Decimal
    begin
        if "Target Amount (LCY)" = 0 then
            exit(0);
        exit(Round(GetActualSalesLCY() / "Target Amount (LCY)" * 100, 0.01));
    end;
}
