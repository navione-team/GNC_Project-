table 70024 "Work Regime"
{
    Caption = 'Regimes of work';

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; "Description"; Text[50])
        {
            Caption = 'Description';
        }
        field(5; "Work Hours per week"; Decimal)
        {
            Caption = 'Working hours per week';
        }
        field(10; "Max. Supp. Hours per month"; Decimal)
        {
            Caption = 'Max. Supp. Hours per month';
        }
        field(15; "Days off per month"; Decimal)
        {
            Caption = 'Days off per month';
        }
        field(16; "Assignement mode"; Option)
        {
            Caption = 'Assignement mode';
            OptionCaption = 'Relative,Absolute';
            OptionMembers = Relative,Absolute;
        }
        field(40; "Default Regime"; Boolean)
        {
            Caption = 'Default Regime';
        }
        field(50; "Worked Day Per Month"; Decimal)
        {
            Caption = 'Worked Day Per Month';
        }
        field(100; "Work Hours per month"; Decimal)
        {
            Caption = 'Work Hours per month';
        }
        field(70000; "Rate of Night"; Decimal)
        {
            Caption = 'Rate of Night';
        }
        field(70001; "Rate of No Working Day"; Decimal)
        {
            Caption = 'Rate of No Working Day';
        }
        field(70002; "Rate of No Working Paied Day"; Decimal)
        {
            Caption = 'Rate of No Working Paied Day';
        }
        field(70003; "Rate of Roulement"; Decimal)
        {
            Caption = 'Rate of Roulement';
        }
        field(70004; "User ID"; Code[50])
        {
            Editable = false;
            TableRelation = User;
        }
        field(70005; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(70006; "Type Calendar"; Option)
        {
            Caption = 'Type Calendrier';
            OptionMembers = " ",Administratif,Roulement;
        }
        field(70007; "Rate of Repos Days"; Decimal)
        {
            Caption = 'taux jours Repos';
        }
        field(70008; "Night hours begining"; Time)
        {
            Caption = 'Début heures de nuit';
        }
        field(70009; "Night hours ending"; Time)
        {
            Caption = 'Fin heures de nuit';
        }
        field(70010; "Rate of Night hours"; Decimal)
        {
            Caption = 'Taux heures de nuit';
        }
        field(70011; "Casual Leave"; Decimal)
        {
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

    trigger OnDelete()
    var
        errorDelete: Label 'Error: Unable to delete this line because it is linked to certain existing employees.';
    begin
    end;

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

    var
        "recGWorkRegime": Record "Work Regime";
        "recGWorkRegimeTmp": Record "Work Regime";
        "recGEmployee": Record Employee;
}

