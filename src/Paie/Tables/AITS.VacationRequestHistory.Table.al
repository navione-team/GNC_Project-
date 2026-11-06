table 70004 "Vacation Request History"
{

    fields
    {
        field(1; Employee; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";
        }
        field(2; "Full Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Departement; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Cost Center";
        }
        field(4; "Vacation Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Vacation End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Number of Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Reason For Leave"; Text[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Cause of Absence".Code;
        }
        field(8; "Manager Approve"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "HR Approve"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "CEO Approve"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Open,Released,Pending,Accepted,Rejected;
        }
        field(12; Store; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(13; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(15; Comment; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(16; Hide; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,LP,FS,Vacation,"Business Trip",Maternity,"Haj/Umrah",Emergency,LE,"Paid Casual",Others,"Unpaid Leave";
        }
        field(18; "Resume Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Last Working Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Total Vacation taken"; Decimal)
        {
            CalcFormula = Sum("Recorded Leave entries"."Quantity Days" WHERE(Employee = FIELD(Employee),
                                                                               "Entry Type" = FILTER(Vacation)));
            FieldClass = FlowField;
        }
        field(21; "Employment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Unpaid Leave"; Decimal)
        {
            CalcFormula = Sum("Recorded Leave entries"."Quantity Days" WHERE(Employee = FIELD(Employee),
                                                                               "Entry Type" = FILTER("Unpaid Leave")));
            FieldClass = FlowField;
        }
        field(23; "Grant Exception"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Entry No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Total Leave Taken"; Decimal)
        {
            CalcFormula = Sum("Recorded Leave entries"."Quantity Days" WHERE("Entry Type" = FILTER("Annual Leave"),
                                                                               Employee = FIELD(Employee)));
            FieldClass = FlowField;
        }
        field(26; "Total Romaining"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin

        Comment := UserId
    end;

    var
        recemp: Record Employee;
        UnitHours: Decimal;
        Unitdays: Decimal;
        grosssalary: Decimal;
        EndOfMonth: Date;
        ENDM: Integer;
        UserSetup: Record "User Setup";
}

