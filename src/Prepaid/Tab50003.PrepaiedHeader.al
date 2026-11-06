table 50003 PrepaiedHeader
{
    Caption = 'PrepaiedHeader';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; "Date"; Date)
        {
            Caption = 'Date';
        }
        field(3; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
        }
        field(4; "Number Of Rental"; Integer)
        {
            Caption = 'Number Of Rental';
        }
        field(5; Observation; Text[50])
        {
            Caption = 'Observation';
        }
        field(6; "Begining Date"; Date)
        {
            Caption = 'Begining Date';
            // 
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                "Final Date" := CalcDate(format("Number Of Rental" - 1) + 'M', "Begining Date");
            end;
        }
        field(7; "Final Date"; Date)
        {
            Caption = 'Final Date';
        }
        field(8; "Debit Global Amount Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(9; "Credit Global Amount Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }


        field(10; "Debit Amount Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(11; "Credit Amount Account"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "G/L Account";
        }
        field(12; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(13; Status; Enum "Prepaid Status")
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        //  NoSeriesMgt: codeunit NoSeriesManagement;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin

        IF "No." = '' THEN BEGIN
            GeneralLedgerSetup.get;
            //  NoSeriesMgt.InitSeries(GeneralLedgerSetup."Prepaid Serial No.", xRec."No. Series", TODAY, "No.", "No. Series");
            "No." := GetNextNo(GeneralLedgerSetup."Prepaid Serial No.", Today);
            GeneralLedgerSetup.Get();
            "Debit Global Amount Account" := GeneralLedgerSetup."Prepaid Debit Global Amnt Acc";
            "Credit Global Amount Account" := GeneralLedgerSetup."Prepaid Credit Global Amnt Acc";
            "Debit Amount Account" := GeneralLedgerSetup."Prepaid Debit Amount Account";
            "Credit Amount Account" := GeneralLedgerSetup."Prepaid Credit Amount Account";
        END;
    end;

    trigger OnDelete()
    var
        TextL001: Label 'prohibition of removal';
    begin
        if Status <> Status::Open then Error(TextL001);
    end;

    procedure GetNextNo(NoSeriesCode: Code[20]; UsageDate: Date): Code[20]
    var
        NoSeriesImpl: Codeunit "No. Series";
    begin
        exit(NoSeriesImpl.GetNextNo(NoSeriesCode, UsageDate, false));
    end;

}
