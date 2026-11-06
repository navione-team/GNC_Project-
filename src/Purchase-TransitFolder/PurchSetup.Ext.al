tableextension 50201 "NAV Purch. Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50200; "Transit Folder Nos."; Code[20])
        {
            Caption = 'Transit Folder Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50201; "Auto Create Charge Orders"; Boolean)
        {
            Caption = 'Auto Create Charge Orders';
            DataClassification = CustomerContent;
        }
        field(50202; "Auto Post Charge Receipt"; Boolean)
        {
            Caption = 'Auto Post Charge Receipt';
            DataClassification = CustomerContent;
        }
        field(50203; "Post Charge Accruals"; Boolean)
        {
            Caption = 'Post Charge Accruals at Receipt';
            DataClassification = CustomerContent;
        }
    }
}

pageextension 50201 "NAV Purch. Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(content)
        {
            group(NAVTransitFolder)
            {
                Caption = 'Transit Folders';

                field("Transit Folder Nos."; Rec."Transit Folder Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series used for transit folders.';
                }
                field("Auto Create Charge Orders"; Rec."Auto Create Charge Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that charge orders are created automatically when all orders of the folder are completely received.';
                }
                field("Auto Post Charge Receipt"; Rec."Auto Post Charge Receipt")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the receipt of charge orders is posted automatically after they are created and assigned.';
                }
                field("Post Charge Accruals"; Rec."Post Charge Accruals")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the estimated charges of the transit folder are posted to the G/L when the goods are received (debit inventory account of the location, credit clearing account of each item charge). The accrual is reversed when the charge order is invoiced.';
                }
            }
        }
    }
}
