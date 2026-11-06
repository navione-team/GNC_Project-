permissionset 50320 "NAV Accounting Ctrl"
{
    Assignable = true;
    Caption = 'GNC Accounting Controls';

    Permissions =
        tabledata "NAV User Bank Access" = RIMD,
        tabledata "NAV Statutory Reserve Setup" = RIMD,
        table "NAV User Bank Access" = X,
        table "NAV Statutory Reserve Setup" = X,
        codeunit "NAV Exch. Diff. Simulation" = X,
        codeunit "NAV Bank Access Control" = X,
        report "NAV Calc. Statutory Reserve" = X,
        page "NAV User Bank Access" = X,
        page "NAV Statutory Reserve Setup" = X;
}

// For all the users: read access to the bank access list, needed by the control at posting time
permissionset 50321 "NAV Bank Access Read"
{
    Assignable = true;
    Caption = 'GNC Bank Access (read)';

    Permissions =
        tabledata "NAV User Bank Access" = R,
        codeunit "NAV Bank Access Control" = X,
        codeunit "NAV Exch. Diff. Simulation" = X;
}
