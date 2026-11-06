table 70012 "Store Calendar"
{
    Caption = 'TempStack';

    fields
    {
        field(1; "Store code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(2; "Employee No"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Rec_employee.Get("Employee No") then
                    "Employee Name" := Rec_employee.FullName;
            end;
        }
        field(50000; "Employee Name"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "Date off"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Not Working" := true;
            end;
        }
        field(50002; Comment; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "Not Working"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Date off")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        //
    end;

    var
        LastIndex: Integer;
        Rec_employee: Record Employee;
        pageemp: Page "Employee.List";

    procedure Push(NewValue: RecordID)
    begin
    end;

    procedure Pop(var TopValue: RecordID): Boolean
    begin
    end;

    procedure Peek(var TopValue: RecordID): Boolean
    begin
    end;
}

