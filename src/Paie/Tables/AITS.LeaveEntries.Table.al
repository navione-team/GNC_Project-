table 70016 "Leave Entries"
{

    fields
    {
        field(1; Employee; Code[10])
        {
            TableRelation = Employee;

            trigger OnValidate()
            begin

                if recemployee.Get(Employee) then begin

                    Name := recemployee."Full Name" + ' ' + recemployee."Last Name";
                    "Posting Date" := WorkDate;
                    "SID Expiry Date" := recemployee."SID Expiry Date";
                    "HC Expiry Date" := recemployee."HCard Expiry Date";
                    "Employement Date" := recemployee."Employment Date";
                    recemployee.CalcFields("Gross Salary", "Last Resume Date");
                    Rec.Validate("Work Company", recemployee."Work Company");

                    "Gross Salary" := recemployee."Gross Salary";
                    "Joining Date" := recemployee."Employment Date";
                    "Ticket Amount" := recemployee."Travel Ticket Amount";
                    if recemployee."Last Resume Date" <> 0D THEN
                        "Last resume Date" := recemployee."last resume date";
                end;


                if RecordContract.Get(Employee) then begin
                    RecordContract.CalcFields("Total Package");
                    "Net Salary" := RecordContract."Total Package";
                end;
            end;
        }
        field(2; Name; Text[50])
        {
        }
        field(3; "Posting Date"; Date)
        {
        }
        field(4; "From date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                IF "From date" <> 0D THEN
                    "Last Working Date" := "From date" - 1;
                Year := Date2DMY("Last Working Date", 3);
            end;
        }
        field(5; "To date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                IF "To date" <> 0D then
                    "Resume Date" := "To date" + 1;


            end;


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
        field(12; "Gross Salary"; Decimal)
        {
        }
        field(13; Housing; Decimal)
        {
            CalcFormula = Sum("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Contract Code"),
                                                                 "Allowance Code" = FILTER('ACCOM')));
            FieldClass = FlowField;
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

            trigger OnValidate()
            begin

            end;
        }
        field(17; "Last Working Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin

            end;
        }
        field(19; TA; Decimal)
        {
            CalcFormula = Sum("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Contract Code"),
                                                                 "Allowance Code" = FILTER('TRANS')));
            FieldClass = FlowField;
        }
        field(20; MA; Decimal)
        {
            CalcFormula = Sum("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Contract Code"),
                                                                 "Allowance Code" = FILTER('MOBILE')));
            FieldClass = FlowField;
        }
        field(21; Other; Decimal)
        {
            CalcFormula = Sum("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Contract Code"),
                                                                 "Allowance Code" = FILTER('OTHER')));
            FieldClass = FlowField;
        }
        field(22; "Other Deduction"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Cause of Absence Code"; Code[10])
        {
            Caption = 'Cause of Absence Code';
            TableRelation = "Cause of Absence";
        }
        field(24; "Joining Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Total entitlement Leave Days"; Decimal)
        {
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
        field(42; "SID Cost"; Decimal)
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
            TableRelation = "Grounds for Termination";
        }
        field(45; "SID Expiry Date"; Date)
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
        field(48; "Annual Leave Days"; Decimal)
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
        field(63; "Work Company"; Code[21])
        {
            DataClassification = ToBeClassified;
            TableRelation = Relative;
        }
        field(64; "Net Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(65; "Calculation Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Full Salary","Basic Salary";
        }
        field(66; "OverTime Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(67; "Incentive Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Line No")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        recemployee.SetRange("No.", Employee);
        IF recemployee.findset then begin

            recemployee."Last Resume Date" := 0D;
            recemployee."Last Working Date" := 0D;

            recemployee.modify;
        end;

    end;

    trigger OnInsert()
    begin


        //-"Total Leave Taken";
        Status := Status::Open;
        "Version No" := -1;
        "User ID" := UserId;
        "Last modified date" := CurrentDateTime;
    end;

    var
        recemployee: Record Employee;
        RecGCal: Record "Base Calendar Change";
        total_days: Decimal;
        paid_days: Decimal;
        Abs_days: Decimal;
        SidRomainingDays: Integer;
        HCRomainingDays: Integer;
        SIDExpiryDate: Date;
        HCExpiryDate: Date;
        HRSetup: Record "Human Resources Setup";
        Net_Days: Decimal;
        Sd: Decimal;
        SY: Decimal;
        eosb: Decimal;
        sygross: Decimal;
        RomVacation: Decimal;
        eligibleEOSBDays: Decimal;
        SalaryLines: Record "Salary Line";
        salTest: Decimal;
        USERSETUP: Record "User Setup";
        Vac_req: Page "Vacation Request History";
        Vacation_request: Record "Employee Vacation Request";
        Page_employee: Page "Employee.List";
        Qty_days: Decimal;
        Quantity_Days: Decimal;
        Eligible_vac: Decimal;
        Vac_Days: Decimal;
        test: Decimal;
        RecordContract: Record "Employment Contract";


    procedure FsCalculation(Employee: Code[20]; last_Working_Date: Date; Total_Abs_Days: Decimal) FS_Amount: Decimal
    var
        Employee_: Record Employee;
        Services_days: Decimal;
        Services_year: Decimal;
        FSAmount1: Decimal;
        FSAmount2: Decimal;
        OneDaySal: Decimal;
    begin

        if Employee_.Get(Employee) then
            Employee_.TestField(Status, Employee_.Status::Active);

        Employee_.CalcFields("Basic Salary");
        if last_Working_Date <> 0D then begin
            Evaluate(Services_days, Format(last_Working_Date - Employee_."Employment Date" + 1));

            Services_days := (Services_days / 365) * 360;
            "Service Year" := "Service Days" / 365;
            Message('year %1', "Service Year");
            "Quantity Days" := Services_days;
            Rec.Modify;
            //  Services_year*Employee_."Contract Vacation Days";
            "Service Year" := Round(Services_year, 0.001);
            Employee_.CalcFields("Basic Salary");
            OneDaySal := Employee_."Basic Salary" / 30;

            // IF Services_year<1 THEN ERROR('This employee is not eligible for Gratuity')
            // ELSE
            begin
                "Quantity Days" := "Service Year" * Employee_."Contract Vacation Days";
                FSAmount1 := OneDaySal * "Quantity Days";
                Message('year %1', "Quantity Days");
            end;
            FS_Amount := FSAmount1;
        end;
    end;

    local procedure DivLine()
    begin
    end;
}

