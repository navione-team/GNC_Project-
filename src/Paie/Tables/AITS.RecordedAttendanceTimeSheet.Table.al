table 70019 "Recorded Attendance TimeSheet"
{
    Caption = 'Recorded Attendance';

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
                /*IF Rec_employee_.GET(Employee) THEN
                  "Employee Full Name":=Rec_employee_."First Name"+' '+Rec_employee_."Last Name";
                   VALIDATE("Store Code",Rec_employee_."Global Dimension 1 Code");
                  "Employee Calander":=Rec_employee_."Employee Calendar";
                 */

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
                /*
                Cal.RESET;
                Cal.SETRANGE(Date,Date);
                IF Cal.FINDSET THEN
                BEGIN
                IF Cal.Nonworking=TRUE THEN

                Holiday:=TRUE
                ELSE
                Holiday:=FALSE;
                END;

                  dt.SETRANGE("Period Start",Date);
                  IF dt.FINDSET THEN
                  Day:=dt."Period Name";
                  IF (dt."Period Name"='Thursday')AND ("Store Code"='QNTGC') THEN
                  thursday:=TRUE;
                  IF (dt."Period Name"='Friday') AND ("Store Code"='QNTGC') THEN
                  BEGIN
                  Holiday:=TRUE;
                  Description:=BaseCal.Description;
                  "Time In":=0T;
                  "Time Out":=0T;
                  END;
               //check casual leave
                  Abs_rec.RESET;
                  Abs_rec.SETRANGE("Employee No.",Employee);
                  Abs_rec.SETRANGE("From Date",Date);
                  IF Abs_rec.FINDSET THEN
                   "Absence Reason":="Absence Reason"::Casual;

                  Year:=DATE2DMY(Date,3);
                  Month:=DATE2DMY(Date,2);
               ///
                Store_Cal.RESET;
                 Store_Cal.SETRANGE("Date off",Date);
                 Store_Cal.SETRANGE("Employee No",Employee);
                 Store_Cal.SETRANGE("Store code","Store Code");
                 IF Store_Cal.FINDSET THEN
                    Holiday:=TRUE;

                    */

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
                //Comment:=FORMAT("Absence Reason");
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
                //Description:="Store Code"+'  '+ 'Attendance'+'  ' +FORMAT(Month)+'  '  +FORMAT(Year);
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
        key(Key1; "Entry No", Employee, "Attendance No")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        Salari: Record Employee;
        PeriodeCompta: Record "Accounting Period";
        EmploymentContract: Record "Employment Contract";
        EndOfMonth: Date;
        NODAY: Decimal;
        RecGCal: Record "Base Calendar Change";
}

