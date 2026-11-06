table 70013 "Loan & Advance Entry"
{
    Caption = 'Loan & Advance Entry';
    //DrillDownPageID = 70132;
    //LookupPageID = 70132;

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            Editable = false;
            TableRelation = "Rec. Loan & Advance";
        }
        field(2; Employee; Code[10])
        {
            Caption = 'Employee';
            Editable = true;
            TableRelation = Employee;
        }
        field(3; Name; Text[60])
        {
            Caption = 'Name';
            Editable = true;
        }
        field(4; "Employee Posting Group"; Code[10])
        {
            Caption = 'Employee Posting Group';
            Editable = false;
            TableRelation = "Employee Posting Group";
        }
        field(5; Type; Option)
        {
            Caption = 'Type';
            Editable = false;
            OptionCaption = 'Advance,Loan,Addition';
            OptionMembers = Advance,Loan,Addition;
        }
        field(6; "Document type"; Code[10])
        {
            Caption = 'Document type';
            Editable = false;
            // TableRelation = "Rec.Salary Line" WHERE (Employee=FIELD(Type));
        }
        field(7; "Entry type"; Option)
        {
            Caption = 'Entry type';
            OptionCaption = 'Paiment,Repaiment';
            OptionMembers = Paiment,Repaiment;
        }
        field(10; Amount; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Amount';
            Editable = true;
        }
        field(20; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'In progress,Enclosed';
            OptionMembers = "In progress",Enclosed;
        }
        field(21; Month; Option)
        {
            Caption = 'Month';
            Editable = true;
            OptionCaption = 'January,February,March,April,May,June,July,August,September,October,November,December';
            OptionMembers = " ",January,February,March,April,May,June,July,August,September,October,November,December;
        }
        field(22; Year; Integer)
        {
            Caption = 'Year';
            Editable = false;
        }
        field(23; "Date Paie"; Date)
        {
        }
        field(25; "Payment No."; Code[10])
        {
            Caption = 'Payment No.';
            Editable = true;
        }
        field(30; "Global dimension 1"; Code[20])
        {
            Caption = 'Code département';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(31; "Global dimension 2"; Code[20])
        {
            Caption = 'Code dossier';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(50001; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
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
        field(70002; "Date effet"; Date)
        {

            trigger OnValidate()
            begin
                Month := Date2DMY("Date effet", 2) - 1;
            end;
        }
        field(70007; "EOS Deduct"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "No.", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; Status, Type, Employee, "Global dimension 1", "Global dimension 2")
        {
            SumIndexFields = Amount;
        }
        key(Key3; "Document type", "Employee Posting Group", Employee, "Global dimension 1", "Global dimension 2")
        {
            SumIndexFields = Amount;
        }
        key(Key4; Status, Type, Employee, "Entry No.", "Global dimension 1", "Global dimension 2")
        {
            SumIndexFields = Amount;
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

