tableextension 50000 ExteVendor extends Vendor
{
    fields
    {
        field(50000; "Withholding Tax Type"; Code[20])
        {
            Caption = 'Withholding Tax Type';
            TableRelation = WithholdingTaxTypes;
        }

        field(50001; "Related"; Boolean)
        {
            Caption = 'Related';
        }
        field(50002; "Vendor Activity"; Text[50])
        {
            Caption = 'Vendor Activity';
        }
    }
}
