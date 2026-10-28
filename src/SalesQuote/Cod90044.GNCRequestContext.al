// "Mémoire de session" (SingleInstance) : retient le commercial identifié par PIN et le client
// de la fiche devis actuellement ouverte.
// Pourquoi : en BC 28, les listes de clients et d'articles du devis ouvrent directement les pages
// standard "Customer Lookup" et "Item Lookup" sans passer par un événement du devis. Ces pages ne
// savent donc pas quel devis les a ouvertes : elles lisent ici le commercial et le client à utiliser
// pour filtrer (codeunit 90043). La fiche devis (pageextension 90016) met à jour ces valeurs
// et les vide à sa fermeture.
codeunit 90044 "GNC Request Context"
{
    SingleInstance = true;

    var
        CurrentSalespersonCode: Code[20];
        CurrentCustomerNo: Code[20];

    procedure SetContext(SalespersonCode: Code[20]; CustomerNo: Code[20])
    begin
        CurrentSalespersonCode := SalespersonCode;
        CurrentCustomerNo := CustomerNo;
    end;

    procedure ClearContext()
    begin
        SetContext('', '');
    end;

    procedure GetSalesperson(): Code[20]
    begin
        exit(CurrentSalespersonCode);
    end;

    procedure GetCustomer(): Code[20]
    begin
        exit(CurrentCustomerNo);
    end;
}
