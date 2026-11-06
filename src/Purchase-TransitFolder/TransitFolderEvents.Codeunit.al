codeunit 50201 "NAV Transit Folder Events"
{
    // Release of a foreign vendor order: the transit folder is mandatory
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnBeforeReleasePurchaseDoc', '', false, false)]
    local procedure CheckTransitFolderOnBeforeRelease(var PurchaseHeader: Record "Purchase Header")
    var
        TransitFolderMgt: Codeunit "NAV Transit Folder Mgt.";
    begin
        TransitFolderMgt.CheckTransitFolderRequired(PurchaseHeader);
    end;

    // Before the first receipt: recalculate and freeze the folder amounts
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure FreezeFolderOnBeforePost(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    var
        TransitFolder: Record "NAV Transit Folder";
        TransitFolderMgt: Codeunit "NAV Transit Folder Mgt.";
    begin
        // Foreign vendor order: the transit folder is mandatory
        TransitFolderMgt.CheckTransitFolderRequired(PurchaseHeader);

        if PurchaseHeader."Transit Folder No." = '' then
            exit;

        // Make sure every line carries the folder, so that the posted receipt lines,
        // item ledger entries and value entries are linked to it
        TransitFolderMgt.SyncFolderOnLines(PurchaseHeader);

        if PreviewMode then
            exit;
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit;
        if not PurchaseHeader.Receive then
            exit;
        if not TransitFolder.Get(PurchaseHeader."Transit Folder No.") then
            exit;

        if TransitFolder.Status = TransitFolder.Status::Open then
            TransitFolderMgt.ReleaseFolder(TransitFolder);
    end;

    // After receipt (or receipt + invoice): create the charge orders
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure CreateChargesOnAfterPost(var PurchaseHeader: Record "Purchase Header"; PurchRcpHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        PurchSetup: Record "Purchases & Payables Setup";
        TransitFolder: Record "NAV Transit Folder";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
        TransitFolderMgt: Codeunit "NAV Transit Folder Mgt.";
    begin
        if PurchRcpHdrNo = '' then
            exit;
        if PurchaseHeader."Transit Folder No." = '' then
            exit;
        if CommitIsSupressed or GenJnlPostPreview.IsActive() then
            exit;

        if not TransitFolder.Get(PurchaseHeader."Transit Folder No.") then
            exit;
        if TransitFolder.Status = TransitFolder.Status::"Charges Created" then
            exit;

        PurchSetup.Get();
        if not PurchSetup."Auto Create Charge Orders" then begin
            if GuiAllowed() then
                Message(AutoCreateDisabledMsg, TransitFolder."No.");
            exit;
        end;

        // Wait until all orders of the folder are completely received
        if not TransitFolderMgt.AllOrdersFullyReceived(TransitFolder."No.") then begin
            if GuiAllowed() then
                Message(WaitingForReceiptsMsg, TransitFolder."No.");
            exit;
        end;

        TransitFolderMgt.CreateChargeOrders(TransitFolder, PurchSetup."Auto Post Charge Receipt");
    end;

    // -------------------------------------------------------------------
    // Folder propagation: Purchase Line -> Item Journal Line -> 32 / 5802
    // (on a charge order the line carries the charge folder, so item charge
    //  Value Entries are also linked to the folder)
    // -------------------------------------------------------------------
    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterCopyItemJnlLineFromPurchLine', '', false, false)]
    local procedure CopyFolderToItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; PurchLine: Record "Purchase Line")
    var
        PurchHeader: Record "Purchase Header";
    begin
        ItemJnlLine."Transit Folder No." := PurchLine."Transit Folder No.";
        if ItemJnlLine."Transit Folder No." <> '' then
            exit;
        if PurchHeader.Get(PurchLine."Document Type", PurchLine."Document No.") then
            if PurchHeader."Transit Folder No." <> '' then
                ItemJnlLine."Transit Folder No." := PurchHeader."Transit Folder No."
            else
                ItemJnlLine."Transit Folder No." := PurchHeader."Charge Folder No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    local procedure CopyFolderToItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line")
    begin
        NewItemLedgEntry."Transit Folder No." := ItemJournalLine."Transit Folder No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitValueEntry', '', false, false)]
    local procedure CopyFolderToValueEntry(var ValueEntry: Record "Value Entry"; var ItemJournalLine: Record "Item Journal Line")
    begin
        ValueEntry."Transit Folder No." := ItemJournalLine."Transit Folder No.";
    end;

    var
        AutoCreateDisabledMsg: Label 'The receipt is linked to transit folder %1, but automatic creation of charge orders is turned off in Purchases & Payables Setup. Use the Create Charge Orders action on the transit folder.', Comment = '%1 = Folder No.';
        WaitingForReceiptsMsg: Label 'The charge orders of transit folder %1 will be created when all purchase orders of the folder are completely received.', Comment = '%1 = Folder No.';
}
