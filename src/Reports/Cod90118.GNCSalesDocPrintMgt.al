// 1.0.0.42 – Fonctions communes aux documents de vente imprimés GNC (facture fiscale 90113,
// bon de commande 90115, avoir 90116) : QR code ZATCA, lots d'une ligne, pays, dates.
codeunit 90118 "GNC Sales Doc. Print Mgt."
{
    var
        LotLineTxt: Label 'Manufacturer Batch#: %1', Comment = '%1 = lot no.';
        MfgDateTxt: Label 'Manufactured Date: %1', Comment = '%1 = manufacturing date';
        ExpDateTxt: Label 'Expiry Date: %1', Comment = '%1 = expiry date';
        LotQtyTxt: Label 'Qty: %1', Comment = '%1 = quantity of the lot';

    // QR code ZATCA (phase 1) en image PNG encodée en Base64 : 5 champs TLV (vendeur, n° TVA,
    // date-heure, total TTC, total TVA), le tout en Base64, puis dessiné par BC (Dynamics 2D).
    procedure GetQRCodeImage(PostingDate: Date; CreatedAt: DateTime; TotalInclVAT: Decimal; VATAmount: Decimal): Text
    var
        CompanyInfo: Record "Company Information";
        TempBlob: Codeunit "Temp Blob";
        QRBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        BarcodeImageProvider2D: Interface "Barcode Image Provider 2D";
        OutStr: OutStream;
        InStr: InStream;
        QRInStr: InStream;
        InvoiceDateTime: DateTime;
    begin
        CompanyInfo.Get();
        InvoiceDateTime := CreateDateTime(PostingDate, DT2Time(CreatedAt));
        TempBlob.CreateOutStream(OutStr);
        WriteTLV(OutStr, 1, CompanyInfo.Name);
        WriteTLV(OutStr, 2, CompanyInfo."VAT Registration No.");
        WriteTLV(OutStr, 3, Format(InvoiceDateTime, 0, '<Year4>-<Month,2>-<Day,2>T<Hours24,2>:<Minutes,2>:<Seconds,2>Z'));
        WriteTLV(OutStr, 4, FormatAmount(TotalInclVAT));
        WriteTLV(OutStr, 5, FormatAmount(VATAmount));
        TempBlob.CreateInStream(InStr);
        BarcodeImageProvider2D := Enum::"Barcode Image Provider 2D"::Dynamics2D;
        QRBlob := BarcodeImageProvider2D.EncodeImage(Base64Convert.ToBase64(InStr), Enum::"Barcode Symbology 2D"::"QR-Code");
        QRBlob.CreateInStream(QRInStr);
        exit(Base64Convert.ToBase64(QRInStr));
    end;

    // Lots d'une ligne de document enregistré (facture ou avoir) : écritures valeur du document
    // -> écritures article. Un même lot livré en plusieurs fois est regroupé sur une seule ligne.
    procedure GetLotText(DocumentType: Enum "Item Ledger Document Type"; DocumentNo: Code[20]; DocumentLineNo: Integer): Text
    var
        ValueEntry: Record "Value Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
        Entries: List of [Integer];
        LotKeys: List of [Text];
        LotNos: Dictionary of [Text, Code[50]];
        LotQty: Dictionary of [Text, Decimal];
        LotExp: Dictionary of [Text, Date];
        LotMfg: Dictionary of [Text, Date];
        EntryNo: Integer;
        LotKey: Text;
        Result: Text;
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", DocumentNo);
        ValueEntry.SetRange("Document Type", DocumentType);
        ValueEntry.SetRange("Document Line No.", DocumentLineNo);
        ValueEntry.SetFilter("Item Ledger Entry No.", '<>0');
        if ValueEntry.FindSet() then
            repeat
                if not Entries.Contains(ValueEntry."Item Ledger Entry No.") then
                    Entries.Add(ValueEntry."Item Ledger Entry No.");
            until ValueEntry.Next() = 0;

        foreach EntryNo in Entries do
            if ItemLedgEntry.Get(EntryNo) and (ItemLedgEntry."Lot No." <> '') then begin
                LotKey := ItemLedgEntry."Lot No." + '|' + Format(ItemLedgEntry."Expiration Date", 0, 9);
                if LotKeys.Contains(LotKey) then
                    LotQty.Set(LotKey, LotQty.Get(LotKey) + Abs(ItemLedgEntry.Quantity))
                else begin
                    LotKeys.Add(LotKey);
                    LotNos.Add(LotKey, ItemLedgEntry."Lot No.");
                    LotQty.Add(LotKey, Abs(ItemLedgEntry.Quantity));
                    LotExp.Add(LotKey, ItemLedgEntry."Expiration Date");
                    LotMfg.Add(LotKey, GetManufacturingDate(ItemLedgEntry));
                end;
            end;

        foreach LotKey in LotKeys do begin
            if Result <> '' then
                Result += CRLF;
            Result += StrSubstNo(LotLineTxt, LotNos.Get(LotKey));
            if LotKeys.Count() > 1 then
                Result += '  (' + StrSubstNo(LotQtyTxt, Format(LotQty.Get(LotKey))) + ')';
            if LotMfg.Get(LotKey) <> 0D then
                Result += CRLF + StrSubstNo(MfgDateTxt, FormatDate(LotMfg.Get(LotKey)));
            if LotExp.Get(LotKey) <> 0D then
                Result += CRLF + StrSubstNo(ExpDateTxt, FormatDate(LotExp.Get(LotKey)));
        end;
        exit(Result);
    end;

    // N° de la première expédition livrée par une facture.
    procedure GetFirstShipmentNo(InvoiceNo: Code[20]): Code[20]
    var
        ValueEntry: Record "Value Entry";
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ValueEntry.SetCurrentKey("Document No.");
        ValueEntry.SetRange("Document No.", InvoiceNo);
        ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
        ValueEntry.SetFilter("Item Ledger Entry No.", '<>0');
        if ValueEntry.FindSet() then
            repeat
                if ItemLedgEntry.Get(ValueEntry."Item Ledger Entry No.") then
                    if ItemLedgEntry."Document Type" = ItemLedgEntry."Document Type"::"Sales Shipment" then
                        exit(ItemLedgEntry."Document No.");
            until ValueEntry.Next() = 0;
        exit('');
    end;

    procedure GetCountryName(CountryCode: Code[10]): Text[50]
    var
        CountryRegion: Record "Country/Region";
    begin
        if CountryRegion.Get(CountryCode) then
            exit(CountryRegion.Name);
        exit(CountryCode);
    end;

    procedure FormatDate(Value: Date): Text
    begin
        exit(Format(Value, 0, '<Day,2> <Month Text,3> <Year4>'));
    end;

    procedure GetItemCodes(ItemNo: Code[20]; var NPCCode: Code[20]; var MOHCode: Code[20]; var ArabicDescription: Text[250])
    var
        Item: Record Item;
    begin
        NPCCode := '';
        MOHCode := '';
        ArabicDescription := '';
        if Item.Get(ItemNo) then begin
            NPCCode := Item."GNC NPC Code";
            MOHCode := Item."GNC MOH Code";
            ArabicDescription := Item."Arabic Description";
        end;
    end;

    // Date de fabrication : fiche du lot (module Stock du manager), sinon "Warranty Date" de l'écriture.
    local procedure GetManufacturingDate(ItemLedgEntry: Record "Item Ledger Entry"): Date
    var
        LotNoInfo: Record "Lot No. Information";
    begin
        if LotNoInfo.Get(ItemLedgEntry."Item No.", ItemLedgEntry."Variant Code", ItemLedgEntry."Lot No.") then
            if LotNoInfo."Manufacturing Date" <> 0D then
                exit(LotNoInfo."Manufacturing Date");
        exit(ItemLedgEntry."Warranty Date");
    end;

    // Un champ TLV : 1 octet tag, 1 octet longueur (en octets UTF-8), puis la valeur en UTF-8.
    local procedure WriteTLV(var OutStr: OutStream; Tag: Byte; Value: Text)
    var
        ValueBlob: Codeunit "Temp Blob";
        ValueOut: OutStream;
        ValueIn: InStream;
        Len: Byte;
        B: Byte;
    begin
        ValueBlob.CreateOutStream(ValueOut, TextEncoding::UTF8);
        ValueOut.WriteText(CopyStr(Value, 1, 80));
        Len := ValueBlob.Length();
        OutStr.Write(Tag);
        OutStr.Write(Len);
        ValueBlob.CreateInStream(ValueIn);
        while not ValueIn.EOS() do begin
            ValueIn.Read(B);
            OutStr.Write(B);
        end;
    end;

    local procedure FormatAmount(Value: Decimal): Text
    begin
        exit(Format(Round(Value, 0.01), 0, '<Precision,2:2><Standard Format,9>'));
    end;
}
