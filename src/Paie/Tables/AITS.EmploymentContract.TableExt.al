tableextension 70027 "Employment Contract Ext" extends "Employment Contract"
{
    fields
    {
        field(70000; "Employment contracts"; Text[200]) { Caption = 'Employment contracts'; }
        field(70001; "Regular payments"; Integer) { Caption = 'Regular payments'; }
        field(70002; "Temporary payments"; Decimal) { Caption = 'Temporary payments'; }

        field(70003; "Adjust indemnity amount"; Boolean) { Caption = 'Adjust indemnity amount'; }

        field(70004; "Employee's type"; Option)
        {
            Caption = 'Employee''s type';
            OptionMembers = "Hour based","Month based";
        }

        field(70005; "Regimes of work"; Code[10]) { Caption = 'Regimes of work'; }
        field(70006; Taxable; Boolean) { Caption = 'Taxable'; }
        field(70007; "Take in account deductions"; Boolean) { Caption = 'Take in account deductions'; }

        field(70008; "Calculation mode of the taxes"; Option)
        {
            Caption = 'Calculation mode of the taxes';
            OptionMembers = "Barème standard","Forfaitaire";
        }

        field(70009; "Inclusive ratio"; Decimal) { Caption = 'Inclusive ratio'; }
        field(70010; "Default Employment Contract"; Boolean) { Caption = 'Default Employment Contract'; }
        field(70011; "No. Series"; Code[20]) { Caption = 'No. Series'; }
        field(70012; "User ID"; Code[50]) { Caption = 'User ID'; }
        field(70013; "Last Date Modified"; Date) { Caption = 'Last Date Modified'; }

        field(70014; "Assiduity Type"; Option)
        {
            Caption = 'Assiduity Type';
            OptionMembers = "Par Heure","Par Jour";
        }

        field(70015; Employee; Code[50])
        {
            Caption = 'Employee';
            FieldClass = FlowField;
            CalcFormula = lookup(Employee."No." where("Emplymt. Contract Code" = field(Code)));
        }

        field(70016; "Employee name"; Text[250])
        {
            Caption = 'Employee name';
            FieldClass = FlowField;
            CalcFormula = lookup(Employee."Search Name" where("Emplymt. Contract Code" = field(Code)));
        }

        field(70017; "Total Package"; Decimal)
        {
            Caption = 'Total Package';
            FieldClass = FlowField;
            CalcFormula = Sum("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD(Code)));
        }

        field(70018; "Global Dimension 1 Code"; Code[20]) { Caption = 'Global Dimension 1 Code'; }

        field(70019; "Contract Date"; Date)
        {
            Caption = 'Contract Date';
            FieldClass = FlowField;
            CalcFormula = lookup(Employee."Employment Date");
        }
        field(70020; "Contract Description"; Text[250])
        {
            Caption = 'Desciption';
            FieldClass = FlowField;
            CalcFormula = lookup(Employee."No." where("Emplymt. Contract Code" = field(Code)));

        }
    }
    // trigger OnAfterInsert()

    //  begin
    //     CalcFields(Employee, "Employee name");
    //    message('name:%1', "Employee name");
    //    "Contract Description" := Code + ':' + "Employee name" + ' ' + 'Contract';
    //   rec.Modify(true);
    // end;



}

//}
