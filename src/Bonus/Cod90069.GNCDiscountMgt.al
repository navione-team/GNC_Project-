// Lot 6 – Remises GNC (FRD « Discount Management », règles 1–3, 13, 15, 17 ; REQ-DB-001 à 006, 015).
// 1. Proposition automatique : quand BC calcule le prix d'une ligne d'article (saisie de l'article,
//    de la quantité, de l'unité...), on cherche une règle GNC Discount Setup. Si on en trouve une,
//    sa remise remplace celle des Price Lists standard ; sinon on garde la remise standard.
//    Priorité (GNC Sales Setup) : la règle la plus précise, ou la remise la plus élevée.
// 2. Contrôle de la remise saisie à la main (si "Control Manual Discount" est coché dans GNC Sales Setup) :
//    refusée si elle dépasse à la fois la remise proposée et la remise maximum de l'utilisateur
//    ("Max Line Discount %" dans User Setup ; pas de ligne User Setup = 0).
// Les remises ajoutées par le code (bonus, remise additionnelle, MOH) ne sont pas contrôlées.
codeunit 90069 "GNC Discount Mgt."
{
    var
        CustomerItemTxt: Label 'Customer + item';
        CustomerCategoryTxt: Label 'Customer + item category';
        CustomerAllItemsTxt: Label 'Customer, all items';
        AllCustomersItemTxt: Label 'All customers + item';
        AllCustomersCategoryTxt: Label 'All customers + item category';
        MaxDiscountErr: Label 'You cannot give a line discount of %1%. The maximum allowed for you is %2% (suggested discount %3%, your maximum in User Setup %4%).', Comment = '%1 = entered discount, %2 = allowed discount, %3 = suggested discount, %4 = user maximum';

    // ---------- 1. Proposition de la remise ----------

    // Juste après le calcul standard du prix et de la remise, avant le recalcul des montants
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnUpdateUnitPriceByFieldOnAfterFindPrice', '', false, false)]
    local procedure ApplyGNCDiscountOnAfterFindPrice(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CalledByFieldNo: Integer; CallingFieldNo: Integer)
    var
        DiscountPct: Decimal;
    begin
        if not IsDiscountDocument(SalesLine) then
            exit;
        if FindDiscount(SalesHeader, SalesLine, DiscountPct) then
            SalesLine."Line Discount %" := DiscountPct; // les montants sont recalculés juste après par le standard
    end;

    // Remise GNC applicable à la ligne (false = aucune règle)
    procedure FindDiscount(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"; var DiscountPct: Decimal): Boolean
    var
        Item: Record Item;
        GNCSalesSetup: Record "GNC Sales Setup";
        DiscountType: Enum "GNC Discount Type";
        CustomerNos: array[2] of Code[20];
        RuleDate: Date;
        RulePct: Decimal;
        Found: Boolean;
        i: Integer;
        j: Integer;
    begin
        if (SalesLine.Type <> SalesLine.Type::Item) or (SalesLine."No." = '') then
            exit(false);
        if not Item.Get(SalesLine."No.") then
            exit(false);
        RuleDate := SalesHeader."Order Date";
        if RuleDate = 0D then
            RuleDate := WorkDate();
        GNCSalesSetup.GetSetup();

        // Ordre de précision : client puis tous les clients ; article, puis catégorie, puis tous les articles
        CustomerNos[1] := SalesHeader."Sell-to Customer No.";
        CustomerNos[2] := '';
        for i := 1 to 2 do
            for j := 0 to 2 do begin
                DiscountType := "GNC Discount Type".FromInteger(j);
                if FindValidRule(CustomerNos[i], DiscountType, GetRuleNo(DiscountType, Item), RuleDate, RulePct) then begin
                    if GNCSalesSetup."Discount Priority" = GNCSalesSetup."Discount Priority"::"Most Specific" then begin
                        DiscountPct := RulePct;
                        exit(true);
                    end;
                    // "Highest Discount" : on garde la plus élevée
                    if (not Found) or (RulePct > DiscountPct) then
                        DiscountPct := RulePct;
                    Found := true;
                end;
            end;
        exit(Found);
    end;

    // Simulateur (page 90096) : les 5 niveaux de précision, la règle trouvée à chaque niveau et le gagnant.
    // Même ordre et même règle de priorité que FindDiscount. WinnerIndex = -1 s'il n'y a aucune règle.
    procedure GetDiscountLadder(CustomerNo: Code[20]; ItemNo: Code[20]; RuleDate: Date; var Ladder: JsonArray; var WinnerIndex: Integer; var DiscountPct: Decimal)
    var
        Item: Record Item;
        GNCSalesSetup: Record "GNC Sales Setup";
        DiscountType: Enum "GNC Discount Type";
        Level: JsonObject;
        CustomerNos: array[2] of Code[20];
        Labels: array[5] of Text;
        RulePct: Decimal;
        Found: Boolean;
        i: Integer;
        j: Integer;
        Index: Integer;
    begin
        Labels[1] := CustomerItemTxt;
        Labels[2] := CustomerCategoryTxt;
        Labels[3] := CustomerAllItemsTxt;
        Labels[4] := AllCustomersItemTxt;
        Labels[5] := AllCustomersCategoryTxt;
        WinnerIndex := -1;
        DiscountPct := 0;
        if not Item.Get(ItemNo) then
            exit;
        GNCSalesSetup.GetSetup();
        CustomerNos[1] := CustomerNo;
        CustomerNos[2] := '';
        for i := 1 to 2 do
            for j := 0 to 2 do
                if not ((i = 2) and (j = 2)) then begin
                    DiscountType := "GNC Discount Type".FromInteger(j);
                    RulePct := 0;
                    Found := FindValidRule(CustomerNos[i], DiscountType, GetRuleNo(DiscountType, Item), RuleDate, RulePct);
                    Clear(Level);
                    Level.Add('label', Labels[Index + 1]);
                    Level.Add('found', Found);
                    Level.Add('pct', RulePct);
                    Ladder.Add(Level);
                    if Found then
                        if (WinnerIndex = -1) or
                           ((GNCSalesSetup."Discount Priority" = GNCSalesSetup."Discount Priority"::"Highest Discount") and (RulePct > DiscountPct))
                        then begin
                            WinnerIndex := Index;
                            DiscountPct := RulePct;
                        end;
                    Index += 1;
                end;
    end;

    local procedure GetRuleNo(DiscountType: Enum "GNC Discount Type"; Item: Record Item): Code[20]
    begin
        case DiscountType of
            DiscountType::Item:
                exit(Item."No.");
            DiscountType::"Item Category":
                exit(Item."Item Category Code");
        end;
        exit(''); // All Items
    end;

    // Règle valable à la date ; s'il y en a plusieurs, la plus récente (date de début la plus grande)
    local procedure FindValidRule(CustomerNo: Code[20]; DiscountType: Enum "GNC Discount Type"; No: Code[20]; RuleDate: Date; var DiscountPct: Decimal): Boolean
    var
        DiscountSetup: Record "GNC Discount Setup";
    begin
        if (DiscountType <> DiscountType::"All Items") and (No = '') then
            exit(false); // article sans catégorie
        if (DiscountType = DiscountType::"All Items") and (CustomerNo = '') then
            exit(false); // n'existe pas (refusé dans la table)

        DiscountSetup.SetRange("Customer No.", CustomerNo);
        DiscountSetup.SetRange(Type, DiscountType);
        DiscountSetup.SetRange("No.", No);
        DiscountSetup.SetFilter("Starting Date", '..%1', RuleDate);
        if DiscountSetup.FindLast() then
            repeat
                if (DiscountSetup."Ending Date" = 0D) or (DiscountSetup."Ending Date" >= RuleDate) then begin
                    DiscountPct := DiscountSetup."Discount %";
                    exit(true);
                end;
            until DiscountSetup.Next(-1) = 0;
        exit(false);
    end;

    // Demandes (devis), commandes et factures ; pas les lignes bonus (remise 100 % voulue)
    local procedure IsDiscountDocument(SalesLine: Record "Sales Line"): Boolean
    begin
        if SalesLine.IsTemporary() or SalesLine."GNC Bonus Line" then
            exit(false);
        exit(SalesLine."Document Type" in [SalesLine."Document Type"::Quote, SalesLine."Document Type"::Order, SalesLine."Document Type"::Invoice]);
    end;

    // ---------- 2. Contrôle de la remise saisie à la main ----------
    // CurrFieldNo = champ modifié par l'utilisateur dans la page (0 = modification par le code).

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Line Discount %', false, false)]
    local procedure CheckOnAfterValidateLineDiscountPct(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = Rec.FieldNo("Line Discount %") then
            CheckManualDiscount(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Line Discount Amount', false, false)]
    local procedure CheckOnAfterValidateLineDiscountAmount(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = Rec.FieldNo("Line Discount Amount") then
            CheckManualDiscount(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Line Amount', false, false)]
    local procedure CheckOnAfterValidateLineAmount(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = Rec.FieldNo("Line Amount") then
            CheckManualDiscount(Rec);
    end;

    local procedure CheckManualDiscount(SalesLine: Record "Sales Line")
    var
        GNCSalesSetup: Record "GNC Sales Setup";
        UserSetup: Record "User Setup";
        SalesHeader: Record "Sales Header";
        SuggestedPct: Decimal;
        UserMaxPct: Decimal;
        AllowedPct: Decimal;
    begin
        GNCSalesSetup.GetSetup();
        if not GNCSalesSetup."Control Manual Discount" then
            exit;
        if not IsDiscountDocument(SalesLine) or (SalesLine.Type <> SalesLine.Type::Item) then
            exit;

        // Remise proposée : règle GNC (0 s'il n'y en a pas)
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            if not FindDiscount(SalesHeader, SalesLine, SuggestedPct) then
                SuggestedPct := 0;
        if UserSetup.Get(UserId()) then
            UserMaxPct := UserSetup."GNC Max Line Discount %";

        AllowedPct := SuggestedPct;
        if UserMaxPct > AllowedPct then
            AllowedPct := UserMaxPct;
        if SalesLine."Line Discount %" > AllowedPct then
            Error(MaxDiscountErr, SalesLine."Line Discount %", AllowedPct, SuggestedPct, UserMaxPct);
    end;
}
