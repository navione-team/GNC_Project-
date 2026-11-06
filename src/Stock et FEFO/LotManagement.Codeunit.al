codeunit 50250 "NAV Lot Management"
{
    // Batch (lot) rules:
    //  - Rules 1-3: at purchase receipt, the expiry date must be later than the receipt
    //    date; the manufacturing date (standard "Warranty Date", relabelled) cannot be
    //    later than the receipt date nor than the expiry date. A Lot No. Information card
    //    is created with the manufacturing date.
    //  - Rules 6, 9: Lot Status. Quarantine / Blocked / Expired batches are blocked
    //    (standard Blocked flag); only Lot Status Approvers can change the status.
    //  - Rule 17: reason code mandatory on adjustments of batch-tracked items.
    //  - Rule 19: quantity of unusable batches (expired, quarantine, blocked).

    Permissions = tabledata "Lot No. Information" = RIM;

    // ---------------------------------------------------------------
    // Rules 1-3: checks at receipt + batch card creation
    // ---------------------------------------------------------------
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure CheckReceiptOnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line")
    begin
        if NewItemLedgEntry."Lot No." = '' then
            exit;
        if NewItemLedgEntry."Entry Type" <> NewItemLedgEntry."Entry Type"::Purchase then
            exit;
        if not NewItemLedgEntry.Positive then
            exit;
        if NewItemLedgEntry.Correction then
            exit;

        CheckReceiptDates(NewItemLedgEntry);
        CreateOrUpdateLotInfo(NewItemLedgEntry);
    end;

    local procedure CheckReceiptDates(ItemLedgEntry: Record "Item Ledger Entry")
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if not Item.Get(ItemLedgEntry."Item No.") then
            exit;
        if Item."Item Tracking Code" = '' then
            exit;
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit;

        // Rule 3: expiry date must be later than the receipt date
        if ItemTrackingCode."Use Expiration Dates" then begin
            if ItemLedgEntry."Expiration Date" = 0D then
                Error(ExpiryMissingErr, ItemLedgEntry."Lot No.", ItemLedgEntry."Item No.");
            if ItemLedgEntry."Expiration Date" <= ItemLedgEntry."Posting Date" then
                Error(ExpiryTooEarlyErr, ItemLedgEntry."Lot No.", ItemLedgEntry."Item No.",
                    ItemLedgEntry."Expiration Date", ItemLedgEntry."Posting Date");
        end;

        // Rule 1: manufacturing date (standard Warranty Date)
        if ItemTrackingCode."Man. Warranty Date Entry Reqd." and (ItemLedgEntry."Warranty Date" = 0D) then
            Error(MfgDateMissingErr, ItemLedgEntry."Lot No.", ItemLedgEntry."Item No.");
        if ItemLedgEntry."Warranty Date" <> 0D then begin
            if ItemLedgEntry."Warranty Date" > ItemLedgEntry."Posting Date" then
                Error(MfgDateInFutureErr, ItemLedgEntry."Lot No.", ItemLedgEntry."Warranty Date", ItemLedgEntry."Posting Date");
            if (ItemLedgEntry."Expiration Date" <> 0D) and (ItemLedgEntry."Warranty Date" >= ItemLedgEntry."Expiration Date") then
                Error(MfgAfterExpiryErr, ItemLedgEntry."Lot No.", ItemLedgEntry."Warranty Date", ItemLedgEntry."Expiration Date");
        end;
    end;

    local procedure CreateOrUpdateLotInfo(ItemLedgEntry: Record "Item Ledger Entry")
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        if LotNoInfo.Get(ItemLedgEntry."Item No.", ItemLedgEntry."Variant Code", ItemLedgEntry."Lot No.") then begin
            if (LotNoInfo."Manufacturing Date" = 0D) and (ItemLedgEntry."Warranty Date" <> 0D) then begin
                LotNoInfo."Manufacturing Date" := ItemLedgEntry."Warranty Date";
                LotNoInfo.Modify();
            end;
            exit;
        end;

        LotNoInfo.Init();
        LotNoInfo."Item No." := ItemLedgEntry."Item No.";
        LotNoInfo."Variant Code" := ItemLedgEntry."Variant Code";
        LotNoInfo."Lot No." := ItemLedgEntry."Lot No.";
        LotNoInfo."Manufacturing Date" := ItemLedgEntry."Warranty Date";
        LotNoInfo."Lot Status" := LotNoInfo."Lot Status"::Available;
        LotNoInfo."Created by Receipt No." := ItemLedgEntry."Document No.";
        LotNoInfo.Insert();
    end;

    // New batches of a receipt get the default status (e.g. Quarantine), after posting
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure ApplyDefaultStatusOnAfterPostPurchaseDoc(PurchRcpHdrNo: Code[20])
    var
        InventorySetup: Record "Inventory Setup";
        LotNoInfo: Record "Lot No. Information";
    begin
        if PurchRcpHdrNo = '' then
            exit;
        InventorySetup.Get();
        if InventorySetup."Default Lot Status at Receipt" = InventorySetup."Default Lot Status at Receipt"::Available then
            exit;

        LotNoInfo.SetRange("Created by Receipt No.", PurchRcpHdrNo);
        LotNoInfo.SetRange("Lot Status", LotNoInfo."Lot Status"::Available);
        if LotNoInfo.FindSet(true) then
            repeat
                LotNoInfo."Lot Status" := InventorySetup."Default Lot Status at Receipt";
                ApplyStatus(LotNoInfo);
                LotNoInfo.Modify();
            until LotNoInfo.Next() = 0;
    end;

    // ---------------------------------------------------------------
    // Rules 6, 9: Lot Status
    // ---------------------------------------------------------------
    procedure CheckStatusChange(LotNoInfo: Record "Lot No. Information")
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then
            Error(NotApproverErr, UserId());
        if not UserSetup."Lot Status Approver" then
            Error(NotApproverErr, UserId());

        if (LotNoInfo."Lot Status" = LotNoInfo."Lot Status"::Available) and IsLotExpired(LotNoInfo) then
            Error(CannotReleaseExpiredErr, LotNoInfo."Lot No.", GetLotExpirationDate(LotNoInfo));
    end;

    // Synchronizes the standard Blocked flag:
    //  - Quarantine and Blocked batches are blocked for all postings;
    //  - Expired batches are NOT flagged Blocked: sale and consumption are already
    //    refused by the standard Strict Expiration Posting, and the batch must stay
    //    removable from stock (negative adjustment with a reason code, return).
    procedure ApplyStatus(var LotNoInfo: Record "Lot No. Information")
    begin
        LotNoInfo.Blocked := LotNoInfo."Lot Status" in [LotNoInfo."Lot Status"::Quarantine, LotNoInfo."Lot Status"::Blocked];
        LotNoInfo."Status Changed By" := CopyStr(UserId(), 1, MaxStrLen(LotNoInfo."Status Changed By"));
        LotNoInfo."Status Changed At" := CurrentDateTime();
    end;

    procedure IsLotExpired(LotNoInfo: Record "Lot No. Information"): Boolean
    var
        ExpirationDate: Date;
    begin
        ExpirationDate := GetLotExpirationDate(LotNoInfo);
        exit((ExpirationDate <> 0D) and (ExpirationDate <= Today()));
    end;

    procedure GetLotExpirationDate(LotNoInfo: Record "Lot No. Information"): Date
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", "Variant Code", "Lot No.");
        ItemLedgEntry.SetRange("Item No.", LotNoInfo."Item No.");
        ItemLedgEntry.SetRange("Variant Code", LotNoInfo."Variant Code");
        ItemLedgEntry.SetRange("Lot No.", LotNoInfo."Lot No.");
        ItemLedgEntry.SetFilter("Expiration Date", '<>%1', 0D);
        if ItemLedgEntry.FindFirst() then
            exit(ItemLedgEntry."Expiration Date");
        exit(0D);
    end;

    // ---------------------------------------------------------------
    // Rule 17: reason code mandatory on adjustments of batch-tracked items
    // ---------------------------------------------------------------
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", 'OnAfterCheckItemJnlLine', '', false, false)]
    local procedure CheckReasonCodeOnAfterCheckItemJnlLine(var ItemJnlLine: Record "Item Journal Line")
    var
        InventorySetup: Record "Inventory Setup";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if not (ItemJnlLine."Entry Type" in [ItemJnlLine."Entry Type"::"Positive Adjmt.", ItemJnlLine."Entry Type"::"Negative Adjmt."]) then
            exit;
        if ItemJnlLine."Reason Code" <> '' then
            exit;
        if ItemJnlLine."Value Entry Type" <> ItemJnlLine."Value Entry Type"::"Direct Cost" then
            exit;
        InventorySetup.Get();
        if not InventorySetup."Lot Adjmt. Reason Mandatory" then
            exit;
        if not Item.Get(ItemJnlLine."Item No.") then
            exit;
        if Item."Item Tracking Code" = '' then
            exit;
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit;
        if not ItemTrackingCode."Lot Specific Tracking" then
            exit;

        Error(ReasonCodeMandatoryErr, ItemJnlLine."Item No.", ItemJnlLine."Entry Type");
    end;

    // ---------------------------------------------------------------
    // Rule 19: quantity of unusable batches (expired, quarantine, blocked)
    // ---------------------------------------------------------------
    procedure GetUnusableQty(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]): Decimal
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        LotNoInfo: Record "Lot No. Information";
        Total: Decimal;
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code");
        ItemLedgEntry.SetRange("Item No.", ItemNo);
        ItemLedgEntry.SetRange(Open, true);
        ItemLedgEntry.SetRange("Variant Code", VariantCode);
        ItemLedgEntry.SetRange(Positive, true);
        ItemLedgEntry.SetRange("Location Code", LocationCode);
        ItemLedgEntry.SetFilter("Lot No.", '<>%1', '');
        if ItemLedgEntry.FindSet() then
            repeat
                if (ItemLedgEntry."Expiration Date" <> 0D) and (ItemLedgEntry."Expiration Date" <= Today()) then
                    Total += ItemLedgEntry."Remaining Quantity"
                else
                    if LotNoInfo.Get(ItemLedgEntry."Item No.", ItemLedgEntry."Variant Code", ItemLedgEntry."Lot No.") then
                        if LotNoInfo."Lot Status" <> LotNoInfo."Lot Status"::Available then
                            Total += ItemLedgEntry."Remaining Quantity";
            until ItemLedgEntry.Next() = 0;
        exit(Total);
    end;

    var
        ExpiryMissingErr: Label 'Batch %1 of item %2 has no expiry date. Enter the expiration date on the item tracking lines.', Comment = '%1 = Lot No., %2 = Item No.';
        ExpiryTooEarlyErr: Label 'Batch %1 of item %2 cannot be received: its expiry date %3 is earlier than or equal to the receipt date %4.', Comment = '%1 = Lot No., %2 = Item No., %3 = Expiration Date, %4 = Posting Date';
        MfgDateMissingErr: Label 'Batch %1 of item %2 has no manufacturing date. Enter the manufacturing date on the item tracking lines.', Comment = '%1 = Lot No., %2 = Item No.';
        MfgDateInFutureErr: Label 'The manufacturing date %2 of batch %1 is later than the receipt date %3.', Comment = '%1 = Lot No., %2 = Manufacturing Date, %3 = Posting Date';
        MfgAfterExpiryErr: Label 'The manufacturing date %2 of batch %1 must be earlier than its expiry date %3.', Comment = '%1 = Lot No., %2 = Manufacturing Date, %3 = Expiration Date';
        NotApproverErr: Label 'User %1 is not allowed to change the status of a batch. Ask a Lot Status Approver (User Setup).', Comment = '%1 = User ID';
        CannotReleaseExpiredErr: Label 'Batch %1 expired on %2 and cannot be made available.', Comment = '%1 = Lot No., %2 = Expiration Date';
        ReasonCodeMandatoryErr: Label 'A reason code is mandatory for the %2 of batch-tracked item %1.', Comment = '%1 = Item No., %2 = Entry Type';
}
