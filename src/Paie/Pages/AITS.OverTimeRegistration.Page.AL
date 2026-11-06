page 70054 "Over Time Registration"
{
    PageType = List;
    SourceTable = "Employee Absence";
    SourceTableView = ORDER(Ascending);
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Employee No."; Rec."Employee No.") { ApplicationArea = All; }
                field("Full Name"; Rec."Full Name") { ApplicationArea = All; }
                field("Entry Type"; Rec."Entry Type") { ApplicationArea = All; }
                field("Posting month"; Rec."Posting month") { ApplicationArea = All; }
                field("Posting year"; Rec."Posting year") { ApplicationArea = All; }
                field("Over Time Hours"; Rec."Over Time Hours") { ApplicationArea = All; }
                field("Over time Rate"; Rec."Over time Rate") { ApplicationArea = All; }
                field("Over Time Amount"; Rec."Over Time Amount") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(PostOverTime)
            {
                Caption = '✔ Post';
                // Promoted = true;


                ApplicationArea = All;
                trigger OnAction()
                var
                    confirmed: Boolean;
                    RecGPostedAbsence: Record "Employee Posted Absence";
                begin
                    confirmed := confirm('Do you went to Post?', false);
                    if confirmed then begin
                        CurrPage.SetSelectionFilter(rec);
                        if rec.findset then
                            repeat
                                if rec."Posting month" = 0 then
                                    error('Month should not be Empty')
                                else begin
                                    RecGPostedAbsence.init;
                                    RecGPostedAbsence.TransferFields(Rec);
                                    RecGPostedAbsence.Validate("Posting year");
                                    RecGPostedAbsence.insert;

                                end;
                            until rec.next = 0;
                        rec.DeleteAll();
                        Message('Over Time sucessfully posted');
                    end;

                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)

    begin
        rec."Entry Type" := rec."Entry Type"::"Over Time";
        rec."Posting year" := Date2DMY(WorkDate(), 3);
    end;


}

