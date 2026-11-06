codeunit 50242 "NAV Tablet Pack Display"
{
    // Inventory of the item at the location / variant of the sales line, in packs
    procedure GetAvailablePacks(SalesLine: Record "Sales Line"): Decimal
    var
        Item: Record Item;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit(0);
        if not Item.Get(SalesLine."No.") then
            exit(0);
        if Item.GetPackQtyPerUoM() = 0 then
            exit(0);
        Item.SetRange("Location Filter", SalesLine."Location Code");
        Item.SetRange("Variant Filter", SalesLine."Variant Code");
        Item.CalcFields(Inventory);
        exit(Item.ToPacks(Item.Inventory));
    end;
}
