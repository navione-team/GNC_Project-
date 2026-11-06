page 50270 "NAV Damage Transfer"
{
    Caption = 'Damage Transfer';
    PageType = Document;
    SourceTable = "NAV Damage Transfer Header";
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
                    ToolTip = 'Specifies the number of the damage transfer.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the location where the damaged products are stored. They are moved to the damaged bin of this location.';
                }
                field("Damage Date"; Rec."Damage Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies when the damage was identified.';
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the reason of the damage.';
                }
                field("Responsible User ID"; Rec."Responsible User ID")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the user responsible for the transfer.';
                }
                field("Related Document No."; Rec."Related Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the related document, when applicable (receipt, return, inventory count...).';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the damage.';
                }
            }
            part(Lines; "NAV Damage Transfer Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                ApplicationArea = All;
                Caption = 'Post';
                Image = Post;
                ShortcutKey = 'F9';
                ToolTip = 'Moves the damaged quantities to the damaged bin and archives the document as a posted damage transfer.';

                trigger OnAction()
                var
                    DamageTransferPost: Codeunit "NAV Damage Transfer-Post";
                begin
                    if not Confirm(PostQst, false, Rec."No.") then
                        exit;
                    DamageTransferPost.Post(Rec);
                    Message(PostedMsg);
                    CurrPage.Close();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Post_Promoted; Post) { }
        }
    }

    var
        PostQst: Label 'Do you want to post damage transfer %1?', Comment = '%1 = Document No.';
        PostedMsg: Label 'The damage transfer has been posted.';
}

page 50271 "NAV Damage Transfer Subform"
{
    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "NAV Damage Transfer Line";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the damaged product.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the product.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the variant.';
                }
                field("From Bin Code"; Rec."From Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bin where the damaged product is stored now.';
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the batch number, when the item is tracked by batch.';
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the expiry date of the batch.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure in which the product is stored in the bin.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the damaged quantity.';
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the damaged quantity in the base unit of measure.';
                }
                field("To Bin Code"; Rec."To Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the damaged bin that receives the product (proposed from the location).';
                }
            }
        }
    }
}

page 50272 "NAV Damage Transfers"
{
    Caption = 'Damage Transfers';
    PageType = List;
    SourceTable = "NAV Damage Transfer Header";
    CardPageId = "NAV Damage Transfer";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = All; ToolTip = 'Specifies the number.'; }
                field("Location Code"; Rec."Location Code") { ApplicationArea = All; ToolTip = 'Specifies the location.'; }
                field("Damage Date"; Rec."Damage Date") { ApplicationArea = All; ToolTip = 'Specifies the damage date.'; }
                field("Reason Code"; Rec."Reason Code") { ApplicationArea = All; ToolTip = 'Specifies the damage reason.'; }
                field("Responsible User ID"; Rec."Responsible User ID") { ApplicationArea = All; ToolTip = 'Specifies the responsible user.'; }
                field("Related Document No."; Rec."Related Document No.") { ApplicationArea = All; ToolTip = 'Specifies the related document.'; }
            }
        }
    }
}

