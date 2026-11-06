page 50204 "NAV Transit Folder Accruals"
{
    Caption = 'Transit Folder Charge Accruals';
    PageType = List;
    SourceTable = "NAV Transit Folder Accrual";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number.';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the entry is an accrual (posted at goods receipt) or a reversal (posted at charge invoice).';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posting date.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the posted receipt (accrual) or posted invoice (reversal) number.';
                }
                field("Folder No."; Rec."Folder No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transit folder.';
                }
                field("Item Charge No."; Rec."Item Charge No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item charge.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the received item.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the receiving location.';
                }
                field("Inventory Account No."; Rec."Inventory Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the inventory account debited by the accrual.';
                }
                field("Clearing Account No."; Rec."Clearing Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the clearing account credited by the accrual.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount. A positive amount is an accrual, a negative amount is a reversal.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who posted the entry.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(GLEntries)
            {
                ApplicationArea = All;
                Caption = 'G/L Entries';
                Image = GLRegisters;
                ToolTip = 'Opens the G/L entries of the document.';

                trigger OnAction()
                var
                    GLEntry: Record "G/L Entry";
                begin
                    GLEntry.SetRange("Document No.", Rec."Document No.");
                    GLEntry.SetRange("Posting Date", Rec."Posting Date");
                    Page.Run(Page::"General Ledger Entries", GLEntry);
                end;
            }
        }
        area(Promoted)
        {
            actionref(GLEntries_Promoted; GLEntries) { }
        }
    }
}
