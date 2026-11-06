codeunit 50261 "NAV Sales Controls"
{
    // 1.2 Stores "Not for Sale" (DAMAGE-VENDOR, DAMAGE-STORE): no quote, order or
    //     invoice line can use them. Returns, transfers and purchase returns remain possible.
    // 1.3 Refunds: the Reason Code (refund reason) is mandatory on sales credit memos
    //     and return orders, before approval and before posting; a rejection reason
    //     (approval comment) is mandatory when such an approval request is rejected.

    // ---------------------------------------------------------------
    // 1.2 Not for Sale locations
    // ---------------------------------------------------------------
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure CheckLocationOnAfterValidateLocationCode(var Rec: Record "Sales Line")
    begin
        CheckSalesLineLocation(Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeReleaseSalesDoc', '', false, false)]
    local procedure CheckLocationsOnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        CheckSalesDocumentLocations(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure CheckOnBeforePostSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        CheckSalesDocumentLocations(SalesHeader);
        CheckRefundReason(SalesHeader);
    end;

    local procedure CheckSalesDocumentLocations(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        if not IsOutboundSalesDocument(SalesHeader."Document Type") then
            exit;
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("Location Code", '<>%1', '');
        if SalesLine.FindSet() then
            repeat
                CheckSalesLineLocation(SalesLine);
            until SalesLine.Next() = 0;
    end;

    procedure CheckSalesLineLocation(SalesLine: Record "Sales Line")
    var
        Location: Record Location;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        if SalesLine."Location Code" = '' then
            exit;
        if not IsOutboundSalesDocument(SalesLine."Document Type") then
            exit;
        if not Location.Get(SalesLine."Location Code") then
            exit;
        if Location."Not for Sale" then
            Error(NotForSaleErr, SalesLine."Location Code", SalesLine."No.");
    end;

    local procedure IsOutboundSalesDocument(DocumentType: Enum "Sales Document Type"): Boolean
    begin
        exit(DocumentType in [DocumentType::Quote, DocumentType::Order, DocumentType::Invoice, DocumentType::"Blanket Order"]);
    end;

    // ---------------------------------------------------------------
    // 1.3 Refund reason (standard Reason Code) mandatory
    // ---------------------------------------------------------------
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSendSalesDocForApproval', '', false, false)]
    local procedure CheckRefundReasonOnSendSalesDocForApproval(var SalesHeader: Record "Sales Header")
    begin
        CheckRefundReason(SalesHeader);
    end;

    procedure CheckRefundReason(SalesHeader: Record "Sales Header")
    begin
        if not (SalesHeader."Document Type" in [SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order"]) then
            exit;
        if SalesHeader."Reason Code" = '' then
            Error(RefundReasonErr, SalesHeader."Document Type", SalesHeader."No.");
    end;

    // ---------------------------------------------------------------
    // 1.3 Rejection reason mandatory (approval comment of the approver)
    // ---------------------------------------------------------------
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    local procedure CheckRejectionReasonOnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        ApprovalCommentLine: Record "Approval Comment Line";
    begin
        if ApprovalEntry."Table ID" <> Database::"Sales Header" then
            exit;
        if not (ApprovalEntry."Document Type" in [ApprovalEntry."Document Type"::"Credit Memo", ApprovalEntry."Document Type"::"Return Order"]) then
            exit;

        ApprovalCommentLine.SetRange("Table ID", ApprovalEntry."Table ID");
        ApprovalCommentLine.SetRange("Record ID to Approve", ApprovalEntry."Record ID to Approve");
        ApprovalCommentLine.SetRange("Workflow Step Instance ID", ApprovalEntry."Workflow Step Instance ID");
        ApprovalCommentLine.SetRange("User ID", UserId());
        if ApprovalCommentLine.IsEmpty() then
            Error(RejectionReasonErr, ApprovalEntry."Document Type", ApprovalEntry."Document No.");
    end;

    var
        NotForSaleErr: Label 'Location %1 is not for sale. Item %2 cannot be sold from this location.', Comment = '%1 = Location Code, %2 = Item No.';
        RefundReasonErr: Label 'The Refund Reason Code (Reason Code) is mandatory on %1 %2.', Comment = '%1 = Document Type, %2 = Document No.';
        RejectionReasonErr: Label 'Enter the rejection reason before rejecting %1 %2: choose Comments on the approval request, write the reason, then choose Reject.', Comment = '%1 = Document Type, %2 = Document No.';
}
