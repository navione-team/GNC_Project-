page 50310 "NAV Bank Facility Setup"
{
    Caption = 'Bank Facility Setup';
    PageType = Card;
    SourceTable = "NAV Bank Facility Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Facility Nos."; Rec."Facility Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series of the bank facilities. The facility no. is the document no. of its entries.';
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the general journal template where the facility entries are generated.';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the general journal batch reserved for the facility entries (without no. series).';
                }
                field("Review Before Posting"; Rec."Review Before Posting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the generated entries stay in the journal to be reviewed and posted by the user. If not, they are posted at once.';
                }
            }
            group(Defaults)
            {
                Caption = 'Defaults for New Facilities';

                field("Default Facility Account"; Rec."Default Facility Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank facility account (liability) proposed on new facilities.';
                }
                field("Default Commission Account"; Rec."Default Commission Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank charges / commission account proposed on new facilities.';
                }
                field("Default Commission %"; Rec."Default Commission %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the commission rate proposed on new facilities. Leave 0 to enter the commission amount on each facility.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}

page 50311 "NAV Bank Facilities"
{
    Caption = 'Bank Facilities';
    PageType = List;
    SourceTable = "NAV Bank Facility";
    CardPageId = "NAV Bank Facility Card";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    SourceTableView = sorting("No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the facility number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the facility.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank account.';
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank name.';
                }
                field("Facility Date"; Rec."Facility Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the facility date.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    StyleExpr = DueStyle;
                    ToolTip = 'Specifies the due date of the facility.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of the bank account. Empty = local currency.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the facility amount.';
                }
                field("Commission Amount"; Rec."Commission Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank commission paid at the due date.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies the status: Draft, Initial Pending, Open, Matured or Processed.';
                }
                field("Maturity Posting Date"; Rec."Maturity Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the maturity entry was posted.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProcessDue)
            {
                ApplicationArea = All;
                Caption = 'Generate Due Maturity Entries';
                Image = DueDate;
                ToolTip = 'Generates the maturity entries of all the open facilities whose due date is today or earlier (same as the job queue).';

                trigger OnAction()
                var
                    FacilityMgt: Codeunit "NAV Bank Facility Mgt.";
                begin
                    Message(ProcessedMsg, FacilityMgt.ProcessDueFacilities());
                    CurrPage.Update(false);
                end;
            }
            action(Journal)
            {
                ApplicationArea = All;
                Caption = 'Facility Journal';
                Image = Journal;
                ToolTip = 'Opens the general journal batch of the facility entries, to review and post them.';

                trigger OnAction()
                var
                    FacilityMgt: Codeunit "NAV Bank Facility Mgt.";
                begin
                    FacilityMgt.OpenJournal();
                end;
            }
        }
        area(Creation)
        {
            action(ShowOpen)
            {
                ApplicationArea = All;
                Caption = 'Open';
                Image = FilterLines;
                ToolTip = 'Shows the facilities waiting for their due date.';

                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Open);
                end;
            }
            action(ShowMatured)
            {
                ApplicationArea = All;
                Caption = 'Matured';
                Image = FilterLines;
                ToolTip = 'Shows the facilities whose maturity entry is waiting in the journal.';

                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Matured);
                end;
            }
            action(ShowProcessed)
            {
                ApplicationArea = All;
                Caption = 'Processed';
                Image = FilterLines;
                ToolTip = 'Shows the facilities repaid.';

                trigger OnAction()
                begin
                    Rec.SetRange(Status, Rec.Status::Processed);
                end;
            }
            action(ShowAll)
            {
                ApplicationArea = All;
                Caption = 'All';
                Image = ClearFilter;
                ToolTip = 'Shows all the facilities.';

                trigger OnAction()
                begin
                    Rec.SetRange(Status);
                end;
            }
        }
        area(Promoted)
        {
            actionref(ProcessDue_Promoted; ProcessDue) { }
            actionref(Journal_Promoted; Journal) { }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StatusStyle := '';
        DueStyle := '';
        case Rec.Status of
            Rec.Status::Open:
                begin
                    StatusStyle := 'Ambiguous';
                    if (Rec."Due Date" <> 0D) and (Rec."Due Date" <= Today()) then
                        DueStyle := 'Unfavorable';
                end;
            Rec.Status::Matured, Rec.Status::"Initial Pending":
                StatusStyle := 'StrongAccent';
            Rec.Status::Processed:
                StatusStyle := 'Favorable';
        end;
    end;

    var
        StatusStyle: Text;
        DueStyle: Text;
        ProcessedMsg: Label '%1 maturity entry(ies) generated.', Comment = '%1 = count';
}

page 50312 "NAV Bank Facility Card"
{
    Caption = 'Bank Facility';
    PageType = Card;
    SourceTable = "NAV Bank Facility";
    DataCaptionFields = "No.", Description;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = IsDraft;
                    ToolTip = 'Specifies the facility number. It is the document no. of the initial and maturity entries.';

                    trigger OnAssistEdit()
                    var
                        Setup: Record "NAV Bank Facility Setup";
                        NoSeries: Codeunit "No. Series";
                    begin
                        Setup.GetSetup();
                        Setup.TestField("Facility Nos.");
                        if NoSeries.LookupRelatedNoSeries(Setup."Facility Nos.", xRec."No. Series", Rec."No. Series") then begin
                            Rec."No." := NoSeries.GetNextNo(Rec."No. Series");
                            CurrPage.Update();
                        end;
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the facility.';
                }
                field("Bank Reference"; Rec."Bank Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reference of the facility given by the bank. It is copied to the External Document No. of the entries.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status: Draft, Initial Pending (initial entry in the journal), Open, Matured (maturity entry in the journal) or Processed.';
                }
            }
            group(Facility)
            {
                Caption = 'Facility';
                Editable = IsDraft;

                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the bank account that receives the facility (debited by the initial entry, credited at the due date).';
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank name.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of the bank account. Empty = local currency.';
                }
                field("Facility Date"; Rec."Facility Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the facility date (posting date of the initial entry).';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the facility amount.';
                }
                field("Facility Account No."; Rec."Facility Account No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the bank facility account, credited by the initial entry and debited at the due date.';
                }
            }
            group(Maturity)
            {
                Caption = 'Due Date and Commission';
                Editable = IsDraft or IsOpen;

                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the due date (posting date of the maturity entry).';
                }
                field("Commission %"; Rec."Commission %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the commission rate. The commission amount is then calculated = facility amount x %.';
                }
                field("Commission Amount"; Rec."Commission Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank commission paid at the due date. Enter it directly when it is not a rate.';
                }
                field("Commission Account No."; Rec."Commission Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank charges / commission account debited at the due date.';
                }
            }
            group(Trace)
            {
                Caption = 'Posting';
                Editable = false;

                field("Initial Posting Date"; Rec."Initial Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the initial entry was posted.';
                }
                field("Initial Bank Entry No."; Rec."Initial Bank Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank ledger entry of the initial entry.';
                }
                field("Maturity Generated"; Rec."Maturity Generated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the maturity entry was generated (it cannot be generated twice).';
                }
                field("Maturity Total"; Rec."Maturity Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total credited to the bank at the due date = amount + commission.';
                }
                field("Maturity Posting Date"; Rec."Maturity Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the maturity entry was posted.';
                }
                field("Maturity Bank Entry No."; Rec."Maturity Bank Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank ledger entry of the maturity entry.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(InitialEntry)
            {
                ApplicationArea = All;
                Caption = 'Generate Initial Entry';
                Image = CreateDocument;
                Enabled = IsDraft;
                ToolTip = 'Generates the initial entry: Debit Bank / Credit Bank Facility Account.';

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    FacilityMgt.GenerateInitialEntry(Rec);
                    CurrPage.Update(false);
                    ShowResult();
                end;
            }
            action(MaturityEntry)
            {
                ApplicationArea = All;
                Caption = 'Generate Maturity Entry';
                Image = DueDate;
                Enabled = IsOpen;
                ToolTip = 'Generates the maturity entry now: Debit Bank Facility Account + Debit Commission / Credit Bank. The job queue does it automatically on the due date.';

                trigger OnAction()
                begin
                    CurrPage.SaveRecord();
                    if Rec."Due Date" > WorkDate() then
                        if not Confirm(EarlyQst, false, Rec."Due Date") then
                            exit;
                    FacilityMgt.GenerateMaturityEntry(Rec);
                    CurrPage.Update(false);
                    ShowResult();
                end;
            }
            action(CancelPending)
            {
                ApplicationArea = All;
                Caption = 'Cancel Pending Entry';
                Image = Cancel;
                Enabled = IsPending;
                ToolTip = 'Deletes the generated lines still in the journal and resets the status (Draft or Open).';

                trigger OnAction()
                begin
                    if not Confirm(CancelQst, false) then
                        exit;
                    FacilityMgt.CancelPendingEntry(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Journal)
            {
                ApplicationArea = All;
                Caption = 'Facility Journal';
                Image = Journal;
                ToolTip = 'Opens the general journal batch of the facility entries, to review and post them.';

                trigger OnAction()
                begin
                    FacilityMgt.OpenJournal();
                end;
            }
        }
        area(Navigation)
        {
            action(BankEntries)
            {
                ApplicationArea = All;
                Caption = 'Bank Account Ledger Entries';
                Image = BankAccountLedger;
                RunObject = page "Bank Account Ledger Entries";
                RunPageLink = "Bank Account No." = field("Bank Account No."), "Document No." = field("No.");
                ToolTip = 'Shows the bank entries of the facility.';
            }
            action(GLEntries)
            {
                ApplicationArea = All;
                Caption = 'G/L Entries';
                Image = GLRegisters;
                RunObject = page "General Ledger Entries";
                RunPageLink = "Document No." = field("No.");
                ToolTip = 'Shows the G/L entries of the facility.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(InitialEntry_Promoted; InitialEntry) { }
                actionref(MaturityEntry_Promoted; MaturityEntry) { }
                actionref(CancelPending_Promoted; CancelPending) { }
                actionref(Journal_Promoted; Journal) { }
            }
            group(Category_Navigate)
            {
                Caption = 'Related';

                actionref(BankEntries_Promoted; BankEntries) { }
                actionref(GLEntries_Promoted; GLEntries) { }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetControls();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsDraft := true;
        IsOpen := false;
        IsPending := false;
    end;

    local procedure SetControls()
    begin
        IsDraft := Rec.Status = Rec.Status::Draft;
        IsOpen := Rec.Status = Rec.Status::Open;
        IsPending := Rec.Status in [Rec.Status::"Initial Pending", Rec.Status::Matured];
    end;

    local procedure ShowResult()
    begin
        if Rec.Status in [Rec.Status::"Initial Pending", Rec.Status::Matured] then
            Message(InJournalMsg, Rec."No.")
        else
            Message(PostedMsg, Rec."No.", Rec.Status);
    end;

    var
        FacilityMgt: Codeunit "NAV Bank Facility Mgt.";
        IsDraft: Boolean;
        IsOpen: Boolean;
        IsPending: Boolean;
        EarlyQst: Label 'The due date is %1. Generate the maturity entry now, on the due date?', Comment = '%1 = due date';
        CancelQst: Label 'Delete the lines of this facility still in the journal?';
        InJournalMsg: Label 'The entries of facility %1 are in the facility journal. Review and post them (action Facility Journal).', Comment = '%1 = no.';
        PostedMsg: Label 'The entries of facility %1 are posted. Status: %2.', Comment = '%1 = no., %2 = status';
}
