// 1.0.0.42 – Avoir GNC imprimé (Credit Note), sur le modèle du document actuel du client (exemple
// CN-01821 du zip) : date, Ref#, n° et date de la facture d'origine, motif (Reason Code, ex. « Expired
// Goods »), lignes avec codes NPC et MOH et lots retournés, totaux, montant utilisé / restant, résumé
// de la TVA et QR code ZATCA (phase 1).
report 90116 "GNC Credit Note"
{
    Caption = 'GNC Credit Note';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Reports/RDL/GNCCreditNote.rdl';
    ApplicationArea = All;
    UsageCategory = None;

    dataset
    {
        dataitem(Header; "Sales Cr.Memo Header")
        {
            RequestFilterFields = "No.", "Sell-to Customer No.", "Posting Date";

            column(Hdr_No; "No.") { }
            column(Hdr_Date; PrintMgt.FormatDate("Posting Date")) { }
            column(Hdr_Ref; "External Document No.") { }
            column(Hdr_InvoiceNo; InvoiceNo) { }
            column(Hdr_InvoiceDate; InvoiceDate) { }
            column(Hdr_Subject; Subject) { }
            column(Hdr_CurrencyCode; CurrencyCode) { }
            column(Hdr_QRCode; QRCodeImage) { }
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
            column(Cust_TRN; "VAT Registration No.") { }
            column(Cust_CRN; CustomerCRNo) { }
            // totaux
            column(Tot_Sub; TotalSub) { }
            column(Tot_VAT; TotalVAT) { }
            column(Tot_Total; TotalInclVAT) { }
            column(Tot_Used; CreditsUsed) { }
            column(Tot_Remaining; CreditsRemaining) { }

            dataitem(Line; "Sales Cr.Memo Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.") where(Type = filter(<> " "));

                column(Ln_SeqNo; SeqNo) { }
                column(Ln_ItemNo; "No.") { }
                column(Ln_Description; Description) { }
                column(Ln_ArabicDescription; ArabicDescription) { }
                column(Ln_LotText; LotText) { }
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
                    NPCCode := '';
                    MOHCode := '';
                    ArabicDescription := '';
                    LotText := '';
                    if Type = Type::Item then begin
                        PrintMgt.GetItemCodes("No.", NPCCode, MOHCode, ArabicDescription);
                        LotText := PrintMgt.GetLotText(Enum::"Item Ledger Document Type"::"Sales Credit Memo", "Document No.", "Line No.");
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
                SalesInvHeader: Record "Sales Invoice Header";
                ReasonCode: Record "Reason Code";
                SalesCrMemoLine: Record "Sales Cr.Memo Line";
            begin
                CustomerCRNo := '';
                if Customer.Get("Sell-to Customer No.") then
                    CustomerCRNo := Customer."GNC CR No.";
                BillCountry := PrintMgt.GetCountryName("Bill-to Country/Region Code");
                CurrencyCode := "Currency Code";
                if CurrencyCode = '' then
                    CurrencyCode := GLSetup."LCY Code";

                // facture d'origine (avoir créé par « Correct » ou lettré sur une facture)
                InvoiceNo := '';
                InvoiceDate := '';
                if "Applies-to Doc. Type" = "Applies-to Doc. Type"::Invoice then
                    InvoiceNo := "Applies-to Doc. No.";
                if (InvoiceNo <> '') and SalesInvHeader.Get(InvoiceNo) then
                    InvoiceDate := PrintMgt.FormatDate(SalesInvHeader."Posting Date");

                // motif de l'avoir
                Subject := "Reason Code";
                if ReasonCode.Get("Reason Code") and (ReasonCode.Description <> '') then
                    Subject := ReasonCode.Description;

                SalesCrMemoLine.SetRange("Document No.", "No.");
                SalesCrMemoLine.CalcSums(Amount, "Amount Including VAT");
                TotalSub := SalesCrMemoLine.Amount;
                TotalInclVAT := SalesCrMemoLine."Amount Including VAT";
                TotalVAT := TotalInclVAT - TotalSub;

                // montant restant de l'avoir (écriture client), et montant déjà utilisé
                CalcFields("Remaining Amount");
                CreditsRemaining := Abs("Remaining Amount");
                CreditsUsed := TotalInclVAT - CreditsRemaining;

                QRCodeImage := PrintMgt.GetQRCodeImage("Posting Date", SystemCreatedAt, TotalInclVAT, TotalVAT);
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
        LotText: Text;
        CustomerCRNo: Code[30];
        SellerCountry: Text[50];
        BillCountry: Text[50];
        CurrencyCode: Code[10];
        InvoiceNo: Code[20];
        InvoiceDate: Text;
        Subject: Text[100];
        QRCodeImage: Text;
        TotalSub: Decimal;
        TotalVAT: Decimal;
        TotalInclVAT: Decimal;
        CreditsUsed: Decimal;
        CreditsRemaining: Decimal;
}
