table 50200 "NAV Transit Folder"
{
    Caption = 'Transit Folder';
    DataClassification = CustomerContent;
    LookupPageId = "NAV Transit Folder List";
    DrillDownPageId = "NAV Transit Folder List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                NoSeries: Codeunit "No. Series";
            begin
                if "No." <> xRec."No." then begin
                    PurchSetup.Get();
                    NoSeries.TestManual(PurchSetup."Transit Folder Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
                PurchHeader: Record "Purchase Header";
            begin
                if "Vendor No." = xRec."Vendor No." then
                    exit;
                TestField(Status, Status::Open);

                if xRec."Vendor No." <> '' then begin
                    PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
                    PurchHeader.SetRange("Transit Folder No.", "No.");
                    if not PurchHeader.IsEmpty() then
                        Error(OrdersLinkedErr, "No.");
                end;

                if "Vendor No." = '' then begin
                    "Vendor Name" := '';
                    exit;
                end;

                Vendor.Get("Vendor No.");
                Vendor.CheckBlockedVendOnDocs(Vendor, false);
                "Vendor Name" := Vendor.Name;
                "Currency Code" := Vendor."Currency Code";
                if "Shipment Method Code" = '' then
                    "Shipment Method Code" := Vendor."Shipment Method Code";

                // Folder already numbered: insert default charges when the vendor is first selected
                if ("No." <> '') and (xRec."Vendor No." = '') and not HasLines() then
                    TransitFolderMgt.InsertDefaultCharges(Rec);
            end;
        }
        field(4; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            Editable = false;
        }
        field(5; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(6; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(7; "Shipment Method Code"; Code[10])
        {
            Caption = 'Incoterm (Shipment Method)';
            TableRelation = "Shipment Method";
        }
        field(8; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
        }
        field(9; "Port of Loading"; Text[50])
        {
            Caption = 'Port of Loading';
        }
        field(10; "Port of Discharge"; Code[10])
        {
            Caption = 'Port of Discharge';
            TableRelation = "Entry/Exit Point";
        }
        field(11; "Bill of Lading No."; Code[35])
        {
            Caption = 'Bill of Lading / AWB No.';
        }
        field(12; "Container No."; Code[35])
        {
            Caption = 'Container No.';
        }
        field(13; "Departure Date"; Date)
        {
            Caption = 'Departure Date';
        }
        field(14; "Expected Arrival Date"; Date)
        {
            Caption = 'Expected Arrival Date';
        }
        field(15; "Actual Arrival Date"; Date)
        {
            Caption = 'Actual Arrival Date';
        }
        field(16; "Customs Declaration No."; Code[35])
        {
            Caption = 'Customs Declaration No.';
        }
        field(17; "Customs Declaration Date"; Date)
        {
            Caption = 'Customs Declaration Date';
        }
        field(18; "Forwarding Agent No."; Code[20])
        {
            Caption = 'Forwarding Agent No.';
            TableRelation = Vendor;
        }
        field(19; "Customs Regime"; Code[20])
        {
            Caption = 'Customs Regime';
        }
        field(20; Status; Enum "NAV Transit Folder Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(21; "Base Amount (LCY)"; Decimal)
        {
            Caption = 'Orders Amount Excl. VAT (LCY)';
            AutoFormatType = 1;
            Editable = false;
        }
        field(22; "Total Charges (LCY)"; Decimal)
        {
            Caption = 'Total Charges (LCY)';
            AutoFormatType = 1;
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum("NAV Transit Folder Line".Amount where("Folder No." = field("No.")));
        }
        field(23; "No. of Orders"; Integer)
        {
            Caption = 'No. of Orders';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Purchase Header" where("Document Type" = const(Order), "Transit Folder No." = field("No.")));
        }
        field(24; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Vendor; "Vendor No.") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description, "Vendor No.", "Vendor Name", Status) { }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "No." = '' then begin
            PurchSetup.Get();
            PurchSetup.TestField("Transit Folder Nos.");
            "No. Series" := PurchSetup."Transit Folder Nos.";
            "No." := NoSeries.GetNextNo("No. Series", WorkDate());
        end;
        if "Document Date" = 0D then
            "Document Date" := WorkDate();

        if ("Vendor No." <> '') and not HasLines() then
            TransitFolderMgt.InsertDefaultCharges(Rec);
    end;

    trigger OnDelete()
    var
        FolderLine: Record "NAV Transit Folder Line";
        ItemLine: Record "NAV Transit Folder Item Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        AccrualEntry: Record "NAV Transit Folder Accrual";
    begin
        if Status = Status::"Charges Created" then
            Error(CannotDeleteErr, "No.");

        AccrualEntry.SetRange("Folder No.", "No.");
        if not AccrualEntry.IsEmpty() then
            Error(AccrualsExistErr, "No.");

        FolderLine.SetRange("Folder No.", "No.");
        FolderLine.DeleteAll();

        ItemLine.SetRange("Folder No.", "No.");
        ItemLine.DeleteAll();

        PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Order);
        PurchHeader.SetRange("Transit Folder No.", "No.");
        PurchHeader.ModifyAll("Transit Folder No.", '');

        PurchLine.SetCurrentKey("Transit Folder No.");
        PurchLine.SetRange("Transit Folder No.", "No.");
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.ModifyAll("Transit Folder No.", '');
    end;

    procedure HasLines(): Boolean
    var
        FolderLine: Record "NAV Transit Folder Line";
    begin
        if "No." = '' then
            exit(false);
        FolderLine.SetRange("Folder No.", "No.");
        exit(not FolderLine.IsEmpty());
    end;

    var
        PurchSetup: Record "Purchases & Payables Setup";
        TransitFolderMgt: Codeunit "NAV Transit Folder Mgt.";
        OrdersLinkedErr: Label 'You cannot change the vendor because purchase orders are linked to transit folder %1.', Comment = '%1 = Folder No.';
        AccrualsExistErr: Label 'Transit folder %1 cannot be deleted because charge accruals have been posted for it.', Comment = '%1 = Folder No.';
        CannotDeleteErr: Label 'Transit folder %1 cannot be deleted because its charge orders have already been created.', Comment = '%1 = Folder No.';
}
