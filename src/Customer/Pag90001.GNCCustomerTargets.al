// Liste des objectifs annuels client avec réalisé et % de réalisation.
// Ouverte depuis la fiche client (action "Annual Targets") ou par la recherche BC.
page 90001 "GNC Customer Targets"
{
    Caption = 'Customer Targets';
    PageType = List;
    SourceTable = "GNC Customer Target";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer that the target applies to.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the customer.';
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
                    ToolTip = 'Specifies the posted sales (excluding VAT) of the customer for the year, in local currency.';
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
        // Si la page est filtrée sur un seul client (ouverte depuis la fiche), on le reprend
        if Rec.GetFilter("Customer No.") <> '' then
            if Rec.GetRangeMin("Customer No.") = Rec.GetRangeMax("Customer No.") then
                Rec."Customer No." := Rec.GetRangeMin("Customer No.");
        ActualSalesLCY := 0;
        AchievementPct := 0;
    end;
}
