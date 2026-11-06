table 70003 "Employee Vacation Request"
{

    fields
    {
        field(1; Employee; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Employee."No.";

            trigger OnValidate()
            begin
                if recemployee.Get(Employee) then begin
                    "Full Name" := recemployee."First Name" + ' ' + recemployee."Last Name";
                    Store := recemployee."Global Dimension 1 Code";
                    Validate(Departement, recemployee."Global Dimension 2 Code");
                    "Employment Date" := recemployee."Employment Date";
                end;
            end;
        }
        field(2; "Full Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(3; Departement; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Cost Center";
        }
        field(4; "Vacation Start Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                "Last Working Date" := "Vacation Start Date" - 1;
            end;
        }
        field(5; "Vacation End Date"; Date)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                /*
                  EVALUATE("Number of Days",FORMAT(("Vacation End Date" -"Vacation Start Date")+1) );
                  "Resume Date":="Vacation End Date"+1;
                
                   "Last Working Date":="Vacation Start Date"-1;
                    EVALUATE(Quantity_Days,FORMAT(("Last Working Date" -recemployee."Employment Date")+1) );
                    CALCFIELDS("Total Vacation token","Unpaid Leave");
                    sd:=Quantity_Days-"Unpaid Leave"-"Total Vacation token";
                    tenure:=ROUND(sd/365,0.01);*/

                // MESSAGE('Tenure=%1',tenure);
                /* IF (tenure<1) AND ("Grant Exception"=FALSE) THEN

                   ERROR('This Employee is not elligible for vacation');

                  EXIT;*/
                ///

                Evaluate("Number of Days", Format(("Vacation End Date" - "Vacation Start Date") + 1));
                "Resume Date" := "Vacation End Date" + 1;
                recemployee.Reset;
                recemployee.SetRange("No.", Employee);
                if recemployee.FindSet then begin
                    recemployee."Vacation Resume Date" := "Resume Date";
                    recemployee."Last Working Date" := "Vacation Start Date" - 1;
                    recemployee.Modify;
                end;
                "Last Working Date" := "Vacation Start Date" - 1;
                Evaluate(Quantity_Days, Format(("Last Working Date" - recemployee."Employment Date") + 1));
                CalcFields("Total Vacation token", "Unpaid Leave");
                sd := Quantity_Days - "Unpaid Leave";
                tenure := Round(sd / 365, 0.01);
                ///
                if Rec_Employee.Get(Employee) then begin
                    if Rec_Employee."Office Manager" = true then
                        if tenure > 1 then
                            Eligible_vac := Rec_Employee."Contract Vacation Days" * tenure;

                    if (Rec_Employee."Office Manager" = false) then
                        if (tenure > 1) and (tenure < 5) then
                            Eligible_vac := Rec_Employee."Contract Vacation Days" * tenure;

                    if tenure > 5 then begin
                        Vac_Days := 28;
                        Eligible_vac := 5 * Rec_Employee."Contract Vacation Days" + (tenure - 5) * Vac_Days
                    end;
                    Eligible_vac := Eligible_vac - "Total Vacation token";

                    if (Eligible_vac = 0) and ("Grant Exception" = false) then
                        Error('This employee is not eligible for Vacation');
                    if ("Number of Days" > Eligible_vac) and ("Grant Exception" = false) then begin
                        Message('This Employee is Elegibile Only for %1 days', Round(Eligible_vac, 1));
                        "Number of Days" := 0;
                        "Vacation End Date" := 0D;
                        "Last Working Date" := 0D;
                        "Resume Date" := 0D;
                    end;

                end;

                // MESSAGE('eligible vacation=%1',Eligible_vac);

            end;
        }
        field(6; "Number of Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Reason For Leave"; Text[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Cause of Absence".Code;
        }
        field(8; "Manager Approve"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; "HR Approve"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(10; "CEO Approve"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Open,Released,Pending,Approved,Rejected;
        }
        field(12; Store; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(13; "Document Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(14; "User ID"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(15; Comment; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(16; Hide; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Entry Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,AL,FS,Vacation,"Business Trip",Maternity,"Haj/Umrah",Emergency,"Paid Casual",Others,"Unpaid Leave";
        }
        field(18; "Resume Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Last Working Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Total Vacation token"; Decimal)
        {
            CalcFormula = Sum("Recorded Leave entries"."Quantity Days" WHERE("Entry Type" = FILTER("Annual Leave"),
                                                                               Employee = FIELD(Employee)));
            FieldClass = FlowField;
        }
        field(21; "Employment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Unpaid Leave"; Decimal)
        {
            CalcFormula = Sum("Recorded Leave entries"."Quantity Days" WHERE("Entry Type" = FILTER("Unpaid Leave"),
                                                                               Employee = FIELD(Employee)));
            FieldClass = FlowField;
        }
        field(23; "Grant Exception"; Boolean)
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
        "Document Date" := WorkDate;
        "User ID" := UserId;
    end;

    var
        recemployee: Record Employee;
        RecGCal: Record "Base Calendar Change";
        toth: Decimal;
        Usersetup: Record "User Setup";
        testleave: Date;
        date: Date;
        job: Record "Dimension Value";
        Rec_Cause_abs: Record "Cause of Absence";
        RH_Setup: Record "User Setup";
        Rec_Employee: Record Employee;
        recG_Recorded_paid_anuel_L: Record "Employee Vacation Request";
        Total_Leave_Taken: Decimal;
        net_days: Decimal;
        sd: Decimal;
        sy: Decimal;
        tenure: Decimal;
        Total_entitlement_Leave_Days: Decimal;
        Total_Romaining: Decimal;
        Quantity_Days: Decimal;
        Vac_Days: Decimal;
        Eligible_vac: Decimal;
}

