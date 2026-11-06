table 70014 "Loan & Advance Lines"
{
    Caption = 'Loan & Advance Lines';
    // DrillDownPageID = "Employee Transfert Request";
    // LookupPageID = "Employee Transfert Request";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Non.';
            TableRelation = "Rec. Loan & Advance";
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(3; Employee; Code[10])
        {
            Caption = 'Employee';
            TableRelation = Employee;
        }
        field(5; "Employee Posting Group"; Code[10])
        {
            Caption = 'Employee Posting Group';
            Editable = true;
            TableRelation = "employee posting group";
        }
        field(6; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Advance,Loan,Addition';
            OptionMembers = Advance,Loan,Addition;
        }
        field(7; "Document type"; Code[20])
        {
            Caption = 'Document type';
            TableRelation = "Loan & Advance Type" WHERE(Type = FIELD(Type));
        }
        field(10; "Line Amount"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Line Amount';

            trigger OnValidate()
            begin
                if Header.Get("No.") then begin
                    "Line %" := ("Line Amount" / Header.Amount) * 100
                end
            end;
        }
        field(11; "Line %"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Line %';
            DecimalPlaces = 3 : 3;

            trigger OnValidate()
            begin
                if Header.Get("No.") then begin
                    "Line Amount" := ("Line %" * Header.Amount) / 100
                end
            end;
        }
        field(20; Status; Option)
        {
            Caption = 'Status';
            Editable = true;
            OptionCaption = 'In progress,Closed,Holded';
            OptionMembers = "In progress",Closed,Holded;
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
            Editable = true;
        }
        field(23; "Payroll Date"; Date)
        {
            Caption = 'Payroll Date';
        }
        field(30; "Payment No."; Code[20])
        {
            Caption = 'Payment No.';
            Editable = true;
            TableRelation = IF (Paid = FILTER(false)) "Salary Header"
            ELSE
            IF (Paid = FILTER(true)) "Rec.Salary Header";
        }
        field(31; Paid; Boolean)
        {
            Caption = 'Paid';
            Editable = true;
        }
        field(32; "Global dimension 1"; Code[20])
        {
            Caption = 'Departement Code';
            Editable = true;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(33; "Global dimension 2"; Code[20])
        {
            Caption = 'Code dossier';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(50; "Principal Amount"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Principal Amount';
        }
        field(51; "Interest Amount"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Interest Amount';
        }
        field(70000; "User ID"; Code[50])
        {
            Caption = 'User ID';
            Editable = false;
            TableRelation = User;
        }
        field(70001; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = true;
        }
        field(70002; "Loan Status"; Option)
        {


            Caption = 'Loan Status';
            Description = 'RTC 24/04/2014';
            //  FieldClass = FlowField;
            //  CalcFormula = Lookup("Rec. Loan & Advance".Status WHERE(No.=FIELD(No.),Employee=FIELD(Employee),Type=FIELD(Type)));
            OptionCaption = 'In progress,Closed,Holded';
            OptionMembers = "In progress",Closed,Holded;
        }
        field(70013; "EOSB Advance"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "No.", "Entry No.")
        {
            Clustered = true;
            SumIndexFields = "Line Amount", "Line %";
        }
        key(Key2; "Document type", "Employee Posting Group", "Payment No.", Status, Type, Employee, "Global dimension 1", "Global dimension 2", Month, Year, Paid)
        {
            SumIndexFields = "Line Amount", "Line %";
        }
        key(Key3; "Payment No.", Status, Type, Employee)
        {
            SumIndexFields = "Line Amount", "Line %";
        }
        key(Key4; "No.", Status, Type, Employee)
        {
            SumIndexFields = "Line Amount", "Line %", "Principal Amount", "Interest Amount";
        }
        key(Key5; "Payment No.", Paid, Employee)
        {
            SumIndexFields = "Line Amount", "Line %", "Principal Amount", "Interest Amount";
        }
        key(Key6; "No.", Status, Type, Employee, Paid)
        {
            SumIndexFields = "Line Amount", "Line %", "Principal Amount", "Interest Amount";
        }
        key(Key7; "Document type", "Global dimension 1", "Global dimension 2", Employee)
        {
            SumIndexFields = "Line Amount", "Line %", "Principal Amount", "Interest Amount";
        }
        key(Key8; Employee, Status, "Payment No.", Paid)
        {
            SumIndexFields = "Line Amount", "Line %", "Principal Amount", "Interest Amount";
        }
        key(Key9; "No.", Employee, Paid)
        {
            SumIndexFields = "Line Amount", "Line %", "Principal Amount", "Interest Amount";
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Last Date Modified" := WorkDate;
        "User ID" := UserId;

        if Header.Get("No.") then begin
            Header.CalcFields("Paid amount", "Repaid %");

            //"Remaining amount"   := Header."Total to repay" - Header."Repaid amount";
            //"Remaining %"        := 100 - Header."Repaid %";
        end
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := WorkDate;
        "User ID" := UserId;

        if Header.Get("No.") then begin
            Header.CalcFields("Paid amount", "Repaid %");
            //"Remaining amount"   := Header."Total to repay" - Header."Repaid amount";
            //"Remaining %"        := 100 - Header."Repaid %";
        end
    end;

    trigger OnRename()
    begin
        "Last Date Modified" := WorkDate;
        "User ID" := UserId;
    end;

    var
        Header: Record "Rec. Loan & Advance";
        errAmount: Label 'Error on the inserted Amount.';
}

