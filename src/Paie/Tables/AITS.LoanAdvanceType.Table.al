table 70007 "Loan & Advance Type"
{
    Caption = 'Loan & Advance Type';
    DrillDownPageID = "L&A Installment Schedule";
    LookupPageID = "L&A Installment Schedule";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Advance,Loan,Addition';
            OptionMembers = Advance,Loan,Addition;
        }
        field(4; "Repayment slices"; Integer)
        {
            Caption = 'Repayment slices';
        }
        field(11; "Interest %"; Decimal)
        {
            Caption = 'Interest %';
            DecimalPlaces = 0 : 2;
        }
        field(30; "Account Type"; Option)
        {
            Caption = 'Account Type';
            OptionCaption = 'G/L Account,Bank Account';
            OptionMembers = "G/L Account","Bank Account";

            trigger OnValidate()
            begin
                if (("Account Type" = "Bal. Account Type")
                    and
                    ("Account Type" = 1))
                 then
                    case "Account Type" of
                        0:
                            begin
                                "Bal. Account Type" := 1;
                                "Bal. Account No." := '';

                            end;
                        1:
                            begin
                                "Bal. Account Type" := 0;
                                "Bal. Account No." := '';
                                "Avance sur Prime" := false;
                            end;
                    end;
            end;
        }
        field(31; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type" = FILTER("G/L Account")) "G/L Account"
            ELSE
            IF ("Account Type" = FILTER("Bank Account")) "Bank Account" WHERE("Currency Code" = FILTER(''));
        }
        field(32; "Bal. Account Type"; Option)
        {
            Caption = 'Bal. Account Type';
            OptionCaption = 'G/L Account,Bank Account';
            OptionMembers = "G/L Account","Bank Account";

            trigger OnValidate()
            begin
                if (("Account Type" = "Bal. Account Type")
                    and
                    ("Account Type" = 1))
                 then
                    case "Bal. Account Type" of
                        0:
                            begin
                                "Account Type" := 1;
                                "Account No." := '';
                            end;
                        1:
                            begin
                                "Account Type" := 0;
                                "Account No." := '';
                            end;
                    end;
            end;
        }
        field(33; "Bal. Account No."; Code[10])
        {
            Caption = 'Bal. Account No.';
            TableRelation = IF ("Bal. Account Type" = FILTER("G/L Account")) "G/L Account"
            ELSE
            IF ("Bal. Account Type" = FILTER("Bank Account")) "Bank Account" WHERE("Currency Code" = FILTER(''));
        }
        field(40; "Account Type Long Terme"; Option)
        {
            Caption = 'Type Compte Long Terme';
            OptionCaption = 'G/L Account,Bank Account';
            OptionMembers = "G/L Account","Bank Account";
        }
        field(41; "Account No. Lng Termeo"; Code[10])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type Long Terme" = FILTER("G/L Account"),
                                Type = CONST(Loan)) "G/L Account"
            ELSE
            IF ("Account Type Long Terme" = FILTER("Bank Account"),
                                         Type = CONST(Loan)) "Bank Account" WHERE("Currency Code" = FILTER(''));
        }
        field(50; "Interest Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = "G/L Account";
        }
        field(101; "Employee Posting Grp. filter"; Code[20])
        {
            Caption = 'Employee Posting Grp. filter';
            FieldClass = FlowFilter;
            TableRelation = "Employee Posting Group";
        }
        field(102; Balance; Decimal)
        {
            AutoFormatType = 2;

            Caption = 'Balance';
            FieldClass = FlowField;
            CalcFormula = Sum("Loan & Advance Entry".Amount WHERE("Document type" = FIELD(Code)));
        }
        field(105; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(110; "Avance sur Prime"; Boolean)
        {

            trigger OnValidate()
            begin
                if Type <> 0 then
                    Error('C''est un Prêt !!!!!!');
            end;
        }
        field(50000; "Avance sur 13 eme"; Boolean)
        {
        }
        field(70000; "type amortissement"; Option)
        {
            OptionCaption = 'Dégressif,Lineaire,Constant';
            OptionMembers = "Dégressif",Lineaire,Constant;
        }
        field(70001; "Imputation Comptable"; Option)
        {
            OptionCaption = 'Imputable,Non Imputable';
            OptionMembers = Imputable,"Non Imputable";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

