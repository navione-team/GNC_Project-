permissionset 90030 "NAVIONE PHARMA MIG"
{
    Assignable = true;
    Caption = 'Navione - Pharma Data Migration';

    Permissions = tabledata "Product Group" = RIMD,
                  tabledata "Item Family" = RIMD,
                  page "Product Group List" = X,
                  page "Item Family List" = X;
}
