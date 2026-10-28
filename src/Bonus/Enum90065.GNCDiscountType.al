// Lot 6 – Niveau produit d'une règle de remise GNC (FRD « Discount Management ») :
// un article, une catégorie d'articles, ou tous les articles (remise « client »).
enum 90065 "GNC Discount Type"
{
    Extensible = true;

    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; "Item Category")
    {
        Caption = 'Item Category';
    }
    value(2; "All Items")
    {
        Caption = 'All Items';
    }
}
