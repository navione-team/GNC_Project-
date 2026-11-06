report 70004 "Payroll Summary"
{
    Caption = 'Payroll Summary';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            column(Name; Name) { }
            column(Address; Address) { }
            column(Picture; Picture) { }
            dataitem("Salary Header"; "Salary Header")
            {
                column(No; No) { }
                column(Posting_Date; "Posting Date") { }
                column(Posting_Year; "Posting Year") { }
                column(Posting_Month; "Posting Month") { }
                column(Description; Description) { }
                dataitem("Salary Line"; "Salary Line")
                {
                    column(Document_No_; "Document No.") { }
                    column(Employee; Employee) { }
                    column(Full_Name; "Full Name") { }
                    column(Position; Position) { }
                    column(Employee_Nationality; "Employee Nationality") { }
                    column(Global_Dimension_1_Code; "Global Dimension 1 Code") { }
                    column(Basic_Salary; "Basic Salary") { }
                    column(Accomodation_Allowance; "Accomodation Allowance") { }
                    column(Transport_Allowance; "Transport Allowance") { }
                    column(Mobile_Allowance; "Mobile Allowance") { }
                    column(Bonus_Allowance; "Bonus Allowance") { }
                    column(Other_Allowance; "Other Allowance") { }
                    column(Education_Allowance; "Education Allowance") { }
                    column(Addition; Addition) { }
                    column(Over_Time_Amount; "Over Time Amount") { }
                    column(Adjustment; Adjustment) { }
                    column(Gross_Salary; "Gross Salary") { }
                    column(Deductions; Deductions) { }
                    column(Advance; Advance) { }
                    column(Loan; Loan) { }
                    column(GOSI_Employee_Amount; "GOSI Employee Amount") { }
                    column(Net_Pay; "Net Pay") { }
                    column(Annual_Leave__Amount; "Annual Leave  Amount") { }
                    column(Employee_Insurance_Amount; "Employee Insurance Amount") { }
                    column(EOSB_Amount; "EOSB Amount") { }
                    column(GOSI_Employer_Amount; "GOSI Employer Amount") { }
                    column(Tickets_Allowances_Amount; "Tickets Allowances Amount")
                    {
                        Description = 'Travel Ticket';
                    }
                }





            }
        }
    }
}