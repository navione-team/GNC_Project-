pageextension 70056 "HR Setup PageExt" extends "Human Resources Setup"
{
    layout
    {
        addafter("Base Unit of Measure")
        {
            field("Payroll No"; rec."Payroll No") { ApplicationArea = all; }
            field("Job Offer Nos"; rec."Job Offer Nos") { ApplicationArea = all; }
            field("Contract Nos"; rec."Contract No") { ApplicationArea = all; }
            field("Attendance Nos"; rec."Attendance No") { ApplicationArea = all; }
            field("Loan&Advance No"; rec."Loan&Advance No") { ApplicationArea = all; }
        }

        addlast(Content)
        {
            group("HR Additional Setup")
            {
                field("Standard Hour Per day"; rec."Standard Hour Per day") { ApplicationArea = all; }
                field("Ramadhan Hour Per Day"; rec."Ramadhan Hour Per Day") { ApplicationArea = all; }

                field("Max Casual Leave"; rec."Max Casual Leave") { ApplicationArea = all; }
                field("Max Full Paid Sick Leave"; rec."Max Full Paid Sick Leave") { ApplicationArea = all; }
                field("Max Maternity Days"; rec."Max Maternity Days") { ApplicationArea = all; }
                field("Apply Loan After"; rec."Apply Loan After") { ApplicationArea = all; }
                field("Paid Days"; rec."Paid Days") { ApplicationArea = all; }
                field("Manager Vacation Days"; rec."Maanager Vacation Days") { ApplicationArea = all; }
                field("Worker Vacation Days"; rec."Worker Vacation Days") { ApplicationArea = all; }

                field("Thursday Standard Hours"; rec."Thursday Standard Hours") { ApplicationArea = all; }
                field("Store Standard Hours"; rec."Store Standard Hours") { ApplicationArea = all; }
                field("Leave Days Per Month"; rec."Leave Days Per Month") { ApplicationArea = all; }
            }

            group("Payroll Posting Setup")
            {
                field("Automatic Post to G/L"; Rec."Automatic Post to G/L")
                {
                    ApplicationArea = all;
                }
                field("Payroll Gen.Journal template"; rec."Payroll Gen.Journal template")
                {

                    ApplicationArea = all;
                }
                field("Payroll Gen.Journal batch"; rec."Payroll Gen.Journal batch")
                {

                    ApplicationArea = all;
                }


                field("LA.Gen.Journal Batch"; rec."LA.Gen.Journal Batch")
                {

                    Caption = 'Loan and Advance Journal Template';
                    ApplicationArea = all;
                }

                // 🔽 Payroll Posting Accounts 🔽
                //field("Basic Salary Acc"; rec."Basic Salary Acc") { ApplicationArea = all; }
                //field("Housing Acc"; rec."Housing Acc") { ApplicationArea = all; }
                //field("Transportation Acc"; rec."Transportation Acc") { ApplicationArea = all; }
                //field("Mobile Acc"; rec."Mobile Acc") { ApplicationArea = all; }
                //field("Education Acc"; rec."Education Acc") { ApplicationArea = all; }
                //field("Staff Bonus Acc"; rec."Staff Bonus Acc") { ApplicationArea = all; }
                //field("Leave Ticket Exp. Acc"; rec."Leave Ticket Exp. Acc") { ApplicationArea = all; }
                //field("Leave Salary Exp. Acc"; rec."Leave Salary Exp. Acc") { ApplicationArea = all; }
                //field("EOS Indemnity Acc"; rec."EOS Indemnity Acc") { ApplicationArea = all; }
                field("Leave Tickets Prov. Acc"; rec."Leave Tickets Prov. Acc") { ApplicationArea = all; }
                field("Leave Days Prov. Acc"; rec."Leave Days Prov. Acc") { ApplicationArea = all; }
                field("EOS Provision Acc"; rec."EOS Provision Acc") { ApplicationArea = all; }
                field("Health Insurance Acc"; rec."Health Insurance Acc") { ApplicationArea = all; }
                field("Prepaid Health Insurance Acc"; rec."Prepaid Health Insurance Acc") { ApplicationArea = all; }
                //field("GOSI Acc"; rec."GOSI Acc") { ApplicationArea = all; }
                field("Staff Loan Acc"; rec."Staff Loan Acc") { ApplicationArea = all; }
                field("Staff Advance Acc"; rec."Staff Advance Acc") { ApplicationArea = all; }
                field("Adjustment Acc"; rec."Adjustment Acc") { ApplicationArea = all; }
                field("Deduction Acc"; rec."Deduction Acc") { ApplicationArea = all; }
                field("Net Payroll Acc"; rec."Net Payroll Acc") { ApplicationArea = all; }
            }

            group("Accounting Setup")
            {
                part("Social Contribution"; "Social Contribution List")
                { ApplicationArea = all; }

                part(EmployeePostingGroupList; "Employee Postroup ListPart")
                { ApplicationArea = all; }
            }
        }
    }
}
