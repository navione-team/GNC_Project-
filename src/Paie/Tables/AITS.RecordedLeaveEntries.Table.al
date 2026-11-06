table 70017 "Recorded Leave entries"
{

    fields
    {
        field(1; Employee; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin

                if recemployee.Get(Employee) then
                    Name := recemployee."Full Name";
            end;
        }
        field(2; Name; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "From date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "To date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Payroll Month"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "  ",January,February,March,April,May,June,July,August,September,October,November,December;

            trigger OnValidate()
            begin
                Year := Date2DMY("Last Working Date", 3);
            end;
        }
        field(7; Year; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,"Annual Leave","End of service",Vacation,"Business Trip",Maternity,"Haj/Umrah",Emergency,"Paid Casual",Others,"Unpaid Leave";
        }
        field(9; "Quantity Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(11; "Contract Code"; Code[10])
        {
            CalcFormula = Lookup(Employee."Emplymt. Contract Code" WHERE("No." = FIELD(Employee)));
            FieldClass = FlowField;
        }
        field(12; "Basis Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; Housing; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Contract Code"), "Allowance Type" = CONST(Accomodation)));
        }
        field(14; "Total Amount  To pay"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Manuel Input Days"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(16; "Resume Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Last Working Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(19; TA; Decimal)
        {
            CalcFormula = Lookup("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Contract Code"), "Allowance type" = FILTER(Transport)));
            FieldClass = FlowField;
        }
        field(20; MA; Decimal)
        {
            CalcFormula = Lookup("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Contract Code"), "Allowance type" = FILTER(Mobile)));
            FieldClass = FlowField;
        }
        field(21; Other; Decimal)
        {
            CalcFormula = Lookup("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Contract Code"), "Allowance type" = FILTER(Other)));
            FieldClass = FlowField;
        }
        field(22; "Other Deduction"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Cause of Absence Code"; Code[10])
        {
            Caption = 'Cause of Absence Code';
            DataClassification = ToBeClassified;
            TableRelation = "Cause of Absence";
        }
        field(24; "Joining Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Total entitlement Leave Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Unpaid Leave"; Decimal)
        {
            CalcFormula = Sum("Recorded Leave entries"."Quantity Days" WHERE(Employee = FIELD(Employee),
                                                                               "Entry Type" = FILTER("Unpaid Leave")));
            FieldClass = FlowField;
        }
        field(27; "Total Leave Taken"; Decimal)
        {
            CalcFormula = Sum("Recorded Leave entries"."Quantity Days" WHERE("Entry Type" = FILTER("Annual Leave"),
                                                                               Employee = FIELD(Employee)));
            FieldClass = FlowField;
        }
        field(28; "Total Romaining"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Employement Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Service Year"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Total Unpaid Days"; Decimal)
        {
            CalcFormula = Sum("Recorded Leave entries"."Quantity Days" WHERE(Employee = FIELD(Employee),
                                                                               "Total Amount  To pay" = FILTER(= 0),
                                                                               "Entry Type" = FILTER("Unpaid Leave")));
            FieldClass = FlowField;
        }
        field(32; "Pending Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(33; "EOSB Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(34; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,Open,Released;
        }
        field(35; "Version No"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Direction Approve"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(37; "Direction Approve date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(38; "Account Approve"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(39; "Account Approve Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(40; "EOSB Tenure"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Leave Salary Entitled"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(42; "QID Cost"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(43; "HC Cost"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(44; "Grounds for Term. Code"; Code[10])
        {
            Caption = 'Grounds for Term. Code';
            DataClassification = ToBeClassified;
            TableRelation = "Grounds for Termination";
        }
        field(45; "QID Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(46; "HC Expiry Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(47; "Total Absent Days"; Decimal)
        {
            CalcFormula = Sum("Employee Posted Absence"."Quantity(days)" WHERE("Employee No." = FIELD(Employee),
                                                                                "Cause of Absence Code" = FILTER('ABSENT')));
            FieldClass = FlowField;
        }
        field(48; "Eligible Vacation"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(49; "Eligible EOSB Tenure Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(52; "Ac.Userid"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(53; "Gm.UserId"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(54; "User ID"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Last modified date"; DateTime)
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Total Unpaid OT Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(57; "Ticket Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(58; "Pending Salary days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(59; "EOSB Advance Amount"; Decimal)
        {
            CalcFormula = Sum("Rec. Loan & Advance".Amount WHERE(Employee = FIELD(Employee),
                                                                  "EOSB Advance" = FILTER(true)));
            FieldClass = FlowField;
        }
        field(60; "Grant Exception"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(61; "Service Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(62; "Last resume Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(63; "Payment No"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; Employee)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        /*IF RecLEcritureSanctions.FINDLAST THEN
          "N° Sequences":=RecLEcritureSanctions."N° Sequences"+1
        ELSE
          "N° Sequences":=1;*/

    end;

    var
        recemployee: Record Employee;


    procedure CalculerNote(CodeNote: Code[20]): Decimal
    var
        RecLParamGRH: Record "Human Resources Setup";
    begin
    end;
}

