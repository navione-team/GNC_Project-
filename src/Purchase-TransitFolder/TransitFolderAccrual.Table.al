// Estimated charge accruals posted at goods receipt and their reversals
// posted at charge invoice (one entry per G/L posting line).
table 50203 "NAV Transit Folder Accrual"
{
    Caption = 'Transit Folder Accrual';
    DataClassification = CustomerContent;
    LookupPageId = "NAV Transit Folder Accruals";
    DrillDownPageId = "NAV Transit Folder Accruals";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            OptionMembers = Accrual,Reversal;
            OptionCaption = 'Accrual,Reversal';
        }
        field(3; "Folder No."; Code[20])
        {
            Caption = 'Folder No.';
            TableRelation = "NAV Transit Folder";
        }
        field(4; "Folder Line No."; Integer)
        {
            Caption = 'Folder Line No.';
        }
        field(5; "Item Charge No."; Code[20])
        {
            Caption = 'Item Charge No.';
            TableRelation = "Item Charge";
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(8; "Source Line No."; Integer)
        {
            Caption = 'Source Line No.';
        }
        field(9; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(11; "Inventory Account No."; Code[20])
        {
            Caption = 'Inventory Account No.';
            TableRelation = "G/L Account";
        }
        field(12; "Clearing Account No."; Code[20])
        {
            Caption = 'Clearing Account No.';
            TableRelation = "G/L Account";
        }
        field(13; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            AutoFormatType = 1;
        }
        field(14; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(FolderLine; "Folder No.", "Folder Line No.", "Inventory Account No.", "Clearing Account No.", "Entry Type")
        {
            SumIndexFields = "Amount (LCY)";
        }
    }
}
