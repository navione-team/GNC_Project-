permissionset 50200 "NAV Transit Folder"
{
    Assignable = true;
    Caption = 'Transit Folder';

    Permissions =
        tabledata "NAV Transit Folder" = RIMD,
        tabledata "NAV Transit Folder Line" = RIMD,
        tabledata "NAV Transit Folder Item Line" = RIMD,
        table "NAV Transit Folder Item Line" = X,
        page "NAV Transit Folder Item Lines" = X,
        table "NAV Transit Folder" = X,
        table "NAV Transit Folder Line" = X,
        codeunit "NAV Transit Folder Mgt." = X,
        codeunit "NAV Transit Folder Events" = X,
        page "NAV Transit Folder" = X,
        page "NAV Transit Folder List" = X,
        page "NAV Transit Folder Subform" = X,
        report "NAV Transit Folder" = X,
        report "NAV Landed Cost by Item" = X,
        tabledata "NAV Transit Folder Accrual" = RIMD,
        table "NAV Transit Folder Accrual" = X,
        codeunit "NAV Transit Folder Accrual" = X,
        codeunit "NAV Transit Folder Attachments" = X,
        page "NAV Transit Folder Accruals" = X;
}
