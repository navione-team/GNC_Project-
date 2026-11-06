tableextension 70028 "Employee Posting Group Ext" extends "Employee Posting Group"
{
    fields
    {
        field(70000; "G/L Expense Account"; Code[20])
        {
            Caption = 'G/L Expense Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70001; "G/L Basic Salary"; Code[20])
        {
            Caption = 'G/L Basic Salary';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70002; "G/L Housing Allowance"; Code[20])
        {
            Caption = 'G/L Housing Allowance';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70003; "G/L Transportation Allowance"; Code[20])
        {
            Caption = 'G/L Transportation Allowance';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70004; "G/L Mobile Allowance"; Code[20])
        {
            Caption = 'G/L Mobile Allowance';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70005; "G/L Education Allowance"; Code[20])
        {
            Caption = 'G/L Education Allowance';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70006; "G/L Staff Bonus"; Code[20])
        {
            Caption = 'G/L Staff Bonus';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70007; "G/L Leave Ticket Expenses"; Code[20])
        {
            Caption = 'G/L Leave Ticket Expenses';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70008; "G/L Leave Salary Expenses"; Code[20])
        {
            Caption = 'G/L Leave Salary Expenses';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70009; "G/L End of Service Indemnity"; Code[20])
        {
            Caption = 'G/L End of Service Indemnity';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70010; "G/L Social Security (GOSI)"; Code[20])
        {
            Caption = 'G/L Social Security (GOSI)';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
        field(70011; "G/L Sales Comm"; Code[20])
        {
            Caption = 'G/L Sales Comm';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
        }
    }
}
