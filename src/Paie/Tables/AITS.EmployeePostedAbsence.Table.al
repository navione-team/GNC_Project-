table 70018 "Employee Posted Absence"
{
    Caption = 'Employee Posted Absence';

    fields
    {
        field(1; "Employee No."; Code[20])
        {
            Caption = 'Employee No.';
            DataClassification = ToBeClassified;
            NotBlank = true;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                Employee.Get("Employee No.");
                "Employee Full Name" := Employee."Full Name" + Employee."Last Name";
            end;
        }
        field(2; "Entry No."; Integer)
        {
            //AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(3; "From Date"; Date)
        {
            Caption = 'From Date';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Posting year" := Date2DMY("From Date", 3);

                "Posting month" := Date2DMY("From Date", 2);
                "To Date" := "From Date";
                Quantity := 1;
            end;
        }
        field(4; "To Date"; Date)
        {
            Caption = 'To Date';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin

                if "From Date" <> 0D then
                    if "To Date" <> 0D then
                        //KKA
                        Quantity := "To Date" - "From Date" + 1;
                if "To Date" = "From Date" then
                    Quantity := 1;
                ////
                /*
                RecHRSetup.GET();
              totqty:=EmployeeAbs.Quantity;
              EMPNO:=EmployeeAbs."Employee No.";
              from:=EmployeeAbs."From Date";


                IF Employee.GET("Employee No.") THEN
                  ContractStartDate:=Employee."Employment Date";
                IF ("From Date">= ContractStartDate) THEN BEGIN
                  qtydays:="From Date"-ContractStartDate;
                  qtyyear:=qtydays/365;

                  qtyyear:=ROUND(qtyyear-1,1);
                  StartPeriode:=ContractStartDate+(qtyyear*364);
                  EndPeriode:=StartPeriode+364;

              IF EndPeriode>="To Date" THEN
                    BEGIN
                  Rec."Start Periode":=StartPeriode;
                  Rec."End Periode":=EndPeriode;
                //  Rec.MODIFY(TRUE);
                  END ELSE
                  BEGIN
                    StartPeriode:=EndPeriode+1;
                    EndPeriode:=EndPeriode+364;
                    Rec."Start Periode":="Start Periode";
                    Rec."End Periode":=EndPeriode;
                  //  Rec.MODIFY(TRUE);
                   END;
                END;
                //
                */

            end;
        }
        field(5; "Cause of Absence Code"; Code[10])
        {
            Caption = 'Cause of Absence Code';
            DataClassification = ToBeClassified;
            TableRelation = "Cause of Absence";
        }
        field(6; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if "Unit of Measure Code" = 'HOUR' then
                    Validate("Quantity(days)", Quantity / 8);

                if "Unit of Measure Code" = 'DAY' then
                    Validate("Quantity(days)", Quantity);
            end;
        }
        field(8; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = ToBeClassified;
            TableRelation = "Human Resource Unit of Measure";
        }
        field(11; Comment; Boolean)
        {
            CalcFormula = Exist("Human Resource Comment Line" WHERE("Table Name" = CONST("Employee Absence"),
                                                                     "Table Line No." = FIELD("Entry No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(12; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure", 1);
                Validate(Quantity, "Quantity (Base)");
            end;
        }
        field(13; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(70000; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                //ValidateShortcutDimCode(1,"Global Dimension 1 Code");
            end;
        }
        field(70001; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                //ValidateShortcutDimCode(2,"Global Dimension 2 Code");
            end;
        }
        field(70002; "Posting month"; Option)
        {
            Caption = 'Posting month';
            DataClassification = ToBeClassified;
            Editable = true;
            OptionCaption = ', January, February, March, April, May, June, July, August, September, October, November, December';
            OptionMembers = ," January"," February"," March"," April"," May"," June"," July"," August"," September"," October"," November"," December";
        }
        field(70003; "Posting year"; Integer)
        {
            Caption = 'Posting year';
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(70004; "Line type"; Option)
        {
            Caption = 'Line type';
            DataClassification = ToBeClassified;
            Editable = true;
            OptionMembers = "  ","Deductible of Salary","Day off Consumption";
        }
        field(70005; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = User;
        }
        field(70006; "Employee Full Name"; Text[250])
        {
            Caption = 'Name';
            FieldClass = FlowField;
            CalcFormula = Lookup(Employee."Full Name" WHERE("No." = FIELD("Employee No.")));
        }
        field(70007; "Quantity(days)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70008; "Date Time"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(70011; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Over Time",Incentive,"Addition","Deduction","Puplic Holiday","Salary Adjustement";
        }
        field(70012; "Over time Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70013; "Over Time Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70014; "Employee Basic Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70015; "Over Time Hours"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70016; "Gross Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70017; "OverTime Days"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70018; "Incentive Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70019; Amount; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70020; "OverTime Quantity Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(70021; Unit; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,Hour,Day;
        }
        field(70023; Remarks; Text[100]) { }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
            SumIndexFields = Quantity;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Validate(Quantity);
    end;

    var
        CauseOfAbsence: Record "Cause of Absence";
        Employee: Record Employee;
}

