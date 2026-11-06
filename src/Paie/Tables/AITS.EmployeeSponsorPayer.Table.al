table 70026 "Employee Sponsor/Payer"
{
    DataPerCompany = true;
    Caption = 'Employee Sponsor/Payer';
    LookupPageId = "Employee Sponsor/Payer List";

    fields
    {
        field(1; Code; Code[10]) { Caption = 'Code'; }
        field(2; Name; Text[50]) { Caption = 'Name'; }
        field(50000; "Payer Bank"; Code[20]) { Caption = 'Payer Bank'; }
        field(50001; "Payer EID"; Code[20]) { Caption = 'Payer EID'; }
        field(50002; "Payer IBAN"; Code[25]) { Caption = 'Payer IBAN'; }
        field(50003; "Payer QID"; Code[20]) { Caption = 'Payer QID'; }
        field(50004; Description; Code[30]) { Caption = 'Description'; }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
