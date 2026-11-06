namespace LABSV.LABSV;

using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;

report 50001 WHT
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/RDL/WHT.rdl';
    Caption = 'WHT List';
    dataset
    {
        dataitem(PurchInvHeader; "Purch. Inv. Header")
        {
            RequestFilterFields = "Posting Date", "Buy-from Vendor No.";
            DataItemTableView = where("WHT Rate" = filter(<> 0));
            column(AmountIncludingVAT; "Amount Including VAT")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(WHTRate; "WHT Rate")
            {
            }
            column(CurrencyCode; "Currency Code")
            {
            }
            column(BuyfromVendorName; "Buy-from Vendor Name")
            {
            }
            column(BuyfromCounty; "Buy-from County")
            {
            }
            column(VendorActivity; Vendor."Vendor Activity")
            {

            }
            column(WhtAmount; WhtAmount)
            {

            }
            column(MonthName; FORMAT("Posting Date", 0, '<Month Text>'))
            {

            }

            column(Year; format(Date2DMY("Posting Date", 3)))
            {

            }


            trigger OnAfterGetRecord()
            var

            begin
                if Vendor.get("Buy-from Vendor No.") then;
                PurchInvHeader.CalcFields("Amount Including VAT");
                WHTAmount := "Amount Including VAT" * ("WHT Rate" / 100);
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
    var
        WhtAmount: Decimal;
        Vendor: Record Vendor;
}
