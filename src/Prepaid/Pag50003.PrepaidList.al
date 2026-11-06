page 50003 PrepaidList
{
    ApplicationArea = All;
    Caption = 'Prepaid List';
    PageType = List;
    SourceTable = PrepaiedHeader;
    UsageCategory = Lists;
    CardPageId = PrepaidHeader;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.', Comment = '%';
                }
                field("Begining Date"; Rec."Begining Date")
                {
                    ToolTip = 'Specifies the value of the Begining Date field.', Comment = '%';
                }
                field("Final Date"; Rec."Final Date")
                {
                    ToolTip = 'Specifies the value of the Final Date field.', Comment = '%';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ToolTip = 'Specifies the value of the Total Amount field.', Comment = '%';
                }
                field("Number Of Rental"; Rec."Number Of Rental")
                {
                    ToolTip = 'Specifies the value of the Number Of Rental field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Insert Rentall Ledger Entries")
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    GlobalFunction: Codeunit "Global Function";
                    TextL001: Label 'Confirm This Action ?';
                begin
                    if not confirm(TextL001) then exit;
                    GlobalFunction.InsertPrepaidRental();
                end;
            }
        }
    }
}
