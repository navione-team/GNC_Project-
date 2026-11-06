permissionset 50310 "NAV Bank Facility"
{
    Assignable = true;
    Caption = 'Bank Facility Management';

    Permissions =
        tabledata "NAV Bank Facility Setup" = RIMD,
        tabledata "NAV Bank Facility" = RIMD,
        table "NAV Bank Facility Setup" = X,
        table "NAV Bank Facility" = X,
        codeunit "NAV Bank Facility Mgt." = X,
        codeunit "NAV Bank Facility Maturity Job" = X,
        page "NAV Bank Facility Setup" = X,
        page "NAV Bank Facilities" = X,
        page "NAV Bank Facility Card" = X;
}
