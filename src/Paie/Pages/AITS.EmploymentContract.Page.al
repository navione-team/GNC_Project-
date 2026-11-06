page 70035 "Employment Contract Card"
{
    PageType = Card;
    SourceTable = "Employment Contract";
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group("Employment Contract")
            {
                field("Code"; rec.Code)
                {
                    TableRelation = "Employment Contract";
                }

                field("Employee name"; rec."Employee name")
                {
                }

                field("Total Package"; rec."Total Package")
                {
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Regular payments"; rec."Regular payments")
                {
                    Visible = false;
                }
                field("Temporary payments"; rec."Temporary payments")
                {
                    Visible = false;
                }
                field("Employee's type"; rec."Employee's type")
                {
                    Visible = false;
                }
                field("Regimes of work"; rec."Regimes of work")
                {
                    Visible = false;
                }
                field(Taxable; rec.Taxable)
                {
                    Visible = false;
                }
                field("Take in account deductions"; rec."Take in account deductions")
                {
                    Visible = false;
                }
                field("Calculation mode of the taxes"; rec."Calculation mode of the taxes")
                {
                    Visible = false;
                }
                field("Default Employment Contract"; rec."Default Employment Contract")
                {
                    Visible = false;
                }
            }
            group(Package)
            {
            }
            part(Control1000000014; Packages)
            {
                Caption = 'Package';
                SubPageLink = "Employment Contract Code" = FIELD(Code);
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Apply Contract")
            {
                Image = ContractPayment;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin

                    HistContract.RESET;
                    HistContract.SETRANGE("Employee No", Rec.Code);
                    HistContract.SETRANGE("Entry Type", HistContract."Entry Type"::Contract);
                    IF HistContract.FINDSET THEN
                        ERROR('employee Contract already exist')
                    ELSE
                        HistContract.RESET;
                    IF HistContract.FINDLAST THEN
                        Num := HistContract."Entry No";
                    HistContract.INIT;
                    HistContract."Entry No" := Num + 1;
                    IF RecordEmp.GET(Rec.Code) THEN
                        HistContract."Employment Date" := RecordEmp."Employment Date";
                    HistContract."Entry Type" := HistContract."Entry Type"::Contract;
                    HistContract.VALIDATE("Employee No", Rec.Code);
                    HistContract.VALIDATE("Contract No", Rec.Code);
                    HistContract.INSERT;
                    HistContract.VALIDATE("Employee No");
                    MESSAGE('Contract Applied ');
                end;

            }
            action("Apply Incriment")

            {
                trigger OnAction()
                begin
                    HistContract.RESET;
                    HistContract.SETRANGE("Employee No", Rec.Code);
                    IF HistContract.FINDSET THEN
                        Rec.CALCFIELDS("Total Package");
                    IF Rec."Total Package" <> HistContract."Total Package" THEN BEGIN
                        HistContract.RESET;
                        HistContract.SETRANGE("Employee No", Rec.Code);
                        HistContract.SETRANGE("Entry Type", HistContract."Entry Type"::Promotion);

                        IF HistContract.FINDLAST THEN
                            HistContract.INIT;
                        Num := HistContract."Entry No";
                        HistContract.INIT;
                        HistContract."Entry No" := Num + 1;
                        HistContract."Promotion Date" := WORKDATE;
                        HistContract."Entry Type" := HistContract."Entry Type"::Promotion;
                        HistContract.VALIDATE("Employee No", Rec.Code);
                        HistContract.VALIDATE(HistContract."Contract No", Rec.Code);
                        HistContract.Observation := 'Salary Incriment';
                        HistContract.INSERT;
                        HistContract.VALIDATE("Employee No");
                        MESSAGE('Promotion/Incriment Applied ');
                    END
                    ELSE
                        IF Rec."Total Package" = HistContract."Total Package" THEN
                            ERROR('Contract or promotion/Incriment already exist');
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.Update(true);

    end;

    var
        VContract_G: Boolean;
        defalowance: Record "Default Allowances";
        CodeAllow: Record "Recorded Leave entries";
        HistContract: Record "Employee Contract History";
        RecordEmp: Record Employee;
        Num: Integer;
}

