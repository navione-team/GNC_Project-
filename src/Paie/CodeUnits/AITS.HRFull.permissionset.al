permissionset 70090 "AITS HR - Full"
{
    Caption = 'AITS HR - Full Access';
    Assignable = true;

    Permissions =
        tabledata "Job Offer" = RIMD,
        tabledata "Allowance Code" = RIMD,
        tabledata "Default Allowances" = RIMD,
        tabledata "Employee Vacation Request" = RIMD,
        tabledata "Vacation Request History" = RIMD,
        tabledata "TimeSheet Header" = RIMD,
        tabledata "TimeSheet Line" = RIMD,
        tabledata "Store Calendar" = RIMD,
        tabledata "Loan & Advance Type" = RIMD,
        tabledata "Loan & Advance" = RIMD,
        tabledata "Rec. Loan & Advance" = RIMD,
        tabledata "L&A Installment Schedule" = RIMD,
        tabledata "Loan & Advance Entry" = RIMD,
        tabledata "Leave Entries" = RIMD,
        tabledata "Recorded Leave entries" = RIMD,
        tabledata "Recorded Attendance TimeSheet" = RIMD,
        tabledata "Rec TimeSheet Header" = RIMD,
        tabledata "Employee Posted Absence" = RIMD,
        tabledata "Salary Header" = RIMD,
        tabledata "Salary Line" = RIMD,
        tabledata "Rec.Salary Header" = RIMD,
        tabledata "Rec.Salary Line" = RIMD,
        tabledata "Work Regime" = RIMD,
        tabledata "Employee Sponsor/Payer" = RIMD,
        tabledata "Social Contribution" = RIMD,
        tabledata "Employee Contract History" = RIMD,
        tabledata "Loan & Advance Lines" = RIMD;
}
