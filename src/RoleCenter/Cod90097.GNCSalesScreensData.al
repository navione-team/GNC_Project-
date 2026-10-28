// Données JSON des écrans Sales Overview (page 90094), Customer 360 (90095) et Price Simulator (90096),
// et ouverture des pages BC quand l'utilisateur clique dans ces écrans.
// Les calculs réutilisent ceux des lots précédents : objectifs (écritures client), archives Won / Failed,
// plan de livraison, remises (90069) et bonus (90062).
codeunit 90097 "GNC Sales Screens Data"
{
    var
        NoReasonTxt: Label '(no reason)';
        CustomerCardTxt: Label 'Customer card';
        AssignmentTxt: Label 'Assignment';
        AllItemsTxt: Label 'All items';
        MostSpecificTxt: Label 'the most specific rule';
        HighestTxt: Label 'the highest discount';
        SelectSimulationTxt: Label 'Select a customer and an item above to see which discount and bonus apply.';
        VeryUrgentNoDriverTxt: Label '%1 very urgent order(s) without a driver', Comment = '%1 = number';
        ToGroupTxt: Label '%1 approved request(s) waiting to be grouped', Comment = '%1 = number';
        NoPINTxt: Label '%1 approved request(s) without salesperson PIN', Comment = '%1 = number';
        MissingCRTxt: Label '%1 customer(s) without CR No.', Comment = '%1 = number';
        MissingPhoneTxt: Label '%1 customer(s) without phone number', Comment = '%1 = number';
        DeliveryPlanTxt: Label 'Delivery Plan';
        RequestsToGroupTxt: Label 'Requests to Group';
        PINDetailTxt: Label 'They cannot be grouped until the salesperson enters the PIN';
        RefusedTxt: Label 'Refused on sales documents';
        BonusDetailTxt: Label '%1 free from %2 · +%3% · MOH %4%', Comment = '%1 = bonus qty, %2 = minimum qty, %3 = additional %, %4 = MOH %';

    // ---------- Sales Overview ----------

    procedure BuildOverview() Data: JsonObject
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        SalespersonTarget: Record "GNC Salesperson Target";
        Salesperson: Record "Salesperson/Purchaser";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GNCSalespersonPINMgt: Codeunit "GNC Salesperson PIN Mgt.";
        Tiles: JsonObject;
        Pipeline: JsonObject;
        Targets: JsonArray;
        Attention: JsonArray;
        Target: JsonObject;
        Year: Integer;
        Month: Integer;
        MonthStart: Date;
        MonthEnd: Date;
        ToGroup: Integer;
        NoPIN: Integer;
        VeryUrgentNoDriver: Integer;
        MissingCR: Integer;
        MissingPhone: Integer;
    begin
        GeneralLedgerSetup.Get();
        Year := Date2DMY(WorkDate(), 3);
        Month := Date2DMY(WorkDate(), 2);
        MonthStart := CalcDate('<-CM>', WorkDate());
        MonthEnd := CalcDate('<CM>', WorkDate());
        Data.Add('dateText', Format(WorkDate(), 0, '<Weekday Text> <Day> <Month Text> <Year4>'));
        Data.Add('monthName', Format(WorkDate(), 0, '<Month Text> <Year4>'));
        Data.Add('year', Year);
        Data.Add('currency', GeneralLedgerSetup."LCY Code");

        // Bandeau
        SetQuoteFilter(SalesHeader, SalesHeader.Status::Open);
        Tiles.Add('openRequests', SalesHeader.Count());
        Pipeline.Add('requests', SalesHeader.Count());
        SetQuoteFilter(SalesHeader, SalesHeader.Status::Released);
        ToGroup := SalesHeader.Count();
        Tiles.Add('toGroup', ToGroup);
        Pipeline.Add('approved', ToGroup);
        if SalesHeader.FindSet() then
            repeat
                if not GNCSalespersonPINMgt.IsSalespersonConfirmed(SalesHeader) then
                    NoPIN += 1;
            until SalesHeader.Next() = 0;
        SetToShipFilter(SalesHeader);
        Tiles.Add('toShip', SalesHeader.Count());
        Pipeline.Add('toShip', SalesHeader.Count());
        SalesHeader.SetRange("GNC Delivery Priority", SalesHeader."GNC Delivery Priority"::"Very Urgent");
        Tiles.Add('veryUrgent', SalesHeader.Count());
        SalesHeader.SetRange("GNC Driver Code", '');
        VeryUrgentNoDriver := SalesHeader.Count();
        Tiles.Add('veryUrgentNoDriver', VeryUrgentNoDriver);
        Tiles.Add('salesMonth', GetSales('', MonthStart, MonthEnd));
        Tiles.Add('salesMonthPrev', GetSales('', CalcDate('<-1Y>', MonthStart), CalcDate('<-1Y>', MonthEnd)));
        Data.Add('tiles', Tiles);

        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        Pipeline.Add('orders', SalesHeader.Count());
        SalesHeader.SetRange("Shipped Not Invoiced", true);
        Pipeline.Add('toInvoice', SalesHeader.Count());
        Data.Add('pipeline', Pipeline);

        // Objectifs des commerciaux de l'année
        SalespersonTarget.SetRange(Year, Year);
        if SalespersonTarget.FindSet() then
            repeat
                Clear(Target);
                Target.Add('code', SalespersonTarget."Salesperson Code");
                if Salesperson.Get(SalespersonTarget."Salesperson Code") then begin
                    Target.Add('name', Salesperson.Name);
                    Target.Add('type', Format(Salesperson."GNC Type"));
                end else begin
                    Target.Add('name', SalespersonTarget."Salesperson Code");
                    Target.Add('type', '');
                end;
                Target.Add('target', SalespersonTarget."Target Amount (LCY)");
                Target.Add('actual', SalespersonTarget.GetActualSalesLCY());
                Targets.Add(Target);
            until SalespersonTarget.Next() = 0;
        Data.Add('targets', Targets);

        // Ventes par mois (année en cours jusqu'au mois de la date de travail, année précédente complète)
        Data.Add('monthly', GetMonthlySales('', Year, Month));
        Data.Add('monthlyPrev', GetMonthlySales('', Year - 1, 12));

        // À traiter
        Customer.SetRange("GNC CR No.", '');
        MissingCR := Customer.Count();
        Customer.SetRange("GNC CR No.");
        Customer.SetRange("Phone No.", '');
        MissingPhone := Customer.Count();
        if VeryUrgentNoDriver > 0 then
            AddAttention(Attention, 'crit', StrSubstNo(VeryUrgentNoDriverTxt, VeryUrgentNoDriver), DeliveryPlanTxt, 'delivery');
        if ToGroup > 0 then
            AddAttention(Attention, 'warn', StrSubstNo(ToGroupTxt, ToGroup), RequestsToGroupTxt, 'grouping');
        if NoPIN > 0 then
            AddAttention(Attention, 'warn', StrSubstNo(NoPINTxt, NoPIN), PINDetailTxt, 'grouping');
        if MissingCR > 0 then
            AddAttention(Attention, 'crit', StrSubstNo(MissingCRTxt, MissingCR), RefusedTxt, 'missingCR');
        if MissingPhone > 0 then
            AddAttention(Attention, 'warn', StrSubstNo(MissingPhoneTxt, MissingPhone), RefusedTxt, 'missingPhone');
        Data.Add('attention', Attention);

        Data.Add('won', CountArchivedQuotes('', "GNC Quote Status"::Won, MonthStart, MonthEnd));
        Data.Add('failed', CountArchivedQuotes('', "GNC Quote Status"::Failed, MonthStart, MonthEnd));
        Data.Add('reasons', GetFailedReasons('', DMY2Date(1, 1, Year), DMY2Date(31, 12, Year)));
    end;

    local procedure AddAttention(var Attention: JsonArray; Level: Text; Txt: Text; Detail: Text; ViewKey: Text)
    var
        Item: JsonObject;
    begin
        Item.Add('level', Level);
        Item.Add('text', Txt);
        Item.Add('detail', Detail);
        Item.Add('key', ViewKey);
        Attention.Add(Item);
    end;

    local procedure SetQuoteFilter(var SalesHeader: Record "Sales Header"; Status: Enum "Sales Document Status")
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange(Status, Status);
        SalesHeader.SetRange("GNC Closed", false);
    end;

    // Même filtre que le plan de livraison (pages 90077 / 90090)
    local procedure SetToShipFilter(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
        SalesHeader.SetRange("Completely Shipped", false);
    end;

    // Ventes HT (écritures client « Sales (LCY) » = factures - avoirs), CustomerNo vide = tous les clients
    local procedure GetSales(CustomerNo: Code[20]; FromDate: Date; ToDate: Date): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if CustomerNo <> '' then
            CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange("Posting Date", FromDate, ToDate);
        CustLedgerEntry.CalcSums("Sales (LCY)");
        exit(CustLedgerEntry."Sales (LCY)");
    end;

    // 12 montants mensuels ; les mois après LastMonth sont vides (null) pour ne pas tracer l'avenir
    local procedure GetMonthlySales(CustomerNo: Code[20]; Year: Integer; LastMonth: Integer) Months: JsonArray
    var
        NullValue: JsonValue;
        Month: Integer;
        MonthStart: Date;
    begin
        NullValue.SetValueToNull();
        for Month := 1 to 12 do
            if Month <= LastMonth then begin
                MonthStart := DMY2Date(1, Month, Year);
                Months.Add(GetSales(CustomerNo, MonthStart, CalcDate('<CM>', MonthStart)));
            end else
                Months.Add(NullValue.Clone());
    end;

    // Demandes archivées Won / Failed (CustomerNo vide = tous les clients ; FromDate vide = toutes les dates)
    local procedure CountArchivedQuotes(CustomerNo: Code[20]; QuoteStatus: Enum "GNC Quote Status"; FromDate: Date; ToDate: Date): Integer
    var
        SalesHeaderArchive: Record "Sales Header Archive";
    begin
        SalesHeaderArchive.SetRange("Document Type", SalesHeaderArchive."Document Type"::Quote);
        SalesHeaderArchive.SetRange("GNC Quote Status", QuoteStatus);
        if CustomerNo <> '' then
            SalesHeaderArchive.SetRange("Sell-to Customer No.", CustomerNo);
        if FromDate <> 0D then
            SalesHeaderArchive.SetRange("Date Archived", FromDate, ToDate);
        exit(SalesHeaderArchive.Count());
    end;

    // Motifs des ventes ratées, du plus fréquent au moins fréquent
    local procedure GetFailedReasons(CustomerNo: Code[20]; FromDate: Date; ToDate: Date) Reasons: JsonArray
    var
        SalesHeaderArchive: Record "Sales Header Archive";
        FailedSaleReason: Record "GNC Failed Sale Reason";
        Counts: Dictionary of [Text, Integer];
        Names: List of [Text];
        Reason: JsonObject;
        ReasonName: Text;
        BestName: Text;
        BestCount: Integer;
        Count: Integer;
    begin
        SalesHeaderArchive.SetRange("Document Type", SalesHeaderArchive."Document Type"::Quote);
        SalesHeaderArchive.SetRange("GNC Quote Status", SalesHeaderArchive."GNC Quote Status"::Failed);
        if CustomerNo <> '' then
            SalesHeaderArchive.SetRange("Sell-to Customer No.", CustomerNo);
        if FromDate <> 0D then
            SalesHeaderArchive.SetRange("Date Archived", FromDate, ToDate);
        if SalesHeaderArchive.FindSet() then
            repeat
                ReasonName := NoReasonTxt;
                if FailedSaleReason.Get(SalesHeaderArchive."GNC Failed Reason Code") then
                    ReasonName := FailedSaleReason.Description;
                if ReasonName = '' then
                    ReasonName := SalesHeaderArchive."GNC Failed Reason Code";
                if Counts.Get(ReasonName, Count) then
                    Counts.Set(ReasonName, Count + 1)
                else begin
                    Counts.Add(ReasonName, 1);
                    Names.Add(ReasonName);
                end;
            until SalesHeaderArchive.Next() = 0;

        while Names.Count() > 0 do begin
            BestCount := 0;
            foreach ReasonName in Names do
                if Counts.Get(ReasonName) > BestCount then begin
                    BestCount := Counts.Get(ReasonName);
                    BestName := ReasonName;
                end;
            Clear(Reason);
            Reason.Add('reason', BestName);
            Reason.Add('count', BestCount);
            Reasons.Add(Reason);
            Names.Remove(BestName);
        end;
    end;

    // ---------- Customer 360 ----------

    procedure BuildCustomer360(var Customer: Record Customer) Data: JsonObject
    var
        CustomerTarget: Record "GNC Customer Target";
        LastYearTarget: Record "GNC Customer Target";
        Salesperson: Record "Salesperson/Purchaser";
        Assignment: Record "GNC Cust. Salesperson Assign.";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DiscountSetup: Record "GNC Discount Setup";
        BonusSetup: Record "GNC Bonus Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Checks: JsonArray;
        Salespeople: JsonArray;
        Discounts: JsonArray;
        Bonuses: JsonArray;
        Invoices: JsonArray;
        Target: JsonObject;
        Quotes: JsonObject;
        Orders: JsonObject;
        Line: JsonObject;
        SeenCodes: List of [Code[20]];
        Year: Integer;
        OrderAmount: Decimal;
        InvoiceCount: Integer;
    begin
        GeneralLedgerSetup.Get();
        Year := Date2DMY(WorkDate(), 3);
        Customer.CalcFields("Balance (LCY)");
        Data.Add('no', Customer."No.");
        Data.Add('name', Customer.Name);
        Data.Add('sector', Format(Customer."GNC Sector"));
        Data.Add('type', Customer."GNC Customer Type");
        Data.Add('region', Customer."GNC Region Code");
        Data.Add('city', Customer.City);
        Data.Add('phone', Customer."Phone No.");
        Data.Add('balance', Customer."Balance (LCY)");
        Data.Add('currency', GeneralLedgerSetup."LCY Code");
        Data.Add('noCR', Customer."GNC CR No." = '');

        // Champs obligatoires (lot 1), GLN facultatif, position GPS (carte de tournée)
        AddCheck(Checks, 'Name', Customer.Name <> '');
        AddCheck(Checks, 'Phone No.', Customer."Phone No." <> '');
        AddCheck(Checks, 'CR No.', Customer."GNC CR No." <> '');
        AddCheck(Checks, 'GLN (optional)', Customer.GLN <> '');
        AddCheck(Checks, 'GPS position', (Customer."GNC Latitude" <> 0) or (Customer."GNC Longitude" <> 0));
        Data.Add('checks', Checks);

        // Objectif de l'année (réalisé calculé même sans objectif saisi) et réalisé de l'année précédente
        if not CustomerTarget.Get(Customer."No.", Year) then begin
            CustomerTarget.Init();
            CustomerTarget."Customer No." := Customer."No.";
            CustomerTarget.Year := Year;
        end;
        Target.Add('year', Year);
        Target.Add('target', CustomerTarget."Target Amount (LCY)");
        Target.Add('actual', CustomerTarget.GetActualSalesLCY());
        Data.Add('target', Target);
        LastYearTarget."Customer No." := Customer."No.";
        LastYearTarget.Year := Year - 1;
        Data.Add('prevActual', LastYearTarget.GetActualSalesLCY());
        Data.Add('monthly', GetMonthlySales(Customer."No.", Year, Date2DMY(WorkDate(), 2)));
        Data.Add('monthlyPrev', GetMonthlySales(Customer."No.", Year - 1, 12));

        // Commerciaux : celui de la fiche client + ceux des affectations (lot 2)
        if Salesperson.Get(Customer."Salesperson Code") then begin
            AddSalesperson(Salespeople, Salesperson, CustomerCardTxt);
            SeenCodes.Add(Salesperson.Code);
        end;
        Assignment.SetRange("Customer No.", Customer."No.");
        if Assignment.FindSet() then
            repeat
                if not SeenCodes.Contains(Assignment."Salesperson Code") then
                    if Salesperson.Get(Assignment."Salesperson Code") then begin
                        AddSalesperson(Salespeople, Salesperson, AssignmentTxt + ' · ' + Format(Assignment.Type) + ' ' + Assignment."No.");
                        SeenCodes.Add(Salesperson.Code);
                    end;
            until Assignment.Next() = 0;
        Data.Add('salespeople', Salespeople);

        // Demandes gagnées / ratées / en cours
        Quotes.Add('won', CountArchivedQuotes(Customer."No.", "GNC Quote Status"::Won, 0D, 0D));
        Quotes.Add('failed', CountArchivedQuotes(Customer."No.", "GNC Quote Status"::Failed, 0D, 0D));
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
        SalesHeader.SetRange("GNC Closed", false);
        Quotes.Add('open', SalesHeader.Count());
        Data.Add('quotes', Quotes);
        Data.Add('reasons', GetFailedReasons(Customer."No.", 0D, 0D));

        // Commandes en cours
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("Sell-to Customer No.", Customer."No.");
        Orders.Add('count', SalesHeader.Count());
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.CalcFields("Amount Including VAT");
                OrderAmount += SalesHeader."Amount Including VAT";
            until SalesHeader.Next() = 0;
        Orders.Add('amount', OrderAmount);
        Data.Add('orders', Orders);

        // Conditions commerciales (lots 5 et 6)
        DiscountSetup.SetRange("Customer No.", Customer."No.");
        if DiscountSetup.FindSet() then
            repeat
                Clear(Line);
                if DiscountSetup.Type = DiscountSetup.Type::"All Items" then
                    Line.Add('what', AllItemsTxt)
                else
                    Line.Add('what', Format(DiscountSetup.Type) + ' ' + DiscountSetup."No.");
                Line.Add('pct', DiscountSetup."Discount %");
                Discounts.Add(Line);
            until DiscountSetup.Next() = 0;
        Data.Add('discounts', Discounts);
        BonusSetup.SetRange("Customer No.", Customer."No.");
        if BonusSetup.FindSet() then
            repeat
                Clear(Line);
                Line.Add('what', 'Item ' + BonusSetup."Item No.");
                Line.Add('detail', StrSubstNo(BonusDetailTxt, BonusSetup."Bonus Quantity", BonusSetup."Minimum Quantity", BonusSetup."Additional Discount %", BonusSetup."MOH Discount %"));
                Bonuses.Add(Line);
            until BonusSetup.Next() = 0;
        Data.Add('bonus', Bonuses);

        // 5 dernières factures enregistrées
        SalesInvoiceHeader.SetCurrentKey("Sell-to Customer No.");
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", Customer."No.");
        SalesInvoiceHeader.Ascending(false);
        if SalesInvoiceHeader.FindSet() then
            repeat
                SalesInvoiceHeader.CalcFields("Amount Including VAT");
                Clear(Line);
                Line.Add('no', SalesInvoiceHeader."No.");
                Line.Add('date', Format(SalesInvoiceHeader."Posting Date"));
                Line.Add('amount', SalesInvoiceHeader."Amount Including VAT");
                Invoices.Add(Line);
                InvoiceCount += 1;
            until (SalesInvoiceHeader.Next() = 0) or (InvoiceCount = 5);
        Data.Add('invoices', Invoices);
    end;

    local procedure AddCheck(var Checks: JsonArray; Label: Text; Ok: Boolean)
    var
        Check: JsonObject;
    begin
        Check.Add('label', Label);
        Check.Add('ok', Ok);
        Checks.Add(Check);
    end;

    local procedure AddSalesperson(var Salespeople: JsonArray; Salesperson: Record "Salesperson/Purchaser"; Source: Text)
    var
        Person: JsonObject;
    begin
        Person.Add('code', Salesperson.Code);
        Person.Add('name', Salesperson.Name);
        Person.Add('source', Source);
        Salespeople.Add(Person);
    end;

    // ---------- Price Simulator ----------

    procedure BuildSimulator(CustomerNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; SimulationDate: Date) Data: JsonObject
    var
        Customer: Record Customer;
        Item: Record Item;
        BonusSetup: Record "GNC Bonus Setup";
        GNCSalesSetup: Record "GNC Sales Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GNCDiscountMgt: Codeunit "GNC Discount Mgt.";
        GNCBonusMgt: Codeunit "GNC Bonus Mgt.";
        Ladder: JsonArray;
        Bonus: JsonObject;
        WinnerIndex: Integer;
        BasePct: Decimal;
        AddPct: Decimal;
        MOHPct: Decimal;
        TotalPct: Decimal;
        Gross: Decimal;
        IsGovernment: Boolean;
    begin
        if not (Customer.Get(CustomerNo) and Item.Get(ItemNo)) then begin
            Data.Add('empty', SelectSimulationTxt);
            exit;
        end;
        if Quantity <= 0 then
            Quantity := 1;
        if SimulationDate = 0D then
            SimulationDate := WorkDate();
        GNCSalesSetup.GetSetup();
        GeneralLedgerSetup.Get();
        IsGovernment := Customer."GNC Sector" = Customer."GNC Sector"::Government;

        GNCDiscountMgt.GetDiscountLadder(CustomerNo, ItemNo, SimulationDate, Ladder, WinnerIndex, BasePct);

        // Bonus : règle qui existe à cette date ? quantité minimum atteinte ?
        if GNCBonusMgt.FindBonusRule(CustomerNo, ItemNo, SimulationDate, 999999999, BonusSetup) then begin
            Bonus.Add('exists', true);
            Bonus.Add('qty', BonusSetup."Bonus Quantity");
            Bonus.Add('min', BonusSetup."Minimum Quantity");
            Bonus.Add('add', BonusSetup."Additional Discount %");
            Bonus.Add('moh', BonusSetup."MOH Discount %");
            if Quantity >= BonusSetup."Minimum Quantity" then begin
                Bonus.Add('found', true);
                AddPct := BonusSetup."Additional Discount %";
                if IsGovernment then
                    MOHPct := BonusSetup."MOH Discount %";
            end else
                Bonus.Add('found', false);
        end else begin
            Bonus.Add('exists', false);
            Bonus.Add('found', false);
        end;
        TotalPct := BasePct + AddPct + MOHPct;
        if TotalPct > 100 then
            TotalPct := 100;
        Gross := Quantity * Item."Unit Price";

        Data.Add('customerName', Customer.Name);
        Data.Add('sector', Format(Customer."GNC Sector"));
        Data.Add('gov', IsGovernment);
        Data.Add('itemNo', Item."No.");
        Data.Add('itemName', Item.Description);
        Data.Add('qty', Quantity);
        Data.Add('unitPrice', Item."Unit Price");
        Data.Add('currency', GeneralLedgerSetup."LCY Code");
        Data.Add('ladder', Ladder);
        Data.Add('winner', WinnerIndex);
        if GNCSalesSetup."Discount Priority" = GNCSalesSetup."Discount Priority"::"Most Specific" then
            Data.Add('priorityMode', MostSpecificTxt)
        else
            Data.Add('priorityMode', HighestTxt);
        Data.Add('base', BasePct);
        Data.Add('add', AddPct);
        Data.Add('moh', MOHPct);
        Data.Add('total', TotalPct);
        Data.Add('gross', Gross);
        Data.Add('net', Round(Gross * (1 - TotalPct / 100)));
        Data.Add('bonus', Bonus);
    end;

    // ---------- Clics : ouverture des pages BC ----------
    // ViewKey = écran demandé par le JavaScript ; Arg = n° de document ; CustomerNo = client affiché (Customer 360)
    procedure OpenView(ViewKey: Text; Arg: Text; CustomerNo: Code[20])
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesHeaderArchive: Record "Sales Header Archive";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerTarget: Record "GNC Customer Target";
        DiscountSetup: Record "GNC Discount Setup";
        BonusSetup: Record "GNC Bonus Setup";
    begin
        case ViewKey of
            'requests':
                Page.Run(Page::"Sales Quotes");
            'newRequest':
                begin
                    // Nouvelle Request Collection (comme le bouton Nouveau du standard)
                    SalesHeader.Init();
                    SalesHeader."Document Type" := SalesHeader."Document Type"::Quote;
                    SalesHeader.Insert(true);
                    Page.Run(Page::"Sales Quote", SalesHeader);
                end;
            'grouping':
                Page.Run(Page::"GNC Requests to Group Board");
            'delivery':
                Page.Run(Page::"GNC Delivery Plan Board");
            'orders', 'toInvoice':
                begin
                    SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                    if CustomerNo <> '' then
                        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
                    if ViewKey = 'toInvoice' then
                        SalesHeader.SetRange("Shipped Not Invoiced", true);
                    Page.Run(Page::"Sales Order List", SalesHeader);
                end;
            'invoices':
                Page.Run(Page::"Posted Sales Invoices");
            'invoice':
                if SalesInvoiceHeader.Get(CopyStr(Arg, 1, MaxStrLen(SalesInvoiceHeader."No."))) then
                    Page.Run(Page::"Posted Sales Invoice", SalesInvoiceHeader);
            'targets':
                if CustomerNo <> '' then begin
                    CustomerTarget.SetRange("Customer No.", CustomerNo);
                    Page.Run(Page::"GNC Customer Targets", CustomerTarget);
                end else
                    Page.Run(Page::"GNC Salesperson Targets");
            'outcomes', 'archives':
                begin
                    SalesHeaderArchive.SetRange("Document Type", SalesHeaderArchive."Document Type"::Quote);
                    if CustomerNo <> '' then
                        SalesHeaderArchive.SetRange("Sell-to Customer No.", CustomerNo);
                    Page.Run(Page::"Sales Quote Archives", SalesHeaderArchive);
                end;
            'missingCR':
                begin
                    Customer.SetRange("GNC CR No.", '');
                    Page.Run(Page::"Customer List", Customer);
                end;
            'missingPhone':
                begin
                    Customer.SetRange("Phone No.", '');
                    Page.Run(Page::"Customer List", Customer);
                end;
            'ledger':
                begin
                    CustLedgerEntry.SetRange("Customer No.", CustomerNo);
                    Page.Run(Page::"Customer Ledger Entries", CustLedgerEntry);
                end;
            'customerCard':
                if Customer.Get(CustomerNo) then
                    Page.Run(Page::"Customer Card", Customer);
            'discounts':
                begin
                    if CustomerNo <> '' then
                        DiscountSetup.SetRange("Customer No.", CustomerNo);
                    Page.Run(Page::"GNC Discount Setup", DiscountSetup);
                end;
            'bonus':
                begin
                    if CustomerNo <> '' then
                        BonusSetup.SetRange("Customer No.", CustomerNo);
                    Page.Run(Page::"GNC Bonus Setup", BonusSetup);
                end;
        end;
    end;
}
