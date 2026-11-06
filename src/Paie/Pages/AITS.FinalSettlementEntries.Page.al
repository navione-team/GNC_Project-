page 70022 "Final Settlement Entries"
{
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Employee,Navigate';
    SourceTable = "Leave Entries";
    SourceTableView = WHERE("Entry Type" = FILTER("End of service"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(General)
            {
            }
            group(Approvals)
            {
                Visible = false;
                field("Direction Approve"; rec."Direction Approve")
                {
                    Caption = 'HR Approval';
                    Editable = coedit;

                    trigger OnValidate()
                    begin
                        UserSetup.Reset;
                        UserSetup.Get(UserId);
                        if rec."Direction Approve" = true then begin
                            rec."Gm.UserId" := UserSetup."User ID";
                            rec."Direction Approve date" := WorkDate;
                        end else
                            rec."Direction Approve date" := 0D;
                    end;
                }
                field("Direction Approve date"; rec."Direction Approve date")
                {
                    Caption = 'HR Approval date';
                }
                field("Account Approve"; rec."Account Approve")
                {
                    Caption = 'Account Approval';
                    Editable = accedit;

                    trigger OnValidate()
                    begin

                        UserSetup.Reset;
                        UserSetup.Get(UserId);
                        if rec."Account Approve" = true then begin
                            rec."Ac.Userid" := UserSetup."User ID";
                            rec."Account Approve Date" := WorkDate;
                        end else
                            rec."Account Approve Date" := 0D;
                    end;
                }
                field("Account Approve Date"; rec."Account Approve Date")
                {
                    Caption = 'Account Approval Date';
                }
            }
            group(Group)
            {
                Caption = 'Employee Informations';
                field("Entry Type"; rec."Entry Type")
                {
                    Editable = false;
                }
                field("Grounds for Term. Code"; rec."Grounds for Term. Code")
                {
                    Caption = 'Cause Of End Relationship';
                }
                field(Employee; rec.Employee)
                {
                }
                field(Name; rec.Name)
                {
                    Editable = false;
                }
                field("Contract Code"; rec."Contract Code")
                {
                    Editable = false;
                }
                field("Posting Date"; rec."Posting Date")
                {
                    Editable = false;
                }
                field("Joining Date"; rec."Joining Date")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Employement Date"; rec."Employement Date")
                {
                    Editable = false;
                }
                field("Last Working Date"; rec."Last Working Date")
                {
                }
                field("QID Expiry Date"; rec."SID Expiry Date")
                {
                    Editable = false;
                    Visible = false;
                }
                field("HC Expiry Date"; rec."HC Expiry Date")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Payroll Month"; rec."Payroll Month")
                {
                }
                field(Year; rec.Year)
                {
                    Editable = false;
                }
            }
            group("Final Sttlement Information")
            {
                Caption = 'Final Sttlement Information';
                Description = 'Final Sttlement Information';
                field("Basis Salary"; rec."Gross Salary")
                {
                    Editable = false;
                }
                field(Housing; rec.Housing)
                {
                    Editable = false;
                    Visible = false;
                }
                field("Annual Leave Days"; rec."Annual Leave Days")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Total Unpaid Days"; rec."Total Unpaid Days")
                {
                    Editable = false;
                }
                field("Total entitlement Leave Days"; rec."Total entitlement Leave Days")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Unpaid Leave"; rec."Unpaid Leave")
                {
                    Editable = false;
                }
                field("Total Leave Taken"; rec."Total Leave Taken")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Total Romaining"; rec."Total Romaining")
                {
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                    Visible = false;
                }
                group("Final Settlement Calculation")
                {
                    Caption = 'Final Settlement Calculation';
                }
                field("Service Year"; rec."Service Year")
                {
                    Caption = 'Period Eligeble for Gratuity Year';
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field("Service Days"; rec."Service Days")
                {
                    Caption = 'Period Eligeble for Gratuity Days';
                }
                field("Quantity Days"; rec."Quantity Days")
                {
                    Caption = 'Gratuity Days';
                    Editable = false;
                    Style = StrongAccent;
                    StyleExpr = TRUE;
                    Visible = false;
                }
                field("Leave Salary Entitled"; rec."Leave Salary Entitled")
                {
                    Editable = false;
                    Style = AttentionAccent;
                    StyleExpr = TRUE;
                    Visible = false;
                }
                field("Pending Salary"; rec."Pending Salary")
                {
                    Editable = false;
                    Style = AttentionAccent;
                    StyleExpr = TRUE;
                    Visible = false;
                }
                field("Total Unpaid OT Amount"; rec."Total Unpaid OT Amount")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Ticket Amount"; rec."Ticket Amount")
                {
                }
                field("EOSB Advance Amount"; rec."EOSB Advance Amount")
                {
                }
                field("Other Deduction"; rec."Other Deduction")
                {
                }
                field("QID Cost"; rec."SID Cost")

                {
                    Editable = false;
                    Visible = false;
                }
                field("HC Cost"; rec."HC Cost")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Total Amount  To pay"; rec."Total Amount  To pay")
                {
                    Caption = 'Total Gratuity Amount';
                    Editable = false;
                    Style = Favorable;
                    StyleExpr = TRUE;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control48; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Calculate Gratuity")
            {
                Image = CalculateConsumption;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    HRSetup.Get();
                    if rec."Last Working Date" = 0D then
                        Message('Please fill Last Working Date')
                    else
                        if rec."Payroll Month" = rec."Payroll Month"::"  " then
                            Message('Please fill Payroll Month')
                        else begin
                            rec.CalcFields("EOSB Advance Amount");
                            //
                            if RecGEmployee.Get(rec.Employee) then
                                RecGEmployee.TestField(Status, RecGEmployee.Status::Active);

                            RecGEmployee.CalcFields("Basic Salary");
                            if Rec."Last Working Date" <> 0D then
                                Rec."Service Year" := Rec."Service Days" / 360;
                            if Rec."Service Year" < 1 then
                                Gratuity_Year := 0
                            else begin
                                Evaluate(Rec."Service Days", Format(Rec."Last Working Date" - RecGEmployee."Employment Date" + 1));
                                OneDaySal := RecGEmployee."Basic Salary" / 30;
                                Rec."Service Days" := Rec."Service Days" / 365 * 360;
                                Rec."Service Year" := Rec."Service Days" / 360;
                                rec."Quantity Days" := Rec."Service Days";
                                Rec.Modify;
                                rec."Service Year" := Rec."Service Year";
                                Gratuity_Year := OneDaySal * RecGEmployee."Contract Vacation Days";
                                //  MESSAGE('%1',Gratuity_Year);
                                rec."Total Amount  To pay" := Gratuity_Year * rec."Service Year" + Rec."Pending Salary";

                            end;

                        end;


                    Rec."Total Amount  To pay" := (Rec."Total Amount  To pay" + Rec."Ticket Amount" + Rec."Pending Salary") - Rec."EOSB Advance Amount" - Rec."Other Deduction";
                    Rec.Modify;

                    Message('Calculation Done');
                end;
            }
            action("Calculate Pending Salary")
            {
                Image = PaymentHistory;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = true;

                trigger OnAction()
                begin
                    //"Get Previous Salary"(Rec);
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
                    Rec.Status := Rec.Status::Released;
                    Rec."Version No" := Rec."Version No" + 1;
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
                    Rec.Status := Rec.Status::Open;
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
                    if Rec."Direction Approve" = false then
                        Error('Record Not Approved')
                    else

                        if Confirm('confirm registration?', true) then begin
                            recG_Recorded_paid_anuel_L.Init;

                            repeat
                                recG_Recorded_paid_anuel_L.TransferFields(Rec);
                                recG_Recorded_paid_anuel_L.Insert;
                            until Rec.Next = 0;
                            Rec.DeleteAll;
                            Message('Succefully recorded');

                        end
                        else
                            Message('Posting Cancelled');


                end;
            }
            action("Print FS Form")
            {
                Image = Print;
                Promoted = true;

                trigger OnAction()
                begin
                    /*IF "Direction Approve"=FALSE THEN
                     ERROR('Record Not Approved')
                   ELSE */

                    Rec.SetRange(Employee, Rec.Employee);
                    if Rec.FindSet then
                        REPORT.Run(50036, true, false, Rec);

                end;
            }
            action("Tenure Calculation")
            {
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = false;
            }
        }
    }

    trigger OnInit()
    begin

        UserSetup.Reset;
        UserSetup.Get(UserId);
        /*
        CurrPage.UPDATE;
        visible:=FALSE;
        */

    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec."Entry Type" := Rec."Entry Type"::"End of service";
        Rec."Cause of Absence Code" := 'FS';
        if RecGEmployee.Get(Rec.Employee) then
            Rec."Grounds for Term. Code" := RecGEmployee."Grounds for Term. Code";
    end;

    trigger OnModifyRecord(): Boolean
    begin
        /*IF UserSetup.HR=FALSE THEN
          ERROR('You are not alowed to Modify this recored');
          */

    end;

    trigger OnOpenPage()
    begin
        /*IF UserSetup.GET(USERID) THEN
          BEGIN
          IF UserSetup."GM Leave Approve"=TRUE THEN
             GMedit:=TRUE;
          "Gm.UserId":=UserSetup."User ID";
        
          IF UserSetup."Account leave Approve"=TRUE THEN
             AccountEdit:=TRUE;
            "Ac.Userid":=UserSetup."User ID";
        
        
         END;
         IF UserSetup.HR=TRUE THEN
         visible:=TRUE;
        
        // "Manuel Input Days":=FALSE;
         "User ID":=USERID;
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
        RecGDaysoff: Record "Employee Posted Absence";
        isvisible: Boolean;
        fromdate: Boolean;
        todate: Boolean;
        resumedate: Boolean;
        amountleavetopay: Boolean;
        payrollmonth: Boolean;
        payrollyear: Boolean;
        contractcode: Boolean;
        basissalary: Boolean;
        employmentdate: Boolean;
        joinningdate: Boolean;
        tenue: Boolean;
        entitlementdays: Boolean;
        leavetaken: Boolean;
        totromain: Boolean;
        vacdays: Boolean;
        previoussal: Boolean;
        eosb: Boolean;
        hraamount: Boolean;
        lastworkingdate: Boolean;
        qty: Boolean;
        deduct: Boolean;
        STATUS: Boolean;
        UserSetup: Record "User Setup";
        GMedit: Boolean;
        AccountEdit: Boolean;
        Eosbtenure: Boolean;
        PaidleaveAmount: Boolean;
        QidRomainingDays: Integer;
        HCRomainingDays: Integer;
        QIDExpiryDate: Date;
        HCExpiryDate: Date;
        HRSetup: Record "Human Resources Setup";
        RecgLeaveEntries: Record "Leave Entries";
        RecGrecordedPL: Record "Recorded Leave entries";
        TotalAmountPL: Decimal;
        NORMALOT: Decimal;
        HOLIDAYOT: Decimal;
        Tot_previous_Salary: Decimal;
        RecGSalaryline: Record "Rec.Salary Line";
        NoEmp: Code[10];
        visible: Boolean;
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
        bascalc: Decimal;
        CoEdit: Boolean;
        AccEdit: Boolean;
        OneDaySal: Decimal;
        Gratuity_Year: Decimal;

    local procedure "Get Previous Salary"(RecFS: Record "Leave Entries")
    var
        RecEmployee: Record Employee;
        RecAbsence: Record "Employee Posted Absence";
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

        GrosSalaryM := (totalPackage / 30) * WorkedDaysM;
        NetsalaryCashedM := GrosSalaryM - LoanAdvanceAmountM - DeductionsM + AdditionM;
        Rec."Pending Salary" := Round(NetsalaryCashedM, 1);
        Rec."Pending Salary days" := WorkedDaysM;
        Rec.Modify(true);
        Message('The calculation of the total salary has been completed')

    end;
}

