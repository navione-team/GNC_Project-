page 50200 "NAV Transit Folder"
{
    Caption = 'Transit Folder';
    PageType = Document;
    SourceTable = "NAV Transit Folder";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transit folder number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the folder description.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the vendor of the goods (mandatory).';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor name.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the folder currency.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the folder date.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the folder status.';
                }
                field("No. of Orders"; Rec."No. of Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of linked purchase orders.';

                    trigger OnDrillDown()
                    begin
                        ShowOrders();
                    end;
                }
                field("Base Amount (LCY)"; Rec."Base Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the linked orders amount excluding VAT in local currency (base for percentage charges).';
                }
                field("Total Charges (LCY)"; Rec."Total Charges (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total charges of the folder.';
                }
            }
            part(Lines; "NAV Transit Folder Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Folder No." = field("No.");
                UpdatePropagation = Both;
            }
            part(ItemLines; "NAV Transit Folder Item Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Folder No." = field("No.");
            }
            group(Shipping)
            {
                Caption = 'Shipping';

                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Incoterm.';
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transport method.';
                }
                field("Forwarding Agent No."; Rec."Forwarding Agent No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the forwarding agent.';
                }
                field("Port of Loading"; Rec."Port of Loading")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the port or airport of loading.';
                }
                field("Port of Discharge"; Rec."Port of Discharge")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the port or airport of discharge.';
                }
                field("Bill of Lading No."; Rec."Bill of Lading No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bill of lading or air waybill number.';
                }
                field("Container No."; Rec."Container No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the container number.';
                }
                field("Departure Date"; Rec."Departure Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the departure date.';
                }
                field("Expected Arrival Date"; Rec."Expected Arrival Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expected arrival date.';
                }
                field("Actual Arrival Date"; Rec."Actual Arrival Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actual arrival date.';
                }
            }
            group(Customs)
            {
                Caption = 'Customs';

                field("Customs Declaration No."; Rec."Customs Declaration No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customs declaration number.';
                }
                field("Customs Declaration Date"; Rec."Customs Declaration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customs declaration date.';
                }
                field("Customs Regime"; Rec."Customs Regime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customs regime.';
                }
            }
        }
        area(FactBoxes)
        {
            // Documents attached to the folder (PDF, Word, text, pictures...)
            part(AttachedDocuments; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"NAV Transit Folder"), "No." = field("No.");
            }
            systempart(Links; Links)
            {
                ApplicationArea = All;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InsertDefaultCharges)
            {
                ApplicationArea = All;
                Caption = 'Insert Default Charges';
                Image = SuggestLines;
                ToolTip = 'Adds the charges marked "By Default" that are missing from the folder.';

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Open);
                    Rec.TestField("Vendor No.");
                    TransitFolderMgt.InsertDefaultCharges(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Recalculate)
            {
                ApplicationArea = All;
                Caption = 'Recalculate Amounts';
                Image = Calculate;
                ToolTip = 'Recalculates the orders amount excluding VAT and the percentage charges.';

                trigger OnAction()
                begin
                    TransitFolderMgt.RecalculateAmounts(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(SimulateLandedCost)
            {
                ApplicationArea = All;
                Caption = 'Simulate Landed Cost';
                Image = CalculateCost;
                ToolTip = 'Loads the item lines of the folder orders and receipts, and calculates the landed cost of each item (item cost + landed charges).';

                trigger OnAction()
                begin
                    TransitFolderMgt.SimulateLandedCost(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Release)
            {
                ApplicationArea = All;
                Caption = 'Release';
                Image = ReleaseDoc;
                ToolTip = 'Recalculates, then freezes the folder amounts.';

                trigger OnAction()
                begin
                    TransitFolderMgt.ReleaseFolder(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Reopen)
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                Image = ReOpen;
                ToolTip = 'Reopens the folder as long as the charge orders are not created.';

                trigger OnAction()
                begin
                    TransitFolderMgt.ReopenFolder(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CreateChargeOrders)
            {
                ApplicationArea = All;
                Caption = 'Create Charge Orders';
                Image = CreateDocuments;
                ToolTip = 'Creates one charge order per vendor, assigns the charges to the received lines and posts the receipt.';

                trigger OnAction()
                var
                    PurchSetup: Record "Purchases & Payables Setup";
                begin
                    if not Confirm(CreateChargesQst, false, Rec."No.") then
                        exit;
                    PurchSetup.Get();
                    TransitFolderMgt.CreateChargeOrders(Rec, PurchSetup."Auto Post Charge Receipt");
                    CurrPage.Update(false);
                end;
            }
            action(PostChargeReceipts)
            {
                ApplicationArea = All;
                Caption = 'Post Charge Receipts';
                Image = PostedReceipt;
                ToolTip = 'Posts the receipt of the charge orders of the folder that are not received yet.';

                trigger OnAction()
                begin
                    if not Confirm(PostChargeReceiptsQst, false, Rec."No.") then
                        exit;
                    TransitFolderMgt.PostChargeReceipts(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Reporting)
        {
            action(PrintTransitFolder)
            {
                ApplicationArea = All;
                Caption = 'Print';
                Image = Print;
                Ellipsis = true;
                ToolTip = 'Prints the transit folder with the item details of its purchase orders and the landed cost per item.';

                trigger OnAction()
                var
                    TransitFolder: Record "NAV Transit Folder";
                begin
                    TransitFolder := Rec;
                    TransitFolder.SetRecFilter();
                    Report.RunModal(Report::"NAV Transit Folder", true, false, TransitFolder);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(PurchaseOrders)
            {
                ApplicationArea = All;
                Caption = 'Purchase Orders';
                Image = Document;
                ToolTip = 'Opens the goods purchase orders linked to the folder.';

                trigger OnAction()
                begin
                    ShowOrders();
                end;
            }
            action(ChargeOrders)
            {
                ApplicationArea = All;
                Caption = 'Charge Orders';
                Image = Costs;
                ToolTip = 'Opens the charge orders generated by the folder.';
                RunObject = page "Purchase Order List";
                RunPageLink = "Charge Folder No." = field("No.");
            }
            action(PostedReceipts)
            {
                ApplicationArea = All;
                Caption = 'Posted Receipts';
                Image = PostedReceipts;
                ToolTip = 'Opens the posted receipts of the folder orders.';
                RunObject = page "Posted Purchase Receipts";
                RunPageLink = "Transit Folder No." = field("No.");
            }
            action(PostedChargeReceipts)
            {
                ApplicationArea = All;
                Caption = 'Posted Charge Receipts';
                Image = PostedReceipts;
                ToolTip = 'Opens the posted receipts of the charge orders generated by the folder.';
                RunObject = page "Posted Purchase Receipts";
                RunPageLink = "Charge Folder No." = field("No.");
            }
            action(NAVAttachments)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                ToolTip = 'Adds or opens the documents attached to the transit folder (PDF, Word, text, pictures...). Several files can be attached.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(ChargeAccruals)
            {
                ApplicationArea = All;
                Caption = 'Charge Accruals';
                Image = Accruals;
                ToolTip = 'Opens the estimated charge accruals posted at goods receipt and their reversals posted at charge invoice.';
                RunObject = page "NAV Transit Folder Accruals";
                RunPageLink = "Folder No." = field("No.");
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(SimulateLandedCost_Promoted; SimulateLandedCost) { }
                actionref(Release_Promoted; Release) { }
                actionref(Reopen_Promoted; Reopen) { }
                actionref(Recalculate_Promoted; Recalculate) { }
                actionref(CreateChargeOrders_Promoted; CreateChargeOrders) { }
                actionref(PostChargeReceipts_Promoted; PostChargeReceipts) { }
            }
            group(Category_Report)
            {
                Caption = 'Print';

                actionref(PrintTransitFolder_Promoted; PrintTransitFolder) { }
            }
            group(Category_Related)
            {
                Caption = 'Related';

                actionref(PurchaseOrders_Promoted; PurchaseOrders) { }
                actionref(ChargeOrders_Promoted; ChargeOrders) { }
                actionref(PostedReceipts_Promoted; PostedReceipts) { }
                actionref(PostedChargeReceipts_Promoted; PostedChargeReceipts) { }
                actionref(ChargeAccruals_Promoted; ChargeAccruals) { }
                actionref(NAVAttachments_Promoted; NAVAttachments) { }
            }
        }
    }

    local procedure ShowOrders()
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("Transit Folder No.", Rec."No.");
        Page.Run(Page::"Purchase Order List", PurchHeader);
    end;

    var
        TransitFolderMgt: Codeunit "NAV Transit Folder Mgt.";
        PostChargeReceiptsQst: Label 'Do you want to post the receipt of the charge orders of transit folder %1?', Comment = '%1 = Folder No.';
        CreateChargesQst: Label 'Do you want to create the charge orders for transit folder %1?', Comment = '%1 = Folder No.';
}

page 50201 "NAV Transit Folder List"
{
    Caption = 'Transit Folders';
    PageType = List;
    SourceTable = "NAV Transit Folder";
    CardPageId = "NAV Transit Folder";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the folder number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor name.';
                }
                field("Bill of Lading No."; Rec."Bill of Lading No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bill of lading or air waybill number.';
                }
                field("Expected Arrival Date"; Rec."Expected Arrival Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expected arrival date.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status.';
                }
                field("Base Amount (LCY)"; Rec."Base Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the orders amount excluding VAT (LCY).';
                }
                field("Total Charges (LCY)"; Rec."Total Charges (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total charges.';
                }
            }
        }
        area(FactBoxes)
        {
            part(AttachedDocuments; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"NAV Transit Folder"), "No." = field("No.");
            }
        }
    }
}

