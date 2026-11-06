codeunit 50270 "NAV Damage Transfer-Post"
{
    // Posts a damage transfer as a bin-to-bin movement inside the location
    // (warehouse movement registered through the standard Whse. Jnl.-Register Line):
    // the quantity leaves the source bin and enters the damaged bin, with its batch,
    // expiry date and the damage reason code on the warehouse entries.
    // The document is then moved to the posted damage transfers.

    TableNo = "NAV Damage Transfer Header";
    Permissions = tabledata "NAV Posted Damage Transfer" = RI,
                  tabledata "NAV Posted Damage Trf. Line" = RI;

    trigger OnRun()
    begin
        Post(Rec);
    end;

    procedure Post(var DamageHeader: Record "NAV Damage Transfer Header")
    var
        DamageLine: Record "NAV Damage Transfer Line";
        PostedHeader: Record "NAV Posted Damage Transfer";
        PostedLine: Record "NAV Posted Damage Trf. Line";
        Location: Record Location;
        FromBin: Record Bin;
        ToBin: Record Bin;
    begin
        CheckHeader(DamageHeader);
        Location.Get(DamageHeader."Location Code");
        Location.TestField("Bin Mandatory");

        DamageLine.SetRange("Document No.", DamageHeader."No.");
        DamageLine.SetFilter(Quantity, '<>0');
        if not DamageLine.FindSet() then
            Error(NoLinesErr, DamageHeader."No.");
        repeat
            CheckLine(DamageLine, Location);
        until DamageLine.Next() = 0;

        // Posted header
        PostedHeader.Init();
        PostedHeader.TransferFields(DamageHeader);
        PostedHeader."Registering Date" := WorkDate();
        PostedHeader."Posted By" := CopyStr(UserId(), 1, MaxStrLen(PostedHeader."Posted By"));
        PostedHeader."Posted At" := CurrentDateTime();
        PostedHeader.Insert();

        DamageLine.FindSet();
        repeat
            FromBin.Get(DamageLine."Location Code", DamageLine."From Bin Code");
            ToBin.Get(DamageLine."Location Code", DamageLine."To Bin Code");
            RegisterMovement(DamageHeader, DamageLine, FromBin, ToBin);

            PostedLine.Init();
            PostedLine.TransferFields(DamageLine);
            PostedLine."From Zone Code" := FromBin."Zone Code";
            PostedLine."To Zone Code" := ToBin."Zone Code";
            PostedLine.Insert();
        until DamageLine.Next() = 0;

        DamageHeader.Delete(true);
    end;

    local procedure CheckHeader(DamageHeader: Record "NAV Damage Transfer Header")
    begin
        DamageHeader.TestField("Location Code");
        DamageHeader.TestField("Damage Date");
        DamageHeader.TestField("Reason Code");
        DamageHeader.TestField("Responsible User ID");
    end;

    local procedure CheckLine(DamageLine: Record "NAV Damage Transfer Line"; Location: Record Location)
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        BinContent: Record "Bin Content";
    begin
        DamageLine.TestField("Item No.");
        DamageLine.TestField("From Bin Code");
        DamageLine.TestField("To Bin Code");
        if Location.IsDamagedBin(DamageLine."From Bin Code") then
            DamageLine.FieldError("From Bin Code");
        if not Location.IsDamagedBin(DamageLine."To Bin Code") then
            DamageLine.FieldError("To Bin Code");

        // Batch mandatory for batch items
        Item.Get(DamageLine."Item No.");
        if Item."Item Tracking Code" <> '' then
            if ItemTrackingCode.Get(Item."Item Tracking Code") then
                if ItemTrackingCode."Lot Warehouse Tracking" then
                    DamageLine.TestField("Lot No.");

        // Quantity available in the source bin (for this batch)
        BinContent.SetRange("Location Code", DamageLine."Location Code");
        BinContent.SetRange("Bin Code", DamageLine."From Bin Code");
        BinContent.SetRange("Item No.", DamageLine."Item No.");
        BinContent.SetRange("Variant Code", DamageLine."Variant Code");
        BinContent.SetRange("Unit of Measure Code", DamageLine."Unit of Measure Code");
        if DamageLine."Lot No." <> '' then
            BinContent.SetRange("Lot No. Filter", DamageLine."Lot No.");
        if not BinContent.FindFirst() then
            Error(NotInBinErr, DamageLine."Item No.", DamageLine."From Bin Code");
        BinContent.CalcFields("Quantity (Base)");
        if BinContent."Quantity (Base)" < DamageLine."Quantity (Base)" then
            Error(NotEnoughErr, DamageLine."Item No.", DamageLine."Lot No.", DamageLine."From Bin Code",
                BinContent."Quantity (Base)", DamageLine."Quantity (Base)");
    end;

    local procedure RegisterMovement(DamageHeader: Record "NAV Damage Transfer Header"; DamageLine: Record "NAV Damage Transfer Line"; FromBin: Record Bin; ToBin: Record Bin)
    var
        WhseJnlLine: Record "Warehouse Journal Line";
        WhseJnlRegisterLine: Codeunit "Whse. Jnl.-Register Line";
    begin
        WhseJnlLine.Init();
        WhseJnlLine."Location Code" := DamageLine."Location Code";
        WhseJnlLine."Registering Date" := WorkDate();
        WhseJnlLine."Entry Type" := WhseJnlLine."Entry Type"::Movement;
        WhseJnlLine."Whse. Document Type" := WhseJnlLine."Whse. Document Type"::"Whse. Journal";
        WhseJnlLine."Whse. Document No." := DamageHeader."No.";
        WhseJnlLine."Whse. Document Line No." := DamageLine."Line No.";
        WhseJnlLine."Item No." := DamageLine."Item No.";
        WhseJnlLine."Variant Code" := DamageLine."Variant Code";
        WhseJnlLine.Description := DamageLine.Description;
        WhseJnlLine."Unit of Measure Code" := DamageLine."Unit of Measure Code";
        WhseJnlLine."Qty. per Unit of Measure" := DamageLine."Qty. per Unit of Measure";
        WhseJnlLine."Qty. (Absolute)" := DamageLine.Quantity;
        WhseJnlLine."Qty. (Absolute, Base)" := DamageLine."Quantity (Base)";
        WhseJnlLine."From Zone Code" := FromBin."Zone Code";
        WhseJnlLine."From Bin Code" := FromBin.Code;
        WhseJnlLine."From Bin Type Code" := FromBin."Bin Type Code";
        WhseJnlLine."To Zone Code" := ToBin."Zone Code";
        WhseJnlLine."To Bin Code" := ToBin.Code;
        WhseJnlLine."Lot No." := DamageLine."Lot No.";
        WhseJnlLine."New Lot No." := DamageLine."Lot No.";
        WhseJnlLine."Expiration Date" := DamageLine."Expiration Date";
        WhseJnlLine."New Expiration Date" := DamageLine."Expiration Date";
        WhseJnlLine."Reason Code" := DamageHeader."Reason Code";
        WhseJnlLine."Reference No." := DamageHeader."Related Document No.";
        WhseJnlLine."User ID" := CopyStr(UserId(), 1, MaxStrLen(WhseJnlLine."User ID"));
        WhseJnlRegisterLine.Run(WhseJnlLine);
    end;

    var
        NoLinesErr: Label 'Damage transfer %1 has no line to post.', Comment = '%1 = Document No.';
        NotInBinErr: Label 'Item %1 is not stored in bin %2.', Comment = '%1 = Item No., %2 = Bin Code';
        NotEnoughErr: Label 'Not enough stock of item %1 (batch %2) in bin %3: available %4, damaged quantity %5.', Comment = '%1 = Item No., %2 = Lot No., %3 = Bin Code, %4 = Available, %5 = Quantity';
}

