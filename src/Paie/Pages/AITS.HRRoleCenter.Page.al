page 70004 "HR Manager Role Center"
{
    Caption = 'HR Manager Role Center';
    PageType = RoleCenter;
    ApplicationArea = All;

    layout
    {
        area(rolecenter)
        {
            part(HRManagerCues; "HR Manager Cues")
            {
                ApplicationArea = All;
            }

            part(ApprovalsActivities; "Approvals Activities")
            {
                ApplicationArea = All;
            }

            part(MyInbox; "Report Inbox Part")
            {
                ApplicationArea = All;
            }

            systempart(MyNotes; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(Employees)
            {
                Caption = '🧑 Employees';
                action(EmployeeList)
                {
                    Caption = 'Employee List';
                    RunObject = page "Employee List";
                }
                action(EmployeeContracts)
                {
                    Caption = 'Employee Contracts';
                    RunObject = page "Employment Contracts";
                }
                /*action(UserSetup)
                {
                    Caption = 'User Setup';
                    RunObject = page "User Setup";
                }*/
            }

            group(LeaveAndAttendance)
            {
                Caption = '📅 Leave & Attendance';
                action(VacationRequest)
                {
                    Caption = 'Vacation Requests';
                    RunObject = page "Employee Vacation Request";
                }
                action(AnnualLeave)
                {
                    Caption = 'Annual Leave';
                    RunObject = page "Annual Leave";
                }
                action(AbsenceRegistration)
                {
                    Caption = 'Absence Registration';
                    RunObject = page "Absence Registration";
                }

                action(Attendance)
                {
                    Caption = 'Attendance';
                    RunObject = page "Attendance";
                }
            }
            group(OverTime)
            {
                Caption = '🥁Over Time';
                Action("Over Time Registration")
                {
                    //  Caption = '🥁Over Time';
                    RunObject = page "Over Time Registration";
                }
            }

            group(LoansEOSB)
            {
                Caption = '💰 Loans & EOSB';
                action(Loan)
                {
                    Caption = 'Employee Loan';
                    RunObject = page "Employee Loans";
                }
                action(Advance)
                {
                    Caption = 'Employee Advance';
                    RunObject = page "Employee Advances";
                }

                action(GratuitySettlement)
                {
                    Caption = 'Gratuity Settlement';
                    RunObject = page "Gratuity Settlement";
                }
                /* action(LoanSchedule)
                 {
                     Caption = 'Loan Installment Schedule';
                     RunObject = page "L&A Installment Schedule";
                 }*/
            }

            group(Payroll)
            {
                Caption = '🧾 Payroll';
                action(AdditionsDeductions)
                {
                    Caption = 'Additions & Deductions';
                    RunObject = page "Additions & Deductions";
                }
                action(Adjustment)
                {
                    Caption = '⚖ Adjustment';
                    RunObject = page "Salary Adjustement Entry";
                }

                action(SalaryJournals)
                {
                    Caption = 'Payroll Calculation';
                    RunObject = page "Salary Calculation";
                }

                action(PayrollReport)
                {
                    Caption = 'Payroll Summary Report';
                    //RunObject = report "Payroll Summary Report";
                }
            }

            group(HRConfiguration)
            {
                Caption = '⚙️ HR Configuration';
                action(HRSetup)
                {
                    Caption = 'HR Setup';
                    RunObject = page "Human Resources Setup";
                }
                action(GradeSetup)
                {
                    Caption = 'Employee Grade Setup';
                    //RunObject = page "Employee Grade Setup";
                }
                action(JobSetup)
                {
                    Caption = 'Job Setup';
                    //RunObject = page "Job Setup";
                }
                action(LeaveSetup)
                {
                    Caption = 'Leave Type Setup';
                    //RunObject = page "Leave Type Setup";
                }
                action(DeductionSetup)
                {
                    Caption = 'Deduction Type Setup';
                    //RunObject = page "Deduction Type Setup";
                }
                action(OvertimeSetup)
                {
                    Caption = 'Overtime Type Setup';
                    //RunObject = page "Overtime Type Setup";
                }
            }

            group(HRHistorys)
            {
                Caption = '🛅HR History';
                action(OvertimeHistory)
                {
                    Caption = 'Over Time Transactions';
                    RunObject = page "Over Time transaction History";
                }
                action(DeductionHist)
                {
                    Caption = 'Employee Additons & Deductions';
                    RunObject = page "Recorded Addition & Deduction";
                }
                action(Adjustmenthist)
                {
                    Caption = 'Salary Adjustement';
                    RunObject = page "Salary Adjustment History";
                }
                action(PostedEmployeeABS)
                {
                    Caption = 'Employee Absences';
                    RunObject = page "Posted Employee Absence";
                }
                action(VacationReqHist)
                {
                    Caption = 'Vacations Request';
                    RunObject = page "Vacation Request History";
                }
                action(LoanAdvanceHist)
                {
                    Caption = 'Loan & Advance';
                    RunObject = page "Posted Loan & Advance";
                }
                action(PayrollHistory)
                {
                    Caption = 'Payroll Journal list';
                    RunObject = page "Posted Salary List";
                }
                action(IncrementHistory)
                {
                    Caption = 'Employee Increment History';
                    RunObject = page "Employee Contracts & Promotion";
                }
            }
        }
    }
}
