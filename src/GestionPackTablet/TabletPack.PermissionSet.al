permissionset 50240 "NAV Tablet Pack"
{
    Assignable = true;
    Caption = 'Tablet / Pack and Batches';

    Permissions =
        codeunit "NAV Tablet Sales Line" = X,
        codeunit "NAV Tablet Availability" = X,
        codeunit "NAV Tablet Pack Display" = X,
        codeunit "NAV Lot Management" = X,
        codeunit "NAV Lot Expiry Job" = X,
        tabledata "Lot No. Information" = RIM;
}
