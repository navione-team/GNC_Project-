
tableextension 70029 "Employee Ext" extends Employee
{
    fields
    {
        field(70000; "Passport No."; Text[30])
        {
            Caption = 'Passport No.';
        }
        field(70001; "Passport Expiry Date"; Date)
        {
            Caption = 'Passport Expiry Date';
        }
        field(70002; "SID"; Text[11])
        {
            Caption = 'SID';
        }
        field(70003; "SID Expiry Date"; Date)
        {
            Caption = 'SID Expiry Date';
        }
        field(70004; "Country of Origin"; Code[10])
        {
            Caption = 'Nationality';
            TableRelation = "Country/Region".Code;
        }
        field(70005; "HCard No."; Text[30])
        {
            Caption = 'HCard No.';
        }
        field(70006; "HCard Expiry Date"; Date)
        {
            Caption = 'HCard Expiry Date';
        }
        field(70007; Bank; Text[30])
        {
            Caption = 'Bank';
        }
        field(70008; "IBAN No."; Text[30])
        {
            Caption = 'IBAN No.';
        }
        field(70009; "Travel Tickets"; Option)
        {
            Caption = 'Travel Tickets';
            OptionMembers = " ", "One Year", "Two Years", "Three Years";
        }
        field(70010; "Gross Salary"; Decimal)
        {
            Caption = 'Gross Salary';
            FieldClass = FlowField;
            CalcFormula = sum("Default Allowances".Amount WHERE("Employment Contract Code"=FIELD("Emplymt. Contract Code")));
        }
        field(70013; "Joining Date"; Date)
        {
            Caption = 'Joining Date';
        }
        field(70014; "Basic Salary"; Decimal)
        {
            Caption = 'Basic Salary'; //kka
            FieldClass = FlowField;
            CalcFormula = lookup("Default Allowances".Amount WHERE("Allowance type"=filter(Basic), "Employment Contract Code"=FIELD("Emplymt. Contract Code")));
        }
        field(70015; "Payment Method Code"; Code[20])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method".Code;
        }
        field(70016; "Last Working Date"; Date)
        {
            Caption = 'Last Working Date';
        }
        field(70017; "Vacation Resume Date"; Date)
        {
            Caption = 'Vacation Resume Date';
        }
        field(70018; "Contract Vacation Days"; Decimal)
        {
            Caption = 'Contract Vacation Days';
        }
        field(70019; "Office Manager"; Boolean)
        {
            Caption = 'Office Manager';
        }
        field(70020; "Employee Contract Type"; Option)
        {
            Caption = 'Employee Contract Type';
            OptionMembers = " ", "Full-Time", "Part-time", "Temporary", "Permanent", "Fixed-Term", "Contractor", "Internship", "FreeLance", "Casual";
        }
        field(70021; "Employee Calendar"; Code[20])
        {
            Caption = 'Employee Calendar';
        }
        field(70022; "Leave Status"; Option)
        {
            Caption = 'Leave Status';
            OptionCaption = ' ,On Vacation,Overdue,Holded';
            OptionMembers = " ", "On Vacation", "Overdue", "Holded";
        }
        field(70023; "Work Authorisation"; Boolean)
        {
            Caption = 'Work Authorisation';
        }
        field(70024; Overdue; Decimal)
        {
            Caption = 'Overdue';
        }
        field(70025; "Special Comment"; Text[250])
        {
            Caption = 'Special Comment';
        }
        field(70026; "Vacation Start Date"; Date)
        {
            Caption = 'Vacation Start Date';
        }
        field(70027; "Vacation End Date"; Date)
        {
            Caption = 'Vacation End Date';
        }
        field(70028; "Orverdue Resume date"; Date)
        {
            Caption = 'Overdue Resume Date';
        }
        field(70029; "Punishment Days"; Decimal)
        {
            Caption = 'Punishment Days';
        }
        field(70030; "Transfert date"; Date)
        {
            Caption = 'Transfert Date';
        }
        field(70031; "Transfert from date"; Date)
        {
            Caption = 'Transfert From Date';
        }
        field(70032; "Transfert to date"; Date)
        {
            Caption = 'Transfert To Date';
        }
        field(70033; "Work Company"; Code[20])
        {
            Caption = 'Work Company';
        }
        field(70034; "Work Company Name"; Text[30])
        {
            Caption = 'Work Company Name';
        }
        field(70035; "Sponsor Name"; Text[30])
        {
            Caption = 'Sponsor Name';
        }
        field(70036; IBAN2; Code[25])
        {
            Caption = 'IBAN2';
        }
        field(70037; Sponsor; Code[30])
        {
            Caption = 'Sponsor';
            TableRelation = "Employee Sponsor/Payer";
        }
        field(70038; "Payer ID"; Code[20])
        {
            Caption = 'Payer ID';
            TableRelation = "Employee Sponsor/Payer";
        }
        field(70039; "Marital Status"; Option)
        {
            Caption = 'Marital Status';
            OptionMembers = "Single", "Married", "Divorced", "Widowed";
        }
        field(70040; "Last Resume Date"; Date)
        {
            Caption = 'Last Resume Date';
            FieldClass = FlowField;
            CalcFormula = max("Recorded Leave entries"."Resume Date" where(Employee=field("No. Series")));
        }
        field(70041; "Employee Department"; Code[20])
        {
            Caption = 'Employee Department';
        }
        field(70042; "Travel Ticket Amount"; Decimal)
        {
            Caption = 'Travel Ticket Amount';
        }
        field(70043; "SA Emergency Contact Name"; Text[250])
        {
            Caption = 'SA Emergency Contact Name';
        }
        field(70044; Relationship; Text[250])
        {
            Caption = 'Relationship';
        }
        field(70045; "Mobile Number"; Text[250])
        {
            Caption = 'Mobile Number';
        }
        field(70046; "Home Adress"; Text[250])
        {
            Caption = 'Home Address';
        }
        field(70047; "Home Co Emergency Contact Name"; Text[250])
        {
            Caption = 'Home Co Emergency Contact Name';
        }
        field(70048; "Home Co RelationShip"; Text[250])
        {
            Caption = 'Home Co Relationship';
        }
        field(70049; "Country Mobile Number"; Text[250])
        {
            Caption = 'Country Mobile Number';
        }
        field(70050; "Country Home Adress"; Text[250])
        {
            Caption = 'Country Home Address';
        }
        field(70051; "Full Name"; Text[250])
        {
            Caption = 'Full name';
        }
        field(70052; "GOSI Applied"; Boolean)
        {
        }
        field(70053; "Insurance Affiliated"; Boolean)
        {
        }
        field(70055; "Direct Manager Name"; Text[100])
        {
        }
        field(70056; "End Probation Date"; Date)
        {
        }
        field(70057; "Family Chief"; Boolean)
        {
        }
        field(70058; "Childs In Charge"; Integer)
        {
        }
        field(70059; "Accomodation Allowance"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Default Allowances".Amount WHERE("Allowance type"=filter(Accomodation), "Employment Contract Code"=FIELD("Emplymt. Contract Code")));
        }
        field(70060; "Contract Type"; Option)
        {
            Caption = 'Contract Type';
            OptionMembers = Unlimited, Limited, PartTime, Temporary, Internship, Freelancer, Consultant, Apprenticeship, Probation, Seasonal;
            OptionCaption = 'Unlimited,Limited,Part-Time,Temporary,Internship,Freelancer,Consultant,Apprenticeship,Probation,Seasonal';
        }
        field(70061; "Insurance Amount per Year"; Decimal)
        {
        }
        field(70062; "Transportation Allowances"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Default Allowances".Amount WHERE("Allowance type"=filter(transport), "Employment Contract Code"=FIELD("Emplymt. Contract Code")));
        }
        modify("Job Title")
        {
        TableRelation = Qualification.code;
        }
        modify("Last Name")
        {
        trigger OnAfterValidate();
        begin
            REC."Full Name":="First Name" + ' ' + "Middle Name" + ' ' + "Last Name";
        end;
        }
        modify("Manager No.")
        {
        trigger OnAfterValidate();
        begin
            if recGEmp.GET("Manager No.")then "Direct Manager Name":=recGEmp."Search Name";
        end;
        }
    }
    trigger OnInsert()
    begin
        // rec."Full Name" := "Search Name";
        ctr.reset;
        ctr.Init();
        //iF ctr.FINDLAST THEN
        ctr.Code:=FORMAT("No.");
        ctr.INSERT;
        "Emplymt. Contract Code":=ctr.Code;
    end;
    var recGEmp: Record Employee;
    ctr: Record "Employment Contract";
}
