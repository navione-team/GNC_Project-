page 50260 "NAV Sales Reservations"
{
    Caption = 'Sales Reservations (Expiry)';
    PageType = List;
    SourceTable = "Reservation Entry";
    SourceTableView = where("Reservation Status" = const(Reservation), "Source Type" = const(37), "Source Subtype" = const(1), Positive = const(false));
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Order No.';
                    ToolTip = 'Specifies the sales order of the reservation.';

                    trigger OnDrillDown()
                    var
                        SalesHeader: Record "Sales Header";
                    begin
                        if SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Source ID") then
                            Page.Run(Page::"Sales Order", SalesHeader);
                    end;
                }
                field(NAVCustomerNo; CustomerNo)
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the customer of the sales order.';
                }
                field(NAVCustomerName; CustomerName)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the name of the customer.';
                }
                field(NAVSalespersonCode; SalespersonCode)
                {
                    ApplicationArea = All;
                    Caption = 'Salesperson Code';
                    ToolTip = 'Specifies the salesperson who receives the expiry alert.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reserved item.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location.';
                }
                field(NAVReservedQty; ReservedQty)
                {
                    ApplicationArea = All;
                    Caption = 'Reserved Quantity (Base)';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the reserved quantity.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    Caption = 'Reserved On';
                    ToolTip = 'Specifies when the reservation was made (or last extended).';
                }
                field(NAVExpiryDate; ExpiryDate)
                {
                    ApplicationArea = All;
                    Caption = 'Expiry Date';
                    StyleExpr = ExpiryStyle;
                    ToolTip = 'Specifies when the reservation is cancelled: reserved on + reservation validity of the customer. Empty = no expiry.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ExtendReservation)
            {
                ApplicationArea = All;
                Caption = 'Extend Reservation';
                Image = DueDate;
                ToolTip = 'Restarts the validity of the selected reservation from today, after the customer has reconfirmed the order.';

                trigger OnAction()
                var
                    ReservEntry: Record "Reservation Entry";
                begin
                    CurrPage.SetSelectionFilter(ReservEntry);
                    if ReservEntry.FindSet() then
                        repeat
                            ReservationExpiry.ExtendReservation(ReservEntry);
                        until ReservEntry.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
            action(CancelExpired)
            {
                ApplicationArea = All;
                Caption = 'Cancel Expired Reservations';
                Image = Cancel;
                ToolTip = 'Cancels now the reservations whose expiry date is reached. This also runs daily from the Job Queue.';

                trigger OnAction()
                begin
                    Message(CancelledMsg, ReservationExpiry.CancelExpiredReservations(Today()));
                    CurrPage.Update(false);
                end;
            }
            action(SendAlerts)
            {
                ApplicationArea = All;
                Caption = 'Send Expiry Alerts';
                Image = SendMail;
                ToolTip = 'Sends now the e-mail to the salespersons for the reservations expiring tomorrow. This also runs daily from the Job Queue.';

                trigger OnAction()
                begin
                    Message(SentMsg, ReservationExpiry.SendExpiryAlerts(Today() + 1));
                end;
            }
        }
        area(Promoted)
        {
            actionref(ExtendReservation_Promoted; ExtendReservation) { }
            actionref(CancelExpired_Promoted; CancelExpired) { }
            actionref(SendAlerts_Promoted; SendAlerts) { }
        }
    }

    trigger OnAfterGetRecord()
    var
        SalesHeader: Record "Sales Header";
    begin
        CustomerNo := '';
        CustomerName := '';
        SalespersonCode := '';
        if SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Source ID") then begin
            CustomerNo := SalesHeader."Sell-to Customer No.";
            CustomerName := SalesHeader."Sell-to Customer Name";
            SalespersonCode := SalesHeader."Salesperson Code";
        end;
        ReservedQty := Abs(Rec."Quantity (Base)");
        ExpiryDate := ReservationExpiry.GetExpiryDate(Rec);
        case true of
            ExpiryDate = 0D:
                ExpiryStyle := 'Standard';
            ExpiryDate <= Today() + 1:
                ExpiryStyle := 'Unfavorable';
            else
                ExpiryStyle := 'Favorable';
        end;
    end;

    var
        ReservationExpiry: Codeunit "NAV Reservation Expiry";
        CustomerNo: Code[20];
        CustomerName: Text[100];
        SalespersonCode: Code[20];
        ExpiryDate: Date;
        ReservedQty: Decimal;
        ExpiryStyle: Text;
        CancelledMsg: Label '%1 expired reservation(s) cancelled.', Comment = '%1 = number';
        SentMsg: Label '%1 e-mail(s) sent to salespersons.', Comment = '%1 = number';
}
