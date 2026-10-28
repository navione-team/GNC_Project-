// Sur quoi porte l'affectation d'un commercial pour un client :
// un article précis, ou toute une catégorie d'articles.
// Les deux sont proposés tant que GNC n'a pas précisé (question ouverte dans CLAUDE.md).
enum 90031 "GNC Assignment Type"
{
    Extensible = true;
    Caption = 'Assignment Type';

    value(0; Item)
    {
        Caption = 'Item';
    }
    value(1; "Item Category")
    {
        Caption = 'Item Category';
    }
}
