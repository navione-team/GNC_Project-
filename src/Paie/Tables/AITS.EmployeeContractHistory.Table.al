table 70040 "Employee Contract History"
{
    Caption = 'Employee Contract History';

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Contract,Promotion,Reduction;
        }
        field(3; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin

                if RecordEmp.Get("Employee No") then
                    "Employee Name" := RecordEmp."Full Name";


                DefAllow.Reset;
                DefAllow.SetRange("Employment Contract Code", "Employee No");
                DefAllow.SetRange(DefAllow."Allowance type", DefAllow."Allowance type"::Basic);
                if DefAllow.FindSet then
                    Rec.Validate("Basic Salary", DefAllow.Amount);

                DefAllow.Reset;
                DefAllow.SetRange("Employment Contract Code", "Employee No");
                DefAllow.SetRange(DefAllow."Allowance type", DefAllow."Allowance type"::Accomodation);
                if DefAllow.FindSet then
                    Rec.Accomodation := DefAllow.Amount;

                DefAllow.Reset;
                DefAllow.SetRange("Employment Contract Code", "Employee No");
                DefAllow.SetRange(DefAllow."Allowance type", DefAllow."Allowance type"::Transport);
                if DefAllow.FindSet then
                    Rec.Transportation := DefAllow.Amount;

                DefAllow.Reset;
                DefAllow.SetRange("Employment Contract Code", "Employee No");
                DefAllow.SetRange(DefAllow."Allowance type", DefAllow."Allowance type"::Mobile);
                if DefAllow.FindSet then
                    Rec.Mobile := DefAllow.Amount;

                DefAllow.Reset;
                DefAllow.SetRange("Employment Contract Code", "Employee No");
                DefAllow.SetRange(DefAllow."Allowance type", DefAllow."Allowance type"::Other);
                if DefAllow.FindSet then
                    Rec."Other Allowance" := DefAllow.Amount;

                DefAllow.Reset;
                DefAllow.SetRange("Employment Contract Code", "Employee No");
                DefAllow.SetRange(DefAllow."Allowance type", DefAllow."Allowance type"::Bonus);
                if DefAllow.FindSet then
                    Rec.Bonus := DefAllow.Amount;

                "Total Package" := "Basic Salary" + Accomodation + Transportation + Mobile + "Other Allowance" + Bonus;
            end;
        }
        field(4; "Contract No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employment Contract";
        }
        field(5; "Promotion Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Basic Salary"; Decimal)
        {
        }
        field(7; Accomodation; Decimal)
        {
        }
        field(8; Transportation; Decimal)
        {
        }
        field(9; Mobile; Decimal)
        {
        }
        field(10; "Other Allowance"; Decimal)
        {
        }
        field(11; "Total Package"; Decimal)
        {
        }
        field(12; "Employee Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Employment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Observation"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(15; Bonus; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No", "Entry Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        DefAllow: Record "Default Allowances";
        RecordEmp: Record Employee;
}

