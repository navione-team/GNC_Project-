codeunit 50202 "NAV Transit Folder Accrual"
{
    // Estimated landed charges accrual.
    //
    // Goods receipt of an order linked to a transit folder:
    //   Dr Inventory Account (Inventory Posting Setup of the receipt location)
    //   Cr Clearing Account of each item charge (e.g. 1109002...1109005)
    //   Amount = folder charge amount x receipt line amount / folder base amount
    //
    // Invoice of the charge order:
    //   the accrual of each invoiced charge is reversed (Dr Clearing / Cr Inventory)
    //   while the standard posting brings the actual charge into inventory.
    //
    // Both postings run inside the standard posting transaction, with the same
    // G/L register and the same document number.

    Permissions = tabledata "NAV Transit Folder Accrual" = RIMD,
                  tabledata "NAV Transit Folder Line" = RM;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', false, false)]
    local procedure OnAfterFinalizePurchPosting(var PurchHeader: Record "Purchase Header"; var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchInvHeader: Record "Purch. Inv. Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        if PurchHeader."Document Type" <> PurchHeader."Document Type"::Order then
            exit;

        if (PurchRcptHeader."No." <> '') and (PurchRcptHeader."Transit Folder No." <> '') then
            PostReceiptAccruals(PurchRcptHeader, GenJnlPostLine);

        if (PurchInvHeader."No." <> '') and (PurchInvHeader."Charge Folder No." <> '') then
            ReverseInvoicedAccruals(PurchInvHeader, GenJnlPostLine);
    end;

    // ---------------------------------------------------------------
    // Accrual at goods receipt
    // ---------------------------------------------------------------
    local procedure PostReceiptAccruals(PurchRcptHeader: Record "Purch. Rcpt. Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        PurchSetup: Record "Purchases & Payables Setup";
        TransitFolder: Record "NAV Transit Folder";
        FolderLine: Record "NAV Transit Folder Line";
        ItemCharge: Record "Item Charge";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        TempPostingBuffer: Record "NAV Transit Folder Accrual" temporary;
        TransitFolderMgt: Codeunit "NAV Transit Folder Mgt.";
        LineBase: Decimal;
        AccrualAmount: Decimal;
    begin
        PurchSetup.Get();
        if not PurchSetup."Post Charge Accruals" then
            exit;
        if not TransitFolder.Get(PurchRcptHeader."Transit Folder No.") then
            exit;
        if TransitFolder."Base Amount (LCY)" = 0 then
            exit;

        FolderLine.SetRange("Folder No.", TransitFolder."No.");
        FolderLine.SetFilter(Amount, '<>0');
        FolderLine.SetRange("Accrual Closed", false);
        if not FolderLine.FindSet() then
            exit;

        PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
        PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);
        PurchRcptLine.SetFilter(Quantity, '>0');
        PurchRcptLine.SetRange(Correction, false);
        if PurchRcptLine.IsEmpty() then
            exit;

        repeat
            if ItemCharge.Get(FolderLine."Item Charge No.") then
                if ItemCharge."Clearing Account No." <> '' then begin
                    PurchRcptLine.FindSet();
                    repeat
                        LineBase := TransitFolderMgt.GetRcptLineBaseLCY(PurchRcptLine."Document No.", PurchRcptLine."Line No.");
                        AccrualAmount := Round(FolderLine.Amount * LineBase / TransitFolder."Base Amount (LCY)");
                        if AccrualAmount <> 0 then begin
                            InsertEntry(
                                AccrualEntryType::Accrual, TransitFolder."No.", FolderLine, PurchRcptHeader."Posting Date",
                                PurchRcptHeader."No.", PurchRcptLine."Line No.", PurchRcptLine."No.", PurchRcptLine."Location Code",
                                GetInventoryAccount(PurchRcptLine."Location Code", PurchRcptLine."Posting Group"),
                                ItemCharge."Clearing Account No.", AccrualAmount);
                            AddToBuffer(TempPostingBuffer,
                                GetInventoryAccount(PurchRcptLine."Location Code", PurchRcptLine."Posting Group"),
                                ItemCharge."Clearing Account No.", ItemCharge."No.", AccrualAmount);
                        end;
                    until PurchRcptLine.Next() = 0;
                end;
        until FolderLine.Next() = 0;

        PostBuffer(TempPostingBuffer, PurchRcptHeader."Posting Date", PurchRcptHeader."No.",
            StrSubstNo(AccrualDescTxt, TransitFolder."No."), PurchRcptHeader."Dimension Set ID", GenJnlPostLine);
    end;

    // ---------------------------------------------------------------
    // Reversal at charge invoice
    // ---------------------------------------------------------------
    local procedure ReverseInvoicedAccruals(PurchInvHeader: Record "Purch. Inv. Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        PurchInvLine: Record "Purch. Inv. Line";
        FolderLine: Record "NAV Transit Folder Line";
        TempPostingBuffer: Record "NAV Transit Folder Accrual" temporary;
    begin
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        PurchInvLine.SetRange(Type, PurchInvLine.Type::"Charge (Item)");
        PurchInvLine.SetFilter("Transit Folder Line No.", '<>0');
        PurchInvLine.SetFilter(Quantity, '<>0');
        if not PurchInvLine.FindSet() then
            exit;

        repeat
            if FolderLine.Get(PurchInvHeader."Charge Folder No.", PurchInvLine."Transit Folder Line No.") then
                ReverseFolderLine(FolderLine, PurchInvLine, PurchInvHeader, TempPostingBuffer);
        until PurchInvLine.Next() = 0;

        PostBuffer(TempPostingBuffer, PurchInvHeader."Posting Date", PurchInvHeader."No.",
            StrSubstNo(ReversalDescTxt, PurchInvHeader."Charge Folder No."), PurchInvHeader."Dimension Set ID", GenJnlPostLine);
    end;

    local procedure ReverseFolderLine(var FolderLine: Record "NAV Transit Folder Line"; PurchInvLine: Record "Purch. Inv. Line"; PurchInvHeader: Record "Purch. Inv. Header"; var TempPostingBuffer: Record "NAV Transit Folder Accrual" temporary)
    var
        AccrualEntry: Record "NAV Transit Folder Accrual";
        TempGroup: Record "NAV Transit Folder Accrual" temporary;
        ChargeLine: Record "Purchase Line";
        InvoicedLine: Record "Purch. Inv. Line";
        ChargeQty: Decimal;
        TotalInvoicedQty: Decimal;
        Accrued: Decimal;
        Remaining: Decimal;
        ReversalAmount: Decimal;
        FullyInvoiced: Boolean;
    begin
        // Is the charge line completely invoiced after this invoice?
        if ChargeLine.Get(ChargeLine."Document Type"::Order, FolderLine."Charge Order No.", FolderLine."Charge Order Line No.") then begin
            ChargeQty := ChargeLine.Quantity;
            InvoicedLine.SetRange("Order No.", FolderLine."Charge Order No.");
            InvoicedLine.SetRange("Order Line No.", FolderLine."Charge Order Line No.");
            InvoicedLine.CalcSums(Quantity);
            TotalInvoicedQty := InvoicedLine.Quantity;
            FullyInvoiced := (ChargeQty = 0) or (TotalInvoicedQty >= ChargeQty);
        end else
            FullyInvoiced := true; // order deleted after being completely invoiced

        // Group the accrual entries of the folder line by inventory / clearing account
        AccrualEntry.SetCurrentKey("Folder No.", "Folder Line No.", "Inventory Account No.", "Clearing Account No.", "Entry Type");
        AccrualEntry.SetRange("Folder No.", FolderLine."Folder No.");
        AccrualEntry.SetRange("Folder Line No.", FolderLine."Line No.");
        if AccrualEntry.FindSet() then
            repeat
                TempGroup.SetRange("Inventory Account No.", AccrualEntry."Inventory Account No.");
                TempGroup.SetRange("Clearing Account No.", AccrualEntry."Clearing Account No.");
                if not TempGroup.FindFirst() then begin
                    TempGroup.Init();
                    TempGroup."Entry No." := AccrualEntry."Entry No.";
                    TempGroup."Inventory Account No." := AccrualEntry."Inventory Account No.";
                    TempGroup."Clearing Account No." := AccrualEntry."Clearing Account No.";
                    TempGroup."Location Code" := AccrualEntry."Location Code";
                    TempGroup.Insert();
                end;
            until AccrualEntry.Next() = 0;
        TempGroup.Reset();

        if TempGroup.FindSet() then
            repeat
                AccrualEntry.SetRange("Inventory Account No.", TempGroup."Inventory Account No.");
                AccrualEntry.SetRange("Clearing Account No.", TempGroup."Clearing Account No.");
                AccrualEntry.SetRange("Entry Type");
                AccrualEntry.CalcSums("Amount (LCY)");
                Remaining := AccrualEntry."Amount (LCY)";
                AccrualEntry.SetRange("Entry Type", AccrualEntry."Entry Type"::Accrual);
                AccrualEntry.CalcSums("Amount (LCY)");
                Accrued := AccrualEntry."Amount (LCY)";

                if FullyInvoiced then
                    ReversalAmount := Remaining
                else begin
                    ReversalAmount := Round(Accrued * PurchInvLine.Quantity / ChargeQty);
                    if Abs(ReversalAmount) > Abs(Remaining) then
                        ReversalAmount := Remaining;
                end;

                if ReversalAmount <> 0 then begin
                    InsertEntry(
                        AccrualEntryType::Reversal, FolderLine."Folder No.", FolderLine, PurchInvHeader."Posting Date",
                        PurchInvHeader."No.", PurchInvLine."Line No.", '', TempGroup."Location Code",
                        TempGroup."Inventory Account No.", TempGroup."Clearing Account No.", -ReversalAmount);
                    AddToBuffer(TempPostingBuffer, TempGroup."Inventory Account No.", TempGroup."Clearing Account No.",
                        FolderLine."Item Charge No.", -ReversalAmount);
                end;
            until TempGroup.Next() = 0;

        if FullyInvoiced then begin
            FolderLine."Accrual Closed" := true;
            FolderLine.Modify();
        end;
    end;

    // ---------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------
    local procedure InsertEntry(EntryType: Option; FolderNo: Code[20]; FolderLine: Record "NAV Transit Folder Line"; PostingDate: Date; DocumentNo: Code[20]; SourceLineNo: Integer; ItemNo: Code[20]; LocationCode: Code[10]; InventoryAccountNo: Code[20]; ClearingAccountNo: Code[20]; AmountLCY: Decimal)
    var
        AccrualEntry: Record "NAV Transit Folder Accrual";
    begin
        AccrualEntry.Init();
        AccrualEntry."Entry No." := 0;
        AccrualEntry."Entry Type" := EntryType;
        AccrualEntry."Folder No." := FolderNo;
        AccrualEntry."Folder Line No." := FolderLine."Line No.";
        AccrualEntry."Item Charge No." := FolderLine."Item Charge No.";
        AccrualEntry."Posting Date" := PostingDate;
        AccrualEntry."Document No." := DocumentNo;
        AccrualEntry."Source Line No." := SourceLineNo;
        AccrualEntry."Item No." := ItemNo;
        AccrualEntry."Location Code" := LocationCode;
        AccrualEntry."Inventory Account No." := InventoryAccountNo;
        AccrualEntry."Clearing Account No." := ClearingAccountNo;
        AccrualEntry."Amount (LCY)" := AmountLCY;
        AccrualEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(AccrualEntry."User ID"));
        AccrualEntry.Insert();
    end;

    // One G/L line per inventory account / clearing account / item charge
    local procedure AddToBuffer(var TempPostingBuffer: Record "NAV Transit Folder Accrual" temporary; InventoryAccountNo: Code[20]; ClearingAccountNo: Code[20]; ItemChargeNo: Code[20]; AmountLCY: Decimal)
    begin
        TempPostingBuffer.SetRange("Inventory Account No.", InventoryAccountNo);
        TempPostingBuffer.SetRange("Clearing Account No.", ClearingAccountNo);
        TempPostingBuffer.SetRange("Item Charge No.", ItemChargeNo);
        if TempPostingBuffer.FindFirst() then begin
            TempPostingBuffer."Amount (LCY)" += AmountLCY;
            TempPostingBuffer.Modify();
        end else begin
            TempPostingBuffer.Reset();
            if TempPostingBuffer.FindLast() then;
            TempPostingBuffer.Init();
            TempPostingBuffer."Entry No." += 1;
            TempPostingBuffer."Inventory Account No." := InventoryAccountNo;
            TempPostingBuffer."Clearing Account No." := ClearingAccountNo;
            TempPostingBuffer."Item Charge No." := ItemChargeNo;
            TempPostingBuffer."Amount (LCY)" := AmountLCY;
            TempPostingBuffer.Insert();
        end;
        TempPostingBuffer.Reset();
    end;

    // Grouped posting: one G/L line per inventory account (sum of all charges)
    // and one G/L line per clearing account. The lines are posted in the same
    // transaction as the purchase posting, so the transaction stays balanced.
    local procedure PostBuffer(var TempPostingBuffer: Record "NAV Transit Folder Accrual" temporary; PostingDate: Date; DocumentNo: Code[20]; Description: Text; DimSetID: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        TempInventoryTotal: Record "NAV Transit Folder Accrual" temporary;
        TempClearingTotal: Record "NAV Transit Folder Accrual" temporary;
    begin
        TempPostingBuffer.Reset();
        if not TempPostingBuffer.FindSet() then
            exit;

        repeat
            AddToTotal(TempInventoryTotal, TempPostingBuffer."Inventory Account No.", TempPostingBuffer."Amount (LCY)");
            AddToTotal(TempClearingTotal, TempPostingBuffer."Clearing Account No.", TempPostingBuffer."Amount (LCY)");
        until TempPostingBuffer.Next() = 0;

        // Accrual (amount > 0): Dr Inventory / Cr Clearing
        // Reversal (amount < 0): Dr Clearing / Cr Inventory
        TempInventoryTotal.SetFilter("Amount (LCY)", '<>0');
        if TempInventoryTotal.FindSet() then
            repeat
                PostGLLine(TempInventoryTotal."Inventory Account No.", TempInventoryTotal."Amount (LCY)",
                    PostingDate, DocumentNo, Description, DimSetID, GenJnlPostLine);
            until TempInventoryTotal.Next() = 0;

        TempClearingTotal.SetFilter("Amount (LCY)", '<>0');
        if TempClearingTotal.FindSet() then
            repeat
                PostGLLine(TempClearingTotal."Inventory Account No.", -TempClearingTotal."Amount (LCY)",
                    PostingDate, DocumentNo, Description, DimSetID, GenJnlPostLine);
            until TempClearingTotal.Next() = 0;
    end;

    // Totals are kept in "Inventory Account No." (used here as a generic account field)
    local procedure AddToTotal(var TempTotal: Record "NAV Transit Folder Accrual" temporary; AccountNo: Code[20]; AmountLCY: Decimal)
    begin
        TempTotal.SetRange("Inventory Account No.", AccountNo);
        if TempTotal.FindFirst() then begin
            TempTotal."Amount (LCY)" += AmountLCY;
            TempTotal.Modify();
        end else begin
            TempTotal.Reset();
            if TempTotal.FindLast() then;
            TempTotal.Init();
            TempTotal."Entry No." += 1;
            TempTotal."Inventory Account No." := AccountNo;
            TempTotal."Amount (LCY)" := AmountLCY;
            TempTotal.Insert();
        end;
        TempTotal.Reset();
    end;

    local procedure PostGLLine(AccountNo: Code[20]; AmountLCY: Decimal; PostingDate: Date; DocumentNo: Code[20]; Description: Text; DimSetID: Integer; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        DimMgt: Codeunit DimensionManagement;
    begin
        SourceCodeSetup.Get();
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := PostingDate;
        GenJnlLine."Document Date" := PostingDate;
        GenJnlLine."Document No." := DocumentNo;
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := AccountNo;
        GenJnlLine.Description := CopyStr(Description, 1, MaxStrLen(GenJnlLine.Description));
        GenJnlLine.Amount := AmountLCY;
        GenJnlLine."Amount (LCY)" := AmountLCY;
        GenJnlLine."Source Currency Amount" := AmountLCY;
        GenJnlLine."Source Code" := SourceCodeSetup.Purchases;
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine."Dimension Set ID" := DimSetID;
        DimMgt.UpdateGlobalDimFromDimSetID(DimSetID, GenJnlLine."Shortcut Dimension 1 Code", GenJnlLine."Shortcut Dimension 2 Code");
        GenJnlPostLine.RunWithCheck(GenJnlLine);
    end;

    local procedure GetInventoryAccount(LocationCode: Code[10]; InventoryPostingGroup: Code[20]): Code[20]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        InventoryPostingSetup.Get(LocationCode, InventoryPostingGroup);
        InventoryPostingSetup.TestField("Inventory Account");
        exit(InventoryPostingSetup."Inventory Account");
    end;

    var
        AccrualEntryType: Option Accrual,Reversal;
        AccrualDescTxt: Label 'Charge accrual %1', Comment = '%1 = Folder No.';
        ReversalDescTxt: Label 'Charge accrual reversal %1', Comment = '%1 = Folder No.';
}
