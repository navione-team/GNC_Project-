tableextension 60010 "GeneralLedgerSetupTab" extends "General Ledger Setup"//98
{
    fields
    {
        Field(50000; "Default Gen. Jrnl Prepaid Temp"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Default General Journal Prepaid Tempalte';
            TableRelation = "Gen. Journal Template";
        }


        Field(50001; "Default Gen. Jrnl Prep Batch"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Default General Journal Prepaid Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Default Gen. Jrnl Prepaid Temp"));
        }

        field(50002; "Prepaid Serial No."; Code[30])
        {
            DataClassification = ToBeClassified;

            TableRelation = "No. Series";
        }

        field(50003; "Prepaid Source Code"; Code[20])
        {
            DataClassification = ToBeClassified;

            TableRelation = "Source Code";
        }

        field(50004; "WHT Journal Template Code"; Code[10])
        {
            Caption = 'WHT Journal Template Code';
            TableRelation = "Gen. Journal Template";
        }

        field(50005; "WHT Journal Batch Code"; Code[10])
        {
            Caption = 'WHT Journal Batch Code';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("WHT Journal Template Code"));
        }
        field(50006; "WHT Debit Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(50007; "WHT Credit Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }


        field(50008; "Deposit Serial No."; Code[30])
        {
            DataClassification = ToBeClassified;

            TableRelation = "No. Series";
        }


        field(50009; "Deposit Debit Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(50010; "Deposit Credit Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(50011; "Deposit Vat Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }


        Field(50012; "Default Gen. Jrnl Temp"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Default General Journal Tempalte';
            TableRelation = "Gen. Journal Template";
        }


        Field(50013; "Default Gen. Jrnl Batch"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Default General Journal Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Default Gen. Jrnl Temp"));
        }


        Field(50014; "Default Gen. Jrnl POS Temp"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Default General Journal POS Tempalte';
            TableRelation = "Gen. Journal Template";
        }


        Field(50015; "Default Gen. Jrnl POS Batch"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Default General Journal POS Batch';
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Default Gen. Jrnl Prepaid Temp"));
        }

        field(50016; "Change Serial No."; Code[30])
        {
            DataClassification = ToBeClassified;

            TableRelation = "No. Series";
        }

        field(50017; "Non Compliance Serial No."; Code[30])
        {
            DataClassification = ToBeClassified;

            TableRelation = "No. Series";
        }

        field(50018; "Complaint Serial No."; Code[30])
        {
            DataClassification = ToBeClassified;

            TableRelation = "No. Series";
        }
        field(50019; "Prepaid Debit Global Amnt Acc"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
            Caption = 'Default Debit Prepaid Global Amount Account';
        }
        field(50020; "Prepaid Credit Global Amnt Acc"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
            Caption = 'Default Credit Prepaid Global Amount Account';
        }


        field(50021; "Prepaid Debit Amount Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
            Caption = 'Default Debit Prepaid Amount Account';
        }
        field(50022; "Prepaid Credit Amount Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
            Caption = 'Default Credit Prepaid Amount Account';
        }












    }
}