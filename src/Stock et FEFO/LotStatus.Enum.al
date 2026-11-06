// Status of a batch (lot). Only Available batches can be sold, transferred or consumed.
enum 50250 "NAV Lot Status"
{
    Caption = 'Lot Status';
    Extensible = true;

    value(0; Available)
    {
        Caption = 'Available';
    }
    value(1; Quarantine)
    {
        Caption = 'Quarantine';
    }
    value(2; Blocked)
    {
        Caption = 'Blocked';
    }
    value(3; Expired)
    {
        Caption = 'Expired';
    }
}
