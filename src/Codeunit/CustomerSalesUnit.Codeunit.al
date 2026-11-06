codeunit 50230 "NAV Customer Sales Unit"
{
    // When an item is entered on a sales line, the unit of measure of the line is
    // replaced by the Customer Sales Unit of the sell-to customer, provided that the
    // item has this unit in its Item Units of Measure. Otherwise the standard
    // behavior applies (Sales Unit of Measure of the item).

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure ApplyCustomerSalesUnitOnAfterValidateNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        ApplyCustomerSalesUnit(Rec);
    end;

    // Also applied when the variant changes (standard may reset the unit)
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Variant Code', false, false)]
    local procedure ApplyCustomerSalesUnitOnAfterValidateVariant(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec."Variant Code" <> xRec."Variant Code" then
            ApplyCustomerSalesUnit(Rec);
    end;

    procedure ApplyCustomerSalesUnit(var SalesLine: Record "Sales Line")
    var
        SalesUnitCode: Code[10];
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        if SalesLine."No." = '' then
            exit;
        if SalesLine.IsTemporary() then
            exit;

        SalesUnitCode := GetCustomerSalesUnit(SalesLine."Sell-to Customer No.", SalesLine."No.");
        if SalesUnitCode = '' then
            exit;
        if SalesLine."Unit of Measure Code" = SalesUnitCode then
            exit;

        SalesLine.Validate("Unit of Measure Code", SalesUnitCode);
    end;

    // Returns the customer sales unit if it is one of the units of the item, otherwise ''
    procedure GetCustomerSalesUnit(CustomerNo: Code[20]; ItemNo: Code[20]): Code[10]
    var
        Customer: Record Customer;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if (CustomerNo = '') or (ItemNo = '') then
            exit('');
        if not Customer.Get(CustomerNo) then
            exit('');
        if Customer."Customer Sales Unit" = '' then
            exit('');
        if not ItemUnitOfMeasure.Get(ItemNo, Customer."Customer Sales Unit") then
            exit('');
        exit(Customer."Customer Sales Unit");
    end;
}
