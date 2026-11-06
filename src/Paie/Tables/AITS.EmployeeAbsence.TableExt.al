tableextension 70042 EmployeeAbsenceExt extends "Employee Absence"
{
    fields
    {
        field(70000; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
        }
        field(70001; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
        }
        field(70002; "Posting month"; Option)
        {
            Caption = 'Posting Month';
            OptionMembers = , January, February, March, April, May, June, July, August, September, October, November, December;
        }
        field(70003; "Posting year"; Integer)
        {
            Caption = 'Posting Year';
        }
        field(70004; "Line type"; Option)
        {
            Caption = 'Line Type';
            OptionMembers = , "Deductible of Salary", "Day off Consumption";
        }
        field(70005; "User ID"; Code[50])
        {
            Caption = 'User ID';
        }
        field(70006; "Full Name"; Text[250])
        {
            Caption = 'Name';
        //FieldClass = FlowField;
        //CalcFormula = Lookup(Employee."Full Name" WHERE("No." = FIELD("Employee No.")));
        // Add CalcFormula here if needed
        }
        field(70007; "Quantity(days)"; Decimal)
        {
            Caption = 'Quantity (days)';
        }
        field(70008; "Date Time"; DateTime)
        {
            Caption = 'Date Time';
        }
        field(70011; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionMembers = " ", "Over Time", Incentive, "Addition", "Deduction", "Puplic Holiday", "Salary Adjustment";
        }
        field(70012; "Over time Rate"; Decimal)
        {
            Caption = 'Over time Rate';
        }
        field(70013; "Over Time Amount"; Decimal)
        {
            Caption = 'Over Time Amount';
        }
        field(70014; "Basic Salary"; Decimal)
        {
            Caption = 'Basic Salary';
        }
        field(70015; "Over Time Hours"; Decimal)
        {
            Caption = 'Over Time Hours';

            trigger OnValidate()
            var
                BasicPay: Decimal;
                Housing: Decimal;
                Trans: Decimal;
                RecEmp: Record Employee;
            begin
                IF RecEmp.GET("Employee No.")THEN RecEmp.CalcFields("Basic Salary", "Transportation Allowances", "Accomodation Allowance");
                begin
                    BasicPay:=RecEmp."Basic Salary";
                    Housing:=RecEmp."Accomodation Allowance";
                    trans:=RecEmp."Transportation Allowances";
                end;
                if "Entry Type" = "Entry Type"::"Over Time" then if "Over Time Hours" <> 0 then begin
                        "Over time Rate":=(((BasicPay + housing + trans) / 30) / 8) + ((BasicPay / 30) / 8) / 2;
                        "Over Time Amount":="Over time Rate" * "Over Time Hours";
                    end;
            end;
        }
        field(70016; "Gross Salary"; Decimal)
        {
            Caption = 'Gross Salary';
        }
        field(70017; "OverTime Days"; Boolean)
        {
            Caption = 'OverTime Days';
        }
        field(70018; "Incentive Amount"; Decimal)
        {
            Caption = 'Incentive Amount';
        }
        field(70019; "Amount"; Decimal)
        {
            Caption = 'Amount';
        }
        field(70020; "OverTime Quantity Days"; Decimal)
        {
            Caption = 'OverTime Quantity Days';
        }
        field(70021; "Unit"; Option)
        {
            Caption = 'Unit';
            OptionMembers = , Hour, Day;
        }
        field(70022; "Work Company"; Code[20])
        {
            Caption = 'Work Company';
            FieldClass = FlowField;
            CalcFormula = Lookup(Employee."Work Company" WHERE("No."=FIELD("Employee No.")));
        // Add CalcFormula here if needed
        }
        field(70023; Remarks; Text[100])
        {
        }
        modify("Cause of Absence Code")
        {
        trigger OnAfterValidate()
        begin
            if RecCauseAbs.GET("Cause of Absence Code")then begin
                Description:=RecCauseAbs.Description;
                "Line type":=RecCauseAbs.Type;
            end;
        end;
        }
        modify("Employee No.")
        {
        trigger OnAfterValidate()
        begin
            if RecEmp.get("Employee No.")then "Full Name":=RecEmp."Full Name";
        //Message(RecEmp."Full Name");
        end;
        }
        modify("To Date")
        {
        trigger OnAfterValidate()
        begin
            TestField("Unit of Measure Code");
            validate(Quantity, "To Date" - "From Date" + 1);
            if "Unit of Measure Code" = 'HOUR' then VALIDATE("Quantity(days)", Quantity / 8)
            else
                VALIDATE("Quantity(days)", Quantity);
            "Posting Month":=Date2DMY(Rec."To Date", 2);
            "Posting Year":=Date2DMY(Rec."To Date", 3);
            "User ID":=UserId;
            "Date Time":=CreateDateTime(WorkDate, Time);
        end;
        }
    }
    var RecEmp: Record Employee;
    RecCauseAbs: Record "Cause of Absence";
}
