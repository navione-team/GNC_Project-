table 50310 "NAV Bank Facility Setup"
{
    Caption = 'Bank Facility Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10; "Facility Nos."; Code[20])
        {
            Caption = 'Bank Facility Nos.';
            TableRelation = "No. Series";
        }
        // Dedicated general journal batch used for the facility entries
        field(11; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template" where(Type = const(General), Recurring = const(false));
        }
        field(12; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        // Yes = the entries stay in the journal for review, the user posts them.
        // No  = the entries are posted at once.
        field(13; "Review Before Posting"; Boolean)
        {
            Caption = 'Review Entries Before Posting';
            InitValue = true;
        }
        field(20; "Default Facility Account"; Code[20])
        {
            Caption = 'Default Bank Facility Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(21; "Default Commission Account"; Code[20])
        {
            Caption = 'Default Bank Commission Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(22; "Default Commission %"; Decimal)
        {
            Caption = 'Default Commission %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }

    procedure GetSetup()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}
