// ===================================================================
// Table 38 - Purchase Header
// ===================================================================
tableextension 50202 "NAV Purchase Header" extends "Purchase Header"
{
    fields
    {
        // Goods document linked to the folder
        field(50200; "Transit Folder No."; Code[20])
        {
            Caption = 'Transit Folder No.';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder"."No." where("Vendor No." = field("Buy-from Vendor No."));

            trigger OnValidate()
            var
                TransitFolder: Record "NAV Transit Folder";
            begin
                if "Transit Folder No." = xRec."Transit Folder No." then
                    exit;

                if not ("Document Type" in ["Document Type"::Order, "Document Type"::Invoice,
                                            "Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                    FieldError("Document Type");
                TestField("Charge Folder No.", '');

                // On an order, the folder must be open (it is the base for charge calculation)
                if "Document Type" = "Document Type"::Order then
                    if xRec."Transit Folder No." <> '' then
                        if TransitFolder.Get(xRec."Transit Folder No.") then
                            TransitFolder.TestField(Status, TransitFolder.Status::Open);

                if "Transit Folder No." <> '' then begin
                    TransitFolder.Get("Transit Folder No.");
                    if "Document Type" = "Document Type"::Order then
                        TransitFolder.TestField(Status, TransitFolder.Status::Open);
                    if TransitFolder."Vendor No." <> "Buy-from Vendor No." then
                        Error(VendorMismatchErr, "Buy-from Vendor No.", TransitFolder."Vendor No.", TransitFolder."No.");
                end;

                UpdateLinesTransitFolder("Transit Folder No.");
            end;
        }
        // Charge order generated from the folder
        field(50201; "Charge Folder No."; Code[20])
        {
            Caption = 'Transit Folder No. (Charges)';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
            Editable = false;
        }
    }

    keys
    {
        key(NAVTransitFolder; "Transit Folder No.") { }
    }

    local procedure UpdateLinesTransitFolder(NewFolderNo: Code[20])
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.SetRange("Document Type", "Document Type");
        PurchLine.SetRange("Document No.", "No.");
        if not PurchLine.IsEmpty() then
            PurchLine.ModifyAll("Transit Folder No.", NewFolderNo);
    end;

    var
        VendorMismatchErr: Label 'Vendor %1 on the document is different from vendor %2 on transit folder %3.', Comment = '%1 = document vendor, %2 = folder vendor, %3 = folder no.';
}

// ===================================================================
// Table 39 - Purchase Line
// Holds the folder of the goods OR the folder of the charges (charge order)
// ===================================================================
tableextension 50204 "NAV Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(50200; "Transit Folder No."; Code[20])
        {
            Caption = 'Transit Folder No.';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
            Editable = false;
        }
        field(50201; "Transit Folder Line No."; Integer)
        {
            Caption = 'Transit Folder Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(NAVTransitFolder; "Transit Folder No.") { }
    }

    trigger OnBeforeInsert()
    var
        PurchHeader: Record "Purchase Header";
    begin
        if "Transit Folder No." <> '' then
            exit;
        if PurchHeader.Get("Document Type", "Document No.") then
            if PurchHeader."Transit Folder No." <> '' then
                "Transit Folder No." := PurchHeader."Transit Folder No."
            else
                "Transit Folder No." := PurchHeader."Charge Folder No.";
    end;
}

// ===================================================================
// Posted tables: same field IDs => copied by TransferFields
// during posting (Purchase Header -> 120/122/124, Purchase Line -> 121/123)
// ===================================================================
tableextension 50203 "NAV Purch. Rcpt. Header" extends "Purch. Rcpt. Header"
{
    fields
    {
        field(50200; "Transit Folder No."; Code[20])
        {
            Caption = 'Transit Folder No.';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
            Editable = false;
        }
        field(50201; "Charge Folder No."; Code[20])
        {
            Caption = 'Transit Folder No. (Charges)';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
            Editable = false;
        }
    }

    keys
    {
        key(NAVTransitFolder; "Transit Folder No.") { }
    }
}

tableextension 50205 "NAV Purch. Rcpt. Line" extends "Purch. Rcpt. Line"
{
    fields
    {
        field(50200; "Transit Folder No."; Code[20])
        {
            Caption = 'Transit Folder No.';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
            Editable = false;
        }
        field(50201; "Transit Folder Line No."; Integer)
        {
            Caption = 'Transit Folder Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(NAVTransitFolder; "Transit Folder No.") { }
    }
}

tableextension 50206 "NAV Purch. Inv. Header" extends "Purch. Inv. Header"
{
    fields
    {
        field(50200; "Transit Folder No."; Code[20])
        {
            Caption = 'Transit Folder No.';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
            Editable = false;
        }
        field(50201; "Charge Folder No."; Code[20])
        {
            Caption = 'Transit Folder No. (Charges)';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
            Editable = false;
        }
    }

    keys
    {
        key(NAVTransitFolder; "Transit Folder No.") { }
    }
}

tableextension 50207 "NAV Purch. Inv. Line" extends "Purch. Inv. Line"
{
    fields
    {
        field(50200; "Transit Folder No."; Code[20])
        {
            Caption = 'Transit Folder No.';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
            Editable = false;
        }
        field(50201; "Transit Folder Line No."; Integer)
        {
            Caption = 'Transit Folder Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(NAVTransitFolder; "Transit Folder No.") { }
    }
}

tableextension 50208 "NAV Purch. Cr. Memo Hdr." extends "Purch. Cr. Memo Hdr."
{
    fields
    {
        field(50200; "Transit Folder No."; Code[20])
        {
            Caption = 'Transit Folder No.';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
            Editable = false;
        }
        field(50201; "Charge Folder No."; Code[20])
        {
            Caption = 'Transit Folder No. (Charges)';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
            Editable = false;
        }
    }

    keys
    {
        key(NAVTransitFolder; "Transit Folder No.") { }
    }
}

// ===================================================================
// Pages
// ===================================================================
pageextension 50202 "NAV Purchase Order" extends "Purchase Order"
{
    layout
    {
        addlast(General)
        {
            field("Transit Folder No."; Rec."Transit Folder No.")
            {
                ApplicationArea = All;
                ShowMandatory = TransitFolderRequired;
                ToolTip = 'Specifies the transit folder this order is linked to. It is mandatory for orders in foreign currency.';
            }
            field("Charge Folder No."; Rec."Charge Folder No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the transit folder that generated this charge order.';
            }
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            begin
                SetTransitFolderRequired();
            end;
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetTransitFolderRequired();
    end;

    local procedure SetTransitFolderRequired()
    var
        TransitFolderMgt: Codeunit "NAV Transit Folder Mgt.";
    begin
        TransitFolderRequired := TransitFolderMgt.IsTransitFolderRequired(Rec);
    end;

    var
        TransitFolderRequired: Boolean;
}

pageextension 50203 "NAV Posted Purch. Receipt" extends "Posted Purchase Receipt"
{
    layout
    {
        addlast(General)
        {
            field("Transit Folder No."; Rec."Transit Folder No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the transit folder of the received order.';
            }
            field("Charge Folder No."; Rec."Charge Folder No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the transit folder that generated this charge receipt.';
            }
        }
    }
}
