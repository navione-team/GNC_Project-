table 70008 "Loan & Advance"
{
    Caption = 'Loan & Advance';
    DrillDownPageID = "Employee.List";
    LookupPageID = "Employee.List";

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin

                if "No." <> xRec."No." then begin
                    HumanResSetup.Get;
                    NoSeriesMgt.TestManual(HumanResSetup."Loan&Advance No");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Employee; Code[10])
        {
            Caption = 'Employee';
            TableRelation = Employee;

            trigger OnValidate()
            begin
                Slr.Get(Employee);
                Name := Slr."Search Name";
                "Job Title" := Slr."Job Title";

                Validate("Starting Date", WorkDate);
                Validate("Posting Date", WorkDate);

            end;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            Editable = false;
        }
        field(4; "Job Title"; Text[100])
        {
            Caption = 'Job Title';
            Editable = false;
        }
        field(5; "Employee Posting Group"; Code[20])
        {
            Caption = 'Employee Posting Group';
            Editable = true;
            TableRelation = "Employee Posting Group";
        }
        field(6; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Advance,Loan,Addition';
            OptionMembers = Advance,Loan,Addition;
        }
        field(7; "Document type"; Code[10])
        {
            Caption = 'Document type';
            TableRelation = "Rec.Salary Header" WHERE("Posting Month" = FIELD(Type));

            trigger OnValidate()
            begin
                if LoanAdvanceType.Get("Document type") then begin
                    "Repayment slices" := LoanAdvanceType."Repayment slices";
                    if "Repayment slices" = 0 then
                        Validate("Repayment slices", 1);
                    "Bal. Account Type" := LoanAdvanceType."Bal. Account Type";
                    "Bal. Account No." := LoanAdvanceType."Bal. Account No.";
                    "type amortissement" := LoanAdvanceType."type amortissement";

                    //"Interest %" := LoanAdvanceType."Interest %";
                    Validate("Starting Date");
                end;
            end;
        }
        field(10; Amount; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Amount';

            trigger OnValidate()
            begin
                /*IF Slr.GET(Employee) THEN
                BEGIN
                 IF (Slr.Domicilie) THEN
                  IF  (Slr."Fin domiciliation">"Date d'effet") THEN
                    IF NOT CONFIRM(STRSUBSTNO(Text003,Slr."Fin domiciliation")) THEN
                      ERROR(STRSUBSTNO(Text002,Slr."Fin domiciliation"));
                END;*/

                "Total to repay" := Amount;
                //"Interest %" := 0;

                if "Repayment slices" > 0 then
                    "Slice Amount" := "Total to repay" / "Repayment slices"
                else
                    "Slice Amount" := "Total to repay";

                Validate("Starting Date");

            end;
        }

        field(12; "Total to repay"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Total to repay';
            Editable = false;
            InitValue = 0;
        }
        field(15; "Repayment slices"; Integer)
        {
            Caption = 'Repayment slices';

            trigger OnValidate()
            var
                DateT: Date;
            begin
                if "Repayment slices" <= 0 then
                    Error('Repayment slices <10');
                //DateT:=CALCDATE('-15J+FM+1J',"Date d'effet");
                //"Date fin Pr t":=CALCDATE(STRSUBSTNO('+%1M+FM',"Repayment slices"-1),DateT);
                //"Total to repay" := Amount + CalcMntInetret("Date d'effet","Date fin Pr t");
                Validate("Starting Date");
                if "Repayment slices" > 0 then
                    "Slice Amount" := "Total to repay" / "Repayment slices"
                else
                    "Slice Amount" := "Total to repay";
            end;
        }
        field(20; "No. Series"; Code[10])
        {
            Caption = 'Non. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(110; "Avance Sur Prime"; Boolean)
        {
        }
        field(50000; "Global dimension 1"; Code[20])
        {
            Caption = 'Code d partement';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(50001; "Global dimension 2"; Code[20])
        {
            Caption = 'Code dossier';
            Editable = false;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(50003; "Responsibility Center"; Code[20])
        {
            Caption = 'Responsibility center';
            TableRelation = "Responsibility Center";
        }
        field(50200; "Slice Amount"; Decimal)
        {
            DecimalPlaces = 3 : 3;

            trigger OnValidate()
            begin
                if ("Total to repay" mod "Slice Amount") > 0
                 then
                    "Repayment slices" := ("Total to repay" div "Slice Amount") + 1
                else
                    "Repayment slices" := "Total to repay" / "Slice Amount";
            end;
        }
        field(50400; "Posting Date"; Date)
        {
        }
        field(50500; "Starting Date"; Date)
        {

            trigger OnValidate()
            begin



                "End Date" := CalcDate(Format("Repayment slices" - 1) + 'M+CM', "Starting Date");

                if ("End Date" < "Starting Date") or ("End Date" = 0D) then
                    "End Date" := "Starting Date";
                Month := Date2DMY("Starting Date", 2);
                "Posting Year" := Date2DMY("Starting Date", 3);


            end;
        }
        field(50501; "End Date"; Date)
        {

            trigger OnValidate()
            begin
                //"Date d'effet":=CALCDATE(FORMAT(-1*"Repayment slices")+'M+DM',"Date fin Pr t");

                if "End Date" < "Starting Date" then
                    Error('Loan ending date > Starting Date');

                "Repayment slices" := CalcNbreMois;
                //Validate("Interest %");
            end;
        }
        field(50505; "External Document No"; Code[20])
        {
        }
        field(50506; "Avance Sur 13 eme"; Boolean)
        {
            Caption = 'Avance Sur 13 eme';
        }
        field(50507; "Posting Year"; Integer)
        {
            Caption = 'Posting Year';
        }

        field(70000; "User ID"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup"."User ID";
        }
        field(70001; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
        field(70002; "Bal. Account Type"; Option)
        {
            Caption = 'Bal. Account Type';
            OptionCaption = 'G/L Account,Bank Account';
            OptionMembers = "G/L Account","Bank Account";
        }
        field(70003; "Bal. Account No."; Code[10])
        {
            Caption = 'Bal. Account No.';
            TableRelation = IF ("Bal. Account Type" = FILTER("G/L Account")) "G/L Account"
            ELSE
            IF ("Bal. Account Type" = FILTER("Bank Account")) "Bank Account" WHERE("Currency Code" = FILTER(''));
        }
        field(70004; "type amortissement"; Option)
        {
            OptionCaption = 'D gressif,Lineaire,Constant';
            OptionMembers = "D gressif",Lineaire,Constant;
        }
        field(70005; Observation; Text[150])
        {
            Caption = 'Observation';
        }
        field(70006; Month; Option)
        {
            DataClassification = ToBeClassified;
            Caption = 'Posting Month';
            OptionMembers = " ",January,February,March,April,May,June,July,August,September,October,November,December;
        }
        field(70013; "EOSB Advance"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; Employee)
        {
        }
        key(Key3; Type)
        {
        }
        key(Key4; "Document type")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "No." = '' then begin
            HumanResSetup.Get();
            HumanResSetup.TestField("Loan&Advance No");
            // Assign default series and check for any previously used related series
            "No. Series" := HumanResSetup."Loan&Advance No";
            if NoSeriesMgt.AreRelated(HumanResSetup."Loan&Advance No", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            // Retrieve and assign the next document number
            "No." := NoSeriesMgt.GetNextNo("No. Series");
        end;

        "Repayment slices" := 1;

        "Last Date Modified" := WorkDate;
        "User ID" := UserId;
        // >> RTC 20/09/2013
        //VALIDATE("Date d'effet",CALCDATE('-15J+FM+1J',WORKDATE));
        //"Starting Date" := WorkDate;
        // >> RTC 20/09/2013
        "Posting Date" := WorkDate;
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

    var
        HumanResSetup: Record "Human Resources Setup";
        NoSeriesMgt: Codeunit "No. Series";
        LoanAdvance: Record "Loan & Advance";
        LoanAdvanceType: Record "Loan & Advance Type";
        Slr: Record Employee;
        err1: Label 'Error\Document type dosen''t match with the Employee Posting Group.';
        err2: Label 'Error\Unknown document type';
        Text001: Label 'Employee Blocked or Inactive';
        Text002: Label 'Ce salari  est domicil , il n''a pas le droit en une avance sur salaire ni pr t avant le %1.';
        Text003: Label 'Ce salari  est domicil , il n''a pas le droit en une avance sur salaire ni pr t avant le %1.\Voulez-vous continuer?';
        RecGLAD: Record "Rec. Loan & Advance";
        nserie: Record "No. Series Line";

    //[Scope('Internal')]
    procedure AssistEdit(Old: Record "Loan & Advance"): Boolean
    var
        NoSeries: Codeunit "No. Series";
        LoanAdvance: Record "Loan & Advance";
    begin
        LoanAdvance := Rec;
        HumanResSetup.Get();
        HumanResSetup.TestField("Loan&Advance No");
        // Open series selection dialog and update Rec."No. Series"
        if NoSeries.LookupRelatedNoSeries(
               HumanResSetup."Loan&Advance No",
               Old."No. Series",
               Rec."No. Series")
        then begin
            // Once changed, generate the next document number
            Rec."No." := NoSeries.GetNextNo(Rec."No. Series");
            Rec := LoanAdvance;
            exit(true);
        end;
        exit(false);
    end;

    // end;

    procedure CalcPretLongetCourtTerme(var CourtT: Decimal; var LongT: Decimal)
    var
        Datedeb: Date;
        DateFin: Date;
        NbrMois: Decimal;
        NBcrt: Decimal;
        Datecpta: Date;
        MntRest: Decimal;
        Mnt: Decimal;
        Mnt1: Decimal;
    begin
        Datedeb := CalcDate('-15D+CM+1D', "Starting Date");
        DateFin := CalcDate('-15D+CM', "End Date");
        if Date2DMY("Starting Date", 3) = Date2DMY("Posting Date", 3) then
            Datecpta := "Starting Date"
        else
            Datecpta := "Posting Date";
        CourtT := 0;
        MntRest := Amount;
        case Type of
            0:
                begin
                    CourtT := Amount;
                    LongT := 0;
                end;
            1:
                begin
                    if Datedeb > CalcDate('FA', Datecpta) then begin
                        LongT := Amount;
                        CourtT := 0;
                    end else
                        if DateFin <= CalcDate('FA', Datecpta) then begin
                            CourtT := Amount;
                            LongT := 0;
                        end
                        else begin
                            NbrMois := 0;

                            repeat
                                NbrMois := NbrMois + 1;
                            until CalcDate(StrSubstNo('+%1M+CM', NbrMois), Datedeb) > DateFin;
                            // Amortissement D grissif
                            case "type amortissement" of
                                //IF "type amortissement"=0 THEN BEGIN
                                0:
                                    begin
                                        NBcrt := 0;
                                        repeat
                                            if NbrMois <> 0 then begin
                                                CourtT := CourtT + Round(MntRest / (NbrMois - NBcrt), 0.001);
                                                MntRest := MntRest - Round(MntRest / (NbrMois - NBcrt), 0.001);
                                            end;
                                            NBcrt := NBcrt + 1;
                                        until CalcDate(StrSubstNo('+%1M+CM', NBcrt), Datedeb) > CalcDate('FA', Datecpta);

                                        if NbrMois <> 0 then begin
                                            //CourtT:=ROUND((NBcrt/NbrMois)*Amount,0.001);
                                            LongT := Amount - CourtT;
                                        end;
                                    end;
                                // ELSE
                                1:
                                    // Amortissement Lin aire
                                    begin
                                        NBcrt := 0;
                                        repeat
                                            if NbrMois <> 0 then
                                                NBcrt := NBcrt + 1;
                                        until CalcDate(StrSubstNo('+%1M+CM', NBcrt), Datedeb) > CalcDate('FA', Datecpta);
                                        Mnt := 0;
                                        Mnt1 := 0;
                                        if NbrMois <> 0 then
                                            Mnt := Round(Amount / NbrMois, 0.5);
                                        Mnt1 := Amount - (Mnt * (NbrMois - 1));
                                        CourtT := Round(Mnt1 + ((NBcrt - 1) * Mnt), 0.001);
                                        LongT := Amount - CourtT;
                                    end;
                                // Amortissement Constant
                                2:
                                    begin
                                        NBcrt := 0;
                                        repeat
                                            if NbrMois <> 0 then
                                                NBcrt := NBcrt + 1;
                                        until CalcDate(StrSubstNo('+%1M+CM', NBcrt), Datedeb) > CalcDate('FA', Datecpta);
                                        Mnt := 0;
                                        Mnt1 := 0;
                                        if NbrMois <> 0 then
                                            Mnt := Round(Amount / NbrMois, 0.001);
                                        Mnt1 := Amount - (Mnt * (NbrMois - 1));
                                        CourtT := Round(Mnt1 + ((NBcrt - 1) * Mnt), 0.001);
                                        LongT := Amount - CourtT;
                                    end;
                            // Fin Amortissement
                            end;
                        end;
                end;
        end;
    end;

    procedure CalcMntInetret(DateDebT: Date; DateFinT: Date) MntRet: Decimal
    var
        MontiniT: Decimal;
        DateDeb: Date;
        DateFin: Date;
        NbrMois: Decimal;
        j: Integer;
        DateJ: Date;
        Mnt: Decimal;
        Mnt1: Decimal;
    begin

        MontiniT := Amount;
        DateDeb := CalcDate('-15D+CM+1D', "Starting Date");
        DateFin := CalcDate('-15D+CM', "End Date");
        NbrMois := 0;
        repeat
            NbrMois := NbrMois + 1;
        until CalcDate(StrSubstNo('+%1M+CM', NbrMois), DateDeb) > DateFin;
        MntRet := 0;
        if (DateDebT = 0D) or (DateFinT = 0D) or (DateFinT < "Starting Date") or (DateDebT > "End Date")
             or ("Starting Date" = "End Date") then
            exit;
        DateDebT := CalcDate('-15D+CM+1D', DateDebT);
        DateFinT := CalcDate('-15D+CM', DateFinT);
        DateJ := DateDeb;
        // Amortissement D grissif
        case "type amortissement" of
            //IF "type amortissement"=0 THEN
            0:
                begin
                    j := -1;
                    repeat
                        j := j + 1;
                        if DateDebT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb) then
                            MntRet := MntRet;// + Round(((MontiniT * "Interest %") / 1200), 0.001);
                        if (NbrMois - j) <> 0 then
                            MontiniT := MontiniT - Round((MontiniT / (NbrMois - j)), 0.001);
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) or
                       (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));
                end;
            //ELSE
            // Amortissement Lin aire
            1:
                begin
                    j := -1;
                    repeat
                        j := j + 1;

                        //IF DateDebT<=CALCDATE(STRSUBSTNO('+%1M+FM',j),DateDeb) THEN
                        MntRet := MntRet; //+ Round(((MontiniT * "Interest %") / 1200), 0.001);
                        if (NbrMois - j) <> 0 then
                            MontiniT := MontiniT - Round((MontiniT / (NbrMois - j)), 0.001);
                    until (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));

                    Mnt := Round(MntRet / NbrMois, 0.5, '<');
                    Mnt1 := MntRet - (Mnt * (NbrMois - 1));
                    j := -1;
                    MntRet := 0;
                    repeat
                        j := j + 1;
                        if (DateDebT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) then
                            if (CalcDate('+CM', DateDebT) = CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) and (j = 0) then
                                MntRet := MntRet + Mnt1
                            else
                                MntRet := MntRet + Mnt;
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) or
                       (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));

                end;
            // Amortissement Constant
            2:
                begin
                    j := -1;
                    repeat
                        j := j + 1;

                        //IF DateDebT<=CALCDATE(STRSUBSTNO('+%1M+FM',j),DateDeb) THEN
                        MntRet := MntRet;//+ Round(((MontiniT * "Interest %") / 1200), 0.001);
                        if (NbrMois - j) <> 0 then
                            MontiniT := MontiniT - Round((MontiniT / (NbrMois - j)), 0.001);
                    until (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));

                    Mnt := Round(MntRet / NbrMois, 0.001);
                    Mnt1 := MntRet - (Mnt * (NbrMois - 1));
                    j := -1;
                    MntRet := 0;
                    repeat
                        j := j + 1;
                        if (DateDebT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) then
                            if (CalcDate('+CM', DateDebT) = CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) and (j = 0) then
                                MntRet := MntRet + Mnt1
                            else
                                MntRet := MntRet + Mnt;
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) or
                       (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));
                end;
        end;
    end;

    //[Scope('Internal')]
    procedure CalcNbreMois() NbrMois: Integer
    var
        DateDeb: Date;
        DateFin: Date;
    begin
        DateDeb := CalcDate('-15D+CM+1D', "Starting Date");
        DateFin := CalcDate('-15D+CM', "End Date");
        NbrMois := 0;
        repeat
            NbrMois := NbrMois + 1;
        until CalcDate(StrSubstNo('+%1M+CM', NbrMois - 1), DateDeb) > DateFin;
    end;
}

