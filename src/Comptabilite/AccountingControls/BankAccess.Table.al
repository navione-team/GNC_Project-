// FRD 15.1: access management by bank / cash account.
// A bank account with at least one line here is RESTRICTED: only the users listed for it
// can post on it. A line with an empty Bank Account No. gives a user access to all accounts.
// Bank accounts with no line at all stay open to everyone.
table 50320 "NAV User Bank Access"
{
    Caption = 'User Bank Account Access';
    DataClassification = CustomerContent;
    LookupPageId = "NAV User Bank Access";
    DrillDownPageId = "NAV User Bank Access";

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            NotBlank = true;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(2; "Bank Account No."; Code[20])
        {
            Caption = 'Bank / Cash Account No.';
            TableRelation = "Bank Account";

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
            begin
                if BankAccount.Get("Bank Account No.") then
                    "Bank Account Name" := BankAccount.Name
                else
                    "Bank Account Name" := '';
            end;
        }
        field(3; "Bank Account Name"; Text[100])
        {
            Caption = 'Bank / Cash Account Name';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "User ID", "Bank Account No.") { Clustered = true; }
        key(Bank; "Bank Account No.") { }
    }
}
