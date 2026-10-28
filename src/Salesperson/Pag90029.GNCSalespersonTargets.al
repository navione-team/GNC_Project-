// Liste des objectifs annuels par commercial, avec réalisé et % de réalisation.
// Ouverte depuis la fiche commercial (action "Annual Targets") ou la page d'accueil GNC.
page 90029 "GNC Salesperson Targets"
{
    Caption = 'Salesperson Targets';
    PageType = List;
    SourceTable = "GNC Salesperson Target";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sales representative that the target applies to.';
                }
                field("Salesperson Name"; Rec."Salesperson Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the sales representative.';
                }
                field(Year; Rec.Year)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the year of the target.';
                }
                field("Target Amount (LCY)"; Rec."Target Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the annual sales target in local currency.';
                }
                // Colonnes calculées : remplies dans OnAfterGetRecord
                field(ActualSalesLCY; ActualSalesLCY)
                {
                    ApplicationArea = All;
                    Caption = 'Actual Sales (LCY)';
                    ToolTip = 'Specifies the posted sales (excluding VAT) of the sales representative for the year, in local currency.';
                    AutoFormatType = 1;
                    Editable = false;
                }
                field(AchievementPct; AchievementPct)
                {
                    ApplicationArea = All;
                    Caption = 'Achievement %';
                    ToolTip = 'Specifies the actual sales as a percentage of the target.';
                    DecimalPlaces = 0 : 2;
                    Editable = false;
                }
            }
        }
    }

    var
        ActualSalesLCY: Decimal;
        AchievementPct: Decimal;

    trigger OnAfterGetRecord()
    begin
        ActualSalesLCY := Rec.GetActualSalesLCY();
        AchievementPct := Rec.GetAchievementPct();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // Année par défaut = année de la date de travail
        Rec.Year := Date2DMY(WorkDate(), 3);
        // Si la page est filtrée sur un seul commercial (ouverte depuis sa fiche), on le reprend
        if Rec.GetFilter("Salesperson Code") <> '' then
            if Rec.GetRangeMin("Salesperson Code") = Rec.GetRangeMax("Salesperson Code") then
                Rec."Salesperson Code" := Rec.GetRangeMin("Salesperson Code");
        ActualSalesLCY := 0;
        AchievementPct := 0;
    end;
}
