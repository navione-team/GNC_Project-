// Objectif annuel de chiffre d'affaires par client (FRD exigence 1.1 "Annual Targets").
// Le réalisé n'est pas stocké : il est calculé à partir des écritures client.
table 90001 "GNC Customer Target"
{
    Caption = 'Customer Target';
    DataClassification = CustomerContent;
    LookupPageId = "GNC Customer Targets";
    DrillDownPageId = "GNC Customer Targets";

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            NotBlank = true;
            TableRelation = Customer."No.";
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
        // Champ calculé (FlowField) : nom du client, non stocké
        field(10; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Customer No.", Year)
        {
            Clustered = true;
        }
    }

    // Ventes réalisées (HT, devise société) du client sur l'année :
    // somme du champ "Sales (LCY)" des écritures client (factures - avoirs).
    procedure GetActualSalesLCY(): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if ("Customer No." = '') or (Year = 0) then
            exit(0);
        CustLedgerEntry.SetRange("Customer No.", "Customer No.");
        CustLedgerEntry.SetRange("Posting Date", DMY2Date(1, 1, Year), DMY2Date(31, 12, Year));
        CustLedgerEntry.CalcSums("Sales (LCY)");
        exit(CustLedgerEntry."Sales (LCY)");
    end;

    // Pourcentage de réalisation = réalisé / objectif x 100 (0 si pas d'objectif)
    procedure GetAchievementPct(): Decimal
    begin
        if "Target Amount (LCY)" = 0 then
            exit(0);
        exit(Round(GetActualSalesLCY() / "Target Amount (LCY)" * 100, 0.01));
    end;
}
