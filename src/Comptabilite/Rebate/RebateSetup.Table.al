table 50300 "NAV Rebate Setup"
{
    Caption = 'Customer Rebate Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10; "Agreement Nos."; Code[20])
        {
            Caption = 'Rebate Agreement Nos.';
            TableRelation = "No. Series";
        }
        field(11; "Calculation Nos."; Code[20])
        {
            Caption = 'Rebate Calculation Nos.';
            TableRelation = "No. Series";
        }
        field(12; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";
        }
        field(13; "Credit Memo Reason Code"; Code[10])
        {
            Caption = 'Credit Memo Reason Code';
            TableRelation = "Reason Code";
        }
        // End of Deal
        field(20; "End of Deal Expense Acc."; Code[20])
        {
            Caption = 'End of Deal Expense Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(21; "End of Deal Accrued Acc."; Code[20])
        {
            Caption = 'Accrued End of Deal Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
        // Core Rebate
        field(30; "Core Expense Acc."; Code[20])
        {
            Caption = 'Core Rebate Expense Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(31; "Core Accrued Acc."; Code[20])
        {
            Caption = 'Accrued Core Rebate Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
        // Cash Discount
        field(40; "Cash Discount Expense Acc."; Code[20])
        {
            Caption = 'Cash Discount Expense Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
        }
        field(41; "Cash Discount Accrued Acc."; Code[20])
        {
            Caption = 'Accrued Cash Discount Account';
            TableRelation = "G/L Account" where("Account Type" = const(Posting), Blocked = const(false));
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

    procedure GetAccounts(RebateType: Enum "NAV Rebate Type"; var ExpenseAcc: Code[20]; var AccruedAcc: Code[20])
    begin
        case RebateType of
            RebateType::"End of Deal":
                begin
                    TestField("End of Deal Expense Acc.");
                    TestField("End of Deal Accrued Acc.");
                    ExpenseAcc := "End of Deal Expense Acc.";
                    AccruedAcc := "End of Deal Accrued Acc.";
                end;
            RebateType::"Core Rebate":
                begin
                    TestField("Core Expense Acc.");
                    TestField("Core Accrued Acc.");
                    ExpenseAcc := "Core Expense Acc.";
                    AccruedAcc := "Core Accrued Acc.";
                end;
            RebateType::"Cash Discount":
                begin
                    TestField("Cash Discount Expense Acc.");
                    TestField("Cash Discount Accrued Acc.");
                    ExpenseAcc := "Cash Discount Expense Acc.";
                    AccruedAcc := "Cash Discount Accrued Acc.";
                end;
        end;
    end;
}
