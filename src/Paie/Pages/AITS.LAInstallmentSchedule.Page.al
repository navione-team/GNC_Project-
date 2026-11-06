page 70020 "L&A Installment Schedule"
{
    DelayedInsert = false;
    PageType = ListPart;
    Editable = false;
    SourceTable = "L&A Installment Schedule";
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("N° Loan"; rec."N° Loan")
                {
                }
                field("FormatMois(Month)"; FormatMois(rec.Month))
                {
                }
                field(Year; rec.Year)
                {
                }
                field(Slice; rec.Slice)
                {
                }
                field(Valid; rec.Valid)
                {
                }
                field(Balance; rec.Balance)
                {
                }
                field("Slice Nbr"; rec."Slice Nbr")
                {
                    Editable = false;
                }
                field("Payment No"; rec."Payment No")
                {
                }

            }
        }
    }

    actions
    {
    }

    var
        VEchan_G: Boolean;
        LoanAdvance_G: Record "Loan & Advance";

    //[Scope('Internal')]
    procedure EtablirEcheancier(CodLNumPret: Code[20]; DatLStart: Date; DatLEnd: Date; DecLAmount: Decimal; IntLNumTranche: Integer; IntLType: Integer)
    var
        RecLTableEcheancier: Record "L&A Installment Schedule";
        i: Integer;
    begin
        RecLTableEcheancier.SetRange(RecLTableEcheancier."N° Loan", CodLNumPret);
        if not RecLTableEcheancier.Find('-') then begin
            RecLTableEcheancier.Reset;
            i := 1; //kmi
            while (i <= IntLNumTranche)
            do begin
                RecLTableEcheancier.Init;

                i := i + 1;
                RecLTableEcheancier.Validate("N° Loan", CodLNumPret);
                ;
                RecLTableEcheancier.Year := Date2DMY(DatLStart, 3);
                RecLTableEcheancier.Month := Date2DMY(DatLStart, 2);
                RecLTableEcheancier.Slice := DecLAmount;
                RecLTableEcheancier.Valid := true;
                RecLTableEcheancier.Type := IntLType;
                RecLTableEcheancier."Slice Nbr" := IntLNumTranche;
                RecLTableEcheancier.Insert;
                DatLStart := CalcDate('+1M', DatLStart);
            end;
        end
        else begin
            repeat
                RecLTableEcheancier.Delete;
            until RecLTableEcheancier.Next = 0;
            i := 1; //kmi
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
                RecLTableEcheancier.Insert;
                DatLStart := CalcDate('+1M', DatLStart);
            end;
        end;
        CurrPage.Update;
    end;

    //  [Scope('Internal')]
    procedure ReporterEcheance(CodLNumPret: Code[20])
    var
        RecLTableEcheancier: Record "L&A Installment Schedule";
        IntLMois: Integer;
        IntLAnnee: Integer;
        DecLTranche: Decimal;
        IntLNbrTranche: Integer;
        IntLType: Integer;
    begin
        RecLTableEcheancier.SetRange(RecLTableEcheancier."N° Loan", CodLNumPret);
        if RecLTableEcheancier.Find('+') then begin
            IntLMois := Date2DMY(CalcDate('+1M', DMY2Date(1, RecLTableEcheancier.Month, RecLTableEcheancier.Year)), 2);
            IntLAnnee := Date2DMY(CalcDate('+1M', DMY2Date(1, RecLTableEcheancier.Month, RecLTableEcheancier.Year)), 3);
        end;
        RecLTableEcheancier.SetRange(RecLTableEcheancier.Valid, false);
        if RecLTableEcheancier.Find('-') then begin
            DecLTranche := RecLTableEcheancier.Slice;
            IntLNbrTranche := RecLTableEcheancier."Slice Nbr";
            IntLType := RecLTableEcheancier.Type;
            RecLTableEcheancier.Init;
            RecLTableEcheancier.Validate("N° Loan", CodLNumPret);
            RecLTableEcheancier.Month := IntLMois;
            RecLTableEcheancier.Year := IntLAnnee;
            RecLTableEcheancier.Slice := DecLTranche;
            RecLTableEcheancier.Valid := true;
            RecLTableEcheancier.Type := IntLType;
            RecLTableEcheancier."Slice Nbr" := IntLNbrTranche;
            RecLTableEcheancier.Insert;
            IntLMois := Date2DMY(CalcDate('+1M', DMY2Date(1, RecLTableEcheancier.Month, RecLTableEcheancier.Year)), 2);
            IntLAnnee := Date2DMY(CalcDate('+1M', DMY2Date(1, RecLTableEcheancier.Month, RecLTableEcheancier.Year)), 3);
        end;
    end;

    // [Scope('Internal')]
    procedure ReprendreEcheance(CodLNumPret: Code[20]; IntLType: Integer; IntLAnnee: Integer; IntLMois: Integer)
    var
        RecLTableEcheancier: Record "L&A Installment Schedule";
    begin
        RecLTableEcheancier.SetRange("N° Loan", CodLNumPret);
        RecLTableEcheancier.SetRange(Type, IntLType);
        RecLTableEcheancier.SetRange(Valid, true);
        if RecLTableEcheancier.Find('-') then begin
            if RecLTableEcheancier.Count - 1 = RecLTableEcheancier."Slice Nbr" then begin
                RecLTableEcheancier.Reset;
                if RecLTableEcheancier.Get(CodLNumPret, IntLType, IntLAnnee, IntLMois) then begin
                    RecLTableEcheancier.Valid := true;
                    RecLTableEcheancier.Modify;
                end;
                RecLTableEcheancier.Reset;
                RecLTableEcheancier.SetRange(RecLTableEcheancier."N° Loan", CodLNumPret);
                RecLTableEcheancier.SetRange(Type, IntLType);
                if RecLTableEcheancier.Find('+') then
                    RecLTableEcheancier.Delete;
            end
            else begin
                RecLTableEcheancier.Reset;
                if RecLTableEcheancier.Get(CodLNumPret, IntLType, IntLAnnee, IntLMois) then begin
                    RecLTableEcheancier.Valid := false;
                    RecLTableEcheancier.Modify;
                end;
            end;
        end;
        RecLTableEcheancier.Reset;
        RecLTableEcheancier.SetRange("N° Loan", CodLNumPret);
        RecLTableEcheancier.SetRange(Type, IntLType);
        RecLTableEcheancier.SetRange(Valid, true);
        if RecLTableEcheancier.Find('+') then
            if RecLTableEcheancier.Count > RecLTableEcheancier."Slice Nbr" then begin
                RecLTableEcheancier.Valid := false;
                RecLTableEcheancier.Modify;
            end;
        CurrPage.Update;
    end;

    // [Scope('Internal')]
    procedure FormatMois(IntLMois: Integer) TxtLMois: Text[30]
    begin
        case IntLMois of
            1:
                TxtLMois := 'January';
            2:
                TxtLMois := 'February';
            3:
                TxtLMois := 'March';
            4:
                TxtLMois := 'April';
            5:
                TxtLMois := 'May';
            6:
                TxtLMois := 'June';
            7:
                TxtLMois := 'July';
            8:
                TxtLMois := 'August';
            9:
                TxtLMois := 'September';
            10:
                TxtLMois := 'October';
            11:
                TxtLMois := 'November';
            12:
                TxtLMois := 'December';
        end;
    end;

    // [Scope('Internal')]
    procedure ValideInvisible(BooLVisible: Boolean)
    begin
        if BooLVisible = true then begin
            VEchan_G := true;
        end else begin
            VEchan_G := false;
        end;
        CurrPage.Update;
    end;

    //  [Scope('Internal')]
    procedure FermerEcheance()
    var
        RecLLoanAdvanceLines: Record "Loan & Advance Lines";
    begin
        RecLLoanAdvanceLines.SetRange(RecLLoanAdvanceLines.Type, 1);
        RecLLoanAdvanceLines.SetRange(RecLLoanAdvanceLines."No.", rec."N° Loan");
        RecLLoanAdvanceLines.SetFilter(RecLLoanAdvanceLines.Month, FormatMois(rec.Month));
        RecLLoanAdvanceLines.SetRange(RecLLoanAdvanceLines.Year, rec.Year);
        if RecLLoanAdvanceLines.Find('-') then
            rec.Delete;
    end;

    // [Scope('Internal')]
    procedure Refresh()
    begin
        CurrPage.Update;
    end;
}

