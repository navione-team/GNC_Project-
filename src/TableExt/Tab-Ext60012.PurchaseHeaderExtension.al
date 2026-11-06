namespace LABS.LABS;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using System.Security.User;

tableextension 50101 "PurchaseHeaderExtension " extends "Purchase Header"
{
    fields
    {
        field(50000; "Withholding Tax Type"; Code[20])
        {
            Caption = 'Withholding Tax Type';

        }

        field(50001; "Related"; Boolean)
        {
            Caption = 'Related';
        }
        field(50002; "WHT"; Boolean)
        {
            Caption = 'WHT';
        }

        field(50003; "WHT Rate"; Decimal)
        {
            Caption = 'WHT Rate';
        }


        field(50004; "WHT Amount"; Decimal)
        {
            Caption = 'WHT Amount';
        }




        modify("Buy-from Vendor No.")
        {
            trigger OnAfterValidate()
            var
                Vendor: Record Vendor;
                WHTType: Record WithholdingTaxTypes;
            begin
                if "Pay-to Vendor No." <> '' then begin
                    Vendor.Get("Pay-to Vendor No.");
                    if Vendor."Withholding Tax Type" <> '' then begin
                        "Withholding Tax Type" := Vendor."Withholding Tax Type";
                        "Related" := Vendor."Related";
                        WHTType.get(Vendor."Withholding Tax Type");
                        if Related then
                            rec."WHT Rate" := WHTType."Related Rate %"
                        else
                            rec."WHT Rate" := WHTType."Nonrelated Rate %";
                    end;

                end;
            end;
        }
    }
}
