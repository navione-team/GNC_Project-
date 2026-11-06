table 70001 "Allowance Code"
{
    Caption = 'Allowance Code';
    LookupPageId = "Allowances List";


    fields
    {
        field(1; "Code"; Code[30])
        {
            Caption = 'Code';
            trigger OnValidate()
            begin
                TestField("Allowance type");
            end;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,Contract,Incriment,Promotion,Salary Adjustment,Title Change,Benefits Activations';
            OptionMembers = " ",Contract,Incriment,Promotion,"Salary Adjustment","Title Change","Benefits Activations";
        }
        field(4; "Evaluation mode"; Option)
        {
            Caption = 'Evaluation mode';
            OptionCaption = 'Inclusive,on Paid period,on Worked period,on Worked hour,on Flight hours,Nbre Days Worked,Montant = Brut * taux,Montant = Base * Montant';
            OptionMembers = Inclusive,"on Paid period","on Worked period","on Worked hour","on Flight hours","Nbre Days Worked","Montant = Brut * taux","Montant = Base * Taux";
        }
        field(10; "Default amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Default amount';
        }
        field(100; "Employee Posting Grp. filter"; Code[30])
        {
            Caption = 'Employee Posting Grp. filter';
            FieldClass = FlowFilter;
            TableRelation = "Employee Posting Group";
        }
        field(70005; "Minimum value"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Minimum value';
            DecimalPlaces = 3 : 3;
        }
        field(70000; "User ID"; Code[50])
        {
            Editable = false;
            TableRelation = User;
        }
        field(70001; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(70002; Taux; Decimal)
        {
            AutoFormatType = 1;
            DecimalPlaces = 0 : 5;
        }
        field(70003; Sequence; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(70004; "Rate from gross salary"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(70006; "Allowance type"; Option)
        {
            Caption = 'Allowance type';
            OptionMembers = ,Basic,Transport,Accomodation,Mobile,Other,Education,Bonus;
            DataClassification = ToBeClassified;
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

    trigger OnInsert()
    begin
        "Last Date Modified" := WorkDate;
        "User ID" := UserId;

    end;

    trigger OnModify()
    begin
        "Last Date Modified" := WorkDate;
        "User ID" := UserId;
    end;

    trigger OnRename()
    begin
        "Last Date Modified" := WorkDate;
        "User ID" := UserId;
    end;
}

