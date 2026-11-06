permissionset 90030 "NAVIONE PHARMA MIG"
{
    Assignable = true;
    Caption = 'Navione - Pharma Data Migration';

    Permissions = tabledata "Product Group" = RIMD,
                  tabledata "Item Family" = RIMD,
                  page "Product Group List" = X,
                  table WithholdingTaxTypes = X,
                  tabledata WithholdingTaxTypes = RMID,
                  page "Item Family List" = X,
                  codeunit "NAV Customer Sales Unit" = X;


}
