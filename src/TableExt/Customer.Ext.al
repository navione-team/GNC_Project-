tableextension 50230 "NAV Customer" extends Customer
{
    fields
    {
        // Default unit of measure proposed on the sales lines of this customer.
        // It is applied only when the item has this unit in its Item Units of Measure.
        field(50230; "Customer Sales Unit"; Code[10])
        {
            Caption = 'Customer Sales Unit';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
    }
}

