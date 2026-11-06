namespace LABSCloud.LABSCloud;

using Microsoft.Finance.GeneralLedger.Journal;

tableextension 50001 GenenralJournalLine extends "Gen. Journal Line" //81
{
    fields
    {
        field(50000; "WHT Integerated"; Boolean)
        {
            Caption = 'WHT Integerated';
            DataClassification = ToBeClassified;
        }
        field(50001; "Prepaid"; Boolean)
        {
            Caption = 'Prepaid';
            DataClassification = ToBeClassified;
        }
        field(50002; "Hide Dialog"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
}
