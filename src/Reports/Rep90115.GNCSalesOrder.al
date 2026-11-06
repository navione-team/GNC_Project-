// 1.0.0.42 – Bon de commande GNC imprimé, sur le modèle du document actuel du client (exemple
// SO-05200 du zip) : vendeur, Bill To / Ship To avec TRN (n° TVA) et CRN (CR), date, Ref# (n° de PO
// du client = External Document No.), lignes avec codes NPC et MOH, remise %, TVA, résumé de la TVA.
report 90115 "GNC Sales Order"
{
    Caption = 'GNC Sales Order';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/RDL/GNCSalesOrder.rdl';
    ApplicationArea = All;
    UsageCategory = None;

    dataset
    {
        dataitem(Header; "Sales Header")
        {
            DataItemTableView = where("Document Type" = const(Order));
            RequestFilterFields = "No.", "Sell-to Customer No.";

            column(Hdr_No; "No.") { }
            column(Hdr_Date; PrintMgt.FormatDate("Order Date")) { }
            column(Hdr_Ref; "External Document No.") { }
            column(Hdr_CurrencyCode; CurrencyCode) { }
            // vendeur
            column(Sel_Name; CompanyInfo.Name) { }
            column(Sel_Address; CompanyInfo.Address) { }
            column(Sel_District; CompanyInfo."Address 2") { }
            column(Sel_City; CompanyInfo.City + ' ' + CompanyInfo."Post Code") { }
            column(Sel_Country; SellerCountry) { }
            column(Sel_Phone; CompanyInfo."Phone No.") { }
            column(Sel_Email; CompanyInfo."E-Mail") { }
            // facturé à
            column(Bill_Name; "Bill-to Name") { }
            column(Bill_Name2; "Bill-to Name 2") { }
            column(Bill_Address; "Bill-to Address") { }
            column(Bill_Address2; "Bill-to Address 2") { }
            column(Bill_City; "Bill-to City" + ' ' + "Bill-to Post Code") { }
            column(Bill_Country; BillCountry) { }
            // livré à
            column(Ship_Name; "Ship-to Name") { }
            column(Ship_Address; "Ship-to Address") { }
            column(Ship_Address2; "Ship-to Address 2") { }
            column(Ship_City; "Ship-to City" + ' ' + "Ship-to Post Code") { }
            column(Ship_Country; ShipCountry) { }
            column(Cust_TRN; "VAT Registration No.") { }
            column(Cust_CRN; CustomerCRNo) { }
            // totaux
            column(Tot_Sub; TotalSub) { }
            column(Tot_VAT; TotalVAT) { }
            column(Tot_Total; TotalInclVAT) { }

            dataitem(Line; "Sales Line")
            {
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.") where(Type = filter(<> " "));

                column(Ln_SeqNo; SeqNo) { }
                column(Ln_ItemNo; "No.") { }
                column(Ln_Description; Description) { }
                column(Ln_ArabicDescription; ArabicDescription) { }
                column(Ln_NPC; NPCCode) { }
                column(Ln_MOH; MOHCode) { }
                column(Ln_Quantity; Quantity) { }
                column(Ln_Unit; "Unit of Measure Code") { }
                column(Ln_UnitPrice; "Unit Price") { }
                column(Ln_DiscountPct; "Line Discount %") { }
                column(Ln_VATPct; "VAT %") { }
                column(Ln_VATAmount; "Amount Including VAT" - Amount) { }
                column(Ln_Amount; Amount) { }

                trigger OnAfterGetRecord()
                begin
                    SeqNo += 1;
                    PrintMgt.GetItemCodes("No.", NPCCode, MOHCode, ArabicDescription);
                    if Type <> Type::Item then begin
                        NPCCode := '';
                        MOHCode := '';
                        ArabicDescription := '';
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SeqNo := 0;
                end;
            }

            trigger OnAfterGetRecord()
            var
                Customer: Record Customer;
                SalesLine: Record "Sales Line";
            begin
                CustomerCRNo := '';
                if Customer.Get("Sell-to Customer No.") then
                    CustomerCRNo := Customer."GNC CR No.";
                BillCountry := PrintMgt.GetCountryName("Bill-to Country/Region Code");
                ShipCountry := PrintMgt.GetCountryName("Ship-to Country/Region Code");
                CurrencyCode := "Currency Code";
                if CurrencyCode = '' then
                    CurrencyCode := GLSetup."LCY Code";
                SalesLine.SetRange("Document Type", "Document Type");
                SalesLine.SetRange("Document No.", "No.");
                SalesLine.CalcSums(Amount, "Amount Including VAT");
                TotalSub := SalesLine.Amount;
                TotalInclVAT := SalesLine."Amount Including VAT";
                TotalVAT := TotalInclVAT - TotalSub;
            end;
        }
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        GLSetup.Get();
        SellerCountry := PrintMgt.GetCountryName(CompanyInfo."Country/Region Code");
    end;

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        PrintMgt: Codeunit "GNC Sales Doc. Print Mgt.";
        SeqNo: Integer;
        NPCCode: Code[20];
        MOHCode: Code[20];
        ArabicDescription: Text[250];
        CustomerCRNo: Code[30];
        SellerCountry: Text[50];
        BillCountry: Text[50];
        ShipCountry: Text[50];
        CurrencyCode: Code[10];
        TotalSub: Decimal;
        TotalVAT: Decimal;
        TotalInclVAT: Decimal;
}
