report 70000 Fill_Salary
{
    ProcessingOnly = true;
    ApplicationArea = All;

    dataset
    {
        dataitem("Salary Header"; "Salary Header")
        {
            RequestFilterFields = No;
            dataitem(Employee; Employee)
            {
                DataItemTableView = SORTING("No.") WHERE(Status = FILTER(Active));
                RequestFilterFields = "No.", "Global Dimension 1 Code", "Global Dimension 2 Code", "Employee Department";

                trigger OnAfterGetRecord()
                begin
                    if "Salary Header"."Payroll Status" = "Salary Header"."Payroll Status"::Released then
                        Error('Payroll Closed')
                    else begin
                        HR_Setup.Get();
                        SalaryLine.RESET;
                        SalaryLine.SETRANGE("Document No.", "Salary Header".No);
                        SalaryLine.SETRANGE(Employee, Employee."No.");
                        if SalaryLine.FIND('-') then
                            if Confirm('Erase Existing Line?') then
                                SalaryLine.DELETEALL;

                        begin


                            "Salary Header".TESTFIELD("Posting Month");
                            wind.Update(2, Employee."No." + ':' + Employee."Search Name");

                            SalaryLine.RESET;
                            SalaryLine.INIT;


                            SalaryLine.VALIDATE("Document No.", "Salary Header".No);
                            SalaryLine.Description := 'Payroll' + ' ' + Format("Salary Header"."Posting Month") + ' ' + Format("Salary Header"."Posting Year");
                            SalaryLine.VALIDATE(Employee, Employee."No.");
                            SalaryLine."Full Name" := Employee."Search Name";
                            SalaryLine."Posting Month" := "Salary Header"."Posting Month";
                            SalaryLine."Posting Year" := "Salary Header"."Posting Year";
                            SalaryLine."Posting Date" := "Salary Header"."Posting Date";
                            SalaryLine."Creation Date" := Today();
                            Employee.CalcFields("Basic Salary", "Accomodation Allowance", "Transportation Allowances");
                            SalaryLine."Basic Salary" := Employee."Basic Salary";
                            SalaryLine."Employee Nationality" := Employee."Country of Origin";
                            SalaryLine."Employer EID" := Employee."Payer ID";
                            SalaryLine."Employment Date" := Employee."Employment Date";
                            SalaryLine.IBAN := Employee.IBAN;
                            SalaryLine.Sponsor := Employee."Sponsor Name";
                            SalaryLine.VALIDATE("Employee Responsability Center", Employee."Work Company");
                            //SalaryLine."Payer Code" := Employee."Payer ID";
                            //SalaryLine.Payer := Employee.
                            SalaryLine.VALIDATE("Employee Contract Code", Employee."Emplymt. Contract Code");
                            SalaryLine."Paid Days" := HR_Setup."Paid Days";
                            SalaryLine.VALIDATE("Payment Method", Employee."Payment Method Code");
                            Employee.CalcFields("Gross Salary");
                            SalaryLine."Gross Salary" := Employee."Gross Salary" + SalaryLine.Adjustment;

                            SalaryLine."Global Dimension 1 Code" := Employee."Global Dimension 1 Code";
                            SalaryLine."Employee Bank Name" := Employee.Bank;
                            SalaryLine."Employee Posting Group" := Employee."Employee Posting Group";
                            SalaryLine."Employee Departement" := Employee."Employee Posting Group";
                            SalaryLine."Payment Type" := SalaryLine."Payment Type"::Salary;
                            //SalaryLine."Bonus Allowance":=Employee.

                            //Salary Adjustment
                            Abs_emp.RESET;
                            Abs_emp.SETRANGE("Employee No.", SalaryLine.Employee);
                            Abs_emp.SETRANGE("Posting month", "Salary Header"."Posting Month");
                            Abs_emp.SETFILTER("Entry Type", '=%1', Abs_emp."Entry Type"::"Salary Adjustement");
                            if Abs_emp.FINDSET then begin
                                Abs_emp.CALCSUMS(Amount);
                                //MESSAGE('%1', Abs_emp.Amount);
                                SalaryLine.Adjustment := Abs_emp.Amount;

                            end;


                            //leave
                            NofDays := GetDaysInMonth("Salary Header"."Posting Month", "Salary Header"."Posting Year");
                            Employee.CalcFields("Gross Salary");
                            SalaryLine."Annual Leave Days Qty" := HR_Setup."Leave Days Per Month";
                            SalaryLine."Annual Leave  Amount" := round((Employee."Gross Salary" / NofDays) * HR_Setup."Leave Days Per Month", 0.01);

                            //VAVACTION
                            if Employee."Leave Status" = Employee."Leave Status"::"On Vacation" then begin
                                SalaryLine."Gross Salary" := 0;
                                SalaryLine."Net Pay" := 0;
                                // SalaryLine.MODIFY;
                            end;


                            //absence management
                            Abs_emp.RESET;
                            Abs_emp.SETRANGE("Employee No.", SalaryLine.Employee);
                            Abs_emp.SETRANGE("Posting month", "Salary Header"."Posting Month");
                            Abs_emp.SETRANGE("Line type", Abs_emp."Line type"::"Deductible of Salary");
                            if Abs_emp.FINDSET then begin
                                Abs_emp.CALCSUMS("Quantity(days)");
                                SalaryLine."Abscence Days" := Abs_emp."Quantity(days)";
                                SalaryLine."Absence Note" := Abs_emp.Description;

                            end;


                            //OverTime
                            Abs_emp.RESET;
                            Abs_emp.SETRANGE("Employee No.", SalaryLine.Employee);
                            Abs_emp.SETRANGE("Posting month", "Salary Header"."Posting Month");
                            Abs_emp.SETFILTER("Entry Type", '=%1', Abs_emp."Entry Type"::"Over Time");
                            if Abs_emp.FINDSET then begin
                                Abs_emp.CALCSUMS("Over Time Amount");
                                SalaryLine."Over Time Amount" := Abs_emp."Over Time Amount";
                                SalaryLine."Extra Hours" := Abs_emp."Over Time Hours";

                            end;

                            // Incentive Amount
                            Abs_emp.RESET;
                            Abs_emp.SETRANGE("Employee No.", SalaryLine.Employee);
                            Abs_emp.SETRANGE("Posting month", "Salary Header"."Posting Month");
                            Abs_emp.SETFILTER("Entry Type", '=%1', Abs_emp."Entry Type"::Incentive);
                            if Abs_emp.FINDSET then begin
                                Abs_emp.CALCSUMS("Over Time Amount");
                                SalaryLine."Incentive Amount" := Abs_emp."Incentive Amount";
                                SalaryLine."Extra Hours" := Abs_emp."Over Time Hours";

                            end;


                            // Addition Amount
                            Abs_emp.RESET;
                            Abs_emp.SETRANGE("Employee No.", SalaryLine.Employee);
                            Abs_emp.SETRANGE("Posting month", "Salary Header"."Posting Month");
                            Abs_emp.SETFILTER("Entry Type", '=%1', Abs_emp."Entry Type"::"Addition");
                            if Abs_emp.FINDSET then begin
                                Abs_emp.CALCSUMS(Amount);
                                SalaryLine.Addition := Abs_emp.Amount;
                            end;


                            // Deduction Amount
                            Abs_emp.RESET;
                            Abs_emp.SETRANGE("Employee No.", SalaryLine.Employee);
                            Abs_emp.SETRANGE("Posting month", "Salary Header"."Posting Month");
                            Abs_emp.SETFILTER("Entry Type", '=%1', Abs_emp."Entry Type"::"Deduction");
                            if Abs_emp.FINDSET then begin
                                Abs_emp.CALCSUMS(Amount);
                                SalaryLine.Deductions := Abs_emp.Amount;
                            end;

                            //Holiday Salary
                            Abs_emp.RESET;
                            Abs_emp.SETRANGE("Employee No.", SalaryLine.Employee);
                            Abs_emp.SETRANGE("Posting month", "Salary Header"."Posting Month");
                            Abs_emp.SETFILTER("Entry Type", '=%1', Abs_emp."Entry Type"::"Puplic Holiday");
                            if Abs_emp.FINDSET then begin
                                Abs_emp.CALCSUMS("Over Time Amount");
                                // SalaryLine."Over Time Amount":=Abs_emp."Over Time Amount";
                                SalaryLine."Holiday Salary" := Abs_emp."Over Time Amount";

                            end;

                            //Gosi
                            RecSocialCont.get('GOSI');
                            CalcFields("Basic Salary");
                            IF "GOSI Applied" = TRUE then begin
                                SalaryLine."GOSI Employee Amount" := Round(((RecSocialCont."Employee's part" / 100) * ("Basic Salary" + "Accomodation Allowance")), 1);
                                SalaryLine."GOSI Employer Amount" := ROUND(((RecSocialCont."Employer's part" / 100) * ("Basic Salary" + "Accomodation Allowance")), 1);
                            END;

                            //Insurance
                            if "Insurance Affiliated" = true then
                                SalaryLine."Employee Insurance Amount" := "Insurance Amount per Year" / 12;

                            //Loan
                            RecLoanAdvance.RESET;
                            RecLoanAdvance.SETRANGE(Employee, "No.");
                            RecLoanAdvance.SETRANGE(Month, "Salary Header"."Posting Month");
                            RecLoanAdvance.SETRANGE(Year, Date2DMY(WorkDate(), 3));
                            RecLoanAdvance.Setrange(Type, RecLoanAdvance.Type::Loan);
                            IF RecLoanAdvance.FINDSET THEN
                                SalaryLine.Loan := RecLoanAdvance.Amount;

                            //Advance
                            RecLoanAdvance.RESET;
                            RecLoanAdvance.SETRANGE(Employee, "No.");
                            RecLoanAdvance.SETRANGE(Month, "Salary Header"."Posting Month");
                            RecLoanAdvance.Setrange(Type, RecLoanAdvance.Type::Advance);
                            IF RecLoanAdvance.FINDSET THEN
                                SalaryLine.Advance := RecLoanAdvance.Amount;

                            //Service Year 
                            Employee.CalcFields("Gross Salary");
                            ServDays := WorkDate() - "Employment Date" + 1;
                            ServYear := ServDays / 365;
                            if ServYear < 5 then
                                SalaryLine."EOSB Amount" := round(Employee."Gross Salary" * (0.5 / 12), 0.01)
                            else
                                SalaryLine."EOSB Amount" := Employee."Gross Salary" / 12;

                            //  SalaryLine."Worked Days":=SalaryLine."Paid Days"-SalaryLine."Abscence Days";
                            Coming_early_days := 0;
                            Romaining_Days := 0;
                            // -----------------------------------------------------------------------
                            //new contract -Days from joining date to payroll calculation date
                            if Employee."Employment Date" <> 0D then begin
                                if (Date2DMY(Employee."Employment Date", 2) = "Salary Header"."Posting Month") and (Date2DMY(Employee."Employment Date", 3) = "Salary Header"."Posting Year") then
                                    Romaining_Days := SalaryLine."Paid Days" - Date2DMY(Employee."Employment Date", 1)
                            end else
                                Romaining_Days := 0;

                            //Resume early or from vacation during month payroll
                            if Employee."last resume date" <> 0D then begin
                                if (Date2DMY(Employee."last resume date", 2) = "Salary Header"."Posting Month") and (Date2DMY(Employee."last resume date", 3) = "Salary Header"."Posting Year") then
                                    Coming_early_days := SalaryLine."Paid Days" - Date2DMY(Employee."last resume date", 1) + 1
                                else
                                    Coming_early_days := 0;
                            end;

                            if Romaining_Days <> 0 then
                                SalaryLine."Worked Days" := Romaining_Days
                            else
                                SalaryLine."Worked Days" := SalaryLine."Paid Days" - SalaryLine."Abscence Days";

                            if Coming_early_days <> 0 then
                                SalaryLine."Worked Days" := Coming_early_days
                            else
                                SalaryLine."Worked Days" := SalaryLine."Paid Days" - SalaryLine."Abscence Days";
                            /* IF (Romaining_Days=0) AND (Coming_early_days=0) THEN
                             SalaryLine."Worked Days":=SalaryLine."Paid Days"-SalaryLine."Abscence Days";*/
                            SalaryLine.INSERT;

                            //---------------------------------------------------------------------------------------------
                            wind.Update(3, Round((i / Employee.Count) * 10000, 1));
                            i := i + 1;
                        end;
                        Sleep(20)
                    end;

                end;

                trigger OnPostDataItem()
                begin
                    wind.Close;
                end;
            }

            trigger OnPreDataItem()
            begin
                wind.Open(DialogWindow
                          + '\#########################1#'
                          + '\#########################2#'
                          + '\@@@@@@@@@@@@@@@@@@@@@@@@3@');
                wind.Update(1, "Salary Header".No + ' ' + "Salary Header".Description);
                i := 1;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(Bonus; BonusAmount)
                {
                    ApplicationArea = all;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        wind: Dialog;
        DialogWindow: Label 'Creating Salary Lines';
        ComfirmMessage: Label 'Erase Existing Line ?';
        i: Integer;
        SalaryLine: Record "Salary Line";
        HR_Setup: Record "Human Resources Setup";
        Def_Allowances: Record "Allowance Code";
        Recorde_Paid_leave: Record "Recorded Leave entries";
        BonusAmount: Decimal;
        Abs_emp: Record "Employee Posted Absence";
        RecLoanAdvance: Record "Rec. Loan & Advance";
        NofDays: Integer;
        RecSocialCont: Record "Social Contribution";
        MonthBegin: Text;
        MonthEnd: Text;
        ServDays: Decimal;
        ServYear: Decimal;
        TextMonth: Text;
        OP: Codeunit "Config. Validate Management";
        IntegerMonth: Integer;
        CurrentYear: Text;
        PreviousYear: Integer;
        December: Text;
        TextYear: Text;
        beginabs: Date;
        endabs: Date;
        Romaining_Days: Decimal;
        Coming_early_days: Decimal;

    procedure GetDaysInMonth(Month: Integer; Year: Integer): Integer
    var
        StartDate: Date;
        EndDate: Date;
    begin
        StartDate := DMY2Date(1, Month, Year);
        EndDate := CALCDATE('<1M>', StartDate); // First day of the next month
        exit(EndDate - StartDate);
    end;

}

