namespace LABS.LABS;

using Microsoft.Purchases.History;

tableextension 60013 PurchRcptHeaderExtension extends "Purch. Rcpt. Header"
{
    fields
    {
        field(50000; "Withholding Tax Type"; Code[20])
        {
            Caption = 'Withholding Tax Type';

        }

        field(50001; "Related"; Boolean)
        {
            Caption = 'Related';
        }
        field(50002; "WHT"; Boolean)
        {
            Caption = 'WHT';
        }
        field(50003; "WHT Rate"; Decimal)
        {
            Caption = 'WHT Rate';
        }


        field(50004; "WHT Amount"; Decimal)
        {
            Caption = 'WHT Amount';
        }
    }
}
