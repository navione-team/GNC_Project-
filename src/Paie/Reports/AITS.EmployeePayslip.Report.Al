report 70003 "Employee Payslip"
{
    Caption = 'Employee Payslip';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    dataset

    {

        dataitem("Company Information"; "Company Information")
        {
            column(Picture; Picture) { }
            column(Name; Name) { }
            column(Address; Address) { }


            dataitem("Salary Header"; "Salary Header")

            {

                RequestFilterFields = "No";

                dataitem("Salary Line"; "Salary Line")
                {
                    RequestFilterFields = Employee;
                    DataItemLink = "Document No." = field("No");

                    column(EmployeeNo; Employee) { }
                    column(FullName; "Full Name") { }
                    column(Position; Position) { }
                    column(Department; "Employee Departement") { }
                    column(PostingMonth; "Posting Month") { }
                    column(PostingYear; "Posting Year") { }
                    column(IBAN; IBAN) { }
                    column(BankName; "Employee Bank Name") { }
                    column(BasicSalary; "Basic Salary") { }
                    column(Accommodation; "Accomodation Allowance") { }
                    column(Transport; "Transport Allowance") { }
                    column(Mobile; "Mobile Allowance") { }
                    column(Tickets; "Tickets Allowances Amount") { }
                    column(Education; "Education Allowance") { }
                    column(Bonus; Bonus) { }
                    column(Overtime; "Over Time Amount") { }
                    column(HolidaySalary; "Holiday Salary") { }
                    column(Addition; Addition) { }
                    column(Adjustment; Adjustment) { }
                    column(GrossSalary; "Gross Salary") { }
                    column(Advance; Advance) { }
                    column(Loan; Loan) { }
                    column(Deductions; Deductions) { }
                    column(Insurance; "Employee Insurance Amount") { }
                    column(GOSI_Employee_Amount; "GOSI Employee Amount") { }
                    column(Employee_Insurance_Amount; "Employee Insurance Amount") { }
                    column(NetPay; "Net Pay") { }
                    column(PaidDays; "Paid Days") { }
                    column(WorkedDays; "Worked Days") { }
                    column(AbsenceDays; "Abscence Days") { }
                    column(UnpaidDays; "Upaid Days") { }
                    column(Note; Note) { }
                }
            }
        }
    }



    requestpage
    {
        layout
        {
            area(content)
            {
                group("Filter")
                {
                    field("Salary Header Filter"; "Salary Header"."No") { ApplicationArea = All; }
                }
            }
        }
    }

    labels
    {
        EmployeePayslipLbl = 'Employee Payslip';
    }


}




