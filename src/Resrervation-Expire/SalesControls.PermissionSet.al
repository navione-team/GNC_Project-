permissionset 50260 "NAV Sales Controls"
{
    Assignable = true;
    Caption = 'Reservations, Stores, Refunds and Damaged Products';

    Permissions =
        codeunit "NAV Reservation Expiry" = X,
        codeunit "NAV Sales Controls" = X,
        codeunit "NAV Damage Transfer-Post" = X,
        codeunit "NAV Damaged Bin Control" = X,
        page "NAV Sales Reservations" = X,
        report "NAV Non-Moving Stock" = X,
        report "NAV Damaged Stock" = X,
        report "NAV Reserved Stock" = X,
        page "NAV Damage Transfer" = X,
        page "NAV Damage Transfer Subform" = X,
        page "NAV Damage Transfers" = X,
        page "NAV Posted Damage Transfer" = X,
        page "NAV Posted Damage Trf. Subform" = X,
        page "NAV Posted Damage Transfers" = X,
        table "NAV Damage Transfer Header" = X,
        table "NAV Damage Transfer Line" = X,
        table "NAV Posted Damage Transfer" = X,
        table "NAV Posted Damage Trf. Line" = X,
        tabledata "NAV Damage Transfer Header" = RIMD,
        tabledata "NAV Damage Transfer Line" = RIMD,
        tabledata "NAV Posted Damage Transfer" = RI,
        tabledata "NAV Posted Damage Trf. Line" = RI,
        tabledata "Reservation Entry" = RMD;
}
