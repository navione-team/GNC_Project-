page 70051 "Social Contribution List"
{
    PageType = ListPart;
    SourceTable = "Social Contribution";
    Caption = 'Social Insurance';
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec."Code") { ApplicationArea = All; }
                field("Description"; Rec."Description") { ApplicationArea = All; }
                field("Employer's part"; Rec."Employer's part") { ApplicationArea = All; }
                field("Employee's part"; Rec."Employee's part") { ApplicationArea = All; }
                field("Basis of Calculation"; Rec."Basis of Calculation") { ApplicationArea = All; }
                field("Apply to Saudi Only"; Rec."Apply to Saudi Only") { ApplicationArea = All; }
                field("Employee GL/Account"; Rec."Employee G/L Account") { ApplicationArea = All; }
                field("Employer GL/Account"; Rec."Employer G/L Account") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(processing)
        {
            // Add actions here if needed
        }
    }
}
