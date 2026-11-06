table 70020 "Salary Header"
{

    fields
    {
        field(1; No; Code[12])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Posting Month"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,January,February,March,April,May,June,July,August,September,October,November,December';
            OptionMembers = " ",January,February,March,April,May,June,July,August,September,October,November,December;

            trigger OnValidate()
            begin
                case "Posting Month" of
                    1:
                        intmonth := '01';
                    2:
                        intmonth := '02';
                    3:
                        intmonth := '03';
                    4:
                        intmonth := '04';
                    5:
                        intmonth := '05';
                    6:
                        intmonth := '06';
                    7:
                        intmonth := '07';
                    8:
                        intmonth := '08';
                    9:
                        intmonth := '09';
                    10:
                        intmonth := '10';
                    11:
                        intmonth := '11';
                    12:
                        intmonth := '12';
                end;
                if intmonth = '02' then day := '28' else day := '30';
                //EVALUATE("Posting Date",day+'/'+(intmonth)+'/'+FORMAT("Posting Year"));
                Description := Format("Posting Month") + ' ' + Format("Posting Year") + ' ' + 'Payroll';
            end;
        }
        field(4; "Posting Year"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "No Serie"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(8; "Total Gross Salary"; Decimal)
        {
            CalcFormula = Sum("Salary Line"."Gross Salary" WHERE("Document No." = FIELD(No)));
            FieldClass = FlowField;
        }
        field(9; "Total Advance"; Decimal)
        {
            CalcFormula = Sum("Salary Line".Advance WHERE("Document No." = FIELD(No)));
            FieldClass = FlowField;
        }
        field(10; "Total Loan"; Decimal)
        {
            CalcFormula = Sum("Salary Line".Loan WHERE("Document No." = FIELD(No)));
            FieldClass = FlowField;
        }
        field(11; "Total Net Pay"; Decimal)
        {
            CalcFormula = Sum("Salary Line"."Net Pay" WHERE("Document No." = FIELD(No)));
            FieldClass = FlowField;
        }
        field(12; "Paid Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; Sponsor; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employee Sponsor/Payer";
        }
        field(14; "Payer  Bank"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Employer EID"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Union.Code;

            trigger OnValidate()
            begin
                RecPayer.Reset;
                RecPayer.SetRange(Code, "Employer EID");
                if RecPayer.FindSet then begin
                    "Payer EID" := RecPayer."Payer EID";
                    "Payer Name" := RecPayer.Name;
                    "Payer  Bank" := RecPayer."Payer Bank";
                    "Payer IBAN" := RecPayer."Payer IBAN";
                end;
            end;
        }
        field(16; "Payer IBAN"; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Payer QID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Payer Name"; Text[30])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(19; "Payer EID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Payroll Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Open,Released;
        }
    }

    keys
    {
        key(Key1; No)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin

        if Confirm('This Action Will delete all Salary lines') then
            Rec_Salary_Line.Reset;
        Rec_Salary_Line.SetRange(Rec_Salary_Line."Document No.", No);
        if Rec_Salary_Line.FindSet then
            Rec_Salary_Line.DeleteAll;
    end;

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        HumanRsetup.Get();

        if No = '' then begin
            HumanRsetup.TestField("Payroll No");

            // Assign default series from setup
            "No Serie" := HumanRsetup."Payroll No";

            // If previously used series is still related, keep it
            if NoSeries.AreRelated(HumanRsetup."Payroll No", xRec."No Serie") then
                "No Serie" := xRec."No Serie";

            // Generate and assign the next number based on work date
            No := NoSeries.GetNextNo("No Serie", WorkDate());
        end;

        "Document Date" := WorkDate;
        "Posting Year" := Date2DMY(WorkDate, 3);
        "Paid Days" := HumanRsetup."Paid Days";
    end;


    var
        HumanRsetup: Record "Human Resources Setup";
        NoSerieMGT: Codeunit "No. Series - Batch";
        header: Record "Salary Header";
        intmonth: Code[10];
        day: Code[10];
        Rec_Salary_Line: Record "Salary Line";
        RecPayer: Record "Employee Sponsor/Payer";


    procedure AssistEdit(Oldheader: Record "Salary Header"): Boolean
    var
        NoSeries: Codeunit "No. Series";
        header: Record "Salary Header";
    begin
        header := Rec;
        HumanRsetup.Get();
        HumanRsetup.TestField("Payroll No");
        // Allow user to select a related number series
        if NoSeries.LookupRelatedNoSeries(
               HumanRsetup."Payroll No",
               Oldheader."No Serie",
               Rec."No Serie")
        then begin
            // Generate the next number in the selected series
            No := NoSeries.GetNextNo("No Serie");

            Rec := header;
            exit(true);
        end;
        exit(false);
    end;


    local procedure getMonth(var textmonth: Text): Integer
    var
        intmonth: Code[10];
    begin
        case textmonth of
            /* 0:intmonth:='01';
              1:intmonth:='02';
              3:intmonth:=3;
              4:intmonth:=4;
              'May':intmonth:=05;*/
            'June':
                intmonth := '06';
            'July':
                intmonth := '07';
            'August':
                intmonth := '08';
            'September':
                intmonth := '09';
            'October"':
                intmonth := '10';
            'November':
                intmonth := '11';
            'December':
                intmonth := '12';
        end;

    end;

    local procedure CreateSalaryLine(Rec_Salary_header: Record "Salary Header"; Employee_: Code[20]; Rec_Employee: Record Employee)
    var
        wind: Dialog;
        Rec_Salry_line: Record "Salary Line";
        DialogWindow: Label 'Creating Salary Line';
        i: Integer;
    begin
        wind.Open(DialogWindow
            + '\#########################1#'
            + '\#########################2#'
            + '\@@@@@@@@@@@@@@@@@@@@@@@@3@');
        wind.Update(1, Rec_Salary_header.No + ' ' + Rec_Salary_header.Description);
        i := 1;

        wind.Update(2, Rec_Employee."No." + ':' + Rec_Employee.FullName());

        Rec_Salry_line.Reset;
        Rec_Salry_line.SetRange("Document No.", Rec_Salary_header.No);
        Rec_Salry_line.SetRange(Employee, Rec_Employee."No.");
        if Rec_Salry_line.Find('-') then
            if Confirm('Erase Existing Line?') then
                Rec_Salry_line.DeleteAll;


        begin

            Rec_Salry_line.Reset;
            Rec_Salry_line.Init;

            Rec_Salry_line.Validate("Document No.", Rec_Salary_header.No);
            Rec_Salry_line.Description := 'Payroll' + ' ' + Format(Rec_Salary_header."Posting Month") + ' ' + Format(Rec_Salary_header."Posting Year");
            Rec_Salry_line.Validate(Employee, Rec_Employee."No.");
            Rec_Salry_line."Posting Month" := Rec_Salary_header."Posting Month";
            Rec_Salry_line."Posting Year" := Rec_Salary_header."Posting Year";
            Rec_Employee.CalcFields("Basic Salary");
            Rec_Salry_line."Basic Salary" := Rec_Employee."Basic Salary";
            Rec_Salry_line.Insert;



        end;
        wind.Update(3, Round((i / Rec_Employee.Count) * 10000, 1));
        i := i + 1;
    end;
}

