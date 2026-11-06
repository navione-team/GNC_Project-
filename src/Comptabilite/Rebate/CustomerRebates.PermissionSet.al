permissionset 50300 "NAV Customer Rebates"
{
    Assignable = true;
    Caption = 'Customer Rebates';

    Permissions =
        tabledata "NAV Rebate Setup" = RIMD,
        tabledata "NAV Rebate Agreement" = RIMD,
        tabledata "NAV Core Rebate Line" = RIMD,
        tabledata "NAV Rebate Calculation" = RIMD,
        tabledata "NAV Rebate Calc. Line" = RIMD,
        table "NAV Rebate Setup" = X,
        table "NAV Rebate Agreement" = X,
        table "NAV Core Rebate Line" = X,
        table "NAV Rebate Calculation" = X,
        table "NAV Rebate Calc. Line" = X,
        codeunit "NAV Rebate Mgt." = X,
        report "NAV Calculate Customer Rebates" = X,
        page "NAV Rebate Setup" = X,
        page "NAV Rebate Agreements" = X,
        page "NAV Rebate Agreement Card" = X,
        page "NAV Core Rebate Lines" = X,
        page "NAV Rebate Calculations" = X,
        page "NAV Rebate Calculation Card" = X,
        page "NAV Rebate Calc. Lines" = X;
}
