table 70010 "L&A Installment Schedule"
{

    fields
    {
        field(1; Month; Integer)
        {
        }
        field(2; Year; Integer)
        {
        }
        field(3; Slice; Decimal)
        {
            AutoFormatType = 0;
            DecimalPlaces = 3 : 3;
        }
        field(4; "N° Loan"; Code[20])
        {

            trigger OnValidate()
            begin
                RecLoanAdv.Reset;
                RecLoanAdv.SetRange("No.", "N° Loan");
                if RecLoanAdv.FindSet then begin
                    Employee := RecLoanAdv.Employee;
                    Modify;
                end;
            end;
        }
        field(5; Valid; Boolean)
        {
        }
        field(6; Check; Boolean)
        {
        }
        field(7; Type; Option)
        {
            OptionMembers = Loan,Advance,Refund;
        }
        field(8; "Slice Nbr"; Integer)
        {
        }
        field(9; Balance; Boolean)
        {
        }
        field(10; Employee; Code[20])
        {
            CalcFormula = Lookup ("Rec. Loan & Advance".Employee WHERE ("No." = FIELD ("N° Loan")));
            FieldClass = FlowField;
        }
        field(11; "Payment No"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Payment No" <> '' then
                    Paid := true;
            end;
        }
        field(12; Paid; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "N° Loan", Type, Year, Month)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        RecLoanAdv: Record "Rec. Loan & Advance";
}

