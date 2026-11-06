// ===================================================================
// 1.1 Reservation validity per customer
// ===================================================================
tableextension 50260 "NAV Customer Reservation" extends Customer
{
    fields
    {
        // Number of days a reservation is kept; 0 = default of Sales & Receivables Setup
        field(50260; "Reservation Validity (Days)"; Integer)
        {
            Caption = 'Reservation Validity (Days)';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }
}

tableextension 50261 "NAV Sales Setup Reservation" extends "Sales & Receivables Setup"
{
    fields
    {
        // Used when the customer has no validity; 0 = reservations never expire
        field(50260; "Default Reservation Days"; Integer)
        {
            Caption = 'Default Reservation Validity (Days)';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(50261; "Reservation Alert Subject"; Text[100])
        {
            Caption = 'Reservation Alert E-mail Subject';
            DataClassification = CustomerContent;
            InitValue = 'Reservations expiring tomorrow - please contact your customers';
        }
    }
}

// ===================================================================
// 1.2 Stores that cannot be used for sales (DAMAGE-VENDOR, DAMAGE-STORE)
// ===================================================================
tableextension 50262 "NAV Location Not For Sale" extends Location
{
    fields
    {
        field(50260; "Not for Sale"; Boolean)
        {
            Caption = 'Not for Sale';
            DataClassification = CustomerContent;
        }
        // Every bin of this zone holds damaged products
        field(50270; "Damaged Zone Code"; Code[10])
        {
            Caption = 'Damaged Zone Code';
            DataClassification = CustomerContent;
            TableRelation = Zone.Code where("Location Code" = field(Code));
        }
        // Bin proposed by default on Damage Transfer lines
        field(50271; "Damaged Bin Code"; Code[20])
        {
            Caption = 'Damaged Bin Code';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code where("Location Code" = field(Code));
        }
    }

    procedure IsDamagedBin(BinCode: Code[20]): Boolean
    var
        Bin: Record Bin;
    begin
        if BinCode = '' then
            exit(false);
        if BinCode = "Damaged Bin Code" then
            exit(true);
        if "Damaged Zone Code" = '' then
            exit(false);
        if not Bin.Get(Code, BinCode) then
            exit(false);
        exit(Bin."Zone Code" = "Damaged Zone Code");
    end;
}

// ===================================================================
// Pages
// ===================================================================
pageextension 50260 "NAV Customer Card Reservation" extends "Customer Card"
{
    layout
    {
        addafter(Reserve)
        {
            field("Reservation Validity (Days)"; Rec."Reservation Validity (Days)")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how many days a reservation is kept for this customer. After this period the reservation is cancelled and the stock becomes available again. 0 = default of Sales & Receivables Setup.';
            }
        }
    }
}

pageextension 50261 "NAV Sales Setup Reservation" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(General)
        {
            field("Default Reservation Days"; Rec."Default Reservation Days")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how many days a reservation is kept when the customer has no validity of its own. 0 = reservations never expire.';
            }
            field("Reservation Alert Subject"; Rec."Reservation Alert Subject")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the subject of the e-mail sent to the salesperson one day before a reservation expires.';
            }
        }
    }
}

pageextension 50262 "NAV Location Card Not For Sale" extends "Location Card"
{
    layout
    {
        addafter("Use As In-Transit")
        {
            field("Not for Sale"; Rec."Not for Sale")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the stock of this location cannot be sold (for example DAMAGE-VENDOR, DAMAGE-STORE). Transfers and purchase returns remain possible.';
            }
        }
        addafter("Adjustment Bin Code")
        {
            field("Damaged Zone Code"; Rec."Damaged Zone Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the zone that holds damaged products. Stock in this zone can only be taken out by a Damaged Stock Approver.';
            }
            field("Damaged Bin Code"; Rec."Damaged Bin Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the bin proposed by default as destination on damage transfers.';
            }
        }
    }
}

pageextension 50263 "NAV Location List Not For Sale" extends "Location List"
{
    layout
    {
        addafter(Name)
        {
            field("Not for Sale"; Rec."Not for Sale")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the stock of this location cannot be sold.';
            }
        }
    }
}

// 1.3 Refund reason (standard Reason Code) shown as mandatory on refunds
pageextension 50264 "NAV Sales Credit Memo Refund" extends "Sales Credit Memo"
{
    layout
    {
        addlast(General)
        {
            field(NAVRefundReasonCode; Rec."Reason Code")
            {
                ApplicationArea = All;
                Caption = 'Refund Reason Code';
                ShowMandatory = true;
                ToolTip = 'Specifies the reason of the refund. It is mandatory before the credit memo is sent for approval or posted.';
            }
        }
    }
}

pageextension 50265 "NAV Sales Return Order Refund" extends "Sales Return Order"
{
    layout
    {
        addlast(General)
        {
            field(NAVRefundReasonCode; Rec."Reason Code")
            {
                ApplicationArea = All;
                Caption = 'Refund Reason Code';
                ShowMandatory = true;
                ToolTip = 'Specifies the reason of the refund. It is mandatory before the return order is sent for approval or posted.';
            }
        }
    }
}
