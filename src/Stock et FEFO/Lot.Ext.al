tableextension 50250 "NAV Lot No. Information" extends "Lot No. Information"
{
    fields
    {
        // Copied from the "Warranty Date" of the receipt, used as manufacturing date
        field(50250; "Manufacturing Date"; Date)
        {
            Caption = 'Manufacturing Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50251; "Lot Status"; Enum "NAV Lot Status")
        {
            Caption = 'Lot Status';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                LotManagement: Codeunit "NAV Lot Management";
            begin
                if "Lot Status" = xRec."Lot Status" then
                    exit;
                LotManagement.CheckStatusChange(Rec);
                LotManagement.ApplyStatus(Rec);
            end;
        }
        field(50252; "Status Changed By"; Code[50])
        {
            Caption = 'Status Changed By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(50253; "Status Changed At"; DateTime)
        {
            Caption = 'Status Changed At';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50254; "Created by Receipt No."; Code[20])
        {
            Caption = 'Created by Receipt No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}

tableextension 50251 "NAV User Setup Lot" extends "User Setup"
{
    fields
    {
        // Rule 9: approved users who can release a quarantined or blocked batch
        field(50250; "Lot Status Approver"; Boolean)
        {
            Caption = 'Lot Status Approver';
            DataClassification = CustomerContent;
        }
    }
}
