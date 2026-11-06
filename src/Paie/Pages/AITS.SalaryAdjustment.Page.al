page 70057 "Salary Adjustement Entry"
{
    PageType = List;
    SourceTable = "Employee Absence";
    SourceTableView = WHERE("Entry Type" = FILTER("Salary adjustment"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; Rec."Entry Type") { ApplicationArea = All; }
                field("Employee No."; Rec."Employee No.") { ApplicationArea = All; }
                field("Full Name"; Rec."Full Name") { ApplicationArea = All; }
                field("Posting month"; Rec."Posting month") { ApplicationArea = All; }
                field("Posting year"; Rec."Posting year") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field(Remarks; Rec.Remarks) { ApplicationArea = All; }


            }
        }
    }
    actions
    {
        area(processing)
        {
            action(Post)
            {
                Caption = '✔ Post';
                // Promoted = true;


                ApplicationArea = All;
                trigger OnAction()
                var
                    confirmed: Boolean;
                    lineno: Integer;
                    RecGPostedAbsence: Record "Employee Posted Absence";
                begin
                    Confirmed := Confirm('Do you want to post?', false);
                    if not Confirmed then
                        exit;

                    Rec.SetFilter("Entry Type", '%1', Rec."Entry Type"::"Salary Adjustment");

                    if Rec.FindFirst() then
                        repeat
                            if RecGPostedAbsence.FindLast() then
                                LineNo := RecGPostedAbsence."Entry No." + 1
                            else
                                LineNo := 1;

                            if Rec."Posting month" = 0 then
                                Error('Month should not be empty.');

                            RecGPostedAbsence.Reset();
                            RecGPostedAbsence.Init();
                            RecGPostedAbsence.TransferFields(Rec);
                            RecGPostedAbsence."Entry No." := LineNo;
                            RecGPostedAbsence.Validate("Posting year");

                            RecGPostedAbsence.Insert(true); // Insert with trigger
                        until Rec.Next() = 0;
                    rec.DeleteAll();
                    Message('Adjustment sucessfully posted');
                end;

                //  end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)

    begin
        rec."Entry Type" := rec."Entry Type"::"Salary Adjustment";
        rec."Posting year" := Date2DMY(WorkDate(), 3);
    end;


}

