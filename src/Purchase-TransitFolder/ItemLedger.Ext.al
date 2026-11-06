// Table 83 - Item Journal Line: required bridge between the purchase line and the item entries
tableextension 50211 "NAV Item Journal Line" extends "Item Journal Line"
{
    fields
    {
        field(50200; "Transit Folder No."; Code[20])
        {
            Caption = 'Transit Folder No.';
            DataClassification = CustomerContent;
            TableRelation = "NAV Transit Folder";
        }
    }
}

// Table 32 - Item Ledger Entry
tableextension 50209 "NAV Item Ledger Entry" extends "Item Ledger Entry"
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
    }

    keys
    {
        key(NAVTransitFolder; "Transit Folder No.") { }
    }
}

// Table 5802 - Value Entry
// Both goods entries AND charge entries (Item Charge No. <> '') carry the folder
tableextension 50210 "NAV Value Entry" extends "Value Entry"
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
    }

    keys
    {
        key(NAVTransitFolder; "Transit Folder No.") { }
    }
}
