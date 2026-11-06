codeunit 50260 "NAV Reservation Expiry"
{
    // 1.1 Reservation validity.
    // A reservation of a sales order is kept for the validity of the customer
    // (or the default of Sales & Receivables Setup):
    //   Expiry Date = Creation Date of the reservation + validity days.
    // Run daily from the Job Queue:
    //   - one day before the expiry date, an e-mail is sent to the salesperson
    //     of the order to contact the customer and reconfirm;
    //   - on the expiry date, the reservation is cancelled and the stock
    //     becomes available again.

    trigger OnRun()
    begin
        SendExpiryAlerts(Today() + 1);
        CancelExpiredReservations(Today());
    end;

    // ---------------------------------------------------------------
    // Expiry date of a reservation (demand side = sales line entry)
    // ---------------------------------------------------------------
    procedure GetExpiryDate(ReservEntry: Record "Reservation Entry"): Date
    var
        SalesHeader: Record "Sales Header";
        Days: Integer;
    begin
        if not IsSalesReservation(ReservEntry) then
            exit(0D);
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, ReservEntry."Source ID") then
            exit(0D);
        Days := GetValidityDays(SalesHeader."Sell-to Customer No.");
        if (Days = 0) or (ReservEntry."Creation Date" = 0D) then
            exit(0D);
        exit(ReservEntry."Creation Date" + Days);
    end;

    procedure GetValidityDays(CustomerNo: Code[20]): Integer
    var
        Customer: Record Customer;
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if Customer.Get(CustomerNo) then
            if Customer."Reservation Validity (Days)" <> 0 then
                exit(Customer."Reservation Validity (Days)");
        SalesSetup.Get();
        exit(SalesSetup."Default Reservation Days");
    end;

    procedure IsSalesReservation(ReservEntry: Record "Reservation Entry"): Boolean
    begin
        exit(
            (ReservEntry."Reservation Status" = ReservEntry."Reservation Status"::Reservation) and
            (ReservEntry."Source Type" = Database::"Sales Line") and
            (ReservEntry."Source Subtype" = 1) and // Order
            (not ReservEntry.Positive));
    end;

    procedure SetSalesReservationFilter(var ReservEntry: Record "Reservation Entry")
    begin
        ReservEntry.Reset();
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
        ReservEntry.SetRange("Source Type", Database::"Sales Line");
        ReservEntry.SetRange("Source Subtype", 1);
        ReservEntry.SetRange(Positive, false);
    end;

    // ---------------------------------------------------------------
    // Cancel the reservations whose expiry date is reached
    // ---------------------------------------------------------------
    procedure CancelExpiredReservations(OnDate: Date): Integer
    var
        ReservEntry: Record "Reservation Entry";
        TempToCancel: Record "Reservation Entry" temporary;
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        ExpiryDate: Date;
        Counter: Integer;
    begin
        SetSalesReservationFilter(ReservEntry);
        if ReservEntry.FindSet() then
            repeat
                ExpiryDate := GetExpiryDate(ReservEntry);
                if (ExpiryDate <> 0D) and (ExpiryDate <= OnDate) then begin
                    TempToCancel := ReservEntry;
                    TempToCancel.Insert();
                end;
            until ReservEntry.Next() = 0;

        if TempToCancel.FindSet() then
            repeat
                if ReservEntry.Get(TempToCancel."Entry No.", TempToCancel.Positive) then begin
                    ReservEngineMgt.CancelReservation(ReservEntry);
                    Counter += 1;
                end;
            until TempToCancel.Next() = 0;
        exit(Counter);
    end;

    // ---------------------------------------------------------------
    // E-mail to the salesperson for the reservations expiring on AlertDate
    // ---------------------------------------------------------------
    procedure SendExpiryAlerts(AlertDate: Date): Integer
    var
        ReservEntry: Record "Reservation Entry";
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        Item: Record Item;
        Lines: Dictionary of [Code[20], Text];
        SalespersonCode: Code[20];
        RowText: Text;
        Existing: Text;
        Sent: Integer;
    begin
        SetSalesReservationFilter(ReservEntry);
        if ReservEntry.FindSet() then
            repeat
                if GetExpiryDate(ReservEntry) = AlertDate then
                    if SalesHeader.Get(SalesHeader."Document Type"::Order, ReservEntry."Source ID") then
                        if SalesHeader."Salesperson Code" <> '' then begin
                            if not Customer.Get(SalesHeader."Sell-to Customer No.") then
                                Customer.Init();
                            if not Item.Get(ReservEntry."Item No.") then
                                Item.Init();
                            RowText := StrSubstNo(RowTxt,
                                SalesHeader."No.", SalesHeader."Sell-to Customer No.", Customer.Name, Customer."Phone No.",
                                ReservEntry."Item No.", Item.Description, Abs(ReservEntry."Quantity (Base)"), AlertDate);
                            SalespersonCode := SalesHeader."Salesperson Code";
                            if Lines.Get(SalespersonCode, Existing) then
                                Lines.Set(SalespersonCode, Existing + RowText)
                            else
                                Lines.Add(SalespersonCode, RowText);
                        end;
            until ReservEntry.Next() = 0;

        foreach SalespersonCode in Lines.Keys() do
            if SendEmail(SalespersonCode, Lines.Get(SalespersonCode), AlertDate) then
                Sent += 1;
        exit(Sent);
    end;

    local procedure SendEmail(SalespersonCode: Code[20]; Rows: Text; AlertDate: Date): Boolean
    var
        Salesperson: Record "Salesperson/Purchaser";
        SalesSetup: Record "Sales & Receivables Setup";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        Body: Text;
    begin
        if not Salesperson.Get(SalespersonCode) then
            exit(false);
        if Salesperson."E-Mail" = '' then
            exit(false);
        SalesSetup.Get();

        Body := StrSubstNo(BodyStartTxt, Salesperson.Name, AlertDate) + TableHeaderTxt + Rows + TableEndTxt;
        EmailMessage.Create(Salesperson."E-Mail", SalesSetup."Reservation Alert Subject", Body, true);
        exit(Email.Send(EmailMessage, Enum::"Email Scenario"::Default));
    end;

    // ---------------------------------------------------------------
    // Extend a reservation: the validity restarts from today
    // ---------------------------------------------------------------
    procedure ExtendReservation(ReservEntry: Record "Reservation Entry")
    var
        PairEntry: Record "Reservation Entry";
    begin
        PairEntry.SetRange("Entry No.", ReservEntry."Entry No.");
        PairEntry.ModifyAll("Creation Date", Today());
    end;

    var
        BodyStartTxt: Label '<p>Hello %1,</p><p>The following reservations expire on <b>%2</b>. Please contact your customers to reconfirm their commitment; otherwise the reservations will be cancelled and the stock released.</p>', Comment = '%1 = Salesperson name, %2 = Expiry date';
        TableHeaderTxt: Label '<table border="1" cellpadding="4" cellspacing="0"><tr><th>Order No.</th><th>Customer No.</th><th>Customer</th><th>Phone</th><th>Item No.</th><th>Description</th><th>Reserved Qty.</th><th>Expiry Date</th></tr>', Locked = true;
        RowTxt: Label '<tr><td>%1</td><td>%2</td><td>%3</td><td>%4</td><td>%5</td><td>%6</td><td>%7</td><td>%8</td></tr>', Locked = true;
        TableEndTxt: Label '</table>', Locked = true;
}
