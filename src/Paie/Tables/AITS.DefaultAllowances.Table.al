table 70002 "Default Allowances"
{
    Caption = 'Default Allowances';
    DataPerCompany = true;

    fields
    {
        field(70000; "Employment Contract Code"; Code[10])
        {
            Caption = 'Employment Contract Code';
            Editable = true;
            TableRelation = "Employment Contract".Code;
        }
        field(70001; "Allowance Code"; Code[20])
        {
            Caption = 'Allowance Code';
            FieldClass = Normal;
            NotBlank = true;
            TableRelation = "Allowance Code".Code; // adjust as needed
            trigger OnValidate()
            begin
                if Indemnity.Get("Allowance Code") then begin
                    EmploymentContract.Get("Employment Contract Code");
                    Description := Indemnity.Description;
                    Amount := Indemnity."Default amount";
                end;

            end;
        }
        field(70002; Description; Text[50]) { Caption = 'Description'; }
        field(70003; Type; Option)
        {
            Caption = 'Type';
            Editable = true;
            OptionMembers = " ",Contract,Incriment,Promotion,"Salary Adjustment","Title Change","Benefits Activations";
        }
        field(70004; "Evaluation mode"; Option)
        {
            Caption = 'Evaluation mode';
            Editable = true;
            OptionMembers = Inclusive,"on Paid period","on Worked period","on Worked hour","on Flight hours","Nbre Days Worked","Montant = Brut * Taux","Montant = Base * Taux";
        }
        field(70005; Amount; Decimal)
        {
            Caption = 'Amount';
            AutoFormatType = 2;
        }
        field(70006; Mois; Option)
        {
            Caption = 'Mois';
            OptionMembers = " ",January,February,March,April,May,June,July,August,September,October,November,December;
        }
        field(70007; Annee; Integer) { Caption = 'Annee'; }
        field(70008; Employee; Code[100])
        {
            Caption = 'Employee';
            FieldClass = FlowField;
            CalcFormula = Lookup(Employee."First Name" WHERE("Emplymt. Contract Code" = FIELD("Employment Contract Code")));
        }
        field(70009; "Employee name"; Text[100]) { Caption = 'Employee name'; }
        field(70010; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Department Code';
            DataClassification = ToBeClassified;
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(70011; Desegnation; Text[200]) { Caption = 'Designation'; DataClassification = ToBeClassified; }
        field(70012; "Last Modified Date"; Date) { DataClassification = ToBeClassified; }
        field(70013; "User ID"; Code[25]) { DataClassification = ToBeClassified; }
        field(70014; Taux; Decimal) { Caption = 'Taux'; DataClassification = ToBeClassified; }
        field(70015; "Allowance type"; Option)
        {
            Caption = 'Allowance type';
            OptionMembers = Basic,Transport,Accomodation,Mobile,Other,Education,Bonus;
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Employment Contract Code", "Allowance Code")
        {
            Clustered = true;
        }
        key(Key2; "Allowance Code", "Employment Contract Code") { }
    }

    trigger OnInsert()
    begin
        "Last Modified Date" := WorkDate;
        "User ID" := USERID;
        RecEmp.SetRange("No.", Employee);
        if RecEmp.FindSet then
            Validate("Global Dimension 1 Code", RecEmp."Global Dimension 1 Code");

    end;

    trigger OnModify()
    begin
        "Last Modified Date" := WorkDate;
        "User ID" := USERID;
    end;

    trigger OnRename()
    begin
        "Last Modified Date" := WorkDate;
        "User ID" := USERID;
    end;

    var
        Indemnity: Record "Allowance Code";
        SelectedInd: Record "Allowance Code";
        EmploymentContract: Record "Employment Contract";
        FormIndemnity: Page "Allowances List";
        RecEmp: Record Employee;
}
