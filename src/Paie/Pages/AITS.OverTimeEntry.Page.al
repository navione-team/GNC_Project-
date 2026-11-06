page 70043 "OverTime Entry"
{
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Employee Absence";
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
                field("Employee Basic Salary"; rec."Basic Salary")
                {
                    Editable = false;
                }
                field(Unit; rec.Unit)
                {

                    trigger OnValidate()
                    begin
                        if rec.Unit = rec.Unit::Day then
                            visible := true;
                        if rec.Unit = rec.Unit::Hour then
                            Hvisible := true;
                        CurrPage.Update(true);
                    end;
                }
                field("Gross Salary"; rec."Gross Salary")
                {
                    Editable = false;
                }
                field("OverTime Quantity Days"; rec."OverTime Quantity Days")
                {
                    Visible = visible;

                    trigger OnValidate()
                    begin
                        rec.CalcFields("Work Company");
                        if rec."Work Company" = 'KZUAE' then
                            rec.Validate("Over Time Amount", ((rec."Basic Salary" / 30) * rec."OverTime Quantity Days") * rec."Over time Rate")
                        else
                            rec.Validate("Over Time Amount", (((rec."Gross Salary" / 30)) * rec."OverTime Quantity Days"));
                    end;
                }
                field("Over time Rate"; rec."Over time Rate")
                {
                }
                field("Over Time Hours"; rec."Over Time Hours")
                {
                    Visible = hvisible;

                    trigger OnValidate()
                    begin


                        rec.Validate("Over Time Amount", ((((rec."Basic Salary" / 30) / 8) * rec."Over Time Hours")) * (rec."Over time Rate"));
                    end;
                }
                field("Posting month"; rec."Posting month")
                {
                }
                field("Posting year"; rec."Posting year")
                {
                }
                field("Global Dimension 1 Code"; rec."Global Dimension 1 Code")
                {
                }
                field("Over Time Amount"; rec."Over Time Amount")
                {
                }
                field(Description; rec.Description)
                {
                }
                field("Work Company"; rec."Work Company")
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
                                if rec."Posting month" = 0 then
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
        visible := false;
        Hvisible := false;
    end;

    var
        RecG_Posted_Absence: Record "Employee Posted Absence";
        visible: Boolean;
        Hvisible: Boolean;
        AmountHours: Decimal;
}

