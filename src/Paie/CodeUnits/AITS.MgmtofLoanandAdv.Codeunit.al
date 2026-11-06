codeunit 70000 "Mgmt. of Loans and Advances"
{

    trigger OnRun()
    begin
    end;

    var
        errValidate: Label 'Validation interrupted. Task canceled.';

    procedure "MntRemboursé"(LoanAdvanceHeader: Record "Rec. Loan & Advance"): Decimal
    begin
        //LoanAdvanceHeader.CALCFIELDS("Repaid amount");
        exit(LoanAdvanceHeader."Paid amount");
    end;

    //[Scope('Internal')]
    procedure "CréerLigneRembourcement"(var SalaryLineTmp: Record "Salary Line")
    var
        RecLLoanAdvanceHeader: Record "Rec. Loan & Advance";
        RecLLoanAdvanceLines: Record "Loan & Advance Lines";
        RecLLALines: Record "Loan & Advance Lines";
        RecLExistLoanAdvanceLine: Record "Loan & Advance Lines";
        RecLEmployee: Record Employee;
        DateD: Date;
        DateF: Date;
        RecLLoanAD: Record "Rec. Loan & Advance";
        DecLMnt: Decimal;
        DecLMntTmp: Decimal;
        RecLEntSal: Record "Salary Header";
    begin
        if SalaryLineTmp."Posting Month" <= 12 then  // IF SalaryLineTmp.Month<12 THEN
         begin                          //  DATE NON DEFINI NE PEUT PAS ETRE UTILISE DANS DES CALCULLES HORAIRES
                                        //  DateD:=DMY2DATE(1,SalaryLineTmp."Posting Month",SalaryLineTmp."Posting Year");//kka
            DateF := CalcDate('CM', DateD);
        end
        else begin
            RecLEntSal.Reset;
            RecLEntSal.SetCurrentKey("Posting Year", "Posting Month", No);
            //  RecLEntSal.SETRANGE("Posting Year",SalaryLineTmp."Posting Year");
            RecLEntSal.SetFilter("Posting Month", '%1..%2', 1, 12);  // RecLEntSal.SETFILTER(Month,'%1..%2',0,12);
            if RecLEntSal.Find('-') then;               // DATE NON DEFINI NE PEUT PAS ETRE UTILISE DANS DES CALCULLES HORAIRES
                                                        //   DateD:=DMY2DATE(1,DATE2DMY(SalaryLineTmp."Posting Date",2),SalaryLineTmp."Posting Year");kka
            DateF := CalcDate('CM', DateD);
        end;
        SalaryLineTmp.Loan := 0;
        SalaryLineTmp.Advance := 0;
        RecLLoanAdvanceLines.Reset;
        RecLLoanAdvanceLines.SetCurrentKey("Payment No.", Paid, Employee);
        RecLLoanAdvanceLines.SetFilter("Payment No.", SalaryLineTmp."Document No.");
        RecLLoanAdvanceLines.SetRange(Paid, false);
        RecLLoanAdvanceLines.SetFilter(Employee, SalaryLineTmp.Employee);
        RecLLoanAdvanceLines.DeleteAll;
        if SalaryLineTmp."Posting Month" < 12 then begin
            RecLLoanAD.Reset;
            RecLLoanAD.SetCurrentKey(Employee, Type, Status, "No.", "Avance Sur Prime");
            RecLLoanAD.SetFilter(Employee, SalaryLineTmp.Employee);
            RecLLoanAD.SetRange(Type, RecLLoanAD.Type::Loan);
            RecLLoanAD.SetRange(Status, RecLLoanAD.Status::"In progress");
            //  RecLLoanAD.SETRANGE("Not include",FALSE);
            RecLLoanAD.SetRange("Avance Sur Prime", false);
            if RecLLoanAD.Find('-') then
                repeat
                    if calcSolde(RecLLoanAD, SalaryLineTmp) then begin
                        SalaryLineTmp.Loan := SalaryLineTmp.Loan + Round(RecLLoanAD.CalcMnPrinciPeriodeeng(DateD, DateF), 0.001) +
                                             Round(RecLLoanAD.CalcMntInetretEng1(DateD, DateF), 0.001);
                        if (Round(RecLLoanAD.CalcMnPrinciPeriodeeng(DateD, DateF), 0.001) <> 0) or
                        (Round(RecLLoanAD.CalcMntInetretEng1(DateD, DateF), 0.001) <> 0) then
                            InsererLigne(SalaryLineTmp, RecLLoanAD, Round(RecLLoanAD.CalcMnPrinciPeriodeeng(DateD, DateF), 0.001),
                            Round(RecLLoanAD.CalcMntInetretEng1(DateD, DateF), 0.001));
                    end;
                until RecLLoanAD.Next = 0;
            ///refund
            //refund
            /*
            IF SalaryLineTmp."Posting Month"<=12 THEN BEGIN
                 RecLLoanAD.RESET;
                 RecLLoanAD.SETCURRENTKEY(Employee,Type,Status,"No.","Avance Sur Prime");
                 RecLLoanAD.SETFILTER(Employee,SalaryLineTmp.Employee);
                 RecLLoanAD.SETRANGE(Type,RecLLoanAD.Type::Addition);
                 RecLLoanAD.SETRANGE(Status,RecLLoanAD.Status::"In progress");
                 RecLLoanAD.SETRANGE("Not include",FALSE);
                 RecLLoanAD.SETRANGE("Avance Sur Prime",FALSE);
                IF RecLLoanAD.FIND('-') THEN
                   REPEAT
                    IF calcSolde(RecLLoanAD,SalaryLineTmp) THEN BEGIN
                    SalaryLineTmp."L.Addition":=SalaryLineTmp.Loans+ ROUND(RecLLoanAD.CalcMnPrinciPeriodeeng(DateD,DateF),0.001)+
                                         ROUND(RecLLoanAD.CalcMntInetretEng1(DateD,DateF),0.001) ;
                    IF (ROUND(RecLLoanAD.CalcMnPrinciPeriodeeng(DateD,DateF),0.001)<>0) OR
                    (ROUND(RecLLoanAD.CalcMntInetretEng1(DateD,DateF),0.001)<>0) THEN
                       InsererLigne(SalaryLineTmp,RecLLoanAD,ROUND(RecLLoanAD.CalcMnPrinciPeriodeeng(DateD,DateF),0.001),
                       ROUND(RecLLoanAD.CalcMntInetretEng1(DateD,DateF),0.001));
                       END;
                   UNTIL RecLLoanAD.NEXT=0;

            */
            // Advance

            RecLLoanAD.Reset;
            RecLLoanAD.SetCurrentKey(Employee, Type, Status, "No.", "Avance Sur Prime");

            RecLLoanAD.SetFilter(Employee, SalaryLineTmp.Employee);
            RecLLoanAD.SetRange(Type, RecLLoanAD.Type::Advance);
            RecLLoanAD.SetRange(Status, RecLLoanAD.Status::"In progress");
            RecLLoanAD.SetRange("Avance Sur Prime", false);
            // RecLLoanAD.SETRANGE("Not include",FALSE);
            if RecLLoanAD.Find('-') then
                repeat
                    if calcSolde(RecLLoanAD, SalaryLineTmp) then begin
                        SalaryLineTmp.Advance := SalaryLineTmp.Advance + Round(RecLLoanAD.CalcMnPrinciPeriodeeng(DateD, DateF), 0.001);
                        if (Round(RecLLoanAD.CalcMnPrinciPeriodeeng(DateD, DateF), 0.001) <> 0) then
                            InsererLigne(SalaryLineTmp, RecLLoanAD, Round(RecLLoanAD.CalcMnPrinciPeriodeeng(DateD, DateF), 0.001),
                            0);
                    end;

                until RecLLoanAD.Next = 0;
        end else
            //IF SalaryLineTmp.Month<>SalaryLineTmp.Month::"Solde TC" THEN BEGIN
            if (SalaryLineTmp."Posting Month" = SalaryLineTmp."Posting Month"::December) then begin

                DecLMnt := 0;
                DecLMnt := SalaryLineTmp."Net Pay";
                //IF DecLMnt<>0 THEN BEGIN
                if
                   (SalaryLineTmp."Posting Month" = SalaryLineTmp."Posting Month"::December) then begin
                    RecLLoanAD.Reset;
                    RecLLoanAD.SetCurrentKey(Employee, Type, Status, "No.", "Avance Sur Prime");
                    RecLLoanAD.SetFilter(Employee, SalaryLineTmp.Employee);
                    RecLLoanAD.SetRange(Type, RecLLoanAD.Type::Loan);
                    RecLLoanAD.SetRange(Status, RecLLoanAD.Status::"In progress");
                    RecLLoanAD.SetRange("Avance Sur Prime", true);
                    if RecLLoanAD.Find('-') then
                        repeat

                            DecLMntTmp := 0;
                            DecLMntTmp := Round(RecLLoanAD.CalcMntInetretAvPrime(DateF), 0.001);
                            if DecLMnt < DecLMntTmp then begin
                                SalaryLineTmp.Loan := SalaryLineTmp.Loan + DecLMnt;
                                InsererLigne(SalaryLineTmp, RecLLoanAD, (DecLMnt - DecLMntTmp), DecLMntTmp);
                                DecLMnt := 0;
                            end
                            else begin
                                if (DecLMnt - DecLMntTmp) < RecLLoanAD.CalcMnPRincipaleRemb then begin
                                    SalaryLineTmp.Loan := SalaryLineTmp.Loan + DecLMnt;
                                    InsererLigne(SalaryLineTmp, RecLLoanAD, (DecLMnt - DecLMntTmp), DecLMntTmp);
                                    DecLMnt := 0;
                                end else begin
                                    SalaryLineTmp.Loan := SalaryLineTmp.Loan + RecLLoanAD.CalcMnPRincipaleRemb + DecLMntTmp;
                                    InsererLigne(SalaryLineTmp, RecLLoanAD, RecLLoanAD.CalcMnPRincipaleRemb, DecLMntTmp);
                                    DecLMnt := DecLMnt - (DecLMntTmp + RecLLoanAD.CalcMnPRincipaleRemb);
                                end;
                            end;
                        until (RecLLoanAD.Next = 0) or (DecLMnt = 0);

                    // Advance

                    RecLLoanAD.Reset;
                    RecLLoanAD.SetCurrentKey(Employee, Type, Status, "No.", "Avance Sur Prime");

                    RecLLoanAD.SetFilter(Employee, SalaryLineTmp.Employee);
                    RecLLoanAD.SetRange(Type, RecLLoanAD.Type::Advance);
                    RecLLoanAD.SetRange(Status, RecLLoanAD.Status::"In progress");
                    RecLLoanAD.SetRange("Avance Sur Prime", true);
                    if RecLLoanAD.Find('-') then
                        repeat
                            DecLMntTmp := 0;
                            DecLMntTmp := Round(RecLLoanAD.CalcMntInetretAvPrime(DateF), 0.001);
                            if DecLMnt < DecLMntTmp then begin
                                SalaryLineTmp.Advance := SalaryLineTmp.Advance + DecLMnt;
                                InsererLigne(SalaryLineTmp, RecLLoanAD, (DecLMnt - DecLMntTmp), DecLMntTmp);
                                DecLMnt := 0;
                            end
                            else begin
                                if (DecLMnt - DecLMntTmp) < RecLLoanAD.CalcMnPRincipaleRemb then begin
                                    SalaryLineTmp.Advance := SalaryLineTmp.Advance + DecLMnt;
                                    InsererLigne(SalaryLineTmp, RecLLoanAD, (DecLMnt - DecLMntTmp), DecLMntTmp);
                                    DecLMnt := 0;
                                end else begin
                                    SalaryLineTmp.Advance := SalaryLineTmp.Advance + RecLLoanAD.CalcMnPRincipaleRemb;
                                    InsererLigne(SalaryLineTmp, RecLLoanAD, RecLLoanAD.CalcMnPRincipaleRemb, DecLMntTmp);
                                    DecLMnt := DecLMnt - (DecLMntTmp + RecLLoanAD.CalcMnPRincipaleRemb);
                                end;
                            end;
                        until (RecLLoanAD.Next = 0) or (DecLMnt = 0);
                end;
            end;
        //END;

    end;

    //[Scope('Internal')]
    procedure InsererLigneRembourcement(SalaryLine: Record "Salary Line"; LoanAdvanceHeader: Record "Rec. Loan & Advance")
    var
        RecLLoanAdvanceLines: Record "Loan & Advance Lines";
        RecLExistLoanAdvanceLine: Record "Loan & Advance Lines";
        IntLln: Integer;
        RecLEmployee: Record Employee;
    begin

        RecLLoanAdvanceLines.Reset;
        RecLLoanAdvanceLines.SetRange("No.", LoanAdvanceHeader."No.");
        if RecLLoanAdvanceLines.Find('+') then
            IntLln := RecLLoanAdvanceLines."Entry No." + 10000
        else
            IntLln := 10000;

        RecLEmployee.Get(SalaryLine.Employee);

        //LoanAdvanceHeader.CALCFIELDS("Repaiment lines","Repaid amount","Repaid %");

        RecLLoanAdvanceLines.Reset;
        RecLLoanAdvanceLines."No." := LoanAdvanceHeader."No.";
        RecLLoanAdvanceLines."Entry No." := IntLln;
        RecLLoanAdvanceLines.Employee := LoanAdvanceHeader.Employee;
        RecLLoanAdvanceLines."Employee Posting Group" := RecLEmployee."Employee Posting Group";
        RecLLoanAdvanceLines."Global dimension 1" := RecLEmployee."Global Dimension 1 Code";
        RecLLoanAdvanceLines."Global dimension 2" := RecLEmployee."Global Dimension 2 Code";
        RecLLoanAdvanceLines.Type := LoanAdvanceHeader.Type;
        RecLLoanAdvanceLines."Document type" := LoanAdvanceHeader."Document type";
        RecLLoanAdvanceLines."Line Amount" := (LoanAdvanceHeader."Total to repay" - LoanAdvanceHeader."Paid amount")
                                                           / (LoanAdvanceHeader."Repayment slices"
                                                           - LoanAdvanceHeader."Repaiment lines");
        RecLLoanAdvanceLines."Line %" := (RecLLoanAdvanceLines."Line Amount" * 100)
                                                             / LoanAdvanceHeader."Total to repay";
        RecLLoanAdvanceLines.Status := 0;
        RecLLoanAdvanceLines.Paid := false;
        RecLLoanAdvanceLines."Payment No." := SalaryLine."Document No.";
        RecLLoanAdvanceLines.Month := SalaryLine."Posting Month";
        RecLLoanAdvanceLines.Year := SalaryLine."Posting Year";

        RecLLoanAdvanceLines."Payroll Date" := SalaryLine."Posting Date";
        RecLLoanAdvanceLines."User ID" := UserId;
        RecLLoanAdvanceLines."Last Date Modified" := WorkDate;

        RecLExistLoanAdvanceLine.SetRange("No.", LoanAdvanceHeader."No.");
        RecLExistLoanAdvanceLine.SetRange(Employee, LoanAdvanceHeader.Employee);
        RecLExistLoanAdvanceLine.SetRange("Payment No.", SalaryLine."Document No.");
        RecLLoanAdvanceLines.Insert
    end;

    //[Scope('Internal')]
    procedure CloturerDocument(Header: Record "Rec. Loan & Advance")
    var
        RecLLines: Record "Loan & Advance Lines";
        BooLTest: Boolean;
        RecLLoanAdvanceEntry: Record "Loan & Advance Entry";
    begin
        //Header.CALCFIELDS ("Repaid amount","Repaid %");

        if ((Round(Header."Repaid %") = 100) and (Header."Paid amount" = Header."Total to repay")) then begin
            BooLTest := true;
            RecLLines.SetRange("No.", Header."No.");
            if RecLLines.Find('-') then
                repeat
                    if not RecLLines.Paid then
                        BooLTest := false;
                until RecLLines.Next = 0;
            if BooLTest then begin
                Header.Status := 1;
                Header."User ID" := UserId;
                Header."Last Date Modified" := WorkDate;
                Header.Modify;

                RecLLines.Reset;
                RecLLines.SetRange("No.", Header."No.");
                if RecLLines.Find('-') then begin
                    RecLLines.Status := 1;
                    RecLLines.Modify;
                end;
                RecLLoanAdvanceEntry.Reset;
                RecLLoanAdvanceEntry.SetRange("No.", Header."No.");
                if RecLLoanAdvanceEntry.Find('-') then
                    repeat
                        RecLLoanAdvanceEntry.Status := 1;
                        RecLLoanAdvanceEntry.Modify;
                    until RecLLoanAdvanceEntry.Next = 0;
            end;
        end;
    end;

    //[Scope('Internal')]
    procedure EnregDocument(LoanAdvance: Record "Loan & Advance")
    var
        RecLLoanAdvanceHeader: Record "Rec. Loan & Advance";
        errMC: Label 'Validation impossible.\Some important parameter aren''t mentionned.';
        RecLLoanAdvanceEntry: Record "Loan & Advance Entry";
    begin
        /*IF NOT TestValiditeDocument (LoanAdvance) THEN
          ERROR (errMC);*/

        if ((LoanAdvance."Repayment slices" <> 0)
            and
            (LoanAdvance."Total to repay" <> 0)
           ) then begin
            RecLLoanAdvanceHeader.Reset;
            RecLLoanAdvanceHeader.Init;
            RecLLoanAdvanceHeader.TransferFields(LoanAdvance);
            RecLLoanAdvanceHeader."No." := LoanAdvance."No.";
            RecLLoanAdvanceHeader.Validate("Start Date");
            //MESSAGE('%1',  LoanAdvance."No.");
            //       MESSAGE('%1',  LoanAdvanceHeader."No." );
            RecLLoanAdvanceHeader.Employee := LoanAdvance.Employee;
            RecLLoanAdvanceHeader.Name := LoanAdvance.Name;
            RecLLoanAdvanceHeader."Job Title" := LoanAdvance."Job Title";
            /*  RecLLoanAdvanceHeader."Employee Posting Group"   := LoanAdvance."Employee Posting Group";
              RecLLoanAdvanceHeader."Global dimension 1"       := LoanAdvance."Global dimension 1";
              RecLLoanAdvanceHeader."Global dimension 2"       := LoanAdvance."Global dimension 2";*/
            RecLLoanAdvanceHeader.Type := LoanAdvance.Type;
            RecLLoanAdvanceHeader."Document type" := LoanAdvance."Document type";
            RecLLoanAdvanceHeader.Amount := LoanAdvance.Amount;
            //RecLLoanAdvanceHeader."Interest %" := LoanAdvance."Interest %";
            RecLLoanAdvanceHeader."Total to repay" := LoanAdvance."Total to repay";
            RecLLoanAdvanceHeader."N  document Extr." := LoanAdvance."External Document No";
            RecLLoanAdvanceHeader."Montant tranche" := LoanAdvance."Slice Amount";
            RecLLoanAdvanceHeader."Start Date" := LoanAdvance."Starting Date";

            RecLLoanAdvanceHeader."Avance Sur Prime" := LoanAdvance."Avance Sur Prime";
            RecLLoanAdvanceHeader."Repayment slices" := LoanAdvance."Repayment slices";
            RecLLoanAdvanceHeader."No. Series" := LoanAdvance."No. Series";
            RecLLoanAdvanceHeader."Document Date" := WorkDate;
            RecLLoanAdvanceHeader.Status := 0;
            RecLLoanAdvanceHeader."User ID" := UserId;
            RecLLoanAdvanceHeader."Last Date Modified" := LoanAdvance."Last Date Modified";


            if RecLLoanAdvanceHeader.Insert then begin
                RecLLoanAdvanceEntry.Reset;
                RecLLoanAdvanceEntry.Init;
                RecLLoanAdvanceEntry."No." := LoanAdvance."No.";
                RecLLoanAdvanceEntry."Entry No." := 0;
                RecLLoanAdvanceEntry.Employee := LoanAdvance.Employee;
                RecLLoanAdvanceEntry.Name := LoanAdvance.Name;
                RecLLoanAdvanceEntry."Employee Posting Group" := LoanAdvance."Employee Posting Group";
                //  RecLLoanAdvanceEntry."Global dimension 1"    := LoanAdvance."Global dimension 1";
                //RecLLoanAdvanceEntry."Global dimension 2"    := LoanAdvance."Global dimension 2";
                RecLLoanAdvanceEntry.Month := Date2DMY(LoanAdvance."Posting Date", 2) - 1;
                RecLLoanAdvanceEntry.Year := Date2DMY(LoanAdvance."Posting Date", 3);
                RecLLoanAdvanceEntry."Date Paie" := LoanAdvance."Posting Date";
                RecLLoanAdvanceEntry.Type := LoanAdvance.Type;
                RecLLoanAdvanceEntry."Document type" := LoanAdvance."Document type";
                RecLLoanAdvanceEntry."Entry type" := 0;
                RecLLoanAdvanceEntry.Amount := LoanAdvance."Total to repay";
                RecLLoanAdvanceEntry."Date effet" := RecLLoanAdvanceHeader."Start Date";
                RecLLoanAdvanceEntry."User ID" := UserId;
                RecLLoanAdvanceEntry."Last Date Modified" := WorkDate;
                RecLLoanAdvanceEntry.Insert;
                LoanAdvance.Delete;
            end
            else
                Error(errValidate);
        end

    end;

    //[Scope('Internal')]
    procedure TestValiditeDocument(LoanAdvance: Record "Loan & Advance"): Boolean
    begin
        if ((LoanAdvance.Employee <> '')
            and (LoanAdvance."Employee Posting Group" <> '')
            and (LoanAdvance."Document type" <> '')
            and (LoanAdvance.Amount > 0)
            and (LoanAdvance."Total to repay" > 0)
            and (LoanAdvance."Repayment slices" > 0)
            and (LoanAdvance."Bal. Account No." <> '')
           ) then
            exit(true)
        else
            exit(false);
    end;

    //[Scope('Internal')]
    procedure EcrComptaPaiement(LoanAdvance: Record "Loan & Advance"; DateValidation: Date; TypeValidation: Option)
    var
        RecLHumResSetup: Record "Human Resources Setup";
        errConfig: Label 'General Journal Template empty in Human Resource Parameter.';
        RecLLAType: Record "Loan & Advance Type";
        errLATypeMissing: Label 'Loan & Advance Type missing.';
        errWrongParam: Label 'Account No. or Bal. Account No. empty in Loan & Advance type parameter.';
        RecLGenJournalLine: Record "Gen. Journal Line";
        RecLGenJournalBatch: Record "Gen. Journal Batch";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        success: Label 'Document posting operation successfull.\Lines inserted on Journal : %1 - %2.';
        IntLLine: Integer;
        RecLBankAccount: Record "Bank Account";
        DecLCourtT: Decimal;
        DecLLongT: Decimal;
        SuccesV: Label 'Document Validé Avec Succées.';
    begin
        RecLHumResSetup.Get();

        if not RecLLAType.Get(LoanAdvance."Document type")
          then
            Error(errLATypeMissing);

        if ((RecLLAType."Account No." = '')
            or
            (RecLLAType."Bal. Account No." = ''))
          then
            Error(errWrongParam);

        if (RecLHumResSetup."Payroll Gen.Journal batch" = '')
          then
            Error(errConfig);
        RecLGenJournalLine.SetRange("Journal Template Name", RecLHumResSetup."Payroll Gen.Journal template");
        RecLGenJournalLine.SetRange("Journal Batch Name", RecLHumResSetup."Payroll Gen.Journal batch");
        //RecLGenJournalLine.SETRANGE ("Line No.",Line);
        RecLGenJournalLine.SetRange("Document No.", LoanAdvance."No.");
        RecLGenJournalLine.DeleteAll;
        RecLGenJournalLine.Reset;
        RecLGenJournalLine.SetRange("Journal Template Name", RecLHumResSetup."Payroll Gen.Journal template");
        RecLGenJournalLine.SetRange("Journal Batch Name", RecLHumResSetup."LA.Gen.Journal Batch");

        if RecLGenJournalLine.Find('+') then
            IntLLine := RecLGenJournalLine."Line No." + 10000
        else
            IntLLine := 10000;

        RecLGenJournalLine.Reset;
        RecLGenJournalLine."Journal Template Name" := RecLHumResSetup."Payroll Gen.Journal template";
        if RecLHumResSetup."Payroll Gen.Journal batch" <> '' then
            RecLGenJournalLine."Journal Batch Name" := RecLHumResSetup."Payroll Gen.Journal batch"
        else begin
            RecLGenJournalBatch.SetRange("Journal Template Name", RecLHumResSetup."Payroll Gen.Journal template");
            if RecLGenJournalBatch.Find('-') then
                RecLGenJournalLine."Journal Batch Name" := RecLHumResSetup."LA.Gen.Journal Batch";
        end;

        RecLGenJournalLine.Validate("Line No.", IntLLine);
        case RecLLAType."Account Type" of
            0:
                RecLGenJournalLine.Validate("Account Type", 0);
            1:
                begin
                    RecLGenJournalLine.Validate("Account Type", 3);
                    if RecLBankAccount.Get(RecLLAType."Bal. Account No.") then
                        RecLGenJournalLine.Validate("Currency Code", RecLBankAccount."Currency Code");
                end;
        end;
        RecLGenJournalLine.Validate("Account No.", RecLLAType."Account No.");
        RecLGenJournalLine.Validate("Posting Date", DateValidation);
        RecLGenJournalLine."Source Code" := RecLLAType."Source Code";
        RecLGenJournalLine.Validate("Document Type", 0);
        RecLGenJournalLine.Validate("Document No.", LoanAdvance."No.");
        case RecLLAType."Bal. Account Type" of
            0:
                begin
                    RecLGenJournalLine.Validate("Bal. Account Type", 0);
                    RecLGenJournalLine.Validate("Currency Code", '');
                end;
            1:
                begin
                    RecLGenJournalLine.Validate("Bal. Account Type", 3);
                    if RecLBankAccount.Get(RecLLAType."Bal. Account No.") then
                        RecLGenJournalLine.Validate("Currency Code", RecLBankAccount."Currency Code");
                end;
        end;
        RecLGenJournalLine."Source Type" := RecLGenJournalLine."Source Type"::"IC Partner";
        RecLGenJournalLine."Source No." := LoanAdvance.Employee;
        RecLGenJournalLine."External Document No." := LoanAdvance."External Document No";
        if LoanAdvance.Type = 0 then begin
            RecLGenJournalLine.Validate("Bal. Account No.", LoanAdvance."Bal. Account No.");
            RecLGenJournalLine.Validate("Debit Amount", LoanAdvance.Amount);
            RecLGenJournalLine."Source Type" := RecLGenJournalLine."Source Type"::"IC Partner";
            RecLGenJournalLine."Source No." := LoanAdvance.Employee;

            RecLGenJournalLine.Insert;
        end else begin
            //LoanAdvance.CalcPretLongetCourtTerme(DecLCourtT, DecLLongT);

            if DecLCourtT <> 0 then begin
                case RecLLAType."Account Type" of
                    0:
                        begin
                            RecLGenJournalLine.Validate("Account Type", 0);
                            RecLGenJournalLine.Validate("Account No.", RecLLAType."Account No.");

                            RecLGenJournalLine.Validate("Currency Code", '');
                        end;
                    1:
                        begin
                            RecLGenJournalLine.Validate("Account Type", 3);
                            RecLGenJournalLine.Validate("Account No.", RecLLAType."Account No.");
                            if RecLBankAccount.Get(RecLLAType."Account No.") then
                                RecLGenJournalLine.Validate("Currency Code", RecLBankAccount."Currency Code");
                        end;
                end;
                RecLGenJournalLine."Source Type" := RecLGenJournalLine."Source Type"::"IC Partner";
                RecLGenJournalLine."Source No." := LoanAdvance.Employee;
                RecLGenJournalLine.Validate("Debit Amount", DecLCourtT);
                RecLGenJournalLine.Insert;
            end;
            //
            if DecLLongT <> 0 then begin
                IntLLine := IntLLine + 10000;
                RecLGenJournalLine."Line No." := IntLLine;
                case RecLLAType."Account Type Long Terme" of
                    0:
                        begin
                            RecLGenJournalLine.Validate("Account Type", 0);
                            RecLGenJournalLine.Validate("Account No.", RecLLAType."Account No. Lng Termeo");
                            RecLGenJournalLine.Validate("Currency Code", '');
                        end;
                    1:
                        begin
                            RecLGenJournalLine.Validate("Account Type", 3);
                            RecLGenJournalLine.Validate("Account No.", RecLLAType."Account No. Lng Termeo");

                            if RecLBankAccount.Get(RecLLAType."Account No. Lng Termeo") then
                                RecLGenJournalLine.Validate("Currency Code", RecLBankAccount."Currency Code");
                        end;
                end;
                RecLGenJournalLine."Source Type" := RecLGenJournalLine."Source Type"::"IC Partner";
                RecLGenJournalLine."External Document No." := LoanAdvance."External Document No";

                RecLGenJournalLine."Source No." := LoanAdvance.Employee;
                RecLGenJournalLine.Validate("Debit Amount", DecLLongT);
                RecLGenJournalLine.Insert;
            end;
            //
            IntLLine := IntLLine + 10000;
            RecLGenJournalLine."Line No." := IntLLine;
            case LoanAdvance."Bal. Account Type" of
                0:
                    begin
                        RecLGenJournalLine.Validate("Bal. Account Type", 0);
                        RecLGenJournalLine.Validate("Account No.", LoanAdvance."Bal. Account No.");
                        RecLGenJournalLine.Validate("Currency Code", '');
                    end;
                1:
                    begin
                        RecLGenJournalLine.Validate("Account Type", 3);
                        RecLGenJournalLine.Validate("Account No.", LoanAdvance."Bal. Account No.");

                        if RecLBankAccount.Get(LoanAdvance."Bal. Account No.") then
                            RecLGenJournalLine.Validate("Currency Code", RecLBankAccount."Currency Code");
                    end;
            end;
            RecLGenJournalLine."Source Type" := RecLGenJournalLine."Source Type"::"IC Partner";
            RecLGenJournalLine."Source No." := LoanAdvance.Employee;
            RecLGenJournalLine."External Document No." := LoanAdvance."External Document No";

            RecLGenJournalLine.Validate("Credit Amount", LoanAdvance.Amount);
            RecLGenJournalLine.Insert;
        end;

        case TypeValidation of
            0:
                Message(success, RecLHumResSetup."Payroll Gen.Journal batch", RecLHumResSetup."Payroll Gen.Journal batch");
            1:
                begin
                    RecLGenJournalLine.SetRange("Journal Template Name", RecLHumResSetup."Payroll Gen.Journal template");
                    RecLGenJournalLine.SetRange("Journal Batch Name", RecLHumResSetup."LA.Gen.Journal Batch");
                    //RecLGenJournalLine.SETRANGE ("Line No.",Line);
                    RecLGenJournalLine.SetRange("Document No.", LoanAdvance."No.");
                    if RecLGenJournalLine.Find('-') then
                        CODEUNIT.Run(13, RecLGenJournalLine);
                    //MESSAGE (SuccesV);
                end;
        end;
        //kka
    end;

    //[Scope('Internal')]
    procedure EcrComptaPaiement2ln(LoanAdvance: Record "Loan & Advance"; DateValidation: Date; TypeValidation: Option)
    var
        RecLHumResSetup: Record "Human Resources Setup";
        errConfig: Label 'General Journal Template empty in Human Resource Parameter.';
        RecLLAType: Record "Loan & Advance Type";
        errLATypeMissing: Label 'Loan & Advance Type missing.';
        errWrongParam: Label 'Account No. or Bal. Account No. empty in Loan & Advance type parameter.';
        RecLGenJournalLine: Record "Gen. Journal Line";
        RecLGenJournalBatch: Record "Gen. Journal Batch";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        success: Label 'Document posting operation successfull.\Lines inserted on Journal : %1 - %2.';
        IntLLine: Integer;
        RecLBankAccount: Record "Bank Account";
        CodLJTN: Code[10];
        CodLJBN: Code[10];
    begin
        RecLHumResSetup.Get();

        if not RecLLAType.Get(LoanAdvance."Document type")
          then
            Error(errLATypeMissing);

        if ((RecLLAType."Account No." = '')
            or
            (RecLLAType."Bal. Account No." = ''))
          then
            Error(errWrongParam);

        if (RecLHumResSetup."Payroll Gen.Journal template" = '')
          then
            Error(errConfig);

        RecLGenJournalLine.SetRange("Journal Template Name", RecLHumResSetup."Payroll Gen.Journal template");
        if RecLGenJournalLine.Find('+') then
            IntLLine := RecLGenJournalLine."Line No." + 10000
        else
            IntLLine := 10000;

        // Ecriture N°1
        RecLGenJournalLine.Reset;
        RecLGenJournalLine."Journal Template Name" := RecLHumResSetup."Payroll Gen.Journal template";
        if RecLHumResSetup."Payroll Gen.Journal template" <> '' then
            RecLGenJournalLine."Journal Batch Name" := RecLHumResSetup."Payroll Gen.Journal batch"
        else begin
            RecLGenJournalBatch.SetRange("Journal Template Name", RecLHumResSetup."Payroll Gen.Journal template");
            if RecLGenJournalBatch.Find('-') then
                RecLGenJournalLine."Journal Batch Name" := RecLHumResSetup."LA.Gen.Journal Batch";
        end;

        CodLJTN := RecLGenJournalLine."Journal Template Name";
        CodLJBN := RecLGenJournalLine."Journal Batch Name";

        RecLGenJournalLine.Validate("Line No.", IntLLine);
        case RecLLAType."Account Type" of
            0:
                RecLGenJournalLine.Validate("Account Type", 0);
            1:
                begin
                    RecLGenJournalLine.Validate("Account Type", 3);
                    if RecLBankAccount.Get(RecLLAType."Bal. Account No.") then
                        RecLGenJournalLine.Validate("Currency Code", RecLBankAccount."Currency Code");
                end;
        end;
        RecLGenJournalLine.Validate("Account No.", RecLLAType."Account No.");
        RecLGenJournalLine.Validate("Posting Date", DateValidation);
        RecLGenJournalLine.Validate("Document Type", 0);
        RecLGenJournalLine.Validate("Document No.", LoanAdvance."No.");
        RecLGenJournalLine.Validate("Debit Amount", LoanAdvance."Total to repay");
        RecLGenJournalLine.Insert;

        // Ecriture N°2 : Contre partie

        RecLGenJournalLine.Reset;
        RecLGenJournalLine."Journal Template Name" := RecLHumResSetup."Payroll Gen.Journal template";
        if RecLHumResSetup."Payroll Gen.Journal batch" <> '' then
            RecLGenJournalLine."Journal Batch Name" := RecLHumResSetup."Payroll Gen.Journal batch"
        else begin
            RecLGenJournalBatch.SetRange("Journal Template Name", RecLHumResSetup."Payroll Gen.Journal template");
            if RecLGenJournalBatch.Find('-') then
                RecLGenJournalLine."Journal Batch Name" := RecLHumResSetup."LA.Gen.Journal Batch";
        end;

        RecLGenJournalLine.Validate("Line No.", IntLLine + 10000);
        case RecLLAType."Account Type" of
            0:
                RecLGenJournalLine.Validate("Account Type", 0);
            1:
                begin
                    RecLGenJournalLine.Validate("Account Type", 3);
                    if RecLBankAccount.Get(RecLLAType."Bal. Account No.") then
                        RecLGenJournalLine.Validate("Currency Code", RecLBankAccount."Currency Code");
                end;
        end;
        RecLGenJournalLine.Validate("Account No.", RecLLAType."Bal. Account No.");
        RecLGenJournalLine.Validate("Posting Date", DateValidation);
        RecLGenJournalLine.Validate("Document Type", 0);
        RecLGenJournalLine.Validate("Document No.", LoanAdvance."No.");
        RecLGenJournalLine.Validate("Credit Amount", LoanAdvance."Total to repay");
        RecLGenJournalLine.Insert;

        // Validation selon type

        case TypeValidation of
            0:
                Message(success, RecLHumResSetup."Payroll Gen.Journal template", RecLHumResSetup."Payroll Gen.Journal template");
            1:
                begin
                    RecLGenJournalLine.SetRange("Journal Template Name", CodLJTN);
                    RecLGenJournalLine.SetRange("Journal Batch Name", CodLJBN);
                    //GenJournalLine.SETFILTER ("Line No.",'%1|%2',Line,Line+10000);
                    RecLGenJournalLine.SetRange("Document No.", LoanAdvance."No.");
                    if RecLGenJournalLine.Find('-') then begin
                        CODEUNIT.Run(CODEUNIT::"Gen. Jnl.-Post", RecLGenJournalLine);
                    end;
                end;
        end;
    end;

    //[Scope('Internal')]
    procedure Valider(var GenJournalLine: Record "Gen. Journal Line")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
    end;

    //[Scope('Internal')]
    procedure "-------------"()
    begin
    end;

    //[Scope('Internal')]
    procedure Solder(var Header: Record "Rec. Loan & Advance"; var Datecompta: Date; var TypeReg: Text[30]; var NumDoc: Code[20])
    var
        RecLLines: Record "Loan & Advance Lines";
        IntLln: Integer;
        DateF: Date;
        RecLResSetup: Record "Human Resources Setup";
        DecLMontantPrin: Decimal;
        DecLMontantint: Decimal;
        DecLMnttot: Decimal;
    begin
        //Header.CALCFIELDS ("Repaid amount","Repaid %","Principal Amount","Interest Amount");
        if Header."Paid amount" >= Header."Total to repay" then
            Error('This document has been fully refunded !');
        if Header.Status = 1 then
            Error('Document status = %1, cannot continue!', Header.Status);
        RecLResSetup.Get;
        DateF := CalcDate(StrSubstNo('-%1D+CM', RecLResSetup."Apply Loan After"), Datecompta);
        DecLMontantPrin := Header.Amount - Header."Principal Amount";

        //DecLMontantint := Header.CalcMntInetret(Header."Start Date", Datecompta) - Header."Interest Amount";
        if Confirm('Are you sure you want to settle this document??\' +
                    'Document number: %1 for the benefit of %2\' +
                    'Type: %3 - %4\' +
                    'Remains to be repaid: %5', false, Header."No.", Header.Employee + ' ' + Header.Name,
                    Header.Type, Header."Document type", Round(DecLMontantPrin + DecLMontantint, 0.001))
          then begin
            RecLLines.SetRange("No.", Header."No.");
            RecLLines.SetRange(Type, Header.Type);
            RecLLines.SetRange("Document type", Header."Document type");
            if RecLLines.Find('+') then
                IntLln := RecLLines."Entry No." + 10000
            else
                IntLln := 10000;
            DecLMnttot := (DecLMontantPrin + DecLMontantint);
            //IF NOT CreerEcrtTresorerie(Header,Datecompta,TypeReg,NumDoc,DecLMnttot) THEN
            //   ERROR('Verifier Réglement');;

            RecLLines.Init;
            RecLLines."No." := Header."No.";
            RecLLines."Entry No." := IntLln;
            RecLLines.Employee := Header.Employee;
            RecLLines."Employee Posting Group" := Header."Employee Posting Group";
            RecLLines."Global dimension 1" := Header."Global dimension 1";
            RecLLines."Global dimension 2" := Header."Global dimension 2";
            RecLLines.Type := Header.Type;
            RecLLines."Document type" := Header."Document type";
            RecLLines."Line Amount" := DecLMontantPrin + DecLMontantint;
            RecLLines."Line %" := 100 - Header."Repaid %";
            RecLLines.Status := 0;
            RecLLines."Payment No." := 'SLD MANUEL';
            RecLLines.Paid := true;
            RecLLines."Principal Amount" := DecLMontantPrin;
            RecLLines."Interest Amount" := DecLMontantint;
            RecLLines."User ID" := UserId;
            RecLLines."Last Date Modified" := Today;
            //>>SBN 261110
            RecLLines.Month := Date2DMY(Today, 2) - 1;
            RecLLines.Year := Date2DMY(Today, 3);
            //SBN>>
            if not RecLLines.Insert then
                Error('Insertion failed, contact your database administrator !')
        end;
    end;

    //[Scope('Internal')]
    procedure SolderDepasser(var Header: Record "Rec. Loan & Advance"; var Datecompta: Date; var TypeReg: Text[30]; var NumDoc: Code[20])
    var
        RecLLines: Record "Loan & Advance Lines";
        IntLln: Integer;
        DateF: Date;
        RecLResSetup: Record "Human Resources Setup";
        DecLMontantPrin: Decimal;
        DecLMontantint: Decimal;
        DecLMnttot: Decimal;
    begin
        //Header.CALCFIELDS ("Repaid amount","Repaid %","Principal Amount","Interest Amount");
        if Header."Paid amount" >= Header."Total to repay" then
            Error('Ce document a fait l''objet d''un remboursement complet !');
        if Header.Status = 1 then
            Error('Statut du document = %1, impossible de poursuivre !', Header.Status);
        RecLResSetup.Get;
        DateF := CalcDate(StrSubstNo('-%1D+CM', RecLResSetup."Apply Loan After"), Datecompta);
        //DecLMontantPrin := Header.CalcMnPrinciPeriode(Header."Start Date", DateF) - Header."Principal Amount";
        //DecLMontantint := Header.CalcMntInetret(Header."Start Date", DateF) - Header."Interest Amount";
        if Confirm('Etes vous sur de vouloir solder ce document ?\' +
                    'N° document : %1 au bénéfice de %2\' +
                    'Type : %3 - %4\' +
                    'Reste à rembourser : %5', false, Header."No.", Header.Employee + ' ' + Header.Name,
                    Header.Type, Header."Document type", Round(DecLMontantPrin + DecLMontantint, 0.001))
          then begin
            RecLLines.SetRange("No.", Header."No.");
            RecLLines.SetRange(Type, Header.Type);
            RecLLines.SetRange("Document type", Header."Document type");
            if RecLLines.Find('+') then
                IntLln := RecLLines."Entry No." + 10000
            else
                IntLln := 10000;
            DecLMnttot := (DecLMontantPrin + DecLMontantint);
            // IF NOT CreerEcrtTresorerie(Header,Datecompta,TypeReg,NumDoc,DecLMnttot) THEN
            //   ERROR('Verifier Réglement');;
            RecLLines.Init;
            RecLLines."No." := Header."No.";
            RecLLines."Entry No." := IntLln;
            RecLLines.Employee := Header.Employee;
            RecLLines."Employee Posting Group" := Header."Employee Posting Group";
            RecLLines."Global dimension 1" := Header."Global dimension 1";
            RecLLines."Global dimension 2" := Header."Global dimension 2";
            RecLLines.Type := Header.Type;
            RecLLines."Document type" := Header."Document type";
            RecLLines."Line Amount" := DecLMontantPrin + DecLMontantint;
            RecLLines."Line %" := 100 - Header."Repaid %";
            RecLLines.Status := 0;
            RecLLines."Payment No." := 'SLD MANUEL';
            RecLLines.Paid := true;
            RecLLines."Principal Amount" := DecLMontantPrin;
            RecLLines."Interest Amount" := DecLMontantint;
            RecLLines."User ID" := UserId;
            RecLLines."Last Date Modified" := Today;
            if not RecLLines.Insert then
                Error('Insertion échouée, contactez votre administareur base de données !')
        end;
    end;

    //[Scope('Internal')]
    procedure CreerEcrtTresorerie(var Header: Record "Rec. Loan & Advance"; var Datecompta: Date; var TypeReg: Text[30]; var NumDoc: Code[20]; var Mnt: Decimal): Boolean
    var
        NoSeriesMgt: Codeunit "No. Series";
    begin
        /* IF Mnt<=0 THEN ERROR('Verifier Réglement !!!!!');
          CLEAR(PaymentClass);
         IF NOT PaymentClass.GET(TypeReg) THEN
            ERROR('Vous devez verifier Type Payement !!!!');
          CLEAR(StatPayment);
          StatPayment.GET(TypeReg,0);
         IF  NOT StatPayment.Credit THEN
           ERROR(' Choisi un Autre Type de Réglement !!!!');
         EntReg.RESET;
         EntReg."Payment Class":=TypeReg;
         EntReg."No.":=NumDoc;
         EntReg.VALIDATE("Posting Date",Datecompta);
         EntReg.VALIDATE("Document Date",Datecompta);
         //EntReg.validate("Source Code",
         EntReg.VALIDATE("Account Type",PaymentClass."Account Type");
         EntReg.Caisse:=PaymentClass.Caisse;
         EntReg.INSERT;
         LigReg.RESET;
         LigReg."No." := NumDoc;
         LigReg."Line No."  :=10000;
         LigReg."Document ID":=NoSeriesMgt.GetNextNo(PaymentClass."Line No. Series",Datecompta,TRUE);
         LigReg."Account Type":=LigReg."Account Type"::Salary;
         LigReg.VALIDATE("Account No.",Header.Employee);
         LigReg."Payment Class":=TypeReg;
         LigReg."Status No.":=0;
         LigReg.VALIDATE("Credit Amount",Mnt);
        IF LigReg.INSERT THEN
           EXIT(TRUE)
           ELSE
           EXIT(FALSE);*/

    end;

    //[Scope('Internal')]
    procedure InsererLigne(var SalaryLine: Record "Salary Line"; LoanAdvanceHeader: Record "Rec. Loan & Advance"; MntPrinc: Decimal; MntInt: Decimal)
    var
        RecLLoanAdvanceLines: Record "Loan & Advance Lines";
        RecLLALines: Record "Loan & Advance Lines";
        RecLExistLoanAdvanceLine: Record "Loan & Advance Lines";
        InTLln: Integer;
        RecLEmployee: Record Employee;
    begin
        RecLLoanAdvanceLines.Reset;
        RecLLoanAdvanceLines.SetRange("No.", LoanAdvanceHeader."No.");
        if RecLLoanAdvanceLines.Find('+') then
            InTLln := RecLLoanAdvanceLines."Entry No." + 10000
        else
            InTLln := 10000;

        RecLEmployee.Get(SalaryLine.Employee);

        RecLLoanAdvanceLines.Reset;
        RecLLoanAdvanceLines.Init;
        RecLLoanAdvanceLines."No." := LoanAdvanceHeader."No.";
        RecLLoanAdvanceLines."Entry No." := InTLln;
        RecLLoanAdvanceLines.Employee := LoanAdvanceHeader.Employee;
        RecLLoanAdvanceLines."Employee Posting Group" := RecLEmployee."Employee Posting Group";
        RecLLoanAdvanceLines."Global dimension 1" := RecLEmployee."Global Dimension 1 Code";
        RecLLoanAdvanceLines."Global dimension 2" := RecLEmployee."Global Dimension 2 Code";
        RecLLoanAdvanceLines.Type := LoanAdvanceHeader.Type;
        RecLLoanAdvanceLines."Document type" := LoanAdvanceHeader."Document type";


        RecLLoanAdvanceLines."Line Amount" := MntPrinc + MntInt;
        RecLLoanAdvanceLines."Principal Amount" := MntPrinc;
        RecLLoanAdvanceLines."Interest Amount" := MntInt;
        RecLLoanAdvanceLines."Line %" := (RecLLoanAdvanceLines."Line Amount" * 100)
                                                        / LoanAdvanceHeader."Total to repay";
        RecLLoanAdvanceLines.Status := 0;
        RecLLoanAdvanceLines.Paid := false;
        RecLLoanAdvanceLines."Payment No." := SalaryLine."Document No.";
        RecLLoanAdvanceLines.Month := SalaryLine."Posting Month";
        RecLLoanAdvanceLines.Year := SalaryLine."Posting Year";
        RecLLoanAdvanceLines."Payroll Date" := SalaryLine."Posting Date";
        RecLLoanAdvanceLines."User ID" := UserId;
        RecLLoanAdvanceLines."Last Date Modified" := WorkDate;
        RecLLoanAdvanceLines.Insert
    end;

    //[Scope('Internal')]
    procedure calcSolde(recGLAHeader: Record "Rec. Loan & Advance"; SalaryLineTmp: Record "Salary Line") Verif: Boolean
    var
        RecLLines: Record "Loan & Advance Lines";
        DecLMnt: Decimal;
    begin
        //with Header do begin
        Verif := true;
        DecLMnt := 0;
        RecLLines.Reset;
        RecLLines.SetCurrentKey("No.", Employee, Paid);
        RecLLines.SetFilter("No.", recGLAHeader."No.");
        RecLLines.SetFilter(Employee, recGLAHeader.Employee);
        RecLLines.SetRange(Paid, true);
        RecLLines.CalcSums("Principal Amount", "Line Amount");
        DecLMnt := RecLLines."Principal Amount";
        if Round(recGLAHeader.Amount - DecLMnt, 0.1) = 0 then
            Verif := false
        else begin
            RecLLines.SetRange(Year, SalaryLineTmp."Posting Year");
            RecLLines.SetRange(Month, SalaryLineTmp."Posting Month");
            RecLLines.SetFilter("Line Amount", '<>0');
            if RecLLines.Find('-') then
                Verif := false;
        end;

        //end;
    end;
}

