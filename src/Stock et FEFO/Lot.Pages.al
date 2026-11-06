// Manufacturing date = standard "Warranty Date", relabelled on the pages where it is entered or read
pageextension 50250 "NAV Item Tracking Lines Lot" extends "Item Tracking Lines"
{
    layout
    {
        modify("Warranty Date")
        {
            Caption = 'Manufacturing Date';
            Visible = true;
            ToolTip = 'Specifies the manufacturing date of the batch. It cannot be later than the receipt date nor than the expiry date.';
        }
    }
}

pageextension 50251 "NAV Item Tracking Code Lot" extends "Item Tracking Code Card"
{
    layout
    {
        modify("Man. Warranty Date Entry Reqd.")
        {
            Caption = 'Man. Manufacturing Date Entry Reqd.';
            ToolTip = 'Specifies that a manufacturing date must be entered for every batch received.';
        }
    }
}

pageextension 50252 "NAV Item Ledger Entries Lot" extends "Item Ledger Entries"
{
    layout
    {
        // "Warranty Date" is not a control of this page: it is added, labelled as manufacturing date
        addafter("Lot No.")
        {
            field(NAVManufacturingDate; Rec."Warranty Date")
            {
                ApplicationArea = All;
                Caption = 'Manufacturing Date';
                Editable = false;
                ToolTip = 'Specifies the manufacturing date of the batch, recorded at receipt.';
            }
        }
    }
}

pageextension 50253 "NAV Lot No. Info. Card" extends "Lot No. Information Card"
{
    layout
    {
        // The standard Blocked flag is driven by the Lot Status
        modify(Blocked)
        {
            Editable = false;
        }
        addafter(Blocked)
        {
            field("Lot Status"; Rec."Lot Status")
            {
                ApplicationArea = All;
                StyleExpr = StatusStyle;
                ToolTip = 'Specifies the status of the batch. Only Available batches can be sold, transferred or consumed. Only Lot Status Approvers can change it.';
            }
            field("Manufacturing Date"; Rec."Manufacturing Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the manufacturing date recorded at receipt.';
            }
            field(NAVExpirationDate; ExpirationDate)
            {
                ApplicationArea = All;
                Caption = 'Expiration Date';
                Editable = false;
                ToolTip = 'Specifies the expiry date recorded at receipt.';
            }
            field("Status Changed By"; Rec."Status Changed By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the user who last changed the status.';
            }
            field("Status Changed At"; Rec."Status Changed At")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies when the status was last changed.';
            }
            field("Created by Receipt No."; Rec."Created by Receipt No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the posted purchase receipt that created the batch.';
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        LotManagement: Codeunit "NAV Lot Management";
    begin
        ExpirationDate := LotManagement.GetLotExpirationDate(Rec);
        StatusStyle := GetStatusStyle(Rec."Lot Status");
    end;

    local procedure GetStatusStyle(LotStatus: Enum "NAV Lot Status"): Text
    begin
        case LotStatus of
            LotStatus::Available:
                exit('Favorable');
            LotStatus::Quarantine:
                exit('Ambiguous');
            else
                exit('Unfavorable');
        end;
    end;

    var
        ExpirationDate: Date;
        StatusStyle: Text;
}

pageextension 50254 "NAV Lot No. Info. List" extends "Lot No. Information List"
{
    layout
    {
        modify(Blocked)
        {
            Editable = false;
        }
        addafter(Blocked)
        {
            field("Lot Status"; Rec."Lot Status")
            {
                ApplicationArea = All;
                StyleExpr = StatusStyle;
                ToolTip = 'Specifies the status of the batch. Only Available batches can be sold, transferred or consumed.';
            }
            field("Manufacturing Date"; Rec."Manufacturing Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the manufacturing date recorded at receipt.';
            }
            field(NAVExpirationDate; ExpirationDate)
            {
                ApplicationArea = All;
                Caption = 'Expiration Date';
                Editable = false;
                ToolTip = 'Specifies the expiry date recorded at receipt.';
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(NAVUpdateExpiredLots)
            {
                ApplicationArea = All;
                Caption = 'Update Expired Batches';
                Image = DateRange;
                ToolTip = 'Sets the status Expired on every batch whose expiry date is earlier than or equal to today. This also runs daily from the Job Queue.';

                trigger OnAction()
                var
                    LotExpiryJob: Codeunit "NAV Lot Expiry Job";
                begin
                    LotExpiryJob.UpdateExpiredLots(true);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        LotManagement: Codeunit "NAV Lot Management";
    begin
        ExpirationDate := LotManagement.GetLotExpirationDate(Rec);
        case Rec."Lot Status" of
            Rec."Lot Status"::Available:
                StatusStyle := 'Favorable';
            Rec."Lot Status"::Quarantine:
                StatusStyle := 'Ambiguous';
            else
                StatusStyle := 'Unfavorable';
        end;
    end;

    var
        ExpirationDate: Date;
        StatusStyle: Text;
}

pageextension 50255 "NAV User Setup Lot" extends "User Setup"
{
    layout
    {
        addafter("User ID")
        {
            field("Lot Status Approver"; Rec."Lot Status Approver")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the user can change the status of a batch, for example release a quarantined or blocked batch.';
            }
        }
    }
}