page 50202 "NAV Transit Folder Subform"
{
    Caption = 'Charges';
    PageType = ListPart;
    SourceTable = "NAV Transit Folder Line";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Item Charge No."; Rec."Item Charge No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item charge.';

                    trigger OnValidate()
                    begin
                        SetEditable();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the charge description.';
                }
                field("Calculation Type"; Rec."Calculation Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'By Amount = fixed amount entered; By Percent = percentage of the orders amount excluding VAT.';

                    trigger OnValidate()
                    begin
                        SetEditable();
                    end;
                }
                field(Percent; Rec.Percent)
                {
                    ApplicationArea = All;
                    Editable = IsPercent;
                    ToolTip = 'Specifies the percentage applied to the orders amount excluding VAT.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = not IsPercent;
                    ToolTip = 'Specifies the charge amount in local currency.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the vendor of the charge (forwarding agent, carrier, customs...).';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the charge vendor.';
                }
                field("Accrued Amount (LCY)"; Rec."Accrued Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the estimated amount of the charge accrued at goods receipt.';
                }
                field("Open Accrual (LCY)"; Rec."Open Accrual (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the accrued amount not reversed yet (reversed when the charge is invoiced).';
                }
                field("Charge Order No."; Rec."Charge Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the generated charge order.';

                    trigger OnDrillDown()
                    var
                        PurchHeader: Record "Purchase Header";
                    begin
                        if PurchHeader.Get(PurchHeader."Document Type"::Order, Rec."Charge Order No.") then
                            Page.Run(Page::"Purchase Order", PurchHeader);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetEditable();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsPercent := false;
    end;

    local procedure SetEditable()
    begin
        IsPercent := Rec."Calculation Type" = Rec."Calculation Type"::"By Percent";
    end;

    var
        IsPercent: Boolean;
}
