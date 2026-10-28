// Lot 5 – Bonus (FRD « Discount & Bonus », REQ-DB-004 à 016).
// - À la création d'une commande depuis une demande (Make Order standard ou regroupement du lot 4),
//   pour chaque ligne d'article venue d'une demande, on cherche une règle Bonus Setup (client + article,
//   valable à la date de commande, quantité minimum atteinte) :
//     · remise additionnelle (+ remise MOH si le client est Government) : ajoutée à la remise
//       de la ligne commandée (10 % + MOH 5 % + 2 % = 17 %) ;
//     · quantité bonus : nouvelle ligne juste en dessous, même article, remise 100 % (montant 0).
// - La ligne bonus est rattachée à sa ligne commandée par le champ standard "Attached to Line No." :
//   BC la supprime avec sa ligne, et ce lien est recopié sur l'expédition et la facture (REQ-DB-014).
// - Seuls les utilisateurs cochés "Allow Edit Bonus Lines" (User Setup) peuvent modifier ou supprimer
//   une ligne bonus (REQ-DB-016).
// SingleInstance : garde en mémoire, pendant la session, la demande dont le bonus est reporté
// (regroupement) et la ligne commandée en cours de suppression.
codeunit 90062 "GNC Bonus Mgt."
{
    SingleInstance = true;

    var
        PostponedRequestNo: Code[20];
        DeletingDocumentNo: Code[20];
        DeletingLineNo: Integer;
        NotAllowedErr: Label 'Line %1 is a bonus line. You are not allowed to change or delete bonus lines (Allow Edit Bonus Lines in User Setup).', Comment = '%1 = line no.';

    // ---------- Création de la commande ----------

    // Make Order standard (codeunit 86) : bonus appliqué à la fin, quand toutes les lignes existent
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Quote to Order", 'OnAfterOnRun', '', false, false)]
    local procedure ApplyBonusOnAfterMakeOrder(var SalesHeader: Record "Sales Header"; var SalesOrderHeader: Record "Sales Header")
    begin
        // Regroupement : le bonus sera calculé une seule fois, sur les lignes cumulées (codeunit 90056)
        if (PostponedRequestNo <> '') and (SalesHeader."No." = PostponedRequestNo) then begin
            PostponedRequestNo := '';
            exit;
        end;
        ApplyBonusToOrder(SalesOrderHeader);
    end;

    // Appelé par le regroupement juste avant le Make Order de la 1re demande
    procedure PostponeBonusForRequest(RequestNo: Code[20])
    begin
        PostponedRequestNo := RequestNo;
    end;

    // Ajoute les remises additionnelles et les lignes bonus aux lignes venues d'une demande
    procedure ApplyBonusToOrder(SalesOrderHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        BonusSetup: Record "GNC Bonus Setup";
        Customer: Record Customer;
        LineNos: List of [Integer];
        LineNo: Integer;
        IsGovernment: Boolean;
        ExtraDiscountPct: Decimal;
    begin
        if SalesOrderHeader."Document Type" <> SalesOrderHeader."Document Type"::Order then
            exit;
        // Remise MOH : seulement pour les clients du secteur Government
        if Customer.Get(SalesOrderHeader."Sell-to Customer No.") then
            IsGovernment := Customer."GNC Sector" = Customer."GNC Sector"::Government;

        // 1. Lignes concernées (liste à part : on insère des lignes pendant le traitement)
        SalesLine.SetRange("Document Type", SalesOrderHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesOrderHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetFilter("GNC Request No.", '<>%1', '');
        SalesLine.SetRange("GNC Bonus Line", false);
        SalesLine.SetRange("Attached to Line No.", 0);
        if SalesLine.FindSet() then
            repeat
                LineNos.Add(SalesLine."Line No.");
            until SalesLine.Next() = 0;

        // 2. Une règle par ligne
        foreach LineNo in LineNos do begin
            SalesLine.Get(SalesOrderHeader."Document Type", SalesOrderHeader."No.", LineNo);
            if not HasBonusLine(SalesLine) then
                if FindBonusRule(SalesOrderHeader."Sell-to Customer No.", SalesLine."No.", SalesOrderHeader."Order Date", SalesLine.Quantity, BonusSetup) then begin
                    // FRD : remise MOH (clients Government) + remise additionnelle, ajoutées à la remise de la ligne
                    ExtraDiscountPct := BonusSetup."Additional Discount %";
                    if IsGovernment then
                        ExtraDiscountPct += BonusSetup."MOH Discount %";
                    if ExtraDiscountPct <> 0 then
                        AddAdditionalDiscount(SalesLine, ExtraDiscountPct);
                    if BonusSetup."Bonus Quantity" <> 0 then
                        InsertBonusLine(SalesOrderHeader, SalesLine, BonusSetup."Bonus Quantity");
                end;
        end;
    end;

    // Règle valable à la date de commande ; s'il y en a plusieurs, la plus récente (date de début la plus grande).
    // Aussi utilisée pour l'aperçu de l'écran Requests to Group (codeunit 90093).
    procedure FindBonusRule(CustomerNo: Code[20]; ItemNo: Code[20]; OrderDate: Date; OrderedQty: Decimal; var BonusSetup: Record "GNC Bonus Setup"): Boolean
    begin
        BonusSetup.Reset();
        BonusSetup.SetRange("Customer No.", CustomerNo);
        BonusSetup.SetRange("Item No.", ItemNo);
        BonusSetup.SetFilter("Starting Date", '..%1', OrderDate);
        if BonusSetup.FindLast() then
            repeat
                if ((BonusSetup."Ending Date" = 0D) or (BonusSetup."Ending Date" >= OrderDate)) and
                   (OrderedQty >= BonusSetup."Minimum Quantity")
                then
                    exit(true);
            until BonusSetup.Next(-1) = 0;
        exit(false);
    end;

    local procedure HasBonusLine(SalesLine: Record "Sales Line"): Boolean
    var
        BonusLine: Record "Sales Line";
    begin
        BonusLine.SetRange("Document Type", SalesLine."Document Type");
        BonusLine.SetRange("Document No.", SalesLine."Document No.");
        BonusLine.SetRange("Attached to Line No.", SalesLine."Line No.");
        BonusLine.SetRange("GNC Bonus Line", true);
        exit(not BonusLine.IsEmpty());
    end;

    // FRD : la remise additionnelle s'ajoute à la remise principale (addition simple, 100 % au maximum)
    local procedure AddAdditionalDiscount(var SalesLine: Record "Sales Line"; AdditionalDiscountPct: Decimal)
    var
        NewDiscountPct: Decimal;
    begin
        NewDiscountPct := SalesLine."Line Discount %" + AdditionalDiscountPct;
        if NewDiscountPct > 100 then
            NewDiscountPct := 100;
        SalesLine.Validate("Line Discount %", NewDiscountPct);
        SalesLine.Modify(true);
    end;

    // Ligne bonus : même article, variante, magasin, unité et prix que la ligne commandée, remise 100 %
    local procedure InsertBonusLine(SalesOrderHeader: Record "Sales Header"; SourceLine: Record "Sales Line"; BonusQty: Decimal)
    var
        BonusLine: Record "Sales Line";
    begin
        BonusLine.Init();
        BonusLine."Document Type" := SourceLine."Document Type";
        BonusLine."Document No." := SourceLine."Document No.";
        BonusLine."Line No." := GetBonusLineNo(SourceLine);
        BonusLine.Validate(Type, BonusLine.Type::Item);
        BonusLine.Validate("No.", SourceLine."No.");
        if SourceLine."Variant Code" <> '' then
            BonusLine.Validate("Variant Code", SourceLine."Variant Code");
        BonusLine.Validate("Location Code", SourceLine."Location Code");
        BonusLine.Validate("Unit of Measure Code", SourceLine."Unit of Measure Code");
        BonusLine.Validate(Quantity, BonusQty);
        BonusLine.Validate("Unit Price", SourceLine."Unit Price");
        BonusLine.Validate("Line Discount %", 100);

        // Lien avec la ligne commandée + traçabilité (lot 3) : même demande, même commercial
        BonusLine."Attached to Line No." := SourceLine."Line No.";
        BonusLine."GNC Bonus Line" := true;
        BonusLine."GNC Request No." := SourceLine."GNC Request No.";
        BonusLine."GNC Salesperson Code" := SourceLine."GNC Salesperson Code";
        BonusLine.Insert(true);
    end;

    // N° de ligne juste après la ligne commandée (et après ses textes étendus éventuels)
    local procedure GetBonusLineNo(SourceLine: Record "Sales Line"): Integer
    var
        SalesLine: Record "Sales Line";
        PreviousLineNo: Integer;
    begin
        PreviousLineNo := SourceLine."Line No.";
        SalesLine.SetRange("Document Type", SourceLine."Document Type");
        SalesLine.SetRange("Document No.", SourceLine."Document No.");
        SalesLine.SetRange("Attached to Line No.", SourceLine."Line No.");
        if SalesLine.FindLast() then
            PreviousLineNo := SalesLine."Line No.";

        SalesLine.SetRange("Attached to Line No.");
        SalesLine.SetFilter("Line No.", '>%1', PreviousLineNo);
        if not SalesLine.FindFirst() then
            exit(PreviousLineNo + 10000);
        if SalesLine."Line No." - PreviousLineNo >= 2 then
            exit(PreviousLineNo + (SalesLine."Line No." - PreviousLineNo) div 2);

        // Pas de place entre les deux lignes : bonus en fin de commande
        SalesLine.SetRange("Line No.");
        SalesLine.FindLast();
        exit(SalesLine."Line No." + 10000);
    end;

    // ---------- Protection des lignes bonus (REQ-DB-016) ----------

    // Modification à la main (CurrFieldNo <> 0 = saisie dans la page) des champs qui changent le bonus
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'No.', false, false)]
    local procedure CheckOnBeforeValidateNo(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CheckManualChange(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Variant Code', false, false)]
    local procedure CheckOnBeforeValidateVariantCode(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CheckManualChange(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Quantity', false, false)]
    local procedure CheckOnBeforeValidateQuantity(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CheckManualChange(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Unit of Measure Code', false, false)]
    local procedure CheckOnBeforeValidateUnitOfMeasureCode(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CheckManualChange(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Unit Price', false, false)]
    local procedure CheckOnBeforeValidateUnitPrice(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CheckManualChange(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Line Discount %', false, false)]
    local procedure CheckOnBeforeValidateLineDiscountPct(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CheckManualChange(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Line Discount Amount', false, false)]
    local procedure CheckOnBeforeValidateLineDiscountAmount(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CheckManualChange(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeValidateEvent', 'Line Amount', false, false)]
    local procedure CheckOnBeforeValidateLineAmount(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CheckManualChange(Rec, CurrFieldNo);
    end;

    local procedure CheckManualChange(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = 0 then
            exit; // modification par le code (BC, validation...), pas par l'utilisateur
        if not SalesLine."GNC Bonus Line" then
            exit;
        if not IsAllowedToEditBonusLines() then
            Error(NotAllowedErr, SalesLine."Line No.");
    end;

    // Suppression : refusée pour une ligne bonus, sauf si sa ligne commandée est supprimée en même temps
    // (BC supprime alors les lignes rattachées) ou si l'utilisateur est autorisé.
    // RunTrigger = false : suppression par la validation (Post) → pas de contrôle.
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure CheckOnBeforeDeleteSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger then
            exit;
        if not Rec."GNC Bonus Line" then begin
            // Ligne commandée supprimée : ses lignes bonus rattachées pourront l'être aussi
            // (pas pour un texte étendu, lui-même rattaché à une ligne)
            if Rec."Attached to Line No." = 0 then begin
                DeletingDocumentNo := Rec."Document No.";
                DeletingLineNo := Rec."Line No.";
            end;
            exit;
        end;
        if (Rec."Document No." = DeletingDocumentNo) and (Rec."Attached to Line No." = DeletingLineNo) then
            exit;
        if not IsAllowedToEditBonusLines() then
            Error(NotAllowedErr, Rec."Line No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ClearOnAfterDeleteSalesLine(var Rec: Record "Sales Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() or not RunTrigger or Rec."GNC Bonus Line" then
            exit;
        if (Rec."Document No." = DeletingDocumentNo) and (Rec."Line No." = DeletingLineNo) then begin
            DeletingDocumentNo := '';
            DeletingLineNo := 0;
        end;
    end;

    local procedure IsAllowedToEditBonusLines(): Boolean
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then
            exit(false);
        exit(UserSetup."GNC Allow Edit Bonus Lines");
    end;
}
