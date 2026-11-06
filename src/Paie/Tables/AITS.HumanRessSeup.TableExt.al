tableextension 70025 "HR Setup Extension" extends "Human Resources Setup"
{
    fields
    {
        field(70000; "Payroll No"; Code[20])
        {
            TableRelation = "No. Series";
        }

        field(70001; "Standard Hour Per day"; Decimal) { }
        field(70002; "Ramadhan Hour Per Day"; Decimal) { }
        field(70003; "Job Offer Nos"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(70004; "Max Casual Leave"; Decimal) { }
        field(70005; "Max Full Paid Sick Leave"; Decimal) { }
        field(70006; "Max Maternity Days"; Decimal) { }
        field(70007; "Contract No"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(70008; "Loan&Advance No"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(70009; "Payroll Gen.Journal template"; Code[20])
        {
            Caption = 'Payroll Gen. Journal Template';
            TableRelation = "Gen. Journal Template".Name;
        }

        field(70010; "Payroll Gen.Journal batch"; Code[20])
        {
            Caption = 'Payroll Gen. Journal Batch';
            TableRelation = "Gen. Journal Batch".Name
        WHERE("Journal Template Name" = FIELD("Payroll Gen.Journal template"));
        }

        field(70011; "LA.Gen.Journal Batch"; Code[20]) { }
        field(70012; "Apply Loan After"; Integer) { }
        field(70013; "Paid Days"; Decimal) { }
        field(70014; "Maanager Vacation Days"; Decimal) { }
        field(70015; "Worker Vacation Days"; Decimal) { }
        field(70016; "Attendance No"; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(70017; "Thursday Standard Hours"; Decimal) { }
        field(70018; "Store Standard Hours"; Decimal) { }
        field(70019; "Leave Days Per Month"; Decimal) { }

        // 🔽 Payroll Posting Accounts (start after 70019) 🔽
        field(70020; "Basic Salary Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70021; "Housing Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70022; "Transportation Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70023; "Mobile Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70024; "Education Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70025; "Staff Bonus Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70026; "Leave Ticket Exp. Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70027; "Leave Salary Exp. Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70028; "EOS Indemnity Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70029; "Leave Tickets Prov. Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70030; "Leave Days Prov. Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70031; "EOS Provision Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70032; "Health Insurance Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70033; "Prepaid Health Insurance Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70034; "GOSI Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70035; "Staff Loan Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70036; "Staff Advance Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70037; "Adjustment Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70038; "Deduction Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70039; "Net Payroll Acc"; Code[20]) { TableRelation = "G/L Account"; }
        field(70040; "Automatic Post to G/L"; Option)
        {
            OptionMembers = Direct,Journal;
            Caption = 'Automatic Post to G/L';
            InitValue = Journal; // Optional: Set default value to "Journal"
        }
    }
}
