page 70012 Packages
{
    DelayedInsert = true;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = "Default Allowances";
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employment Contract Code"; rec."Employment Contract Code")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Allowance Code"; rec."Allowance Code")
                {
                    Style = AttentionAccent;
                    StyleExpr = TRUE;
                }
                field("Allowance Type"; rec."Allowance type")
                {
                    Editable = TRUE;
                    trigger OnValidate()
                    begin
                        rec.TestField("Allowance type");
                    end;

                }

                field(Description; rec.Description)
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = TRUE;
                }
                field(Amount; rec.Amount)
                {
                }

            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Allowcode.Reset;
        Allowcode.SetCurrentKey(Sequence);
    end;

    var
        Test: Boolean;
        Allowcode: Record "Allowance Code";
        defalowance: Record "Default Allowances";
        CodeAllow: Record "Allowance Code";
        contract: Record "Employment Contract";
}

