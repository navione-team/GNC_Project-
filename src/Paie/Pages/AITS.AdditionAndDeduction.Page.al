page 70048 "Additions & Deductions"
{
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Employee Absence";
    SourceTableView = WHERE("Entry Type" = FILTER("Addition" | "Deduction"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; rec."Entry Type")
                {

                }
                field("Employee No."; rec."Employee No.")
                {
                    trigger OnValidate()
                    begin
                        if recGEmployee.get(rec."Employee No.") THEN begin
                            recGEmployee.CalcFields("Basic Salary", "Gross Salary");
                            rec."Basic Salary" := recGEmployee."Basic Salary";
                            rec."Gross Salary" := recGEmployee."Gross Salary";
                            rec."Posting year" := Date2DMY(Today(), 3);
                            rec."Full Name" := recGEmployee."Full Name";
                        end;

                    end;
                }
                field(Name; rec."Full Name")
                {
                    Caption = 'Full Name';
                }
                field("Basic Salary"; rec."Basic Salary")
                {
                    Editable = false;
                }
                field("Gross Salary"; rec."Gross Salary")
                {
                    Editable = false;
                }
                field("Posting month"; rec."Posting month")
                {
                }
                field("Posting year"; rec."Posting year")
                {
                }
                field(Amount; rec.Amount)
                {
                }
                field("Global Dimension 1 Code"; rec."Global Dimension 1 Code")
                {
                }
                field(Description; rec.Description)
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
                        Message('Not registred') else begiN

                        RecG_Posted_Absence.RESET;
                        IF RecG_Posted_Absence.FINDLAST THEN
                            EntryNo := RecG_Posted_Absence."Entry No." + 1;
                        Rec.RESET;
                        Rec.SETCURRENTKEY("Entry No.");
                        Rec.SetFilter("Entry Type", '%1|%2', Rec."Entry Type"::Addition, Rec."Entry Type"::Deduction);
                        if Rec.FindSet() then
                            repeat
                                if rec."Posting month" = 0 then
                                    Error('Month should not be empty');
                                RecG_Posted_Absence.INIT;
                                RecG_Posted_Absence.TRANSFERFIELDS(Rec);
                                RecG_Posted_Absence."Entry No." := EntryNo;
                                RecG_Posted_Absence.VALIDATE("Posting year");
                                RecG_Posted_Absence.INSERT;
                                EntryNo := EntryNo + 1;
                            until Rec.Next = 0;
                        Rec.DeleteAll;
                        Message('Sucessfully Registred');
                    end;
                end;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin


        rec."Over time Rate" := 1;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        rec."Posting year" := Date2DMY(WorkDate, 3);
        rec."Over time Rate" := 1;
    end;

    trigger OnOpenPage()
    begin
        rec."Entry Type" := rec."Entry Type"::"Over Time";
        rec."Over time Rate" := 1;
    end;

    var
        RecG_Posted_Absence: Record "Employee Posted Absence";
        visible: Boolean;
        recGEmployee: Record Employee;
        EntryNo: Integer;
}

