table 70009 "Rec. Loan & Advance"
{

    Caption = 'Loan & Advance Header';
    DrillDownPageID = "Hiring Request";
    LookupPageID = "Hiring Request";

    fields
    {
        field(1; "No."; Code[10])
        {
            Caption = 'No.';
            Editable = true;

            trigger OnValidate()
            begin
                /*IF "No." <> xRec."No." THEN BEGIN
                  HumanResSetup.GET;
                  NoSeriesMgt.TestManual(HumanResSetup."Loan & Advance Nos.");
                  "No. Series" := '';
                END;*/

            end;
        }
        field(2; Employee; Code[10])
        {
            Caption = 'Employee';
            TableRelation = Employee;

            trigger OnValidate()
            begin
                Slr.Get(Employee);
                Name := Slr."Full Name" + ' ' + Slr."Last Name";
                "Job Title" := Slr."Job Title";
                "Employee Posting Group" := Slr."Employee Posting Group";
                Status := Status::"In progress";
                "Global dimension 1" := Slr."Global Dimension 2 Code";
                Slr.Get(Employee);
                Slr.TestField(Status, Slr.Status::Active);

                /*IF Slr.Blocked = TRUE THEN
                        ERROR (Text001);*/

                if Slr.Status = Slr.Status::Inactive then
                    Error(Text001);

            end;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(4; "Job Title"; Text[100])
        {
            Caption = 'Job Title';
        }
        field(5; "Employee Posting Group"; Code[10])
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
            // TableRelation = Table50010;
        }
        field(10; Amount; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Amount';
        }
        field(11; "Interest %"; Decimal)
        {
            Caption = 'Interest %';
            Editable = true;
        }
        field(12; "Total to repay"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Total to repay';
            InitValue = 0;
        }
        field(15; "Repayment slices"; Integer)
        {
            Caption = 'Repayment slices';
            Editable = true;

            trigger OnValidate()
            begin
                EtablirEcheancier("No.", "Start Date", "End Date", "Montant tranche", "Repayment slices", 0);
                Timeline.Reset;
                Timeline.SetRange("N° Loan", "No.");
                if Timeline.FindSet then
                    repeat
                        Timeline.Employee := Employee;
                        Timeline.Modify;
                    until Timeline.Next = 0;
            end;
        }
        field(20; "No. Series"; Code[10])
        {
            Caption = 'Non. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(25; "Document Date"; Date)
        {
            Caption = 'Document Date';
            Editable = true;
        }
        field(30; "Repaiment lines"; Integer)
        {
            CalcFormula = Count("Loan & Advance Lines" WHERE("No." = FIELD("No."),
                                                              Paid = FILTER(true)));
            Caption = 'Repaiment lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31; "Paid amount"; Decimal)
        {
            CalcFormula = Sum("L&A Installment Schedule".Slice WHERE("Payment No" = FILTER(<> ''),
                                                                      "N° Loan" = FIELD("No.")));
            Caption = 'Repaid amount';
            DecimalPlaces = 3 : 3;
            Editable = true;
            FieldClass = FlowField;
        }
        field(32; "Repaid %"; Decimal)
        {
            Caption = 'Repaid %';
            Editable = false;
            ExtendedDatatype = Ratio;
        }
        field(33; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'In progress,Closed,Holded';
            OptionMembers = "In progress",Closed,Holded;
        }
        field(50; "Principal Amount"; Decimal)
        {
            AutoFormatType = 2;


            Caption = 'Montant Principale';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Sum("Loan & Advance Lines"."Line Amount" WHERE("No." = FIELD("No."), Employee = FIELD(Employee), Type = FIELD(Type), Status = FIELD(Status)));
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
        field(50200; "Montant tranche"; Decimal)
        {
            DecimalPlaces = 3 : 3;
        }
        field(50400; "Posting Date"; Date)
        {
        }
        field(50500; "Start Date"; Date)
        {

            trigger OnValidate()
            begin
                if Type = Type::Advance then begin
                    Month := Date2DMY("Start Date", 2);
                    Year := Date2DMY("Start Date", 3);
                end;
            end;
        }
        field(50501; "End Date"; Date)
        {
        }
        field(50505; "N  document Extr."; Code[20])
        {
        }
        field(70000; "User ID"; Code[50])
        {
            Editable = false;
            TableRelation = User;
        }
        field(70001; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = true;
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
            OptionMembers = " ",January,February,March,April,May,June,July,August,September,October,November,December;
        }
        field(70007; Year; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(70008; Checked; Boolean)
        {
            CalcFormula = Exist("Salary Line" WHERE(Advance = FILTER(> 0),
                                                     Employee = FIELD(Employee),
                                                     "Posting Month" = FIELD(Month),
                                                     "Posting Year" = FIELD(Year)));
            FieldClass = FlowField;
        }
        field(70009; "Payment No"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Type = Type::Advance then begin
                    Paid := true;
                    "Repaiment lines" := 100;
                    Status := Status::Closed
                end;
                if Type = Type::Loan then begin
                    CalcFields("Loan Paid Amount");
                    //  "Repaiment lines":=("Loan Paid Amount"/Amount)*100;ROUND ((No*100) MOD 10, 1,  = );
                    "Repaiment lines" := Round((1 * ("Loan Paid Amount") mod Amount * 100), 1, '=');

                    if "Loan Paid Amount" = Amount then
                        Status := Status::Closed

                end;
            end;
        }
        field(70010; Paid; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(70011; "Loan Paid Amount"; Decimal)
        {
            CalcFormula = Sum("L&A Installment Schedule".Slice WHERE("Payment No" = FILTER(<> ''),
                                                                      "N° Loan" = FIELD("No."),
                                                                      Employee = FIELD(Employee)));
            FieldClass = FlowField;
        }
        field(70012; "Remaining Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
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
        key(Key2; Employee, "Employee Posting Group")
        {
            SumIndexFields = Amount;
        }
        key(Key3; Type)
        {
        }
        key(Key4; "Document type")
        {
        }
        key(Key5; Status)
        {
        }
        key(Key6; Employee, Type, Status, "No.")
        {
        }
        key(Key7; "Posting Date", "No.")
        {
        }
        key(Key8; Employee, Status, Type)
        {
            SumIndexFields = Amount;
        }
        key(Key9; Employee)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        RecLLoanEntry: Record "Loan & Advance Lines";
    begin
        RecLLoanEntry.SetRange(RecLLoanEntry."No.", "No.");
        RecLLoanEntry.DeleteAll;
    end;

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            HumanResSetup.Get();
            HumanResSetup.TestField("Loan&Advance No");

            // Assign the default series code
            "No. Series" := HumanResSetup."Loan&Advance No";
            // Retain previously used series if it's still related
            if NoSeries.AreRelated(HumanResSetup."Loan&Advance No", xRec."No. Series") then
                "No. Series" := xRec."No. Series";

            // Generate and assign the next available number
            "No." := NoSeries.GetNextNo("No. Series", WorkDate());
        end;

        "Last Date Modified" := WorkDate;
        "User ID" := UserId;
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
        Slr: Record Employee;
        Text001: Label 'Salari  Bloqu  ou Indisponible';
        HumanResSetup: Record "Human Resources Setup";
        NoSeriesMgt: Codeunit "No. Series";
        LoanAdvanceHeader: Record "Rec. Loan & Advance";
        emp: Code[20];
        Timeline: Record "L&A Installment Schedule";

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
        Datedeb := CalcDate('-15D+CM+1D', "Start Date");
        DateFin := CalcDate('-15D+CM', "End Date");
        if Date2DMY("Start Date", 3) = Date2DMY("Posting Date", 3) then
            Datecpta := "Start Date"
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
                                0:
                                    begin
                                        // IF "type amortissement"=0 THEN BEGIN
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
                                1:
                                    begin
                                        // ELSE BEGIN
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
                            end;
                        end;
                end;
        end;
    end;

    procedure CalcMntInetretaPaye(DateDebT: Date; DateFinT: Date) MntRet: Decimal
    var
        MontiniT: Decimal;
        DateDeb: Date;
        DateFin: Date;
        NbrMois: Decimal;
        j: Integer;
        DateJ: Date;
    begin

        MontiniT := Amount;
        DateDeb := CalcDate('-15D+CM+1D', "Start Date");
        DateFin := CalcDate('-15D+CM', "End Date");
        NbrMois := 0;
        repeat
            NbrMois := NbrMois + 1;
        until CalcDate(StrSubstNo('+%1M+CM', NbrMois - 1), DateDeb) > DateFin;
        MntRet := 0;
        if (DateDebT = 0D) or (DateFinT = 0D) or (DateFinT < "Start Date") or (DateDebT > "End Date")
             or ("Start Date" = "End Date") then
            exit;
        DateDebT := CalcDate('-15D+CM+1D', DateDebT);
        DateFinT := CalcDate('-15D+CM', DateFinT);
        DateJ := DateDeb;
        j := -1;
        repeat
            j := j + 1;

            if DateDebT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb) then
                MntRet := MntRet + Round(((MontiniT * "Interest %") / 1200), 0.001);
            if (NbrMois - j) <> 0 then
                MontiniT := MontiniT - Round((MontiniT / (NbrMois - j)), 0.001);
        until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) or
           (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));
    end;


    procedure CalcMnPrinciPeriode(DateDebT: Date; DateFinT: Date) MntPrin: Decimal
    var
        MontiniT: Decimal;
        DateDeb: Date;
        DateFin: Date;
        NbrMois: Decimal;
        j: Integer;
        DateJ: Date;
        Mnt1: Decimal;
        Mnt: Decimal;
    begin
        MontiniT := Amount;
        DateDeb := CalcDate('-15D+CM+1D', "Start Date");
        DateFin := CalcDate('-15D+CM', "End Date");
        NbrMois := 0;
        repeat
            NbrMois := NbrMois + 1;
        until CalcDate(StrSubstNo('+%1M+CM', NbrMois), DateDeb) > DateFin;
        MntPrin := 0;
        if (DateDebT = 0D) or (DateFinT = 0D) or (DateFinT < "Start Date") or (DateDebT > "End Date")
             or ("Start Date" = "End Date") then
            exit;
        DateDebT := CalcDate('-15D+CM+1D', DateDebT);
        DateFinT := CalcDate('-15D+CM', DateFinT);
        DateJ := DateDeb;
        // Amortissement D gressif
        case "type amortissement" of
            0:
                begin
                    j := -1;
                    repeat
                        j := j + 1;
                        if DateDebT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb) then
                            MntPrin := MntPrin + Round((MontiniT / (NbrMois - j)), 0.001);
                        if (NbrMois - j) <> 0 then
                            MontiniT := MontiniT - Round((MontiniT / (NbrMois - j)), 0.001);
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) or
                          (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));
                end;
            1:
                begin
                    MntPrin := 0;
                    Mnt := 0;
                    Mnt1 := 0;
                    if NbrMois <> 0 then
                        Mnt := Round(MontiniT / NbrMois, 0.5);
                    Mnt1 := MontiniT - (Mnt * (NbrMois - 1));
                    j := -1;
                    repeat
                        j := j + 1;
                        if (DateDebT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) then
                            if (CalcDate('+FM', DateDebT) = CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) and (j = 0) then
                                MntPrin := MntPrin + Mnt1
                            else
                                MntPrin := MntPrin + Mnt;
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) or
                          (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));
                end;
            2:
                begin
                    MntPrin := 0;
                    Mnt := 0;
                    Mnt1 := 0;
                    if NbrMois <> 0 then
                        Mnt := Round(MontiniT / NbrMois, 0.001);
                    Mnt1 := MontiniT - (Mnt * (NbrMois - 1));
                    j := -1;
                    repeat
                        j := j + 1;
                        if (DateDebT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) then
                            if (CalcDate('+FM', DateDebT) = CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) and (j = 0) then
                                MntPrin := MntPrin + Mnt1
                            else
                                MntPrin := MntPrin + Mnt;
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) or
                          (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));
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
        DateDeb := CalcDate('-15D+CM+1D', "Start Date");
        DateFin := CalcDate('-15D+CM', "End Date");
        NbrMois := 0;
        repeat
            NbrMois := NbrMois + 1;
        until CalcDate(StrSubstNo('+%1M+CM', NbrMois), DateDeb) > DateFin;
        MntRet := 0;
        if (DateDebT = 0D) or (DateFinT = 0D) or (DateFinT < "Start Date") or (DateDebT > "End Date")
             or ("Start Date" = "End Date") then
            exit;
        DateDebT := CalcDate('-15D+CM+1D', DateDebT);
        DateFinT := CalcDate('-15D+CM', DateFinT);
        DateJ := DateDeb;
        // Amortissement D gressif
        case "type amortissement" of
            0:
                begin
                    // IF "type amortissement"=0 THEN BEGIN
                    j := -1;
                    repeat
                        j := j + 1;
                        if DateDebT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb) then
                            MntRet := MntRet + Round(((MontiniT * "Interest %") / 1200), 0.001);
                        if (NbrMois - j) <> 0 then
                            MontiniT := MontiniT - Round((MontiniT / (NbrMois - j)), 0.001);
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) or
                       (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));
                end;
            1:
                begin
                    // ELSE BEGIN
                    j := -1;
                    repeat
                        j := j + 1;

                        //IF DateDebT<=CALCDATE(STRSUBSTNO('+%1M+FM',j),DateDeb) THEN
                        MntRet := MntRet + Round(((MontiniT * "Interest %") / 1200), 0.001);
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
            2:
                begin
                    j := -1;
                    repeat
                        j := j + 1;

                        //IF DateDebT<=CALCDATE(STRSUBSTNO('+%1M+FM',j),DateDeb) THEN
                        MntRet := MntRet + Round(((MontiniT * "Interest %") / 1200), 0.001);
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


    procedure CalcNbreMois() NbrMois: Integer
    var
        DateDeb: Date;
        DateFin: Date;
    begin
        DateDeb := CalcDate('-15DJ+CM+1D', "Start Date");
        DateFin := CalcDate('-15D+CM', "End Date");
        NbrMois := 0;
        repeat
            NbrMois := NbrMois + 1;
        until CalcDate(StrSubstNo('+%1M+CM', NbrMois), DateDeb) > DateFin;
    end;


    procedure CalcMntInetretAvPrime(DateFinT: Date) MntRet: Decimal
    var
        MontiniT: Decimal;
        DateDeb: Date;
        DateFin: Date;
        NbrMois: Decimal;
        j: Integer;
        DateJ: Date;
        Mnt: Decimal;
        Mnt1: Decimal;
        LignePret: Record "Loan & Advance Lines";
        LignePretTmp: Record "Loan & Advance Lines";
    begin
        LignePret.Reset;
        LignePret.SetCurrentKey("No.", Status, Type, Employee, Paid);
        LignePret.SetFilter("No.", "No.");
        //   LignePret.SETRANGE(Status, "Global dimension 1");
        LignePret.SetRange(Type, Type);
        LignePret.SetFilter(Employee, Employee);
        LignePret.SetRange(Paid, true);
        LignePret.CalcSums("Principal Amount");
        MntRet := 0;
        if (DateFinT = 0D) then
            Error('Check Effective Date or Interest Calculation Date !!!');
        MontiniT := Amount - LignePret."Principal Amount";

        LignePretTmp.Reset;
        LignePretTmp.SetCurrentKey("No.", Status, Type, Employee, Paid);
        LignePretTmp.SetFilter("No.", "No.");
        //  LignePretTmp.SETRANGE(Status, "Global dimension 1");
        LignePretTmp.SetRange(Type, Type);
        LignePretTmp.SetFilter(Employee, Employee);
        LignePretTmp.SetRange(Paid, true);
        if LignePretTmp.Find('+') then
            DateDeb := LignePretTmp."Payroll Date"
        else
            DateDeb := "Start Date";

        MntRet := (MontiniT * ("Interest %" / 100) * (DateFinT - DateDeb)) / 365;
    end;

    //[Scope('Internal')]
    procedure CalcMnPRincipaleRemb() MntRest: Decimal
    var
        MontiniT: Decimal;
        DateDeb: Date;
        DateFin: Date;
        NbrMois: Decimal;
        j: Integer;
        DateJ: Date;
        Mnt: Decimal;
        Mnt1: Decimal;
        LignePret: Record "Loan & Advance Lines";
    begin
        LignePret.Reset;
        LignePret.SetCurrentKey("No.", Status, Type, Employee, Paid);
        LignePret.SetFilter("No.", "No.");
        //  LignePret.SETRANGE(Status, "Global dimension 1");
        LignePret.SetRange(Type, Type);
        LignePret.SetFilter(Employee, Employee);
        LignePret.SetRange(Paid, true);
        LignePret.CalcSums("Principal Amount");
        MntRest := 0;
        MntRest := Amount - LignePret."Principal Amount";
        //MESSAGE('MntRest %1',MntRest);
    end;

    //[Scope('Internal')]
    procedure CalcMntInetretEng(DateFinT: Date) MntRet: Decimal
    var
        MontiniT: Decimal;
        DateDeb: Date;
        DateFin: Date;
        NbrMois: Decimal;
        j: Integer;
        DateJ: Date;
        Mnt: Decimal;
        Mnt1: Decimal;
        LignePret: Record "Loan & Advance Lines";
        LignePretTmp: Record "Loan & Advance Lines";
    begin
        LignePret.Reset;
        LignePret.SetCurrentKey("No.", Status, Type, Employee, Paid);
        LignePret.SetFilter("No.", "No.");
        //  LignePret.SETRANGE(Status, "Global dimension 1");
        LignePret.SetRange(Type, Type);
        LignePret.SetFilter(Employee, Employee);
        LignePret.SetRange(Paid, true);
        LignePret.CalcSums("Principal Amount");
        MntRet := 0;
        if (DateFinT = 0D) then
            Error('Check Effective Date or Interest Calculation Date !!!');
        MontiniT := Amount - LignePret."Principal Amount";

        LignePretTmp.Reset;
        LignePretTmp.SetCurrentKey("No.", Status, Type, Employee, Paid);
        LignePretTmp.SetFilter("No.", "No.");
        //  LignePretTmp.SETRANGE(Status, "Global dimension 1");
        LignePretTmp.SetRange(Type, Type);
        LignePretTmp.SetFilter(Employee, Employee);
        LignePretTmp.SetRange(Paid, true);
        if LignePretTmp.Find('+') then
            DateDeb := LignePretTmp."Payroll Date"
        else
            DateDeb := "Start Date";

        MntRet := (MontiniT * ("Interest %" / 100) * (DateFinT - DateDeb)) / 365;
    end;

    //[Scope('Internal')]
    procedure CalcMnPrinciPeriodeeng(DateDebT: Date; DateFinT: Date) MntPrin: Decimal
    var
        MontiniT: Decimal;
        DateDeb: Date;
        DateFin: Date;
        NbrMois: Decimal;
        j: Integer;
        DateJ: Date;
        Mnt1: Decimal;
        Mnt: Decimal;
        LignePret: Record "Loan & Advance Lines";
    begin
        LignePret.Reset;
        LignePret.SetCurrentKey("No.", Status, Type, Employee, Paid);
        LignePret.SetFilter("No.", "No.");
        //   LignePret.SETRANGE(Status, "Global dimension 1");
        LignePret.SetRange(Type, Type);
        LignePret.SetFilter(Employee, Employee);
        LignePret.SetRange(Paid, true);
        LignePret.CalcSums("Principal Amount");
        MontiniT := Round(Amount - LignePret."Principal Amount", 0.001);

        //MESSAGE('MontiniT  %1',MontiniT);
        DateDeb := CalcDate('-CM+1D', "Start Date");//kka27D+
        DateFin := CalcDate('+CM', "End Date");//kka-27D
        NbrMois := "Repayment slices" - LignePret.Count;
        MntPrin := 0;
        if (DateDebT = 0D) or (DateFinT = 0D) or (NbrMois = 0) or (MontiniT = 0) or (DateDebT >= DateFinT)
          or (DateDeb >= DateFinT) then
            exit;
        DateDebT := CalcDate('-CM+1D', DateDebT);//kka27D+
        DateFinT := CalcDate('+CM', DateFinT);//-27D
        DateJ := DateDeb;
        // Amortissement D gressif
        case "type amortissement" of
            0:
                begin
                    //IF "type amortissement"=0 THEN BEGIN
                    j := -1;
                    repeat
                        j := j + 1;

                        if (NbrMois - j) <> 0 then
                            if ControlValiditee("No.", Type, Date2DMY(DateFinT, 3), Date2DMY(DateFinT, 2)) then
                                MntPrin := MntPrin + Round((MontiniT / (NbrMois - j)), 0.001);

                        if (NbrMois - j) <> 0 then
                            if ControlValiditee("No.", Type, Date2DMY(DateFinT, 3), Date2DMY(DateFinT, 2)) then
                                MontiniT := MontiniT - Round((MontiniT / (NbrMois - j)), 0.001);
                    //MESSAGE('NbrMois %1', NbrMois - j);
                    //MESSAGE('MontiniT 2    %1',MontiniT);
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDebT));

                end;
            1:
                begin
                    //ELSE BEGIN
                    MntPrin := 0;
                    Mnt := 0;
                    Mnt1 := 0;
                    if NbrMois <> 0 then
                        Mnt := Round(MontiniT / NbrMois, 0.5);
                    Mnt1 := MontiniT - (Mnt * (NbrMois - 1));
                    j := -1;
                    repeat
                        j := j + 1;

                        // IF (DateDebT<=CALCDATE(STRSUBSTNO('+%1M+FM',j),DateDeb))  THEN
                        if (LignePret.Count = 0) and (j = 0) then begin

                            if ControlValiditee("No.", Type, Date2DMY(DateFinT, 3), Date2DMY(DateFinT, 2)) then
                                MntPrin := MntPrin + Mnt1;
                        end
                        else
                            if ControlValiditee("No.", Type, Date2DMY(DateFinT, 3), Date2DMY(DateFinT, 2)) then
                                MntPrin := MntPrin + Mnt;
                    //MESSAGE('MntPrin 2    %1',MntPrin);
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDebT));
                end;
            2:
                begin
                    MntPrin := 0;
                    Mnt := 0;
                    Mnt1 := 0;
                    if NbrMois <> 0 then
                        Mnt := Round(MontiniT / NbrMois, 0.001);
                    Mnt1 := MontiniT - (Mnt * (NbrMois - 1));
                    j := -1;
                    repeat
                        j := j + 1;

                        //IF (DateDebT<=CALCDATE(STRSUBSTNO('+%1M+FM',j),DateDeb))  THEN
                        if (LignePret.Count = 0) and (j = 0) then begin

                            if ControlValiditee("No.", Type, Date2DMY(DateFinT, 3), Date2DMY(DateFinT, 2)) then
                                MntPrin := MntPrin + Mnt1;
                        end
                        else
                            if ControlValiditee("No.", Type, Date2DMY(DateFinT, 3), Date2DMY(DateFinT, 2)) then
                                MntPrin := MntPrin + Mnt;
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDebT));
                end;
        end;
    end;

    //[Scope('Internal')]
    procedure CalcMntInetretEng1(DateDebT: Date; DateFinT: Date) MntRet: Decimal
    var
        MontiniT: Decimal;
        DateDeb: Date;
        DateFin: Date;
        NbrMois: Decimal;
        j: Integer;
        DateJ: Date;
        Mnt: Decimal;
        Mnt1: Decimal;
        LignePret: Record "Loan & Advance Lines";
    begin
        LignePret.Reset;
        LignePret.SetCurrentKey("No.", Status, Type, Employee, Paid);
        LignePret.SetFilter("No.", "No.");
        //  LignePret.SETRANGE(Status, "Global dimension 1");
        LignePret.SetRange(Type, Type);
        LignePret.SetFilter(Employee, Employee);
        LignePret.SetRange(Paid, true);
        LignePret.CalcSums("Principal Amount");
        MontiniT := Round(Amount - LignePret."Principal Amount", 0.001);

        DateDeb := CalcDate('-27D+CM+1D', "Start Date");
        DateFin := CalcDate('-27D+CM', "End Date");
        NbrMois := 0;
        NbrMois := "Repayment slices" - LignePret.Count;

        MntRet := 0;
        if (DateDebT = 0D) or (DateFinT = 0D) or (NbrMois = 0) or (MontiniT = 0) or (DateDebT >= DateFinT)
        or (DateDeb >= DateFinT) then
            exit;

        DateDebT := CalcDate('-27D+CM+1d', DateDebT);
        DateFinT := CalcDate('-27D+CM', DateFinT);
        DateJ := DateDeb;
        // Amortissement D gressif
        case "type amortissement" of
            0:
                begin
                    // IF "type amortissement"=0 THEN BEGIN
                    j := -1;
                    repeat
                        j := j + 1;
                        //IF DateDebT<=CALCDATE(STRSUBSTNO('+%1M+FM',j),DateDeb) THEN
                        MntRet := MntRet + Round(((MontiniT * "Interest %") / 1200), 0.001);
                        if (NbrMois - j) <> 0 then
                            MontiniT := MontiniT - Round((MontiniT / (NbrMois - j)), 0.001);
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDebT));
                    //(DateFin<=CALCDATE(STRSUBSTNO('+%1M+FM',j),DateDeb));
                end;
            1:
                begin
                    // ELSE BEGIN
                    j := -1;
                    repeat
                        j := j + 1;

                        //IF DateDebT<=CALCDATE(STRSUBSTNO('+%1M+FM',j),DateDeb) THEN
                        MntRet := MntRet + Round(((MontiniT * "Interest %") / 1200), 0.001);
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
                            if (CalcDate('+FM', DateDebT) = CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) and (j = 0) then
                                MntRet := MntRet + Mnt1
                            else
                                MntRet := MntRet + Mnt;
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) or
                       (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));

                end;
            2:
                begin
                    j := -1;
                    repeat
                        j := j + 1;

                        //IF DateDebT<=CALCDATE(STRSUBSTNO('+%1M+FM',j),DateDeb) THEN
                        MntRet := MntRet + Round(((MontiniT * "Interest %") / 1200), 0.001);
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
                            if (CalcDate('+FM', DateDebT) = CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) and (j = 0) then
                                MntRet := MntRet + Mnt1
                            else
                                MntRet := MntRet + Mnt;
                    until (DateFinT <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb)) or
                       (DateFin <= CalcDate(StrSubstNo('+%1M+CM', j), DateDeb));

                end;

        end;
    end;


    procedure ControlValiditee(CodLNumPret: Code[20]; IntLType: Integer; IntLAnnee: Integer; IntLMois: Integer) BooLValide: Boolean
    var
        RecLTableEcheancier: Record "L&A Installment Schedule";
    begin
        //BooLValide:=TRUE;
        if Type = 1 then begin
            if RecLTableEcheancier.Get(CodLNumPret, 0, IntLAnnee, IntLMois) then begin
                BooLValide := RecLTableEcheancier.Valid;
                RecLTableEcheancier.Check := true;
                RecLTableEcheancier.Modify;
            end;
        end;
        if Type = 0 then
            BooLValide := true;//>><<ALH 22.02.19

        // BEGIN
        //   IF RecLTableEcheancier.GET(CodLNumPret,1,IntLAnnee,IntLMois) THEN BEGIN
        //      BooLValide:=RecLTableEcheancier.Valide;
        //      RecLTableEcheancier.Marque:=TRUE;
        //      RecLTableEcheancier.MODIFY;
        //   END;
        // END;
        //>><<COMMENTED BY ALH 22.02.19
    end;


    procedure EtablirEcheancier(CodLNumPret: Code[20]; DatLStart: Date; DatLEnd: Date; DecLAmount: Decimal; IntLNumTranche: Integer; IntLType: Integer)
    var
        RecLTableEcheancier: Record "L&A Installment Schedule";
        i: Integer;
    begin
        RecLTableEcheancier.SetRange(RecLTableEcheancier."N° Loan", CodLNumPret);

        if not RecLTableEcheancier.Find('-') then begin
            RecLTableEcheancier.Reset;
            while (i < IntLNumTranche)
            do begin
                RecLTableEcheancier.Init;

                i := i + 1;
                RecLTableEcheancier.Validate("N° Loan", CodLNumPret);
                RecLTableEcheancier.Year := Date2DMY(DatLStart, 3);
                RecLTableEcheancier.Month := Date2DMY(DatLStart, 2);
                RecLTableEcheancier.Slice := DecLAmount;
                RecLTableEcheancier.Valid := true;
                RecLTableEcheancier.Type := IntLType;
                RecLTableEcheancier."Slice Nbr" := IntLNumTranche;
                RecLTableEcheancier.Employee := emp;
                RecLTableEcheancier.Insert;
                DatLStart := CalcDate('+1M', DatLStart);
            end;
        end
        else begin
            repeat
                RecLTableEcheancier.Delete;
            until RecLTableEcheancier.Next = 0;

            while (i <= IntLNumTranche)
            do begin
                RecLTableEcheancier.Init;
                i := i + 1;
                RecLTableEcheancier.Validate("N° Loan", CodLNumPret);
                RecLTableEcheancier.Year := Date2DMY(DatLStart, 3);
                RecLTableEcheancier.Month := Date2DMY(DatLStart, 2);
                RecLTableEcheancier.Slice := DecLAmount;
                RecLTableEcheancier.Valid := true;
                RecLTableEcheancier.Type := IntLType;
                RecLTableEcheancier."Slice Nbr" := IntLNumTranche;
                RecLTableEcheancier.Employee := emp;
                RecLTableEcheancier.Insert;
                DatLStart := CalcDate('+1M', DatLStart);
            end;
        end;
    end;


    procedure AssistEdit(OldLoanAdvanceHeader: Record "Rec. Loan & Advance"): Boolean
    var
        NoSeries: Codeunit "No. Series";
        LoanAdvanceHeader: Record "Rec. Loan & Advance";
    begin
        LoanAdvanceHeader := Rec;
        HumanResSetup.Get();
        HumanResSetup.TestField("Loan&Advance No");

        // Show series-selection dialog and update Rec."No. Series" if the user selects a series
        if NoSeries.LookupRelatedNoSeries(
               HumanResSetup."Loan&Advance No",
               OldLoanAdvanceHeader."No. Series",
               Rec."No. Series")
        then begin
            // Generate the next number for the selected series
            Rec."No." := NoSeries.GetNextNo(Rec."No. Series");

            Rec := LoanAdvanceHeader;
            exit(true);
        end;
        exit(false);
    end;

}

