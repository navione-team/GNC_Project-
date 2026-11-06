report 70001 "Calculate Salary Lines"
{
    ProcessingOnly = true;
    ApplicationArea = All;

    dataset
    {
        dataitem("Salary Header"; "Salary Header")
        {
            dataitem("Salary Line"; "Salary Line")
            {
                CalcFields = "Accomodation Allowance", "Mobile Allowance", "Transport Allowance", "Other Allowance", "Education Allowance", "Bonus Allowance";
                DataItemTableView = WHERE("Payment Type" = FILTER(Salary));
                RequestFilterFields = Employee;

                trigger OnAfterGetRecord()
                begin

                    if "Salary Header"."Payroll Status" = "Salary Header"."Payroll Status"::Released then
                        Error('Payroll Closed')
                    else begin

                        SalarylineTemp.RESET;
                        Rec_employee.Reset;
                        begin
                            if Rec_employee.Get("Salary Line".Employee) then begin
                                EMpname := Rec_employee.FullName();
                                EmpCode := Rec_employee."No.";
                            end;
                            Wind.Update(2, EmpCode + ':' + EMpname);
                            if "Salary Line"."Paid Days" <> 0 then begin
                                Rec_employee.CalcFields("Gross Salary");
                                "Salary Line"."Attendance Rate" := Round("Salary Line"."Worked Days" / "Salary Line"."Paid Days", 0.01);
                                "Salary Line"."Gross Salary" := Rec_employee."Gross Salary" + "Salary Line".Adjustment;
                                //"Salary Line"."Basic Salary" + "Salary Line"."Accomodation Allowance" + "Salary Line"."Mobile Allowance" + "Salary Line"."Transport Allowance"
                                // + "Salary Line"."Other Allowance" + "Salary Line".Adjustment + "Salary Line"."Bonus Allowance";

                                "Salary Line".MODIFY;
                                OneDaySalary := "Salary Line"."Gross Salary" / 30;
                                "Salary Line"."Gross Salary" := OneDaySalary * "Salary Line"."Worked Days";
                            end;
                            //  "Salary Line"."Gross Salary":="Salary Line"."Gross Salary"*"Salary Line"."Attendance Rate";


                            //Advance
                            Rec_Advance_.RESET;
                            Rec_Advance_.SETRANGE(Employee, Employee);
                            Rec_Advance_.SETRANGE(Month, "Posting Month");
                            Rec_Advance_.SETRANGE(Year, "Posting Year");
                            Rec_Advance_.SETRANGE(Type, Rec_Advance_.Type::Advance);
                            if Rec_Advance_.FINDSET then begin
                                "Salary Line".Advance := Rec_Advance_.Amount;
                                "Salary Line".Note := Rec_Advance_.Observation;
                                Rec_Advance_.VALIDATE("Payment No", "Salary Header".No);
                                Rec_Advance_.MODIFY;
                            end;
                            //Loan
                            Rec_Loan_.RESET;
                            Rec_Advance_.RESET;
                            Rec_Loan_.SETRANGE(Employee, Employee);
                            Rec_Loan_.SETRANGE(Month, "Posting Month");
                            Rec_Loan_.SETRANGE(Year, "Posting Year");
                            Rec_Loan_.SETRANGE(Type, Rec_Advance_.Type::Advance);
                            if Rec_Loan_.FINDSET then begin
                                "Salary Line".Loan := Rec_Loan_.Slice;
                                //  "Salary Line"."Deduction Note":=Rec_Advance_.Observation;
                                Rec_Loan_.VALIDATE("Payment No", "Salary Header".No);
                                Rec_Loan_.MODIFY;
                                Rec_Advance_.SETRANGE("No.", Rec_Loan_."N° Loan");
                                if Rec_Advance_.FINDSET then begin
                                    Rec_Advance_.VALIDATE("Payment No", "Salary Header".No);
                                    "Salary Line"."Deduction Note" := Rec_Advance_.Observation;
                                    Rec_Advance_.MODIFY;
                                end;


                            end;
                            ///EOSB BENEFITS
                            Recorde_Paid_leave.RESET;
                            Recorde_Paid_leave.SETRANGE(Employee, "Salary Line".Employee);
                            Recorde_Paid_leave.SETRANGE("Entry Type", Recorde_Paid_leave."Entry Type"::"End of service");
                            Recorde_Paid_leave.SETRANGE("Payroll Month", "Salary Header"."Posting Month");
                            Recorde_Paid_leave.SETRANGE(Year, "Salary Header"."Posting Year");

                            if Recorde_Paid_leave.FINDSET then begin
                                // Recorde_Paid_leave."Payment No":="Salary Line"."Document No.";
                                Recorde_Paid_leave.MODIFYALL("Payment No", "Salary Line"."Document No.");
                                "Salary Line"."EOSB Amount" := Recorde_Paid_leave."Total Amount  To pay";
                                "Salary Line"."Tickets Allowances Amount" := Recorde_Paid_leave."Ticket Amount";
                                "Salary Line"."Payment Type" := "Salary Line"."Payment Type"::"End Of Service";

                            end;

                            //Net salary Cashed
                            "Salary Line"."Net Pay" := "Salary Line".Addition
                            + "Salary Line"."Gross Salary"

                            + "Salary Line"."Upaid Days"
                            + "Salary Line"."Over Time Amount"
                            + "Salary Line"."Incentive Amount"
                            + "Salary Line"."Extra Hours"
                            + "Salary Line"."Holiday Salary"
                            - "Salary Line".Advance
                            - "Salary Line".Loan
                            - "Salary Line".Deductions
                            - "Salary Line"."GOSI Employee Amount";
                            //- "Salary Line"."Employee Insurance Amount";


                            "Salary Line".MODIFY(true);





                            Wind.Update(3, Round((i / "Salary Line".COUNT) * 10000, 1));
                            i := i + 1;
                        end;
                        Sleep(20)
                    end;

                end;

                trigger OnPostDataItem()
                begin
                    "Salary Line".SETRANGE("Leave Status", "Salary Line"."Leave Status"::"On Vacation");
                    if "Salary Line".FINDSET then
                        repeat
                            "Salary Line"."Worked Days" := 0;
                            "Salary Line"."Paid Days" := 0;
                            "Salary Line"."Attendance Rate" := 0;
                            "Salary Line"."Gross Salary" := 0;
                            "Salary Line"."Net Pay" := 0;

                            "Salary Line".MODIFY;
                        until "Salary Line".NEXT = 0;


                    "Salary Line".RESET;
                    Wind.Close;
                end;
            }

            trigger OnPreDataItem()
            begin
                Wind.Open(DialogWindow
                          + '\#########################1#'
                          + '\#########################2#'
                          + '\@@@@@@@@@@@@@@@@@@@@@@@@3@');
                Wind.Update(1, "Salary Header".No + ' ' + "Salary Header".Description);
                i := 1;
                //"Salary Line".CALCFIELDS("Abscence Days");
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        ec: Record "L&A Installment Schedule";
        Rec_Advance_: Record "Rec. Loan & Advance";
        Wind: Dialog;
        DialogWindow: Label 'Calculating Salary Lines';
        i: Integer;
        SalarylineTemp: Record "Salary Header";
        SalaryHeaderTemp: Record "Salary Line";
        Rec_employee: Record Employee;
        EMpname: Text;
        EmpCode: Code[20];
        Recorde_Paid_leave: Record "Recorded Leave entries";
        Rec_Loan_: Record "L&A Installment Schedule";
        Gross_Paid: Decimal;
        ESBAmout: Decimal;
        OneDaySalary: Decimal;
}

