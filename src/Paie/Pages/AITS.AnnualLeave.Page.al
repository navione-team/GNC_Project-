page 70016 "Annual Leave"
{
    PageType = List;
    SourceTable = "Leave Entries";
    SourceTableView = WHERE("Entry Type" = FILTER("Annual Leave"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(Approvals)
            {
                Visible = false;
                field("Direction Approve"; Rec."Direction Approve")
                {
                    Caption = 'Direction Approve';
                    Editable = CoEdit;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        if Rec."Direction Approve" = true then
                            Rec."Direction Approve date" := WorkDate
                        else
                            Rec."Direction Approve date" := 0D;
                    end;
                }
                field("Direction Approve date"; Rec."Direction Approve date")
                {
                    Caption = 'Direction Approve date';
                    Editable = Gmedit;
                    Visible = false;
                }
                field("Account Approve"; Rec."Account Approve")
                {
                    Editable = AccEdit;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        if Rec."Account Approve" = true then
                            Rec."Account Approve Date" := WorkDate()

                        else
                            Rec."Account Approve Date" := 0D;
                    end;
                }
                field("Account Approve Date"; Rec."Account Approve Date")
                {
                    Editable = AccountEdit;
                    Visible = false;
                }
            }
            repeater(Group)
            {
                field(Employee; Rec.Employee)
                {
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    StyleExpr = TRUE;
                }

                field(Name; Rec.Name)
                {
                    Editable = false;
                }
                field("Contract Code"; Rec."Contract Code")
                {
                    Editable = false;
                }
                field("From date"; Rec."From date")
                {
                }
                field("To date"; Rec."To date")
                {
                }
                field("Joining Date"; Rec."Joining Date")
                {
                    Editable = false;
                }
                field("Last Working Date"; Rec."Last Working Date")
                {
                }
                field("Resume Date"; Rec."Resume Date")
                {
                }

                field("Last resume Date"; Rec."Last resume Date")
                {
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("Grant Exception"; Rec."Grant Exception")
                {
                }
                field("Payroll Month"; Rec."Payroll Month")
                {
                }
                field(Year; Rec.Year)
                {
                    Caption = 'Posting Year';
                }
                field("Leave Days"; Rec."Quantity Days")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                    Caption = 'Leave Days';
                }
                field("Annual Leave Days"; Rec."Annual Leave Days")
                {
                    Visible = false;
                }
                field("Service Year"; Rec."Service Year")
                {
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                    Visible = false;
                }
                field("Total entitlement Leave Days"; Rec."Total entitlement Leave Days")
                {
                    Visible = false;
                }
                field("Total Leave Taken"; Rec."Total Leave Taken")
                {
                    Visible = false;
                }
                field("Total Romaining"; Rec."Total Romaining")
                {
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = TRUE;
                    Visible = false;
                }
                field("Gross Salary"; Rec."Gross Salary")
                {
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("OverTime Amount"; Rec."OverTime Amount")
                {
                    Visible = false;
                }
                field("Incentive Amount"; Rec."Incentive Amount")
                {
                    Visible = false;
                }
                field("Ticket Amount"; Rec."Ticket Amount")
                {
                }
                field("Pending Salary days"; Rec."Pending Salary days")
                {
                }
                field("Pending Salary"; Rec."Pending Salary")
                {
                }
                field("Leave Amount"; Rec."Leave Salary Entitled")
                {

                }
                field("Total Amount  To pay"; Rec."Total Amount  To pay")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
            }
            group(Control10014505)
            {
                ShowCaption = false;
                part("Leave Histroy"; "Leave Histroy SubPage")
                {
                    Caption = 'Leave Histroy';
                    SubPageLink = Employee = FIELD(Employee),
                                  "Entry Type" = FIELD("Entry Type");
                }
            }
        }
        area(factboxes)
        {
            systempart(Control10014502; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Calculate Leave Salary")
            {
                Caption = 'Paid Leave Calculation';
                Image = CalculateConsumption;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if RecGEmployee.get(rec.Employee) then
                        RecGEmployee.CalcFields("Gross Salary");
                    if RecGEmployee."Last Resume Date" = 0D then
                        lastResume := RecGEmployee."Employment Date"
                    else
                        lastResume := RecGEmployee."Last Resume Date";
                    LastWorkingDate := rec."Last Working Date";
                    repeat

                        CalculateLeaveFromResume(lastResume, LastWorkingDate, RecGEmployee."Gross Salary", Amountleavepay);
                        rec."Leave Salary Entitled" := Amountleavepay;

                        rec."Total Amount  To pay" := rec."Leave Salary Entitled" + rec."Pending Salary";
                        rec.Modify(true);

                    until Rec.Next = 0;
                    Message('Calculation Done');

                end;
            }
            action(Post)
            {
                Caption = 'Post';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    /*
                    
                     IF "Direction Approve"=FALSE THEN
                      ERROR('Record Not Approved')
                    ELSE*/

                    if Confirm('confirm registration?', true) then
                        CurrPage.SetSelectionFilter(Rec);
                    if Rec.FindSet then begin
                        recG_Recorded_paid_anuel_L.Init;

                        repeat
                            recG_Recorded_paid_anuel_L.TransferFields(Rec);
                            recG_Recorded_paid_anuel_L.Insert;
                            if RecGEmployee.Get(Rec.Employee) then begin
                                RecGEmployee."Leave Status" := RecGEmployee."Leave Status"::"On Vacation";

                                RecGEmployee.Modify;
                            end;
                        until Rec.Next = 0;
                        Rec.DeleteAll;
                        Message('Succefully recorded');


                    end
                    else
                        Message('Posting Cancelled');



                end;
            }
            action("Print Leave Request Form")
            {
                Caption = 'Print Leave Sattlement Form';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    /* IF "Direction Approve"=FALSE THEN
                      ERROR('Record Not Approved')
                    ELSE */

                    Rec.SetRange(Employee, Rec.Employee);
                    if Rec.FindSet then
                        REPORT.Run(50039, true, true, Rec);

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
                    Rec.Status := 1;
                    Rec."Version No" := Rec."Version No" + 1;
                    CurrPage.Editable := false;
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
                    Rec.Status := 0;
                end;
            }
            action("Import From Employee Request")
            {
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
            }
            action("Calculate Pending Salary")
            {
                Image = PaymentHistory;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    "Get Previous Salary"(Rec);
                    Rec.SetRange(Rec."Entry Type", Rec."Entry Type"::"Annual Leave");
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin


    end;

    trigger OnInit()
    begin
        UserSetup.Get(UserId);
        //visible:=FALSE
        //}
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec."Entry Type" := Rec."Entry Type"::"Annual Leave";

        Rec."Cause of Absence Code" := 'ANN LEAV';
    end;

    trigger OnModifyRecord(): Boolean
    begin
        /*IF UserSetup.HR=FALSE THEN
          ERROR('You are not alowed to Modify this recored');
          */

    end;

    trigger OnOpenPage()
    begin
        /*IF UserSetup.HR=TRUE THEN
          visible:=TRUE;
        IF UserSetup.GET(USERID) THEN
          BEGIN
          IF UserSetup."GM Leave Approve"=TRUE THEN
             GMedit:=TRUE;
          "Gm.UserId":=UserSetup."User ID";
        
          IF UserSetup."Account leave Approve"=TRUE THEN
             AccountEdit:=TRUE;
            "Ac.Userid":=UserSetup."User ID";
           END;
           */
        if UserSetup."CEO Approve" = true then
            CoEdit := true
        else
            CoEdit := false;
        if UserSetup."Account Approve" = true then
            AccEdit := true else
            AccEdit := false;

    end;

    var
        RecGEmployee: Record Employee;
        SD: Decimal;
        SY: Decimal;
        net_days: Decimal;
        recG_Recorded_paid_anuel_L: Record "Recorded Leave entries";
        taken_Days: Decimal;
        rectif: Decimal;
        STATUS: Boolean;
        UserSetup: Record "User Setup";
        GMedit: Boolean;
        AccountEdit: Boolean;
        TotalUpaid: Decimal;
        NoEmp: Code[20];
        visible: Boolean;
        Vacation_req: Page "Vacation Request History";
        Vac_req: Page "Vacation Request History";
        Vacation_request: Record "Employee Vacation Request";
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
        lastResume: date;
        LastWorkingDate: date;
        Amountleavepay: Decimal;
        leaveDays: Decimal;

    local procedure "Get Previous Salary"(RecFS: Record "Leave Entries")
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
        Abs_emp: Record "Employee Posted Absence";
    begin

        Rec.Reset;
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
        Abs_entry.Reset;
        Abs_entry.SetRange("Employee No.", Rec.Employee);
        Abs_entry.SetRange("Posting month", Rec."Payroll Month");
        Abs_entry.SetFilter("Line type", '=%1', Abs_entry."Line type"::"Deductible of Salary");
        if Abs_entry.FindSet then
            Abs_entry.CalcSums("Quantity(days)");
        qty_abs := Abs_entry."Quantity(days)";
        WorkedDaysM := WorkedDaysM - qty_abs;

        GrosSalaryM := (totalPackage / 30) * WorkedDaysM;
        RecordAdv.Reset;
        RecordAdv.SetRange(Month, Rec."Payroll Month");
        RecordAdv.SetRange(Employee, Rec.Employee);
        RecordAdv.SetRange(Year, Rec.Year);
        if RecordAdv.FindSet then
            RecordAdv.CalcSums(Amount);
        LoanAdvanceAmountM := RecordAdv.Amount;

        NetsalaryCashedM := GrosSalaryM - LoanAdvanceAmountM - DeductionsM + AdditionM;
        Rec."Pending Salary" := Round(NetsalaryCashedM, 1);
        Rec."Pending Salary days" := WorkedDaysM;
        //over time Amount
        Abs_emp.Reset;
        Abs_emp.SetRange("Employee No.", Rec.Employee);
        Abs_emp.SetRange("Posting month", Rec."Payroll Month");
        Abs_emp.SetFilter("Over Time Amount", '<>%1', 0);
        if Abs_emp.FindSet then begin
            Abs_emp.CalcSums("Over Time Amount");
            Rec."OverTime Amount" := Abs_emp."Over Time Amount";

        end;
        //over time Amount

        // Incentive Amount

        Abs_emp.Reset;
        Abs_emp.SetRange("Employee No.", Rec.Employee);
        Abs_emp.SetRange("Posting month", Rec."Payroll Month");
        Abs_emp.SetFilter("Entry Type", '=%1', Abs_emp."Entry Type"::Incentive);
        if Abs_emp.FindSet then begin
            Abs_emp.CalcSums("Over Time Amount");
            Rec."Incentive Amount" := Abs_emp."Incentive Amount";


        end;

        // Incentive Amount

        Rec.Modify(true);
        Message('The calculation of the total salary has been completed');
        //Rec.SETFILTER("Entry Type",Rec."Entry Type"::"Annual Leave");

    end;

    local procedure CalculateLeaveFromResume(
    lastResumeDate: Date;
    LastWorkDate: Date;
    MonthlySalary: Decimal;
    LeavePay: Decimal

    )



    var
        LeaveDaysEarned: Decimal;
        DailyRate: Decimal;
        ServiceDays: Integer;
        AnnualEntitlement: Decimal;
    begin

        ServiceDays := LastWorkDate - lastResumeDate + 1;

        // Entitlement based on total service
        if ServiceDays >= (5 * 365) then
            AnnualEntitlement := 30
        else
            AnnualEntitlement := 21;

        // Leave days earned for this vacation period
        LeaveDaysEarned := Round((ServiceDays / 365.0) * AnnualEntitlement, 2);

        REC."Quantity Days" := LeaveDaysEarned;
        rec."Annual Leave Days" := REC."Quantity Days";
        REC.MODIFY;

        // Daily rate (Saudi payroll: 30 days per month)
        DailyRate := Round(MonthlySalary / 30.0, 2);
        // Leave pay
        LeavePay := Round(LeaveDaysEarned * DailyRate, 2);
        Amountleavepay := LeavePay;

    end;
}

