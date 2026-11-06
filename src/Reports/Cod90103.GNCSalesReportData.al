// Lot 8 – Calculs des rapports de ventes (FRD « Collection of management and monitoring reports »)
// et du réalisé des commerciaux. Tous les montants sont HT, en devise société.
// Hypothèse à confirmer par le manager : « Proforma » = commandes pas encore entièrement facturées.
codeunit 90103 "GNC Sales Report Data"
{
    var
        NoRegionTxt: Label '(No region)';
        InvoiceTxt: Label 'Invoice';
        CreditMemoTxt: Label 'Credit Memo';
        GroupBy: Option Product,Customer,Region,Period;

    // ---------- Réalisé d'un commercial (FRD REQ-SR-007, 1.5) ----------

    // Une ligne compte pour son commercial. Une ligne sans commercial (anciennes factures)
    // compte pour le commercial de l'en-tête de son document.
    procedure GetSalespersonSalesLCY(SalespersonCode: Code[20]; FromDate: Date; ToDate: Date): Decimal
    begin
        exit(GetInvoicedLCY(SalespersonCode, FromDate, ToDate) - GetCreditedLCY(SalespersonCode, FromDate, ToDate));
    end;

    local procedure GetInvoicedLCY(SalespersonCode: Code[20]; FromDate: Date; ToDate: Date) Total: Decimal
    var
        InvoiceHeader: Record "Sales Invoice Header";
        InvoiceLine: Record "Sales Invoice Line";
    begin
        InvoiceLine.SetRange("Posting Date", FromDate, ToDate);
        InvoiceLine.SetRange("GNC Salesperson Code", SalespersonCode);
        if InvoiceLine.FindSet() then
            repeat
                if InvoiceHeader."No." <> InvoiceLine."Document No." then
                    InvoiceHeader.Get(InvoiceLine."Document No.");
                Total += ToLCY(InvoiceLine.Amount, InvoiceHeader."Currency Factor");
            until InvoiceLine.Next() = 0;

        InvoiceLine.Reset();
        InvoiceHeader.Reset();
        InvoiceHeader.SetRange("Salesperson Code", SalespersonCode);
        InvoiceHeader.SetRange("Posting Date", FromDate, ToDate);
        if InvoiceHeader.FindSet() then
            repeat
                InvoiceLine.SetRange("Document No.", InvoiceHeader."No.");
                InvoiceLine.SetRange("GNC Salesperson Code", '');
                InvoiceLine.CalcSums(Amount);
                Total += ToLCY(InvoiceLine.Amount, InvoiceHeader."Currency Factor");
            until InvoiceHeader.Next() = 0;
    end;

    local procedure GetCreditedLCY(SalespersonCode: Code[20]; FromDate: Date; ToDate: Date) Total: Decimal
    var
        CrMemoHeader: Record "Sales Cr.Memo Header";
        CrMemoLine: Record "Sales Cr.Memo Line";
    begin
        CrMemoLine.SetRange("Posting Date", FromDate, ToDate);
        CrMemoLine.SetRange("GNC Salesperson Code", SalespersonCode);
        if CrMemoLine.FindSet() then
            repeat
                if CrMemoHeader."No." <> CrMemoLine."Document No." then
                    CrMemoHeader.Get(CrMemoLine."Document No.");
                Total += ToLCY(CrMemoLine.Amount, CrMemoHeader."Currency Factor");
            until CrMemoLine.Next() = 0;

        CrMemoLine.Reset();
        CrMemoHeader.Reset();
        CrMemoHeader.SetRange("Salesperson Code", SalespersonCode);
        CrMemoHeader.SetRange("Posting Date", FromDate, ToDate);
        if CrMemoHeader.FindSet() then
            repeat
                CrMemoLine.SetRange("Document No.", CrMemoHeader."No.");
                CrMemoLine.SetRange("GNC Salesperson Code", '');
                CrMemoLine.CalcSums(Amount);
                Total += ToLCY(CrMemoLine.Amount, CrMemoHeader."Currency Factor");
            until CrMemoHeader.Next() = 0;
    end;

    local procedure ToLCY(Amount: Decimal; CurrencyFactor: Decimal): Decimal
    begin
        if CurrencyFactor = 0 then
            exit(Amount);
        exit(Amount / CurrencyFactor);
    end;

    // ---------- Rapports par produit, client, région, période ----------
    // Amount 1 = facturé, Amount 2 = avoirs, Amount 3 = net.

    procedure FillSalesByProduct(var Buffer: Record "GNC Sales Report Buffer" temporary; FromDate: Date; ToDate: Date)
    begin
        FillSummary(Buffer, GroupBy::Product, FromDate, ToDate);
    end;

    procedure FillSalesByCustomer(var Buffer: Record "GNC Sales Report Buffer" temporary; FromDate: Date; ToDate: Date)
    begin
        FillSummary(Buffer, GroupBy::Customer, FromDate, ToDate);
    end;

    procedure FillSalesByRegion(var Buffer: Record "GNC Sales Report Buffer" temporary; FromDate: Date; ToDate: Date)
    begin
        FillSummary(Buffer, GroupBy::Region, FromDate, ToDate);
    end;

    procedure FillSalesByPeriod(var Buffer: Record "GNC Sales Report Buffer" temporary; FromDate: Date; ToDate: Date)
    begin
        FillSummary(Buffer, GroupBy::Period, FromDate, ToDate);
    end;

    local procedure FillSummary(var Buffer: Record "GNC Sales Report Buffer" temporary; Grouping: Option; FromDate: Date; ToDate: Date)
    var
        InvoiceHeader: Record "Sales Invoice Header";
        InvoiceLine: Record "Sales Invoice Line";
        CrMemoHeader: Record "Sales Cr.Memo Header";
        CrMemoLine: Record "Sales Cr.Memo Line";
        GroupCode: Code[50];
        GroupName: Text[100];
        AmountLCY: Decimal;
    begin
        InvoiceLine.SetRange("Posting Date", FromDate, ToDate);
        InvoiceLine.SetFilter(Type, '<>%1', InvoiceLine.Type::" ");
        if InvoiceLine.FindSet() then
            repeat
                if InvoiceHeader."No." <> InvoiceLine."Document No." then
                    InvoiceHeader.Get(InvoiceLine."Document No.");
                AmountLCY := ToLCY(InvoiceLine.Amount, InvoiceHeader."Currency Factor");
                GetGroup(Grouping, InvoiceLine."No.", InvoiceLine.Description, InvoiceLine."Sell-to Customer No.", InvoiceLine."Posting Date", GroupCode, GroupName);
                AddToGroup(Buffer, GroupCode, GroupName, InvoiceLine."Quantity (Base)", AmountLCY, 0);
            until InvoiceLine.Next() = 0;

        CrMemoLine.SetRange("Posting Date", FromDate, ToDate);
        CrMemoLine.SetFilter(Type, '<>%1', CrMemoLine.Type::" ");
        if CrMemoLine.FindSet() then
            repeat
                if CrMemoHeader."No." <> CrMemoLine."Document No." then
                    CrMemoHeader.Get(CrMemoLine."Document No.");
                AmountLCY := ToLCY(CrMemoLine.Amount, CrMemoHeader."Currency Factor");
                GetGroup(Grouping, CrMemoLine."No.", CrMemoLine.Description, CrMemoLine."Sell-to Customer No.", CrMemoLine."Posting Date", GroupCode, GroupName);
                AddToGroup(Buffer, GroupCode, GroupName, -CrMemoLine."Quantity (Base)", 0, AmountLCY);
            until CrMemoLine.Next() = 0;
    end;

    local procedure GetGroup(Grouping: Option; No: Code[20]; LineDescription: Text[100]; CustomerNo: Code[20]; PostingDate: Date; var GroupCode: Code[50]; var GroupName: Text[100])
    var
        Customer: Record Customer;
        Classification: Record "GNC Cust. Classification";
    begin
        case Grouping of
            GroupBy::Product:
                begin
                    GroupCode := No;
                    GroupName := LineDescription;
                end;
            GroupBy::Customer:
                begin
                    GroupCode := CustomerNo;
                    GroupName := '';
                    if Customer.Get(CustomerNo) then
                        GroupName := Customer.Name;
                end;
            GroupBy::Region:
                begin
                    GroupCode := '';
                    GroupName := NoRegionTxt;
                    if Customer.Get(CustomerNo) and (Customer."GNC Region Code" <> '') then begin
                        GroupCode := Customer."GNC Region Code";
                        GroupName := '';
                        if Classification.Get(Classification.Type::Region, Customer."GNC Region Code") then
                            GroupName := Classification.Description;
                    end;
                end;
            GroupBy::Period:
                begin
                    GroupCode := CopyStr(Format(PostingDate, 0, '<Year4>-<Month,2>'), 1, MaxStrLen(GroupCode));
                    GroupName := CopyStr(Format(PostingDate, 0, '<Month Text> <Year4>'), 1, MaxStrLen(GroupName));
                end;
        end;
    end;

    local procedure AddToGroup(var Buffer: Record "GNC Sales Report Buffer" temporary; GroupCode: Code[50]; GroupName: Text[100]; Quantity: Decimal; InvoicedLCY: Decimal; CreditedLCY: Decimal)
    begin
        Buffer.SetCurrentKey("Code");
        Buffer.SetRange("Code", GroupCode);
        if not Buffer.FindFirst() then begin
            Buffer.Reset();
            InsertEntry(Buffer);
            Buffer."Code" := GroupCode;
            Buffer.Description := GroupName;
        end;
        Buffer.Quantity += Quantity;
        Buffer."Amount 1" += InvoicedLCY;
        Buffer."Amount 2" += CreditedLCY;
        Buffer."Amount 3" := Buffer."Amount 1" - Buffer."Amount 2";
        Buffer.Modify();
        Buffer.Reset();
    end;

    // Crée une ligne vide avec le numéro suivant
    local procedure InsertEntry(var Buffer: Record "GNC Sales Report Buffer" temporary)
    var
        EntryNo: Integer;
    begin
        Buffer.Reset();
        if Buffer.FindLast() then
            EntryNo := Buffer."Entry No.";
        Buffer.Init();
        Buffer."Entry No." := EntryNo + 1;
        Buffer.Insert();
    end;

    // ---------- Rapports par document ----------

    local procedure AddDocument(var Buffer: Record "GNC Sales Report Buffer" temporary; DocumentNo: Code[20]; DocumentDate: Date; CustomerNo: Code[20]; CustomerName: Text[100]; SalespersonCode: Code[20]; DocumentStatus: Text; AmountLCY: Decimal)
    begin
        InsertEntry(Buffer);
        Buffer."Code" := DocumentNo;
        Buffer."Document Date" := DocumentDate;
        Buffer."Customer No." := CustomerNo;
        Buffer.Description := CustomerName;
        Buffer."Salesperson Code" := SalespersonCode;
        Buffer.Status := CopyStr(DocumentStatus, 1, MaxStrLen(Buffer.Status));
        Buffer."Amount 1" := AmountLCY;
        Buffer.Modify();
    end;

    // Devis en cours (Status standard) + devis archivés Won ou Failed
    procedure FillQuotedSales(var Buffer: Record "GNC Sales Report Buffer" temporary; FromDate: Date; ToDate: Date)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        HeaderArchive: Record "Sales Header Archive";
        LineArchive: Record "Sales Line Archive";
        GNCSalesQuoteMgt: Codeunit "GNC Sales Quote Mgt.";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange("Document Date", FromDate, ToDate);
        if SalesHeader.FindSet() then
            repeat
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                SalesLine.CalcSums("Line Amount");
                AddDocument(Buffer, SalesHeader."No.", SalesHeader."Document Date", SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Customer Name",
                    SalesHeader."Salesperson Code", Format(SalesHeader.Status), ToLCY(SalesLine."Line Amount", SalesHeader."Currency Factor"));
            until SalesHeader.Next() = 0;

        HeaderArchive.SetRange("Document Type", HeaderArchive."Document Type"::Quote);
        HeaderArchive.SetRange("Document Date", FromDate, ToDate);
        HeaderArchive.SetFilter("GNC Quote Status", '%1|%2', HeaderArchive."GNC Quote Status"::Won, HeaderArchive."GNC Quote Status"::Failed);
        if HeaderArchive.FindSet() then
            repeat
                // Une demande clôturée, restaurée puis reclôturée a plusieurs versions : seule la dernière compte
                if GNCSalesQuoteMgt.IsLastQuoteOutcome(HeaderArchive) then begin
                    LineArchive.SetRange("Document Type", HeaderArchive."Document Type");
                    LineArchive.SetRange("Document No.", HeaderArchive."No.");
                    LineArchive.SetRange("Doc. No. Occurrence", HeaderArchive."Doc. No. Occurrence");
                    LineArchive.SetRange("Version No.", HeaderArchive."Version No.");
                    LineArchive.CalcSums("Line Amount");
                    AddDocument(Buffer, HeaderArchive."No.", HeaderArchive."Document Date", HeaderArchive."Sell-to Customer No.", HeaderArchive."Sell-to Customer Name",
                        HeaderArchive."Salesperson Code", Format(HeaderArchive."GNC Quote Status"), ToLCY(LineArchive."Line Amount", HeaderArchive."Currency Factor"));
                end;
            until HeaderArchive.Next() = 0;
    end;

    // Commandes pas encore entièrement facturées : montant restant à facturer
    procedure FillProformaSales(var Buffer: Record "GNC Sales Report Buffer" temporary; FromDate: Date; ToDate: Date)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        RemainingAmount: Decimal;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Document Date", FromDate, ToDate);
        if SalesHeader.FindSet() then
            repeat
                RemainingAmount := 0;
                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                SalesLine.SetFilter(Quantity, '<>0');
                if SalesLine.FindSet() then
                    repeat
                        RemainingAmount += SalesLine."Line Amount" * (SalesLine.Quantity - SalesLine."Quantity Invoiced") / SalesLine.Quantity;
                    until SalesLine.Next() = 0;
                if RemainingAmount <> 0 then
                    AddDocument(Buffer, SalesHeader."No.", SalesHeader."Document Date", SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Customer Name",
                        SalesHeader."Salesperson Code", Format(SalesHeader.Status), ToLCY(RemainingAmount, SalesHeader."Currency Factor"));
            until SalesHeader.Next() = 0;
    end;

    // Factures validées, moins les avoirs validés
    procedure FillInvoicedSales(var Buffer: Record "GNC Sales Report Buffer" temporary; FromDate: Date; ToDate: Date)
    var
        InvoiceHeader: Record "Sales Invoice Header";
        CrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        InvoiceHeader.SetRange("Posting Date", FromDate, ToDate);
        InvoiceHeader.SetAutoCalcFields(Amount);
        if InvoiceHeader.FindSet() then
            repeat
                AddDocument(Buffer, InvoiceHeader."No.", InvoiceHeader."Posting Date", InvoiceHeader."Sell-to Customer No.", InvoiceHeader."Sell-to Customer Name",
                    InvoiceHeader."Salesperson Code", InvoiceTxt, ToLCY(InvoiceHeader.Amount, InvoiceHeader."Currency Factor"));
            until InvoiceHeader.Next() = 0;

        CrMemoHeader.SetRange("Posting Date", FromDate, ToDate);
        CrMemoHeader.SetAutoCalcFields(Amount);
        if CrMemoHeader.FindSet() then
            repeat
                AddDocument(Buffer, CrMemoHeader."No.", CrMemoHeader."Posting Date", CrMemoHeader."Sell-to Customer No.", CrMemoHeader."Sell-to Customer Name",
                    CrMemoHeader."Salesperson Code", CreditMemoTxt, -ToLCY(CrMemoHeader.Amount, CrMemoHeader."Currency Factor"));
            until CrMemoHeader.Next() = 0;
    end;

    // ---------- Réalisé comparé à l'objectif ----------
    // Tous les commerciaux qui ont un PIN ou un objectif sur l'année ; objectif 0 = à saisir.
    // Amount 1 = objectif, Amount 2 = réalisé, Amount 3 = % de réalisation.

    procedure FillSalespersonAchievement(var Buffer: Record "GNC Sales Report Buffer" temporary; Year: Integer)
    var
        Salesperson: Record "Salesperson/Purchaser";
        SalespersonTarget: Record "GNC Salesperson Target";
        HasTarget: Boolean;
    begin
        if Salesperson.FindSet() then
            repeat
                HasTarget := SalespersonTarget.Get(Salesperson.Code, Year);
                if HasTarget or (Salesperson."GNC PIN" <> '') then begin
                    InsertEntry(Buffer);
                    Buffer."Code" := Salesperson.Code;
                    Buffer.Description := CopyStr(Salesperson.Name, 1, MaxStrLen(Buffer.Description));
                    Buffer.Status := CopyStr(Format(Salesperson."GNC Type"), 1, MaxStrLen(Buffer.Status));
                    if HasTarget then
                        Buffer."Amount 1" := SalespersonTarget."Target Amount (LCY)";
                    Buffer."Amount 2" := GetSalespersonSalesLCY(Salesperson.Code, DMY2Date(1, 1, Year), DMY2Date(31, 12, Year));
                    if Buffer."Amount 1" <> 0 then
                        Buffer."Amount 3" := Round(Buffer."Amount 2" / Buffer."Amount 1" * 100, 0.01);
                    Buffer.Modify();
                end;
            until Salesperson.Next() = 0;
    end;
}