codeunit 50271 "NAV Damaged Bin Control"
{
    // Stock in damaged bins can only be taken out (pick, movement, adjustment,
    // reclassification, return) by a Damaged Stock Approver (User Setup).
    // Every warehouse posting goes through Whse. Jnl.-Register Line, so this is
    // the single control point.

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Whse. Jnl.-Register Line", 'OnBeforeInsertWhseEntry', '', false, false)]
    local procedure CheckDamagedBinOnBeforeInsertWhseEntry(var WarehouseEntry: Record "Warehouse Entry")
    var
        Location: Record Location;
        UserSetup: Record "User Setup";
    begin
        if WarehouseEntry."Qty. (Base)" >= 0 then
            exit; // entering a bin is always allowed
        if not Location.Get(WarehouseEntry."Location Code") then
            exit;
        if not Location.IsDamagedBin(WarehouseEntry."Bin Code") then
            exit;
        if UserSetup.Get(UserId()) then
            if UserSetup."Damaged Stock Approver" then
                exit;
        Error(NotApproverErr, WarehouseEntry."Item No.", WarehouseEntry."Bin Code", WarehouseEntry."Location Code");
    end;

    var
        NotApproverErr: Label 'Item %1 is in damaged bin %2 of location %3. Only a Damaged Stock Approver (User Setup) can take stock out of a damaged bin.', Comment = '%1 = Item No., %2 = Bin Code, %3 = Location Code';
}
