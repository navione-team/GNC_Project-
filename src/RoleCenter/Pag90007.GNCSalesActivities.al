// Bloc « GNC Activities » de la page d'accueil (maquette validée par Haifa le 2026-10-27) :
// tuiles rangées par métier (Requests, Delivery, Customers, Documents), en couleur selon la situation
// (rouge = bloquant, jaune = à surveiller, vert = rien à faire, bleu-vert = information),
// tuiles de montants (Sales) et tuiles d'action (Go to). Cliquer sur un chiffre ouvre la liste.
// Les tuiles calculées (PIN, livraison, montants) sont des variables de la page, comme dans le standard.
page 90007 "GNC Sales Activities"
{
    Caption = 'GNC Activities';
    PageType = CardPart;
    SourceTable = "GNC Sales Cue";
    RefreshOnActivate = true;
    Permissions = tabledata "GNC Sales Cue" = rimd;

    layout
    {
        area(Content)
        {
            cuegroup(Requests)
            {
                Caption = 'Requests';

                field("Sales Quotes - Open"; Rec."Sales Quotes - Open")
                {
                    ApplicationArea = All;
                    Caption = 'Requests - Open';
                    DrillDownPageId = "Sales Quotes";
                }
                field(RequestsToGroup; RequestsToGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Requests to Group';
                    StyleExpr = RequestsToGroupStyle;
                    ToolTip = 'Specifies the number of approved requests that are waiting to be grouped into a sales order.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GNC Requests to Group Board");
                    end;
                }
                field(WithoutPIN; WithoutPIN)
                {
                    ApplicationArea = All;
                    Caption = 'Without PIN';
                    StyleExpr = WithoutPINStyle;
                    ToolTip = 'Specifies the number of approved requests whose salesperson is not confirmed by PIN. They cannot be grouped.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GNC Requests to Group Board");
                    end;
                }
            }
            cuegroup(Delivery)
            {
                Caption = 'Delivery';

                field(ToShip; ToShip)
                {
                    ApplicationArea = All;
                    Caption = 'Orders to Ship';
                    ToolTip = 'Specifies the number of released sales orders that are not completely shipped.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GNC Delivery Plan Board");
                    end;
                }
                field(VeryUrgent; VeryUrgent)
                {
                    ApplicationArea = All;
                    Caption = 'Very Urgent';
                    StyleExpr = VeryUrgentStyle;
                    ToolTip = 'Specifies the number of very urgent orders to deliver.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GNC Delivery Plan Board");
                    end;
                }
                field(WithoutDriver; WithoutDriver)
                {
                    ApplicationArea = All;
                    Caption = 'Without Driver';
                    StyleExpr = WithoutDriverStyle;
                    ToolTip = 'Specifies the number of orders to deliver that have no driver yet. They cannot be shipped.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GNC Delivery Plan Board");
                    end;
                }
            }
            cuegroup(Customers)
            {
                Caption = 'Customers';

                field(MissingCR; MissingCR)
                {
                    ApplicationArea = All;
                    Caption = 'Missing CR No.';
                    StyleExpr = MissingCRStyle;
                    ToolTip = 'Specifies the number of customers without commercial registration number. They are refused on sales documents.';

                    trigger OnDrillDown()
                    var
                        GNCRoleCenterMgt: Codeunit "GNC Role Center Mgt.";
                    begin
                        GNCRoleCenterMgt.ShowCustomersWithout(true);
                    end;
                }
                field(MissingPhone; MissingPhone)
                {
                    ApplicationArea = All;
                    Caption = 'Missing Phone No.';
                    StyleExpr = MissingPhoneStyle;
                    ToolTip = 'Specifies the number of customers without phone number. They are refused on sales documents.';

                    trigger OnDrillDown()
                    var
                        GNCRoleCenterMgt: Codeunit "GNC Role Center Mgt.";
                    begin
                        GNCRoleCenterMgt.ShowCustomersWithout(false);
                    end;
                }

                actions
                {
                    action(NewCustomer)
                    {
                        ApplicationArea = All;
                        Caption = 'New Customer';
                        RunObject = page "Customer Card";
                        RunPageMode = Create;
                        ToolTip = 'Create a new customer.';
                    }
                }
            }
            cuegroup(Documents)
            {
                Caption = 'Documents';

                field("Sales Orders - Open"; Rec."Sales Orders - Open")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Sales Order List";
                }
                field("Sales Invoices - Unposted"; Rec."Sales Invoices - Unposted")
                {
                    ApplicationArea = All;
                    Caption = 'Invoices - Unposted';
                    DrillDownPageId = "Sales Invoice List";
                }
                field("Sales Cr. Memos - Unposted"; Rec."Sales Cr. Memos - Unposted")
                {
                    ApplicationArea = All;
                    Caption = 'Cr. Memos - Unposted';
                    DrillDownPageId = "Sales Credit Memos";
                }

                actions
                {
                    action(NewSalesQuote)
                    {
                        ApplicationArea = All;
                        Caption = 'New Request Collection';
                        RunObject = page "Sales Quote";
                        RunPageMode = Create;
                        ToolTip = 'Create a new customer request (sales quote).';
                    }
                    action(NewSalesOrder)
                    {
                        ApplicationArea = All;
                        Caption = 'New Sales Order';
                        RunObject = page "Sales Order";
                        RunPageMode = Create;
                        ToolTip = 'Create a new sales order.';
                    }
                }
            }
            // Tuiles de montants (larges)
            cuegroup(Sales)
            {
                Caption = 'Sales';
                CuegroupLayout = Wide;

                field(SalesThisMonth; SalesThisMonth)
                {
                    ApplicationArea = All;
                    Caption = 'Sales This Month';
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the sales of the month, excluding VAT (posted invoices minus credit memos).';

                    trigger OnDrillDown()
                    var
                        GNCRoleCenterMgt: Codeunit "GNC Role Center Mgt.";
                    begin
                        GNCRoleCenterMgt.ShowSalesEntries(CalcDate('<-CM>', WorkDate()), CalcDate('<CM>', WorkDate()));
                    end;
                }
                field(SalesThisYear; SalesThisYear)
                {
                    ApplicationArea = All;
                    Caption = 'Sales This Year';
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the sales of the year, excluding VAT (posted invoices minus credit memos).';

                    trigger OnDrillDown()
                    var
                        GNCRoleCenterMgt: Codeunit "GNC Role Center Mgt.";
                    begin
                        GNCRoleCenterMgt.ShowSalesEntries(CalcDate('<-CY>', WorkDate()), CalcDate('<CY>', WorkDate()));
                    end;
                }
                field(OpenOrdersAmount; OpenOrdersAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Open Orders Amount';
                    AutoFormatType = 1;
                    ToolTip = 'Specifies the total amount including VAT of the sales orders in progress.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Sales Order List");
                    end;
                }
                field(TargetAchievedPct; TargetAchievedPct)
                {
                    ApplicationArea = All;
                    Caption = 'Target Achieved %';
                    DecimalPlaces = 0 : 0;
                    StyleExpr = TargetStyle;
                    ToolTip = 'Specifies how much of the annual salesperson targets is achieved (total actual sales / total targets).';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GNC Salesperson Targets");
                    end;
                }
            }
            // Tuiles d'action : les écrans visuels en pleine page
            cuegroup(GoTo)
            {
                Caption = 'Go to';

                actions
                {
                    action(SalesOverview)
                    {
                        ApplicationArea = All;
                        Caption = 'Sales Overview';
                        Image = TileReport;
                        RunObject = page "GNC Sales Overview";
                        ToolTip = 'See today''s figures, the salesperson targets, the monthly sales and what needs attention.';
                    }
                    action(RequestsToGroupBoard)
                    {
                        ApplicationArea = All;
                        Caption = 'Requests to Group';
                        Image = TileBrickNew;
                        RunObject = page "GNC Requests to Group Board";
                        ToolTip = 'Group the approved requests into one sales order per customer.';
                    }
                    action(DeliveryPlan)
                    {
                        ApplicationArea = All;
                        Caption = 'Delivery Plan';
                        Image = TileSettings;
                        RunObject = page "GNC Delivery Plan Board";
                        ToolTip = 'Assign drivers and ship the orders, the most urgent first.';
                    }
                    action(DeliveryRound)
                    {
                        ApplicationArea = All;
                        Caption = 'Delivery Round';
                        Image = TileCloud;
                        RunObject = page "GNC Delivery Round";
                        ToolTip = 'See the round of a driver on a map.';
                    }
                    action(PriceSimulator)
                    {
                        ApplicationArea = All;
                        Caption = 'Price Simulator';
                        Image = TileCurrency;
                        RunObject = page "GNC Price Simulator";
                        ToolTip = 'Check which discount, bonus and MOH discount apply.';
                    }
                    action(CustomerList)
                    {
                        ApplicationArea = All;
                        Caption = 'Customers';
                        Image = TilePeople;
                        RunObject = page "Customer List";
                        ToolTip = 'Open the customers. Choose Customer 360 to see a customer at a glance.';
                    }
                }
            }
        }
    }

    var
        RequestsToGroup: Integer;
        WithoutPIN: Integer;
        ToShip: Integer;
        VeryUrgent: Integer;
        WithoutDriver: Integer;
        MissingCR: Integer;
        MissingPhone: Integer;
        SalesThisMonth: Decimal;
        SalesThisYear: Decimal;
        OpenOrdersAmount: Decimal;
        TargetAchievedPct: Decimal;
        RequestsToGroupStyle: Text;
        WithoutPINStyle: Text;
        VeryUrgentStyle: Text;
        WithoutDriverStyle: Text;
        MissingCRStyle: Text;
        MissingPhoneStyle: Text;
        TargetStyle: Text;

    trigger OnOpenPage()
    begin
        // Crée l'enregistrement unique la première fois que la page s'ouvre
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetRecord()
    begin
        CalculateCues();
    end;

    local procedure CalculateCues()
    var
        Customer: Record Customer;
        GNCRoleCenterMgt: Codeunit "GNC Role Center Mgt.";
    begin
        RequestsToGroup := GNCRoleCenterMgt.CountRequestsToGroup();
        WithoutPIN := GNCRoleCenterMgt.CountRequestsWithoutPIN();
        ToShip := GNCRoleCenterMgt.CountToShip();
        VeryUrgent := GNCRoleCenterMgt.CountVeryUrgent(false);
        WithoutDriver := GNCRoleCenterMgt.CountWithoutDriver();
        Customer.SetRange("GNC CR No.", '');
        MissingCR := Customer.Count();
        Customer.SetRange("GNC CR No.");
        Customer.SetRange("Phone No.", '');
        MissingPhone := Customer.Count();
        SalesThisMonth := GNCRoleCenterMgt.GetSalesThisMonth();
        SalesThisYear := GNCRoleCenterMgt.GetSalesThisYear();
        OpenOrdersAmount := GNCRoleCenterMgt.GetOpenOrdersAmount();
        TargetAchievedPct := GNCRoleCenterMgt.GetTargetAchievedPct();

        // Couleurs
        RequestsToGroupStyle := GNCRoleCenterMgt.GetStyle(RequestsToGroup, 'Ambiguous');
        WithoutPINStyle := GNCRoleCenterMgt.GetStyle(WithoutPIN, 'Ambiguous');
        VeryUrgentStyle := GNCRoleCenterMgt.GetStyle(VeryUrgent, 'Unfavorable');
        WithoutDriverStyle := GNCRoleCenterMgt.GetStyle(WithoutDriver, 'Unfavorable');
        MissingCRStyle := GNCRoleCenterMgt.GetStyle(MissingCR, 'Unfavorable');
        MissingPhoneStyle := GNCRoleCenterMgt.GetStyle(MissingPhone, 'Ambiguous');
        case true of
            TargetAchievedPct >= 80:
                TargetStyle := 'Favorable';
            TargetAchievedPct >= 50:
                TargetStyle := 'Ambiguous';
            else
                TargetStyle := 'Unfavorable';
        end;
    end;
}
