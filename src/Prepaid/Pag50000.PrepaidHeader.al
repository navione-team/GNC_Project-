page 50000 PrepaidHeader
{
    ApplicationArea = All;
    Caption = 'PrepaidHeader';
    PageType = Card;
    SourceTable = PrepaiedHeader;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = IsOpen;
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.', Comment = '%';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ToolTip = 'Specifies the value of the Total Amount field.', Comment = '%';
                }
                field("Number Of Rental"; Rec."Number Of Rental")
                {
                    ToolTip = 'Specifies the value of the Number Of Rental field.', Comment = '%';
                }
                field("Begining Date"; Rec."Begining Date")
                {
                    ToolTip = 'Specifies the value of the Begining Date field.', Comment = '%';
                }
                field("Final Date"; Rec."Final Date")
                {
                    ToolTip = 'Specifies the value of the Final Date field.', Comment = '%';
                }

                field("Debit Global Amount Account"; Rec."Debit Global Amount Account")
                {

                }

                field("Credit Global Amount Account"; Rec."Credit Global Amount Account")
                {

                }

                field("Debit Amount Account"; Rec."Debit Amount Account")
                {
                    ToolTip = 'Specifies the value of the Debit Amount Account field.', Comment = '%';
                }
                field("Credit Amount Account"; Rec."Credit Amount Account")
                {
                    ToolTip = 'Specifies the value of the Credit Amount Account field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                }
                field(Observation; Rec.Observation)
                {
                    ToolTip = 'Specifies the value of the Observation field.', Comment = '%';
                }
            }
            part("Prepaid Line"; PrepaidLine)
            {
                Editable = IsOpen;
                ApplicationArea = all;
                SubPageLink = "No. Prepaid" = FIELD("No.");
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action("Generate Echu Amounts")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = AddAction;
                trigger OnAction()
                var
                    TextL001: Label 'Do you confirm ?';
                    TextL002: Label 'Action finished with success';
                    PrepaidLine: Record PrepaidLine;
                    RentalAmount: Decimal;
                    CumulRentalAmount: Decimal;
                    I: Integer;
                begin
                    Rec.TestField("Total Amount");
                    Rec.TestField("Number Of Rental");
                    Rec.TestField("Begining Date");
                    Rec.TestField("Debit Amount Account");
                    Rec.TestField("Credit Amount Account");
                    if Rec.Status <> Rec.Status::Open then
                        exit;
                    if not Confirm(TextL001) then
                        exit;

                    RentalAmount := Round(Rec."Total Amount" / Rec."Number Of Rental", 0.01);

                    for I := 1 to Rec."Number Of Rental" do begin
                        PrepaidLine.Init();
                        PrepaidLine."No. Prepaid" := Rec."No.";
                        // 1ère échéance = date de début, puis +1 mois à chaque échéance
                        PrepaidLine."Due Date" := CalcDate('<' + Format(I - 1) + 'M>', Rec."Begining Date");

                        if I = Rec."Number Of Rental" then
                            // dernière échéance : absorbe l'écart d'arrondi
                            PrepaidLine.Amount := Rec."Total Amount" - CumulRentalAmount
                        else begin
                            PrepaidLine.Amount := RentalAmount;
                            CumulRentalAmount += RentalAmount;
                        end;

                        PrepaidLine.Insert();
                    end;

                    Rec.Status := Rec.Status::"Echu Created";
                    Rec.Modify();
                    Message(TextL002);
                end;
            }

            action("Genrate First Accounting Entries")
            {
                Visible = false;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = LedgerEntries;
                trigger OnAction()
                var
                    TextL001: Label 'Do you confirm ?';
                    TextL002: Label 'Action finished with success';
                    PrepaidLine: Record PrepaidLine;
                    GeneralJournalSetup: Record "General Ledger Setup";
                    GeneraJournalLine: Record "Gen. Journal Line";
                begin
                    if rec.Status <> rec.Status::"Echu Created" then exit;
                    if not Confirm(TextL001) then exit;

                    GeneralJournalSetup.get;
                    GeneraJournalLine.setrange("Journal Template Name", GeneralJournalSetup."Default Gen. Jrnl Prepaid Temp");
                    GeneraJournalLine.setrange("Journal Batch Name", GeneralJournalSetup."Default Gen. Jrnl Prep Batch");
                    GeneraJournalLine.DeleteAll();
                    // Debit 
                    GeneraJournalLine.init;
                    GeneraJournalLine."Journal Template Name" := GeneralJournalSetup."Default Gen. Jrnl Prepaid Temp";
                    GeneraJournalLine."Journal Batch Name" := GeneralJournalSetup."Default Gen. Jrnl Prep Batch";
                    GeneraJournalLine."Line No." := 10000;
                    GeneraJournalLine."Document No." := rec."No.";
                    GeneraJournalLine.VALIDATE("Posting Date", rec.Date);
                    GeneraJournalLine."Account Type" := GeneraJournalLine."Account Type"::"G/L Account";
                    GeneraJournalLine.VALIDATE("Account No.", rec."Debit Global Amount Account");
                    GeneraJournalLine.Validate("Source Code", GeneralJournalSetup."Prepaid Source Code");
                    GeneraJournalLine.Validate(amount, rec."Total Amount");
                    GeneraJournalLine."Hide Dialog" := true;
                    GeneraJournalLine.Insert();
                    // Credit
                    GeneraJournalLine.init;
                    GeneraJournalLine."Journal Template Name" := GeneralJournalSetup."Default Gen. Jrnl Prepaid Temp";
                    GeneraJournalLine."Journal Batch Name" := GeneralJournalSetup."Default Gen. Jrnl Prep Batch";
                    GeneraJournalLine."Line No." := 20000;
                    GeneraJournalLine."Document No." := rec."No.";
                    GeneraJournalLine.VALIDATE("Posting Date", rec.Date);
                    GeneraJournalLine."Account Type" := GeneraJournalLine."Account Type"::"G/L Account";
                    GeneraJournalLine.VALIDATE("Account No.", rec."Credit Global Amount Account");
                    GeneraJournalLine.Validate("Source Code", GeneralJournalSetup."Prepaid Source Code");
                    GeneraJournalLine.Validate(amount, -rec."Total Amount");
                    GeneraJournalLine."Hide Dialog" := true;
                    GeneraJournalLine.Insert();
                    // Generate Entries
                    GeneraJournalLine.Reset();
                    GeneraJournalLine.setrange("Journal Template Name", GeneralJournalSetup."Default Gen. Jrnl Prepaid Temp");
                    GeneraJournalLine.setrange("Journal Batch Name", GeneralJournalSetup."Default Gen. Jrnl Prep Batch");
                    if GeneraJournalLine.FindFirst() THEN
                        CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", GeneraJournalLine);

                    rec.Status := rec.Status::"First Entries Created";
                    rec.Modify();
                    Message(TextL002);
                end;

            }

            action("Naviguate")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Navigate;
                trigger OnAction()
                var
                    TextL001: Label 'Do you confirm ?';
                    TextL002: Label 'Action finished with success';
                    PrepaidLine: Record PrepaidLine;
                    GeneralJournalSetup: Record "General Ledger Setup";
                    GLEntry: Record "G/L Entry";
                begin
                    GLEntry.Reset();
                    GLEntry.SetRange("Document No.", rec."No.");
                    page.RunModal(20, GLEntry)
                end;
            }
        }


    }
    trigger OnOpenPage()
    var

    begin
        if rec.Status <> rec.Status::Open then
            IsOpen := false
        else
            IsOpen := true;
    end;

    var
        IsOpen: Boolean;
}
