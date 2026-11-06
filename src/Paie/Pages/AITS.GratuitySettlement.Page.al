page 70041 "Gratuity Settlement"
{
    PageType = List;
    SourceTable = "Leave Entries";
    SourceTableView = WHERE("Entry Type" = FILTER("End of service"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; rec."Entry Type")
                {
                    //  ShowCaption = false;
                }
                field("Grounds for Term. Code"; Rec."Grounds for Term. Code")
                { }
                field(Employee; rec.Employee)
                {
                    //  ShowCaption = false;
                    trigger OnValidate()
                    begin
                        if RecGEmployee.get(rec.Employee) then
                            rec."Last Working Date" := RecGEmployee."Termination Date";
                    end;


                }
                field(Name; rec.Name)
                {
                    // ShowCaption = false;
                }
                field("Posting Date"; rec."Posting Date")
                {
                    //  ShowCaption = false;
                }
                field("Employement Date"; rec."Employement Date")
                {
                    // ShowCaption = false;
                }
                field("Last Working Date"; rec."Last Working Date")
                {
                    caption = 'Termination Date';
                }

                field("Payroll Month"; rec."Payroll Month")
                {
                    // ShowCaption = false;
                }
                field("Contract Code"; rec."Contract Code")
                {
                    // ShowCaption = false;
                }
                field("Gross Salary"; rec."Gross Salary")
                {
                    //ShowCaption = false;
                }

                field("Other Deduction"; rec."Other Deduction")
                {
                    //ShowCaption = false;
                }


                field("Service Year"; rec."Service Year")
                {
                    //ShowCaption = false;
                }
                field("Pending Salary"; rec."Pending Salary")
                {
                    //ShowCaption = false;
                }
                field("EOSB Amount"; rec."EOSB Amount")
                {
                    // ShowCaption = false;
                }
                field("Ticket Amount"; rec."Ticket Amount")
                {
                    //ShowCaption = false;
                }
                field("EOSB Advance Amount"; rec."EOSB Advance Amount")
                {
                    // ShowCaption = false;
                }
                field("Work Company"; rec."Work Company")
                {
                    ShowCaption = false;
                }
                field("Total Amount  To pay"; rec."Total Amount  To pay")
                {
                    // ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Calculate Pending Salary")
            {
                Image = PaymentHistory;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;

                trigger OnAction()
                begin
                    "Get Previous Salary"(Rec);
                    rec.SETRANGE(Rec."Entry Type", Rec."Entry Type"::"Annual Leave");
                end;
            }
            action("Calculate Gratuity")
            {
                Image = CalculateConsumption;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()

                begin

                    HRSetup.Get();
                    CurrPage.SetSelectionFilter(Rec);
                    if Rec.FINDSET then
                        repeat
                            fs.CalcFinalSettlement(rec, EOSBAmount, ServicesYear);
                            rec."EOSB Amount" := EOSBAmount;
                            rec."Service Year" := ServicesYear;

                            rec."Total Amount  To pay" := (rec."EOSB Amount" + rec."Ticket Amount" + rec."Pending Salary") - rec."EOSB Advance Amount" - rec."Other Deduction";
                            rec.MODIFY;


                        until Rec.NEXT = 0;

                    Message('Calculation Done');
                    //END;
                end;

            }
            action(Release)
            {
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    rec.Status := rec.Status::Released;
                    rec."Version No" := rec."Version No" + 1;
                    CurrPage.Editable := false;
                    Message('Released and Waiting for Approve');
                end;
            }
            action(Reopen)
            {
                Image = ReopenCancelled;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    rec.Status := rec.Status::Open;
                end;
            }
            action(Post)
            {
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    /*IF "Direction Approve"=FALSE THEN
                     ERROR('Record Not Approved')
                   ELSE*/

                    if Confirm('confirm registration?', true) then begin
                        recG_Recorded_paid_anuel_L.INIT;

                        repeat
                            recG_Recorded_paid_anuel_L.TRANSFERFIELDS(Rec);
                            recG_Recorded_paid_anuel_L.INSERT;
                        until Rec.NEXT = 0;
                        Rec.DELETEALL;
                        Message('Succefully recorded');

                    end
                    else
                        Message('Posting Cancelled');



                end;
            }
            action("Print Gratuity Form")
            {
                Image = Print;
                Promoted = true;

                trigger OnAction()
                begin
                    /*IF "Direction Approve"=FALSE THEN
                     ERROR('Record Not Approved')
                   ELSE */

                    Rec.SETRANGE(Employee, rec.Employee);
                    if Rec.FINDSET then
                        REPORT.Run(50040, true, false, Rec);

                end;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        rec."Entry Type" := rec."Entry Type"::"End of service";
    end;

    trigger OnOpenPage()
    begin
        rec.SETRANGE(Rec."Entry Type", Rec."Entry Type"::"End of service");

    end;

    var
        HRSetup: Record "Human Resources Setup";
        Gratuity_Year: Decimal;
        OneDaySal: Decimal;
        recG_Recorded_paid_anuel_L: Record "Recorded Leave entries";
        RecGEmployee: Record Employee;
        SD: Decimal;
        SY: Decimal;
        net_days: Decimal;
        taken_Days: Decimal;
        rectif: Decimal;
        STATUS: Boolean;
        UserSetup: Record "User Setup";
        GMedit: Boolean;
        AccountEdit: Boolean;
        TotalUpaid: Decimal;
        NoEmp: Code[20];
        visible: Boolean;
        Vacation_req: Page "Employee Vacation Request";
        Vac_req: Page "Vacation Request History";
        Vacation_request: Record "Vacation Request History";
        CoEdit: Boolean;
        AccEdit: Boolean;
        Vac_days: Decimal;
        "TotalAbsencedaysM-1": Decimal;
        "TotalAmountAbsenceM-1": Decimal;
        TotalAbsencedaysM: Decimal;
        TotalAmountAbsenceM: Decimal;
        AmountGlobalAbsence: Decimal;
        "TotalSalaryM-1": Decimal;
        "PaidDaysM-1": Decimal;
        PrevEndDate: Date;
        PaidDaysM: Integer;
        MonthDaysM: Integer;
        "MonthDaysM-1": Integer;
        WorkedDaysM: Decimal;
        "WorkedDaysM-1": Decimal;
        "LoanAdvanceAmountM-1": Decimal;
        RecordAdv: Record "Rec. Loan & Advance";
        Abs_entry: Record "Employee Posted Absence";
        qty_abs: Decimal;
        Yticket: Decimal;
        Eligible_vac: Decimal;
        fs: Codeunit "EOSB Calculator ";
        EOSBAmount: Decimal;
        ServicesYear: decimal;


    procedure "Get Previous Salary"(RecFS: Record "Leave Entries")
    var
        RecEmployee: Record Employee;
        RecAbsence: Record "TimeSheet Line";
        RecLoanAdv: Record "Loan & Advance";
        GrosSalaryM: Decimal;
        LoanAdvanceAmountM: Decimal;
        DeductionsM: Decimal;
        AdditionM: Decimal;
        NetsalaryCashedM: Decimal;
        recContract: Record "Employment Contract";
        PaidDays: Decimal;
        totalPackage: Decimal;
        holidayOT: Decimal;
        reguilarOT: Decimal;
        AmountReguilarOT: Decimal;
        AmountHolidayOT: Decimal;
        HourBase: Decimal;
        hoursgross: Decimal;
        "LoanAdvanceAmountM-1": Decimal;
        "DeductionsM-1": Decimal;
        "AdditionM-1": Decimal;
        "GrosSalaryM-1": Decimal;
        "NetsalaryCashedM-1": Decimal;
        MonthDaysM: Decimal;
        PrevEndDate: Date;
        "MonthDaysM-1": Integer;

    begin

        Rec.RESET;
        RecEmployee.Reset;
        MonthDaysM := Date2DMY(CalcDate('CM', Rec."Last Working Date"), 1);
        PrevEndDate := CalcDate('<-1D>', CalcDate('CM', Rec."Last Working Date"));
        "MonthDaysM-1" := Date2DMY(CalcDate('cm', PrevEndDate), 1);



        if RecEmployee.Get(Rec.Employee) then
            RecEmployee.CalcFields("Gross Salary");
        totalPackage := RecEmployee."Gross Salary";


        HourBase := Rec."Gross Salary" / 30 / 8;
        hoursgross := totalPackage / 30 / 30;

        WorkedDaysM := (Date2DMY(Rec."Last Working Date", 1)) - TotalAbsencedaysM;

        "WorkedDaysM-1" := "MonthDaysM-1" - "TotalAbsencedaysM-1";

        if (Date2DMY(Rec."Last Working Date", 2) = 2) and (WorkedDaysM >= 28) then
            WorkedDaysM := 30;
        Abs_entry.RESET;
        Abs_entry.SETRANGE("Employee No.", Rec.Employee);
        Abs_entry.SETRANGE("Posting month", Rec."Payroll Month");
        Abs_entry.SETFILTER("Line type", '=%1', Abs_entry."Line type"::"  ");
        if Abs_entry.FINDSET then
            Abs_entry.CALCSUMS("Quantity(days)");
        qty_abs := Abs_entry."Quantity(days)";
        WorkedDaysM := WorkedDaysM - qty_abs;

        GrosSalaryM := (totalPackage / 30) * WorkedDaysM;
        RecordAdv.RESET;
        RecordAdv.SETRANGE(Month, Rec."Payroll Month");
        RecordAdv.SETRANGE(Employee, Rec.Employee);
        RecordAdv.SETRANGE(Year, Rec.Year);
        if RecordAdv.FINDSET then
            RecordAdv.CALCSUMS(Amount);
        LoanAdvanceAmountM := RecordAdv.Amount;

        NetsalaryCashedM := GrosSalaryM - LoanAdvanceAmountM - DeductionsM + AdditionM;
        Rec."Pending Salary" := Round(NetsalaryCashedM, 1);
        Rec."Pending Salary days" := WorkedDaysM;

        Rec.MODIFY(true);
        Message('The calculation of the total salary has been completed');
        //Rec.SETFILTER("Entry Type",Rec."Entry Type"::"Annual Leave");

    end;
}

