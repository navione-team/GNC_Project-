// 1.0.0.39 – Facture fiscale GNC (TAX INVOICE / فاتورة ضريبية), sur le modèle de la facture actuelle
// du client (exemple SI-006200 du zip envoyé par GNC) : arabe / anglais, vendeur et acheteur avec
// n° de TVA et CR, lignes avec lot, date de fabrication et date d'expiration, totaux, QR code.
// QR code = version simple ZATCA (phase 1), dessiné en image PNG par BC. L'e-facturation ZATCA
// phase 2 (envoi à l'administration) n'est PAS faite ici.
// 1.0.0.42 – Fonctions communes déplacées dans le codeunit 90118 ; un même lot livré en plusieurs
// expéditions est regroupé sur une seule ligne.
report 90113 "GNC Tax Invoice"
{
    Caption = 'Tax Invoice';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/RDL/GNCTaxInvoice.rdl';
    ApplicationArea = All;
    UsageCategory = None;

    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            RequestFilterFields = "No.", "Sell-to Customer No.", "Posting Date";

            // --- en-tête ---
            column(Hdr_No; "No.") { }
            column(Hdr_PostingDate; PrintMgt.FormatDate("Posting Date")) { }
            column(Hdr_CustomerNo; "Sell-to Customer No.") { }
            column(Hdr_OrderNo; "Order No.") { }
            column(Hdr_ShipmentNo; ShipmentNo) { }
            column(Hdr_LineCode; CustomerLineCode) { }
            column(Hdr_City; "Sell-to City") { }
            column(Hdr_PONo; "External Document No.") { }
            column(Hdr_CurrencyCode; CurrencyCode) { }
            column(Hdr_QRCode; QRCodeImage) { }
            // --- vendeur (Company Information) ---
            column(Sel_Name; CompanyInfo.Name) { }
            column(Sel_Name2; CompanyInfo."Name 2") { }
            column(Sel_Address; CompanyInfo.Address) { }
            column(Sel_District; CompanyInfo."Address 2") { }
            column(Sel_City; CompanyInfo.City) { }
            column(Sel_Country; SellerCountry) { }
            column(Sel_PostCode; CompanyInfo."Post Code") { }
            column(Sel_VATNo; CompanyInfo."VAT Registration No.") { }
            column(Sel_CRNo; CompanyInfo."Registration No.") { }
            column(Sel_Phone; CompanyInfo."Phone No.") { }
            // --- acheteur ---
            column(Buy_Name; "Bill-to Name") { }
            column(Buy_Name2; "Bill-to Name 2") { }
            column(Buy_Address; "Bill-to Address") { }
            column(Buy_District; "Bill-to Address 2") { }
            column(Buy_City; "Bill-to City") { }
            column(Buy_Country; BuyerCountry) { }
            column(Buy_PostCode; "Bill-to Post Code") { }
            column(Buy_VATNo; "VAT Registration No.") { }
            column(Buy_CRNo; CustomerCRNo) { }
            // --- totaux (calculés sur les lignes) ---
            column(Tot_Taxable; TotalTaxable) { }
            column(Tot_VAT; TotalVAT) { }
            column(Tot_Due; TotalDue) { }
            column(Tot_Discount; TotalDiscount) { }

            dataitem(Line; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.") where(Type = filter(<> " "));

                column(Ln_SeqNo; SeqNo) { }
                column(Ln_LineNo; "Line No.") { }
                column(Ln_ItemNo; "No.") { }
                column(Ln_Description; Description) { }
                column(Ln_ArabicDescription; ArabicDescription) { }
                column(Ln_LotText; LotText) { }
                column(Ln_Unit; "Unit of Measure Code") { }
                column(Ln_UnitPrice; "Unit Price") { }
                column(Ln_Quantity; Quantity) { }
                column(Ln_Taxable; Amount) { }
                column(Ln_Discount; "Line Discount Amount") { }
                column(Ln_VATPct; "VAT %") { }
                column(Ln_VATAmount; "Amount Including VAT" - Amount) { }
                column(Ln_Total; "Amount Including VAT") { }

                trigger OnAfterGetRecord()
                var
                    NPCCode: Code[20];
                    MOHCode: Code[20];
                begin
                    SeqNo += 1;
                    ArabicDescription := '';
                    LotText := '';
                    if Type = Type::Item then begin
                        PrintMgt.GetItemCodes("No.", NPCCode, MOHCode, ArabicDescription);
                        LotText := PrintMgt.GetLotText(Enum::"Item Ledger Document Type"::"Sales Invoice", "Document No.", "Line No.");
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
                SalesInvLine: Record "Sales Invoice Line";
            begin
                CustomerCRNo := '';
                CustomerLineCode := '';
                if Customer.Get("Sell-to Customer No.") then begin
                    CustomerCRNo := Customer."GNC CR No.";
                    CustomerLineCode := Customer."GNC Line Code";
                end;
                BuyerCountry := PrintMgt.GetCountryName("Bill-to Country/Region Code");
                CurrencyCode := "Currency Code";
                if CurrencyCode = '' then
                    CurrencyCode := GLSetup."LCY Code";

                // totaux : HT, TVA, TTC, remises (ligne + facture)
                SalesInvLine.SetRange("Document No.", "No.");
                SalesInvLine.CalcSums(Amount, "Amount Including VAT", "Line Discount Amount", "Inv. Discount Amount");
                TotalTaxable := SalesInvLine.Amount;
                TotalDue := SalesInvLine."Amount Including VAT";
                TotalVAT := TotalDue - TotalTaxable;
                TotalDiscount := SalesInvLine."Line Discount Amount" + SalesInvLine."Inv. Discount Amount";

                ShipmentNo := PrintMgt.GetFirstShipmentNo("No.");
                QRCodeImage := PrintMgt.GetQRCodeImage("Posting Date", SystemCreatedAt, TotalDue, TotalVAT);
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
        ArabicDescription: Text[250];
        LotText: Text;
        ShipmentNo: Code[20];
        CustomerCRNo: Code[30];
        CustomerLineCode: Code[20];
        SellerCountry: Text[50];
        BuyerCountry: Text[50];
        CurrencyCode: Code[10];
        QRCodeImage: Text;
        TotalTaxable: Decimal;
        TotalVAT: Decimal;
        TotalDue: Decimal;
        TotalDiscount: Decimal;
}
