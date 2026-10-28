// Page d'accueil GNC (maquette validée par Haifa le 2026-10-27) : calcul des chiffres affichés par le
// bandeau (page 90098) et les tuiles (page 90007), et ouverture des pages quand on clique dessus.
// Uniquement des éléments standard de BC dans la page d'accueil (pas de JavaScript : il y serait écrasé).
codeunit 90101 "GNC Role Center Mgt."
{
    // ---------- Demandes ----------

    procedure CountRequestsToGroup(): Integer
    var
        SalesHeader: Record "Sales Header";
    begin
        SetReleasedRequestFilter(SalesHeader);
        exit(SalesHeader.Count());
    end;

    // Demandes approuvées dont le commercial n'est pas confirmé par PIN (ne seront pas regroupées)
    procedure CountRequestsWithoutPIN() Result: Integer
    var
        SalesHeader: Record "Sales Header";
        GNCSalespersonPINMgt: Codeunit "GNC Salesperson PIN Mgt.";
    begin
        SetReleasedRequestFilter(SalesHeader);
        if SalesHeader.FindSet() then
            repeat
                if not GNCSalespersonPINMgt.IsSalespersonConfirmed(SalesHeader) then
                    Result += 1;
            until SalesHeader.Next() = 0;
    end;

    local procedure SetReleasedRequestFilter(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
        SalesHeader.SetRange("GNC Closed", false);
    end;

    // ---------- Livraison (même filtre que le plan de livraison) ----------

    procedure SetToShipFilter(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
        SalesHeader.SetRange("Completely Shipped", false);
    end;

    procedure CountToShip(): Integer
    var
        SalesHeader: Record "Sales Header";
    begin
        SetToShipFilter(SalesHeader);
        exit(SalesHeader.Count());
    end;

    procedure CountVeryUrgent(WithoutDriverOnly: Boolean): Integer
    var
        SalesHeader: Record "Sales Header";
    begin
        SetToShipFilter(SalesHeader);
        SalesHeader.SetRange("GNC Delivery Priority", SalesHeader."GNC Delivery Priority"::"Very Urgent");
        if WithoutDriverOnly then
            SalesHeader.SetRange("GNC Driver Code", '');
        exit(SalesHeader.Count());
    end;

    procedure CountWithoutDriver(): Integer
    var
        SalesHeader: Record "Sales Header";
    begin
        SetToShipFilter(SalesHeader);
        SalesHeader.SetRange("GNC Driver Code", '');
        exit(SalesHeader.Count());
    end;

    // ---------- Montants ----------

    // Ventes HT (écritures client « Sales (LCY) » = factures - avoirs)
    procedure GetSales(FromDate: Date; ToDate: Date): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Posting Date", FromDate, ToDate);
        CustLedgerEntry.CalcSums("Sales (LCY)");
        exit(CustLedgerEntry."Sales (LCY)");
    end;

    procedure GetSalesThisMonth(): Decimal
    begin
        exit(GetSales(CalcDate('<-CM>', WorkDate()), CalcDate('<CM>', WorkDate())));
    end;

    procedure GetSalesSameMonthLastYear(): Decimal
    begin
        exit(GetSales(CalcDate('<-CM-1Y>', WorkDate()), CalcDate('<CM-1Y>', WorkDate())));
    end;

    procedure GetSalesThisYear(): Decimal
    begin
        exit(GetSales(CalcDate('<-CY>', WorkDate()), CalcDate('<CY>', WorkDate())));
    end;

    // Montant TTC des commandes en cours
    procedure GetOpenOrdersAmount() Result: Decimal
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.CalcFields("Amount Including VAT");
                Result += SalesHeader."Amount Including VAT";
            until SalesHeader.Next() = 0;
    end;

    // % de l'objectif des commerciaux de l'année (total réalisé / total des objectifs)
    procedure GetTargetAchievedPct(): Decimal
    var
        SalespersonTarget: Record "GNC Salesperson Target";
        TotalTarget: Decimal;
        TotalActual: Decimal;
    begin
        SalespersonTarget.SetRange(Year, Date2DMY(WorkDate(), 3));
        if SalespersonTarget.FindSet() then
            repeat
                TotalTarget += SalespersonTarget."Target Amount (LCY)";
                TotalActual += SalespersonTarget.GetActualSalesLCY();
            until SalespersonTarget.Next() = 0;
        if TotalTarget = 0 then
            exit(0);
        exit(Round(TotalActual / TotalTarget * 100, 1));
    end;

    // ---------- Couleur des tuiles ----------
    // Rouge (Unfavorable) = bloquant, jaune (Ambiguous) = à surveiller, vert (Favorable) = rien à faire

    procedure GetStyle(Value: Decimal; StyleWhenNotZero: Text): Text
    begin
        if Value = 0 then
            exit('Favorable');
        exit(StyleWhenNotZero);
    end;

    // ---------- Ouverture des pages ----------

    procedure ShowSalesEntries(FromDate: Date; ToDate: Date)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Posting Date", FromDate, ToDate);
        CustLedgerEntry.SetFilter("Document Type", '%1|%2', CustLedgerEntry."Document Type"::Invoice, CustLedgerEntry."Document Type"::"Credit Memo");
        Page.Run(Page::"Customer Ledger Entries", CustLedgerEntry);
    end;

    procedure ShowCustomersWithout(MissingCR: Boolean)
    var
        Customer: Record Customer;
    begin
        if MissingCR then
            Customer.SetRange("GNC CR No.", '')
        else
            Customer.SetRange("Phone No.", '');
        Page.Run(Page::"Customer List", Customer);
    end;
}
