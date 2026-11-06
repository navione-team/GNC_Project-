page 70042 "Incentive Entry"
{
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Employee Absence";
    SourceTableView = WHERE("Entry Type" = FILTER("Over Time"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                }
                field("Employee No."; Rec."Employee No.")
                {
                }
                field(Name; Rec."Full Name")
                {
                    Caption = 'Employee Full Name';
                }
                field("Posting month"; Rec."Posting month")
                {
                }
                field("Posting year"; Rec."Posting year")
                {
                }
                field("Incentive Amount"; Rec."Incentive Amount")
                {
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                }
                field(Description; Rec.Description)
                {
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(Post)
            {
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if not Confirm('Would you like to proceed with registering?', false) then
                        Message('Not registred') else begin

                        //  Rec.RESET;
                        //  Rec.SETCURRENTKEY("Entry No.");

                        // IF RecG_Posted_Absence.FINDLAST THEN

                        CurrPage.SetSelectionFilter(Rec);
                        if Rec.FindSet then
                            repeat
                                if Rec."Posting month" = 0 then
                                    Error('Month should not be empty');
                                RecG_Posted_Absence.INIT;
                                RecG_Posted_Absence.TRANSFERFIELDS(Rec);
                                RecG_Posted_Absence.VALIDATE("Posting year");
                                RecG_Posted_Absence.INSERT;

                            until Rec.Next = 0;
                        Rec.DeleteAll;
                        Message('Employee OverTime Sucessfully Registred');
                    end;
                end;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin


        Rec."Over time Rate" := 1;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Posting year" := Date2DMY(WorkDate, 3);
        Rec."Over time Rate" := 1;
    end;

    trigger OnOpenPage()
    begin
        Rec."Entry Type" := Rec."Entry Type"::"Over Time";
        Rec."Over time Rate" := 1;
    end;

    var
        RecG_Posted_Absence: Record "Employee Posted Absence";
        visible: Boolean;
}

