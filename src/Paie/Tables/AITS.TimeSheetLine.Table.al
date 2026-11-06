table 70006 "TimeSheet Line"
{
    // text:=COPYSTR(FORMAT("Worked Hours"),1,2)+'.'+COPYSTR(FORMAT("Worked Hours"),4,2);
    // EVALUATE(diff,text);
    // RhSetup.GET();
    // "Absence Hours":=480-(W_H*60)+W_M;
    // "Absence Hours":="Absence Hours"/60;
    // MESSAGE('%1',W_H);

    LookupPageID = "TimeSheet Line";
    Permissions = TableData "Employee Posted Absence" = rimd;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(2; Employee; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee;

            trigger OnValidate()
            begin
                if Rec_employee_.Get(Employee) then
                    "Employee Full Name" := Rec_employee_."First Name" + ' ' + Rec_employee_."Last Name";
                Validate("Store Code", Rec_employee_."Global Dimension 1 Code");
                "Employee Calander" := Rec_employee_."Employee Calendar";
            end;
        }
        field(3; "Employee Full Name"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Date; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin

                Cal.Reset;
                Cal.SetRange(Date, Date);
                if Cal.FindSet then begin
                    if Cal.Nonworking = true then
                        Holiday := true
                    else
                        Holiday := false;
                end;

                dt.SetRange("Period Start", Date);
                if dt.FindSet then
                    Day := dt."Period Name";
                if (dt."Period Name" = 'Thursday') and ("Store Code" = 'QNTGC') then
                    thursday := true;
                if (dt."Period Name" = 'Friday') and ("Store Code" = 'QNTGC') then begin
                    Holiday := true;
                    Description := BaseCal.Description;
                    "Time In" := 0T;
                    "Time Out" := 0T;
                end;
                //check casual leave
                Abs_rec.Reset;
                Abs_rec.SetRange("Employee No.", Employee);
                Abs_rec.SetRange("From Date", Date);
                if Abs_rec.FindSet then
                    "Absence Reason" := "Absence Reason"::Casual;

                Year := Date2DMY(Date, 3);
                Month := Date2DMY(Date, 2);
                ///
                Store_Cal.Reset;
                Store_Cal.SetRange("Date off", Date);
                Store_Cal.SetRange("Employee No", Employee);
                Store_Cal.SetRange("Store code", "Store Code");
                if Store_Cal.FindSet then
                    Holiday := true;
            end;
        }
        field(5; Day; Text[30])
        {
            Caption = 'Day';
            DataClassification = ToBeClassified;
        }
        field(6; Month; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",January,February,March,April,May,June,July,August,September,October,November,December;
        }
        field(7; Year; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Time In"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Time Out"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Worked Hours"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Absence Hours"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Absence Reason"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Present,Absent,Late,Vacation,Holiday,"Unpaid Leave",OverTime,Casual;

            trigger OnValidate()
            begin
                Comment := Format("Absence Reason");
            end;
        }
        field(13; Comment; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(14; "Over Hours"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Store Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(16; "Attendance No"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "TimeSheet Header"."No.";

            trigger OnValidate()
            begin
                Description := "Store Code" + '  ' + 'Attendance' + '  ' + Format(Month) + '  ' + Format(Year);
            end;
        }
        field(17; Description; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(18; Holiday; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(19; thursday; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Time In1"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Time Out1"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Employee Calander"; Code[10])
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

        attendance.Reset;

        attendance.SetFilter("No.", '<>%1', '');
        if attendance.FindSet then begin
            Validate(Rec."Attendance No", attendance."No.");
            // VALIDATE(Rec."Store Code",attendance."Store Code");

            Validate(Date);
        end else
            Error('TimeSheet Header Empty!!');

        if Rec_employee_.Get(Employee) then
            "Employee Full Name" := Rec_employee_."First Name" + ' ' + Rec_employee_."Last Name";
        Validate("Store Code", Rec_employee_."Global Dimension 1 Code");
        "Employee Calander" := Rec_employee_."Employee Calendar";
        Description := "Store Code" + '  ' + 'Attendance' + '  ' + Format(Month) + '  ' + Format(Year);


        //IF "Store Code"<>'QNTGC' THEN
        //BEGIN

        //END;
    end;

    trigger OnModify()
    begin

        attendance.Reset;

        attendance.SetFilter("No.", '<>%1', '');
        if attendance.FindSet then begin
            Validate(Rec."Attendance No", attendance."No.");
            //VALIDATE(Rec."Store Code",attendance."Store Code");
            Description := "Store Code" + '  ' + 'Attendance' + '  ' + Format(Month) + '  ' + Format(Year);

            //VALIDATE(Date);
        end else
            Error('TimeSheet Header Empty!!');
        if Rec_employee_.Get(Employee) then
            "Employee Full Name" := Rec_employee_."First Name" + ' ' + Rec_employee_."Last Name";
        Validate("Store Code", Rec_employee_."Global Dimension 1 Code");
        "Employee Calander" := Rec_employee_."Employee Calendar";

        Description := "Store Code" + '  ' + 'Attendance' + '  ' + Format(Month) + '  ' + Format(Year);
    end;

    var
        RhSetup: Record "Human Resources Setup";
        timein: Integer;
        timeout: Integer;
        textH: Text;
        Rec_employee_: Record Employee;
        PresHours: Integer;
        Type_helper: Codeunit "Type Helper";
        HourIn: Integer;
        HourOut: Integer;
        MinTIn: Integer;
        MinTout: Integer;
        SecondIn: Integer;
        Secondout: Integer;
        Presmin: Integer;
        testtime: Time;
        diff: Decimal;
        dur: Duration;
        BigInt: BigInteger;
        W_H: Integer;
        W_M: Integer;
        W_S: Integer;
        textM: Text;
        attendance: Record "TimeSheet Header";
        BaseCal: Record "Base Calendar Change";
        recd: Date;
        CustomizedCalendarChange: Record "Customized Calendar Change";
        CalendarMgmt: Codeunit "Calendar Management";
        //PeriodFormMgt: Codeunit PeriodFormManagement;SBN
        CurrentCalendarCode: Code[10];
        CurrentSourceCode: Code[20];
        Description: Text[50];
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        CurrentSourceType: Option Company,Customer,Vendor,Location,"Shipping Agent",Service;
        CurrentAdditionalSourceCode: Code[20];
        Nonworking: Boolean;
        WeekNo: Integer;
        dt: Record Date;
        Abs_rec: Record "Employee Posted Absence";
        VarAtt1: Time;
        VarAtt2: Time;
        Store_Cal: Record "Store Calendar";
        Cal: Record "Base Calendar Change";
}

