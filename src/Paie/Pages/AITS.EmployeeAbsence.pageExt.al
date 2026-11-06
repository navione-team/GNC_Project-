pageextension 70052 EmployeeAbsencePageExt extends "Absence Registration"
{
    layout
    {
        addafter("Employee No.")
        {
            field("Full Name"; Rec."Full Name")
            { ApplicationArea = all; }
        }
        addafter(Quantity)
        {
            field("Quantity(days)"; Rec."Quantity(days)")
            { ApplicationArea = All; }
        }
        movebefore("From Date"; "Unit of Measure Code")
        modify(Comment)
        {
            Visible = false;
        }


    }
    actions
    {
        addlast(Processing) // put the button in the Process group
        {
            action(PostAbsence)
            {
                ApplicationArea = All;
                Caption = 'Post';
                Image = Post;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Post the selected absence registration lines.';

                trigger OnAction()
                var
                    RecG_Posted_Absence: Record "Employee Posted Absence"; // use the source table of the page
                    lastNo: Integer;
                begin
                    IF NOT CONFIRM('Would you like to proceed with registering?', FALSE) THEN
                        MESSAGE('Not registred') ELSE BEGIN
                        lastNo := 0;

                        // IF RecG_Posted_Absence.FINDLAST THEN
                        RecG_Posted_Absence.RESET;
                        RecG_Posted_Absence.SETCURRENTKEY("Entry No.");
                        IF RecG_Posted_Absence.FINDLAST THEN
                            lastNo := RecG_Posted_Absence."Entry No.";

                        Rec.RESET;
                        Rec.SETCURRENTKEY("Entry No.");
                        IF Rec.FindSet() THEN
                            REPEAT
                                RecG_Posted_Absence.INIT;
                                //Message(FORMAT(RecG_Posted_Absence."Entry No."));
                                RecG_Posted_Absence.TRANSFERFIELDS(Rec);
                                RecG_Posted_Absence."Entry No." := lastNo + 1;
                                RecG_Posted_Absence.VALIDATE("Posting year");
                                RecG_Posted_Absence.VALIDATE("Quantity (Base)", Rec.Quantity);
                                RecG_Posted_Absence.INSERT;
                            UNTIL Rec.NEXT = 0;
                        Rec.DELETEALL;
                        MESSAGE('Employee Absence Sucessfully Registred');
                    END;

                    CurrPage.Update(false);
                end;
            }
        }
    }



}