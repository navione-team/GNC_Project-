// Bandeau d'accueil GNC (en haut de la page d'accueil, remplace le bandeau standard « The biggest sales order… »).
// Les messages défilent : salutation, livraisons très urgentes, demandes à regrouper, ventes du mois.
// Un message n'apparaît que s'il y a quelque chose à dire ; cliquer dessus ouvre l'écran concerné.
page 90098 "GNC Sales Headline"
{
    Caption = 'Headline';
    PageType = HeadlinePart;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(Greeting)
            {
                ShowCaption = false;
                Visible = GreetingVisible;

                field(GreetingText; RCHeadlinesPageCommon.GetGreetingText())
                {
                    ApplicationArea = All;
                    Caption = 'Greeting headline';
                    Editable = false;
                }
            }
            group(Delivery)
            {
                ShowCaption = false;
                Visible = DeliveryText <> '';

                field(DeliveryText; DeliveryText)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery headline';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GNC Delivery Plan Board");
                    end;
                }
            }
            group(Requests)
            {
                ShowCaption = false;
                Visible = RequestsText <> '';

                field(RequestsText; RequestsText)
                {
                    ApplicationArea = All;
                    Caption = 'Requests headline';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GNC Requests to Group Board");
                    end;
                }
            }
            group(Sales)
            {
                ShowCaption = false;
                Visible = SalesText <> '';

                field(SalesText; SalesText)
                {
                    ApplicationArea = All;
                    Caption = 'Sales headline';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GNC Sales Overview");
                    end;
                }
            }
        }
    }

    var
        RCHeadlinesPageCommon: Codeunit "RC Headlines Page Common";
        GreetingVisible: Boolean;
        DeliveryText: Text;
        RequestsText: Text;
        SalesText: Text;
        // Format des bandeaux BC : <qualifier> = petit titre, <payload> = phrase, <emphasize> = partie en couleur
        NoDriverTxt: Label '<qualifier>Delivery</qualifier><payload>Today, <emphasize>%1 very urgent order(s)</emphasize> waiting for a driver</payload>', Comment = '%1 = number';
        VeryUrgentTxt: Label '<qualifier>Delivery</qualifier><payload>Today, <emphasize>%1 very urgent order(s)</emphasize> to deliver first</payload>', Comment = '%1 = number';
        RequestsTxt: Label '<qualifier>Requests</qualifier><payload><emphasize>%1 approved request(s)</emphasize> ready to be grouped into orders</payload>', Comment = '%1 = number';
        SalesUpTxt: Label '<qualifier>Insight from this month</qualifier><payload>Sales this month are <emphasize>%1</emphasize>, %2% more than last year</payload>', Comment = '%1 = amount, %2 = percentage';
        SalesDownTxt: Label '<qualifier>Insight from this month</qualifier><payload>Sales this month are <emphasize>%1</emphasize>, %2% less than last year</payload>', Comment = '%1 = amount, %2 = percentage';
        SalesTxt: Label '<qualifier>Insight from this month</qualifier><payload>Sales this month are <emphasize>%1</emphasize></payload>', Comment = '%1 = amount';

    trigger OnOpenPage()
    begin
        RCHeadlinesPageCommon.HeadlineOnOpenPage(Page::"GNC Sales Headline");
        GreetingVisible := RCHeadlinesPageCommon.IsUserGreetingVisible();
        ComputeHeadlines();
    end;

    local procedure ComputeHeadlines()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GNCRoleCenterMgt: Codeunit "GNC Role Center Mgt.";
        NoDriver: Integer;
        VeryUrgent: Integer;
        ToGroup: Integer;
        SalesMonth: Decimal;
        SalesLastYear: Decimal;
        Amount: Text;
        ChangePct: Integer;
    begin
        NoDriver := GNCRoleCenterMgt.CountVeryUrgent(true);
        VeryUrgent := GNCRoleCenterMgt.CountVeryUrgent(false);
        if NoDriver > 0 then
            DeliveryText := StrSubstNo(NoDriverTxt, NoDriver)
        else
            if VeryUrgent > 0 then
                DeliveryText := StrSubstNo(VeryUrgentTxt, VeryUrgent);

        ToGroup := GNCRoleCenterMgt.CountRequestsToGroup();
        if ToGroup > 0 then
            RequestsText := StrSubstNo(RequestsTxt, ToGroup);

        SalesMonth := GNCRoleCenterMgt.GetSalesThisMonth();
        if SalesMonth <> 0 then begin
            GeneralLedgerSetup.Get();
            Amount := GeneralLedgerSetup."LCY Code" + ' ' + Format(Round(SalesMonth, 1), 0, '<Precision,0:0><Standard Format,0>');
            SalesLastYear := GNCRoleCenterMgt.GetSalesSameMonthLastYear();
            if SalesLastYear > 0 then begin
                ChangePct := Round((SalesMonth - SalesLastYear) / SalesLastYear * 100, 1);
                if ChangePct >= 0 then
                    SalesText := StrSubstNo(SalesUpTxt, Amount, ChangePct)
                else
                    SalesText := StrSubstNo(SalesDownTxt, Amount, -ChangePct);
            end else
                SalesText := StrSubstNo(SalesTxt, Amount);
        end;
    end;
}
