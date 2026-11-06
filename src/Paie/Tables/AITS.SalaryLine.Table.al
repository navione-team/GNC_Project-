table 70021 "Salary Line"
{

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Editable = false;
            TableRelation = "Salary Header".No;
        }
        field(2; "Line No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = ToBeClassified;
        }
        field(3; Employee; Code[20])
        {
            TableRelation = Employee;

            trigger OnValidate()
            begin

                if Rec_employee.Get(Employee) then
                    //"Full Name":=Rec_employee.FullName;
                    "Full Name" := Rec_employee."Search Name";
                "Employee SID" := Rec_employee."SID";
                Rec_employee.CalcFields("Basic Salary");
                Position := Rec_employee."Job Title";
                "Basic Salary" := Rec_employee."Basic Salary";
                "Payer Code" := Rec_employee."Payer ID";
                "User Id" := UserId;
                "Modified Date" := WorkDate;
                "Employee Departement" := Rec_employee."Employee Department";
                "Leave Status" := Rec_employee."Leave Status";
            end;
        }
        field(4; "Full Name"; Text[50])
        {
        }
        field(5; "Employee SID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; Position; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Posting Month"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Jaunuary,February,March,April,May,June,July,August,September,October,November,December';
            OptionMembers = " ",Jaunuary,February,March,April,May,June,July,August,September,October,November,December;
        }
        field(8; "Posting Year"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(9; Description; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Employee Nationality"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Employment Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(12; IBAN; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(13; "Payer Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Union.Code;
        }
        field(14; "Employee Contract Code"; Code[20])
        {
            TableRelation = "Employment Contract";
        }
        field(15; "Global Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(16; "Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(17; "Paid Days"; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                /*CALCFIELDS("Abscence Days");
                "Worked Days":="Paid Days"-"Abscence Days";*/

            end;
        }
        field(18; "Worked Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Attendance Rate"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Payment Method"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Payment Method";
        }
        field(21; "Tickets Allowances Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Posting Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Basic Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Accomodation Allowance"; Decimal)
        {
            CalcFormula = Lookup("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Employee Contract Code"),
                                                                    "Allowance Type" = FILTER(Accomodation)));
            FieldClass = FlowField;
        }
        field(25; "Mobile Allowance"; Decimal)
        {
            CalcFormula = Sum("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Employee Contract Code"),
                                                                 "Allowance Type" = FILTER(Mobile)));
            FieldClass = FlowField;
        }
        field(26; "Transport Allowance"; Decimal)
        {
            CalcFormula = Lookup("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Employee Contract Code"),
                                                                    "Allowance Type" = FILTER(Transport)));
            FieldClass = FlowField;
        }
        field(27; "Other Allowance"; Decimal)
        {
            CalcFormula = Lookup("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Employee Contract Code"),
                                                                    "Allowance Type" = FILTER(Other)));
            FieldClass = FlowField;
        }
        field(28; "Gross Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(29; Deductions; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(30; Advance; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(31; Loan; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(32; "Holiday Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(33; Addition; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(34; "EOSB Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Annual Leave Days Qty"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(36; "Annual Leave  Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(37; "Net Pay"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(38; "Creation Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(39; "User Id"; Code[25])
        {
            DataClassification = ToBeClassified;
        }
        field(40; "Modified Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(41; "Abscence Days"; Decimal)
        {
            FieldClass = Normal;
        }
        field(42; "Employee Bank Name"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(43; Bonus; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(44; "Upaid Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(45; "leave Paid"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(46; "Payment Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Salary,"leave Payment","End Of Service";
        }
        field(47; Sponsor; Text[30])
        {
        }
        field(48; Payer; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(49; "Employee Responsability Center"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Relative;

            trigger OnValidate()
            begin
                /*IF RespComp.GET("Employee Responsability Center") THEN
                  "Employee Responsability Center":=RespComp.Description;*/

            end;
        }
        field(50; "Employer EID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Employee Sponsor/Payer";
        }
        field(51; "Employee Departement"; Code[20])
        {
            TableRelation = "Employee Posting Group";
        }
        field(52; "Over Time Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(53; "Extra Hours"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(54; "Pending Salary Days"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Pending Salary Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(56; "Incentive Amount"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(57; "Absence Note"; Text[300])
        {
            DataClassification = ToBeClassified;
        }
        field(58; Note; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(59; "Deduction Note"; Text[300])
        {
            DataClassification = ToBeClassified;
        }
        field(60; "Leave Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","On Vacation",Overdue,Holded;
        }
        field(61; "GOSI Employee Amount"; Decimal) { }
        field(62; "GOSI Employer Amount"; Decimal) { }
        field(63; "Employee Insurance Amount"; Decimal) { }
        field(64; "Education Allowance"; Decimal)
        {
            CalcFormula = Lookup("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Employee Contract Code"),
                                                                    "Allowance Type" = FILTER(Education)));
            FieldClass = FlowField;
        }
        field(65; "Bonus Allowance"; Decimal)
        {
            CalcFormula = Lookup("Default Allowances".Amount WHERE("Employment Contract Code" = FIELD("Employee Contract Code"),
                                                                    "Allowance Type" = FILTER(Bonus)));
            FieldClass = FlowField;
        }
        field(66; "Adjustment"; Decimal)
        {

        }
        field(67; "Employee Posting Group"; Code[20])
        {
            TableRelation = "Employee Posting Group";
        }


    }

    keys
    {
        key(Key1; Employee, "Document No.")
        {
            Clustered = true;
        }
        key(Key2; "Employment Date")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DimMgt: Codeunit DimensionManagement;
        Rec_employee: Record Employee;
        rec_Salary_header: Record "Salary Header";
        RecSponsor: Record "Employee Sponsor/Payer";
        RespComp: Record Relative;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber, ShortcutDimCode);
        //DimMgt.SaveDefaultDim(DATABASE::Employee,"No.",FieldNumber,ShortcutDimCode);
        //MODIFY;
    end;
}