page 50273 "NAV Posted Damage Transfer"
{
    Caption = 'Posted Damage Transfer';
    PageType = Document;
    SourceTable = "NAV Posted Damage Transfer";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.") { ApplicationArea = All; ToolTip = 'Specifies the number.'; }
                field("Location Code"; Rec."Location Code") { ApplicationArea = All; ToolTip = 'Specifies the location.'; }
                field("Damage Date"; Rec."Damage Date") { ApplicationArea = All; ToolTip = 'Specifies the damage date.'; }
                field("Reason Code"; Rec."Reason Code") { ApplicationArea = All; ToolTip = 'Specifies the damage reason.'; }
                field("Responsible User ID"; Rec."Responsible User ID") { ApplicationArea = All; ToolTip = 'Specifies the user responsible for the transfer.'; }
                field("Related Document No."; Rec."Related Document No.") { ApplicationArea = All; ToolTip = 'Specifies the related document.'; }
                field(Description; Rec.Description) { ApplicationArea = All; ToolTip = 'Specifies the description.'; }
                field("Registering Date"; Rec."Registering Date") { ApplicationArea = All; ToolTip = 'Specifies when the movement was registered.'; }
                field("Posted By"; Rec."Posted By") { ApplicationArea = All; ToolTip = 'Specifies the user who posted the transfer.'; }
                field("Posted At"; Rec."Posted At") { ApplicationArea = All; ToolTip = 'Specifies when the transfer was posted.'; }
            }
            part(Lines; "NAV Posted Damage Trf. Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(WarehouseEntries)
            {
                ApplicationArea = All;
                Caption = 'Warehouse Entries';
                Image = BinLedger;
                ToolTip = 'Opens the warehouse entries of the transfer (source bin and damaged bin).';

                trigger OnAction()
                var
                    WarehouseEntry: Record "Warehouse Entry";
                begin
                    WarehouseEntry.SetRange("Whse. Document No.", Rec."No.");
                    Page.Run(Page::"Warehouse Entries", WarehouseEntry);
                end;
            }
        }
        area(Promoted)
        {
            actionref(WarehouseEntries_Promoted; WarehouseEntries) { }
        }
    }
}

page 50274 "NAV Posted Damage Trf. Subform"
{
    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "NAV Posted Damage Trf. Line";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Item No."; Rec."Item No.") { ApplicationArea = All; ToolTip = 'Specifies the product.'; }
                field(Description; Rec.Description) { ApplicationArea = All; ToolTip = 'Specifies the description.'; }
                field("From Zone Code"; Rec."From Zone Code") { ApplicationArea = All; ToolTip = 'Specifies the source zone.'; }
                field("From Bin Code"; Rec."From Bin Code") { ApplicationArea = All; ToolTip = 'Specifies the source bin.'; }
                field("Lot No."; Rec."Lot No.") { ApplicationArea = All; ToolTip = 'Specifies the batch number.'; }
                field("Expiration Date"; Rec."Expiration Date") { ApplicationArea = All; ToolTip = 'Specifies the expiry date.'; }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { ApplicationArea = All; ToolTip = 'Specifies the unit of measure.'; }
                field(Quantity; Rec.Quantity) { ApplicationArea = All; ToolTip = 'Specifies the damaged quantity.'; }
                field("Quantity (Base)"; Rec."Quantity (Base)") { ApplicationArea = All; ToolTip = 'Specifies the damaged quantity in base unit.'; }
                field("To Zone Code"; Rec."To Zone Code") { ApplicationArea = All; ToolTip = 'Specifies the damaged zone.'; }
                field("To Bin Code"; Rec."To Bin Code") { ApplicationArea = All; ToolTip = 'Specifies the damaged bin.'; }
            }
        }
    }
}

page 50275 "NAV Posted Damage Transfers"
{
    Caption = 'Posted Damage Transfers';
    PageType = List;
    SourceTable = "NAV Posted Damage Transfer";
    CardPageId = "NAV Posted Damage Transfer";
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;
    SourceTableView = sorting("No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = All; ToolTip = 'Specifies the number.'; }
                field("Location Code"; Rec."Location Code") { ApplicationArea = All; ToolTip = 'Specifies the location.'; }
                field("Damage Date"; Rec."Damage Date") { ApplicationArea = All; ToolTip = 'Specifies the damage date.'; }
                field("Reason Code"; Rec."Reason Code") { ApplicationArea = All; ToolTip = 'Specifies the damage reason.'; }
                field("Responsible User ID"; Rec."Responsible User ID") { ApplicationArea = All; ToolTip = 'Specifies the responsible user.'; }
                field("Related Document No."; Rec."Related Document No.") { ApplicationArea = All; ToolTip = 'Specifies the related document.'; }
                field("Posted By"; Rec."Posted By") { ApplicationArea = All; ToolTip = 'Specifies who posted.'; }
                field("Posted At"; Rec."Posted At") { ApplicationArea = All; ToolTip = 'Specifies when it was posted.'; }
            }
        }
    }
}
