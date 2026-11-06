codeunit 50200 "NAV Transit Folder Mgt."
{
    // ---------------------------------------------------------------
    // Insert default charges (Item Charge "By Default" = true)
    // ---------------------------------------------------------------
    procedure InsertDefaultCharges(var TransitFolder: Record "NAV Transit Folder")
    var
        ItemCharge: Record "Item Charge";
        FolderLine: Record "NAV Transit Folder Line";
        ExistingLine: Record "NAV Transit Folder Line";
        LineNo: Integer;
    begin
        ItemCharge.SetRange("By Default", true);
        if not ItemCharge.FindSet() then
            exit;

        FolderLine.SetRange("Folder No.", TransitFolder."No.");
        if FolderLine.FindLast() then
            LineNo := FolderLine."Line No.";

        repeat
            ExistingLine.SetRange("Folder No.", TransitFolder."No.");
            ExistingLine.SetRange("Item Charge No.", ItemCharge."No.");
            if ExistingLine.IsEmpty() then begin
                LineNo += 10000;
                FolderLine.Init();
                FolderLine."Folder No." := TransitFolder."No.";
                FolderLine."Line No." := LineNo;
                FolderLine.Validate("Item Charge No.", ItemCharge."No.");
                FolderLine.Insert(true);
            end;
        until ItemCharge.Next() = 0;
    end;

    // ---------------------------------------------------------------
    // Recalculation: base = linked orders amount excl. VAT (LCY)
    // ---------------------------------------------------------------
    procedure RecalculateAmounts(var TransitFolder: Record "NAV Transit Folder")
    var
        FolderLine: Record "NAV Transit Folder Line";
    begin
        TransitFolder.TestField(Status, TransitFolder.Status::Open);

        TransitFolder."Base Amount (LCY)" := GetOrdersBaseAmountLCY(TransitFolder."No.");
        TransitFolder.Modify();

        FolderLine.SetRange("Folder No.", TransitFolder."No.");
        FolderLine.SetRange("Calculation Type", FolderLine."Calculation Type"::"By Percent");
        if FolderLine.FindSet(true) then
            repeat
                FolderLine.Amount := Round(TransitFolder."Base Amount (LCY)" * FolderLine.Percent / 100);
                FolderLine.Modify();
            until FolderLine.Next() = 0;
    end;

    // Release = recalculate, then freeze the amounts
    procedure ReleaseFolder(var TransitFolder: Record "NAV Transit Folder")
    begin
        case TransitFolder.Status of
            TransitFolder.Status::Released:
                exit;
            TransitFolder.Status::"Charges Created":
                Error(StatusChargesCreatedErr, TransitFolder."No.");
        end;

        TransitFolder.TestField("Vendor No.");
        if not HasLinkedOrders(TransitFolder."No.") then
            Error(NoOrderErr, TransitFolder."No.");

        RecalculateAmounts(TransitFolder);
        TransitFolder.Status := TransitFolder.Status::Released;
        TransitFolder.Modify();
    end;

    procedure ReopenFolder(var TransitFolder: Record "NAV Transit Folder")
    begin
        if TransitFolder.Status = TransitFolder.Status::"Charges Created" then
            Error(StatusChargesCreatedErr, TransitFolder."No.");
        TransitFolder.Status := TransitFolder.Status::Open;
        TransitFolder.Modify();
    end;

    // ---------------------------------------------------------------
    // Create charge orders: one order per vendor
    // ---------------------------------------------------------------
    procedure CreateChargeOrders(var TransitFolder: Record "NAV Transit Folder"; PostReceipt: Boolean)
    var
        FolderLine: Record "NAV Transit Folder Line";
        TempVendor: Record Vendor temporary;
        PurchHeader: Record "Purchase Header";
        TempCreatedHeader: Record "Purchase Header" temporary;
        CreatedList: Text;
        ErrorList: Text;
    begin
        // Always work on the current database values (the page may show an old status)
        TransitFolder.Get(TransitFolder."No.");
        TransitFolder.TestField("Vendor No.");

        // Free the lines whose charge order was deleted without being posted
        ReleaseDeletedChargeOrders(TransitFolder."No.");

        FolderLine.SetRange("Folder No.", TransitFolder."No.");
        FolderLine.SetRange("Charge Order No.", '');
        FolderLine.SetFilter(Amount, '<>0');
        if FolderLine.IsEmpty() then begin
            if TransitFolder.Status <> TransitFolder.Status::"Charges Created" then begin
                FolderLine.SetRange("Charge Order No.");
                FolderLine.SetFilter("Charge Order No.", '<>%1', '');
                if not FolderLine.IsEmpty() then begin
                    TransitFolder.Status := TransitFolder.Status::"Charges Created";
                    TransitFolder.Modify();
                end;
            end;
            ChargeOrdersExistError(TransitFolder."No.");
        end;

        if TransitFolder.Status = TransitFolder.Status::Open then
            ReleaseFolder(TransitFolder);

        if not HasReceipts(TransitFolder."No.") then
            Error(NoReceiptErr, TransitFolder."No.");

        // Build the list of distinct vendors
        FolderLine.FindSet();
        repeat
            FolderLine.TestField("Vendor No.");
            if not TempVendor.Get(FolderLine."Vendor No.") then begin
                TempVendor.Init();
                TempVendor."No." := FolderLine."Vendor No.";
                TempVendor.Insert();
            end;
        until FolderLine.Next() = 0;

        TempVendor.FindSet();
        repeat
            CreateChargeOrderForVendor(TransitFolder, TempVendor."No.", PurchHeader);
            TempCreatedHeader := PurchHeader;
            TempCreatedHeader.Insert();
            AddToList(CreatedList, PurchHeader."No.");
        until TempVendor.Next() = 0;

        TransitFolder.Status := TransitFolder.Status::"Charges Created";
        TransitFolder.Modify();
        Commit();

        // Standard receipt posting of the charge orders
        if PostReceipt then begin
            TempCreatedHeader.FindSet();
            repeat
                PostChargeOrderReceipt(TempCreatedHeader."No.", ErrorList);
            until TempCreatedHeader.Next() = 0;
        end;

        if GuiAllowed() then
            if ErrorList = '' then
                Message(ChargesCreatedMsg, TransitFolder."No.", CreatedList)
            else
                Message(ChargesCreatedMsg + PostErrorsMsg, TransitFolder."No.", CreatedList, ErrorList);
    end;

    // ---------------------------------------------------------------
    // Post the receipt of the charge orders already created and not
    // completely received yet
    // ---------------------------------------------------------------
    procedure PostChargeReceipts(var TransitFolder: Record "NAV Transit Folder")
    var
        FolderLine: Record "NAV Transit Folder Line";
        PurchHeader: Record "Purchase Header";
        OrderList: Text;
        StatusList: Text;
        PostedList: Text;
        ErrorList: Text;
        OrderNo: Text;
    begin
        TransitFolder.Get(TransitFolder."No.");

        // Charge orders referenced by the folder lines
        FolderLine.SetRange("Folder No.", TransitFolder."No.");
        FolderLine.SetFilter("Charge Order No.", '<>%1', '');
        if FolderLine.FindSet() then
            repeat
                if StrPos(', ' + OrderList + ', ', ', ' + FolderLine."Charge Order No." + ', ') = 0 then
                    AddToList(OrderList, FolderLine."Charge Order No.");
            until FolderLine.Next() = 0;
        // Charge orders linked to the folder by their header
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("Charge Folder No.", TransitFolder."No.");
        if PurchHeader.FindSet() then
            repeat
                if StrPos(', ' + OrderList + ', ', ', ' + PurchHeader."No." + ', ') = 0 then
                    AddToList(OrderList, PurchHeader."No.");
            until PurchHeader.Next() = 0;

        if OrderList = '' then
            Error(NoChargeOrderErr, TransitFolder."No.");

        foreach OrderNo in OrderList.Split(', ') do
            case GetChargeOrderState(CopyStr(OrderNo, 1, 20)) of
                ChargeOrderState::ToReceive:
                    if PostChargeOrderReceipt(CopyStr(OrderNo, 1, 20), ErrorList) then
                        AddToList(PostedList, OrderNo);
                ChargeOrderState::Received:
                    AddToList(StatusList, StrSubstNo(StateReceivedTxt, OrderNo));
                ChargeOrderState::Invoiced:
                    AddToList(StatusList, StrSubstNo(StateInvoicedTxt, OrderNo));
                ChargeOrderState::NotFound:
                    AddToList(StatusList, StrSubstNo(StateNotFoundTxt, OrderNo));
            end;

        if (PostedList = '') and (ErrorList = '') then
            Error(NothingToReceiveErr, TransitFolder."No.", StatusList);

        if GuiAllowed() then
            if ErrorList = '' then
                Message(ChargeReceiptsPostedMsg, TransitFolder."No.", PostedList)
            else
                Message(ChargeReceiptsPostedMsg + PostErrorsMsg, TransitFolder."No.", PostedList, ErrorList);
    end;

    local procedure GetChargeOrderState(ChargeOrderNo: Code[20]): Option ToReceive,Received,Invoiced,NotFound
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        if PurchHeader.Get(PurchHeader."Document Type"::Order, ChargeOrderNo) then begin
            PurchLine.SetRange("Document Type", PurchHeader."Document Type");
            PurchLine.SetRange("Document No.", PurchHeader."No.");
            PurchLine.SetRange(Type, PurchLine.Type::"Charge (Item)");
            PurchLine.SetFilter("Outstanding Quantity", '<>0');
            if not PurchLine.IsEmpty() then
                exit(ChargeOrderState::ToReceive);
            exit(ChargeOrderState::Received);
        end;
        PurchRcptLine.SetRange("Order No.", ChargeOrderNo);
        if not PurchRcptLine.IsEmpty() then
            exit(ChargeOrderState::Invoiced);
        exit(ChargeOrderState::NotFound);
    end;

    local procedure PostChargeOrderReceipt(ChargeOrderNo: Code[20]; var ErrorList: Text): Boolean
    var
        PurchHeader: Record "Purchase Header";
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        PostErrorText: Text;
    begin
        Commit();
        PurchHeader.Get(PurchHeader."Document Type"::Order, ChargeOrderNo);
        PurchHeader.Receive := true;
        PurchHeader.Invoice := false;

        // The standard posting logs its errors in the Error Message framework and
        // ends with an empty error: activate a handler to get the real messages.
        ErrorMessageMgt.Activate(ErrorMessageHandler);
        if Codeunit.Run(Codeunit::"Purch.-Post", PurchHeader) then
            exit(true);

        // The posting commits before its final steps: if an error is raised after
        // the commit, the receipt is posted anyway. Check the real state of the order.
        if GetChargeOrderState(ChargeOrderNo) <> ChargeOrderState::ToReceive then
            exit(true);

        PostErrorText := GetLastErrorText();
        if PostErrorText = '' then
            PostErrorText := SeeErrorMessagesTxt;
        ErrorList += StrSubstNo('%1: %2\', ChargeOrderNo, PostErrorText);
        if GuiAllowed() and ErrorMessageHandler.HasErrors() then
            ErrorMessageHandler.ShowErrors();
        exit(false);
    end;

    // A charge order deleted before any posting frees its folder lines
    local procedure ReleaseDeletedChargeOrders(FolderNo: Code[20])
    var
        FolderLine: Record "NAV Transit Folder Line";
        PurchHeader: Record "Purchase Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        FolderLine.SetRange("Folder No.", FolderNo);
        FolderLine.SetFilter("Charge Order No.", '<>%1', '');
        if FolderLine.FindSet(true) then
            repeat
                if not PurchHeader.Get(PurchHeader."Document Type"::Order, FolderLine."Charge Order No.") then begin
                    PurchRcptLine.SetRange("Order No.", FolderLine."Charge Order No.");
                    PurchInvLine.SetRange("Order No.", FolderLine."Charge Order No.");
                    if PurchRcptLine.IsEmpty() and PurchInvLine.IsEmpty() then begin
                        FolderLine."Charge Order No." := '';
                        FolderLine."Charge Order Line No." := 0;
                        FolderLine.Modify();
                    end;
                end;
            until FolderLine.Next() = 0;
    end;

    local procedure ChargeOrdersExistError(FolderNo: Code[20])
    var
        FolderLine: Record "NAV Transit Folder Line";
        OrderList: Text;
    begin
        FolderLine.SetRange("Folder No.", FolderNo);
        FolderLine.SetFilter("Charge Order No.", '<>%1', '');
        if FolderLine.FindSet() then begin
            repeat
                if StrPos(', ' + OrderList + ', ', ', ' + FolderLine."Charge Order No." + ', ') = 0 then
                    AddToList(OrderList, FolderLine."Charge Order No.");
            until FolderLine.Next() = 0;
            Commit(); // keep the status update
            Error(AlreadyCreatedErr, FolderNo, OrderList);
        end;
        Error(NoChargeLineErr, FolderNo);
    end;

    local procedure AddToList(var List: Text; Value: Text)
    begin
        if List <> '' then
            List += ', ';
        List += Value;
    end;


    procedure AllOrdersFullyReceived(FolderNo: Code[20]): Boolean
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("Transit Folder No.", FolderNo);
        if PurchHeader.FindSet() then
            repeat
                PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                PurchLine.SetRange("Document No.", PurchHeader."No.");
                PurchLine.SetRange(Type, PurchLine.Type::Item);
                PurchLine.SetFilter("Outstanding Quantity", '<>0');
                if not PurchLine.IsEmpty() then
                    exit(false);
            until PurchHeader.Next() = 0;
        exit(HasReceipts(FolderNo));
    end;

    procedure HasLinkedOrders(FolderNo: Code[20]): Boolean
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("Transit Folder No.", FolderNo);
        exit(not PurchHeader.IsEmpty());
    end;

    procedure HasReceipts(FolderNo: Code[20]): Boolean
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        exit(FindReceiptLines(PurchRcptLine, FolderNo));
    end;

    // Goods receipt lines of the folder (all orders, all receipts).
    // A line is taken when the line OR its receipt header carries the folder,
    // so receipts posted before the line field was filled are also found.
    procedure FindReceiptLines(var PurchRcptLine: Record "Purch. Rcpt. Line"; FolderNo: Code[20]): Boolean
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        PurchRcptLine.Reset();
        PurchRcptLine.ClearMarks();

        // 1. Lines carrying the folder
        PurchRcptLine.SetCurrentKey("Transit Folder No.");
        PurchRcptLine.SetRange("Transit Folder No.", FolderNo);
        if PurchRcptLine.FindSet() then
            repeat
                PurchRcptLine.Mark(true);
            until PurchRcptLine.Next() = 0;
        PurchRcptLine.SetRange("Transit Folder No.");

        // 2. Lines of receipt headers carrying the folder
        PurchRcptLine.SetCurrentKey("Document No.", "Line No.");
        PurchRcptHeader.SetCurrentKey("Transit Folder No.");
        PurchRcptHeader.SetRange("Transit Folder No.", FolderNo);
        if PurchRcptHeader.FindSet() then
            repeat
                PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
                if PurchRcptLine.FindSet() then
                    repeat
                        PurchRcptLine.Mark(true);
                    until PurchRcptLine.Next() = 0;
            until PurchRcptHeader.Next() = 0;
        PurchRcptLine.SetRange("Document No.");

        // 3. Keep goods lines only
        PurchRcptLine.SetRange(Type, PurchRcptLine.Type::Item);
        PurchRcptLine.SetFilter(Quantity, '>0');
        PurchRcptLine.SetRange(Correction, false);
        PurchRcptLine.MarkedOnly(true);
        exit(PurchRcptLine.FindFirst());
    end;

    // A purchase order in foreign currency (foreign vendor) must be linked to a transit folder.
    // Charge orders generated by a folder are not concerned.
    procedure IsTransitFolderRequired(PurchHeader: Record "Purchase Header"): Boolean
    begin
        exit(
            (PurchHeader."Document Type" = PurchHeader."Document Type"::Order) and
            (PurchHeader."Currency Code" <> '') and
            (PurchHeader."Charge Folder No." = ''));
    end;

    procedure CheckTransitFolderRequired(PurchHeader: Record "Purchase Header")
    begin
        if not IsTransitFolderRequired(PurchHeader) then
            exit;
        if PurchHeader."Transit Folder No." = '' then
            Error(TransitFolderRequiredErr, PurchHeader."No.", PurchHeader."Currency Code");
    end;

    // Fills the folder on document lines that do not carry it yet
    procedure SyncFolderOnLines(PurchHeader: Record "Purchase Header")
    var
        PurchLine: Record "Purchase Line";
    begin
        if PurchHeader."Transit Folder No." = '' then
            exit;
        PurchLine.SetRange("Document Type", PurchHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchHeader."No.");
        PurchLine.SetRange("Transit Folder No.", '');
        if not PurchLine.IsEmpty() then
            PurchLine.ModifyAll("Transit Folder No.", PurchHeader."Transit Folder No.");
    end;

    // ---------------------------------------------------------------
    // Landed cost simulation per item
    // ---------------------------------------------------------------
    procedure SimulateLandedCost(var TransitFolder: Record "NAV Transit Folder")
    var
        ItemLine: Record "NAV Transit Folder Item Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        CurrExchRate: Record "Currency Exchange Rate";
        LineAmountLCY: Decimal;
        TotalBase: Decimal;
        TotalCharges: Decimal;
        Allocated: Decimal;
        LineNo: Integer;
        RemainingLines: Integer;
    begin
        if TransitFolder.Status = TransitFolder.Status::Open then
            RecalculateAmounts(TransitFolder);

        ItemLine.SetRange("Folder No.", TransitFolder."No.");
        ItemLine.DeleteAll();

        // 1. Item lines of the orders still open (a folder can have several orders)
        PurchLine.SetCurrentKey("Transit Folder No.");
        PurchLine.SetRange("Transit Folder No.", TransitFolder."No.");
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetFilter(Quantity, '<>0');
        if PurchLine.FindSet() then
            repeat
                if (PurchHeader."Document Type" <> PurchLine."Document Type") or (PurchHeader."No." <> PurchLine."Document No.") then
                    PurchHeader.Get(PurchLine."Document Type", PurchLine."Document No.");
                if PurchHeader."Charge Folder No." = '' then begin // skip charge orders
                    LineAmountLCY := PurchLine.Amount;
                    if PurchHeader."Currency Code" <> '' then
                        LineAmountLCY := CurrExchRate.ExchangeAmtFCYToLCY(
                            PurchHeader."Posting Date", PurchHeader."Currency Code", LineAmountLCY, PurchHeader."Currency Factor");
                    InsertItemLine(ItemLine, LineNo, TransitFolder."No.", ItemLine.Source::"Order",
                        PurchLine."Document No.", PurchLine."Line No.", PurchLine."No.", PurchLine."Variant Code",
                        PurchLine.Description, PurchLine.Quantity, PurchLine."Unit of Measure Code", LineAmountLCY);
                end;
            until PurchLine.Next() = 0;

        // 2. Receipts of completed orders (order deleted after invoicing)
        if FindReceiptLines(PurchRcptLine, TransitFolder."No.") then
            repeat
                if not PurchHeader.Get(PurchHeader."Document Type"::Order, PurchRcptLine."Order No.") then
                    InsertItemLine(ItemLine, LineNo, TransitFolder."No.", ItemLine.Source::Receipt,
                        PurchRcptLine."Document No.", PurchRcptLine."Line No.", PurchRcptLine."No.", PurchRcptLine."Variant Code",
                        PurchRcptLine.Description, PurchRcptLine.Quantity, PurchRcptLine."Unit of Measure Code",
                        GetRcptLineBaseLCY(PurchRcptLine."Document No.", PurchRcptLine."Line No."));
            until PurchRcptLine.Next() = 0;

        // 3. Allocate the folder charges in proportion to the amount excl. VAT
        TransitFolder.CalcFields("Total Charges (LCY)");
        TotalCharges := TransitFolder."Total Charges (LCY)";
        ItemLine.Reset();
        ItemLine.SetRange("Folder No.", TransitFolder."No.");
        ItemLine.CalcSums("Line Amount (LCY)");
        TotalBase := ItemLine."Line Amount (LCY)";

        RemainingLines := ItemLine.Count();
        if ItemLine.FindSet(true) then
            repeat
                RemainingLines -= 1;
                if TotalBase <> 0 then begin
                    ItemLine."Allocation %" := Round(ItemLine."Line Amount (LCY)" / TotalBase * 100, 0.00001);
                    if RemainingLines = 0 then
                        ItemLine."Charges Amount (LCY)" := TotalCharges - Allocated
                    else
                        ItemLine."Charges Amount (LCY)" := Round(TotalCharges * ItemLine."Line Amount (LCY)" / TotalBase);
                end;
                Allocated += ItemLine."Charges Amount (LCY)";
                ItemLine.UpdateCosts();
                ItemLine.Modify();
            until ItemLine.Next() = 0;

        if GuiAllowed() then
            if LineNo = 0 then
                Message(NoItemLineMsg, TransitFolder."No.");
    end;

    local procedure InsertItemLine(var ItemLine: Record "NAV Transit Folder Item Line"; var LineNo: Integer; FolderNo: Code[20]; SourceType: Option; DocNo: Code[20]; DocLineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; ItemDescription: Text[100]; Qty: Decimal; UoMCode: Code[10]; LineAmountLCY: Decimal)
    begin
        LineNo += 10000;
        ItemLine.Init();
        ItemLine."Folder No." := FolderNo;
        ItemLine."Line No." := LineNo;
        ItemLine.Source := SourceType;
        ItemLine."Document No." := DocNo;
        ItemLine."Document Line No." := DocLineNo;
        ItemLine."No." := ItemNo;
        ItemLine."Variant Code" := VariantCode;
        ItemLine.Description := ItemDescription;
        ItemLine.Quantity := Qty;
        ItemLine."Unit of Measure Code" := UoMCode;
        ItemLine."Line Amount (LCY)" := Round(LineAmountLCY);
        ItemLine.UpdateCosts();
        ItemLine.Insert();
    end;

    // ---------------------------------------------------------------
    // Internal
    // ---------------------------------------------------------------
    local procedure GetOrdersBaseAmountLCY(FolderNo: Code[20]): Decimal
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        CurrExchRate: Record "Currency Exchange Rate";
        OrderAmount: Decimal;
        Total: Decimal;
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("Transit Folder No.", FolderNo);
        if PurchHeader.FindSet() then
            repeat
                PurchLine.SetRange("Document Type", PurchHeader."Document Type");
                PurchLine.SetRange("Document No.", PurchHeader."No.");
                PurchLine.SetFilter(Type, '<>%1', PurchLine.Type::"Charge (Item)");
                PurchLine.CalcSums(Amount); // Amount = excl. VAT, after discounts
                OrderAmount := PurchLine.Amount;
                if PurchHeader."Currency Code" <> '' then
                    OrderAmount := CurrExchRate.ExchangeAmtFCYToLCY(
                        PurchHeader."Posting Date", PurchHeader."Currency Code", OrderAmount, PurchHeader."Currency Factor");
                Total += OrderAmount;
            until PurchHeader.Next() = 0;
        exit(Round(Total));
    end;

    local procedure CreateChargeOrderForVendor(TransitFolder: Record "NAV Transit Folder"; VendorNo: Code[20]; var PurchHeader: Record "Purchase Header")
    var
        FolderLine: Record "NAV Transit Folder Line";
        PurchLine: Record "Purchase Line";
        LineNo: Integer;
    begin
        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::Order;
        PurchHeader."No." := '';
        PurchHeader.Insert(true);
        PurchHeader.Validate("Buy-from Vendor No.", VendorNo);
        PurchHeader."Charge Folder No." := TransitFolder."No.";
        PurchHeader."Your Reference" := TransitFolder."No.";
        PurchHeader.Modify(true);

        FolderLine.SetRange("Folder No.", TransitFolder."No.");
        FolderLine.SetRange("Vendor No.", VendorNo);
        FolderLine.SetRange("Charge Order No.", '');
        FolderLine.SetFilter(Amount, '<>0');
        if FolderLine.FindSet(true) then
            repeat
                LineNo += 10000;
                PurchLine.Init();
                PurchLine."Document Type" := PurchHeader."Document Type";
                PurchLine."Document No." := PurchHeader."No.";
                PurchLine."Line No." := LineNo;
                PurchLine.Validate(Type, PurchLine.Type::"Charge (Item)");
                PurchLine.Validate("No.", FolderLine."Item Charge No.");
                PurchLine.Description := FolderLine.Description;
                PurchLine.Validate(Quantity, 1);
                PurchLine.Validate("Direct Unit Cost", ConvertLCYToDocCurrency(FolderLine.Amount, PurchHeader));
                // Set after the validations (Validate(Type) re-initializes the line)
                PurchLine."Transit Folder No." := TransitFolder."No.";
                PurchLine."Transit Folder Line No." := FolderLine."Line No.";
                PurchLine.Insert(true);

                AssignChargeToReceipts(PurchLine, TransitFolder."No.");

                FolderLine."Charge Order No." := PurchHeader."No.";
                FolderLine."Charge Order Line No." := PurchLine."Line No.";
                FolderLine.Modify();
            until FolderLine.Next() = 0;
    end;

    // Assignment of the charge line to the receipt lines of the folder, written
    // in the standard Item Charge Assignment (Purch) table and allocated in
    // proportion to each receipt line amount (same result as "Suggest" > "By Amount").
    local procedure AssignChargeToReceipts(PurchLine: Record "Purchase Line"; FolderNo: Code[20])
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ItemChargeAssgnt: Record "Item Charge Assignment (Purch)";
        TotalBase: Decimal;
        LineBase: Decimal;
        QtyToAssign: Decimal;
        QtyAssigned: Decimal;
        RemainingLines: Integer;
        NextLineNo: Integer;
    begin
        // 1. All goods receipt lines linked to the folder (several orders / receipts)
        if not FindReceiptLines(PurchRcptLine, FolderNo) then
            exit;
        repeat
            TotalBase += GetRcptLineBaseLCY(PurchRcptLine."Document No.", PurchRcptLine."Line No.");
            RemainingLines += 1;
        until PurchRcptLine.Next() = 0;
        if TotalBase = 0 then
            exit;

        // 2. Next free line number on this charge line
        ItemChargeAssgnt.SetRange("Document Type", PurchLine."Document Type");
        ItemChargeAssgnt.SetRange("Document No.", PurchLine."Document No.");
        ItemChargeAssgnt.SetRange("Document Line No.", PurchLine."Line No.");
        if ItemChargeAssgnt.FindLast() then
            NextLineNo := ItemChargeAssgnt."Line No.";

        // 3. One assignment line per receipt line, quantity prorated on the amount
        PurchRcptLine.FindSet();
        repeat
            RemainingLines -= 1;
            LineBase := GetRcptLineBaseLCY(PurchRcptLine."Document No.", PurchRcptLine."Line No.");
            if RemainingLines = 0 then
                QtyToAssign := PurchLine.Quantity - QtyAssigned // rounding remainder on the last line
            else
                QtyToAssign := Round(PurchLine.Quantity * LineBase / TotalBase, 0.00001);

            NextLineNo += 10000;
            ItemChargeAssgnt.Init();
            ItemChargeAssgnt."Document Type" := PurchLine."Document Type";
            ItemChargeAssgnt."Document No." := PurchLine."Document No.";
            ItemChargeAssgnt."Document Line No." := PurchLine."Line No.";
            ItemChargeAssgnt."Line No." := NextLineNo;
            ItemChargeAssgnt."Item Charge No." := PurchLine."No.";
            ItemChargeAssgnt."Applies-to Doc. Type" := ItemChargeAssgnt."Applies-to Doc. Type"::Receipt;
            ItemChargeAssgnt."Applies-to Doc. No." := PurchRcptLine."Document No.";
            ItemChargeAssgnt."Applies-to Doc. Line No." := PurchRcptLine."Line No.";
            ItemChargeAssgnt."Item No." := PurchRcptLine."No.";
            ItemChargeAssgnt.Description := PurchRcptLine.Description;
            ItemChargeAssgnt."Unit Cost" := PurchLine."Unit Cost";
            ItemChargeAssgnt.Insert(true);

            ItemChargeAssgnt.Validate("Qty. to Assign", QtyToAssign);
            ItemChargeAssgnt.Modify(true);
            QtyAssigned += QtyToAssign;
        until PurchRcptLine.Next() = 0;
    end;

    procedure GetRcptLineBaseLCY(RcptNo: Code[20]; RcptLineNo: Integer): Decimal
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        LineAmount: Decimal;
    begin
        if not PurchRcptLine.Get(RcptNo, RcptLineNo) then
            exit(0);
        LineAmount := PurchRcptLine.Quantity * PurchRcptLine."Direct Unit Cost" * (1 - PurchRcptLine."Line Discount %" / 100);
        PurchRcptHeader.Get(RcptNo);
        if PurchRcptHeader."Currency Factor" <> 0 then
            LineAmount := LineAmount / PurchRcptHeader."Currency Factor";
        exit(LineAmount);
    end;

    local procedure ConvertLCYToDocCurrency(AmountLCY: Decimal; PurchHeader: Record "Purchase Header"): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if PurchHeader."Currency Code" = '' then
            exit(AmountLCY);
        exit(Round(CurrExchRate.ExchangeAmtLCYToFCY(
            PurchHeader."Posting Date", PurchHeader."Currency Code", AmountLCY, PurchHeader."Currency Factor")));
    end;

    var
        TransitFolderRequiredErr: Label 'Purchase order %1 is in foreign currency (%2). You must specify the Transit Folder No. before you release or post the order.', Comment = '%1 = Order No., %2 = Currency Code';
        StatusChargesCreatedErr: Label 'Transit folder %1 cannot be changed because its charge orders have already been created.', Comment = '%1 = Folder No.';
        AlreadyCreatedErr: Label 'The charges of transit folder %1 have already been created in charge order(s) %2. Use the Post Charge Receipts action to receive them, or open the charge orders.', Comment = '%1 = Folder No., %2 = charge order list';
        NoOrderErr: Label 'No purchase order is linked to transit folder %1.', Comment = '%1 = Folder No.';
        NoReceiptErr: Label 'There is no posted receipt for transit folder %1. Charges can only be assigned to received lines.', Comment = '%1 = Folder No.';
        NoChargeLineErr: Label 'Transit folder %1 has no charge line to process (non-zero amount and no charge order).', Comment = '%1 = Folder No.';
        ChargesCreatedMsg: Label 'Charge orders created for transit folder %1: %2', Comment = '%1 = Folder No., %2 = order list';
        NoItemLineMsg: Label 'No item lines were found for transit folder %1 (orders or receipts).', Comment = '%1 = Folder No.';
        ChargeReceiptsPostedMsg: Label 'Receipts posted for the charge orders of transit folder %1: %2', Comment = '%1 = Folder No., %2 = order list';
        NothingToReceiveErr: Label 'Transit folder %1 has no charge order left to receive: %2', Comment = '%1 = Folder No., %2 = state of each charge order';
        NoChargeOrderErr: Label 'Transit folder %1 has no charge order. Use the Create Charge Orders action first.', Comment = '%1 = Folder No.';
        StateReceivedTxt: Label 'order %1 is already completely received (to be invoiced)', Comment = '%1 = Charge order No.';
        StateInvoicedTxt: Label 'order %1 is already received and invoiced', Comment = '%1 = Charge order No.';
        StateNotFoundTxt: Label 'order %1 was not found', Comment = '%1 = Charge order No.';
        ChargeOrderState: Option ToReceive,Received,Invoiced,NotFound;
        SeeErrorMessagesTxt: Label 'The receipt was not posted. Open the charge order and post the receipt manually to see the details.';
        PostErrorsMsg: Label '\\Errors while posting the receipt:\%3', Comment = '%3 = error list';
}
