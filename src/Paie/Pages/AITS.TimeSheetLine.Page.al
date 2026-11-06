page 70018 "TimeSheet Line"
{
    Caption = 'Attendance TimeSheet';
    PageType = ListPart;
    Permissions = TableData "Employee Posted Absence" = rimd;
    SourceTable = "TimeSheet Line";
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(Control10014522)
            {
                ShowCaption = false;
            }
            repeater(Group)
            {
                field("Entry No"; Rec."Entry No")
                {
                    Visible = false;
                }
                field(Employee; Rec.Employee)
                {
                    Editable = ts;
                    Enabled = ts;

                    trigger OnValidate()
                    begin
                        /*att.RESET;
                        IF att.FINDSET THEN
                         VALIDATE("Attendance No",att."No.");*/
                        if att.Get() then
                            Rec."Attendance No" := att."No.";

                    end;
                }
                field("Employee Full Name"; Rec."Employee Full Name")
                {
                    Editable = ts;
                }
                field(Description; Rec.Description)
                {
                    Editable = ts;
                }
                field(Date; Rec.Date)
                {
                    Editable = ts;

                    trigger OnValidate()
                    begin
                        if Rec.Holiday = true then begin
                            Rec."Time In" := 0T;
                            Rec."Time Out" := 0T;
                            Rec."Worked Hours" := 0T;
                            Rec.Comment := 'Holiday';
                            Rec."Absence Reason" := Rec."Absence Reason"::Holiday;
                        end;
                    end;
                }
                field(Day; Rec.Day)
                {
                    Editable = ts;
                }
                field(Month; Rec.Month)
                {
                    Editable = ts;
                }
                field(Year; Rec.Year)
                {
                    Editable = ts;
                }
                field("Time In"; Rec."Time In")
                {
                    Editable = ts;
                }
                field("Time Out"; Rec."Time Out")
                {
                    Editable = ts;

                    trigger OnValidate()
                    begin
                        //VALIDATE("Time Out");

                        if Rec."Absence Hours" = 0 then Rec."Absence Reason" := Rec."Absence Reason"::" ";
                        if Rec."Absence Hours" > 0 then Rec."Absence Reason" := Rec."Absence Reason"::Late;
                        if Rec."Absence Hours" = 8 then Rec."Absence Reason" := Rec."Absence Reason"::Absent;
                        Rec."Store Code" := Storeno;
                        Rec."Attendance No" := ATTNO;
                        Rec.Month := Date2DMY(Rec.Date, 2);
                        ;
                        Rec.Validate(Rec."Attendance No", att."No.");
                        // VALIDATE(Rec."Store Code",att."Store Code");
                    end;
                }
                field("Time In1"; Rec."Time In1")
                {
                    Editable = ts;
                }
                field("Time Out1"; Rec."Time Out1")
                {
                    Editable = ts;
                }
                field("Store Code"; Rec."Store Code")
                {
                    Editable = ts;
                }
                field("Worked Hours"; Rec."Worked Hours")
                {
                    Editable = ts;
                }
                field("Absence Hours"; Rec."Absence Hours")
                {
                    Editable = ts;
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field("Over Hours"; Rec."Over Hours")
                {
                    Editable = ts;
                    Style = Favorable;
                    StyleExpr = TRUE;
                }
                field(Holiday; Rec.Holiday)
                {
                    Editable = ts;
                }
                field("Absence Reason"; Rec."Absence Reason")
                {
                    Editable = ts;
                }
                field(Comment; Rec.Comment)
                {
                }
                field("Attendance No"; Rec."Attendance No")
                {
                    Editable = ts;
                    Enabled = ts;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Validation)
            {
                Caption = 'Validation';
            }
            group(Action13)
            {
                action("Post TimeSheet Entries")
                {
                    Image = Timesheet;
                    //  Promoted = true;
                    //  PromotedCategory = Process;

                    trigger OnAction()
                    begin



                        CurrPage.SetSelectionFilter(Rec);

                        if Rec.FindSet then
                            repeat
                                RecordedAttendanceTimeSheet.Init;
                                RecordedAttendanceTimeSheet.TransferFields(Rec);
                                RecordedAttendanceTimeSheet.Insert;

                            until Rec.Next = 0;

                        AbsReg(Rec);
                        Rec.Reset;


                        Message('Operation Finished');

                    end;
                }
                action("Update Absence Status")
                {
                    Image = UpdateDescription;
                    //   Promoted = true;
                    //   PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Rec.Reset;
                        if Rec.FindSet then
                            repeat
                                Rec.Validate("Time Out");
                                if Rec."Absence Hours" = 0 then Rec."Absence Reason" := Rec."Absence Reason"::" ";
                                if Rec."Absence Hours" > 0 then Rec."Absence Reason" := Rec."Absence Reason"::Late;
                                if Rec."Absence Hours" = 8 then Rec."Absence Reason" := Rec."Absence Reason"::Absent;
                                Rec."Store Code" := Storeno;
                                Rec."Attendance No" := ATTNO;
                                Rec.Month := PostingMonth;

                                Rec.Modify(true);
                            until Rec.Next = 0;

                    end;
                }
                action("Print Attendance")
                {
                    Image = Print;
                    //Promoted = true;
                    //  PromotedCategory = Process;
                    //  RunObject = Report "Employee Certificate";
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

        if att.Get() then
            Rec."Attendance No" := att."No.";
    end;

    trigger OnModifyRecord(): Boolean
    begin
        //check casual leave
        EmployeePostedAbsence.Reset;
        EmployeePostedAbsence.SetRange("Employee No.", Rec.Employee);
        EmployeePostedAbsence.SetRange("From Date", Rec.Date);
        if EmployeePostedAbsence.FindSet then
            Rec."Absence Reason" := Rec."Absence Reason"::Casual;
        Rec.Year := Date2DMY(Rec.Date, 3);
        Rec.Month := Date2DMY(Rec.Date, 2);
        ///
    end;

    trigger OnOpenPage()
    begin
        if UserSetup.Get(UserId) then
            if UserSetup."Time Sheet Admin." = true then
                ts := true
            else
                ts := false;

    end;

    var
        dialogMess1: Label 'Updating ';
        dialogMess2: Label 'Updating recorded lines.';
        Text001: Label 'Do you want to generate a new checklist?';
        Text002: Label '#1 lines selected.\Are you sure to want to validate the selected lines ?';
        Text003: Label 'La ligne n° %1 _ %2 : %3: %4  presente un risque d''une double saisie avec la ligne n° %5 !';
        Text004: Label 'Le mois de comptabilisation de la ligne n° %1 _ %2  est différente du mois de travail : %3 !';
        Text005: Label 'L''année de comptabilisation de la ligne n° %1 _ %2  est différente de l''année de travail : %3 !';
        lineno: Integer;
        RecordedAttendanceTimeSheet: Record "Recorded Attendance TimeSheet";
        Storeno: Code[20];
        tsyear: Code[10];
        y: Code[10];
        i: Integer;
        varMonth: Code[2];
        PostingMonth: Option " ",January,February,March,April,May,June,July,August,September,October,November,December;
        "Posting year": Integer;
        ATTNO: Code[25];
        EmployeePostedAbsence: Record "Employee Posted Absence";
        Absence: Record "Employee Posted Absence";
        textH: Text;
        textM: Text;
        W_M: Integer;
        W_H: Integer;
        RhSetup: Record "Human Resources Setup";
        att: Record "TimeSheet Header";
        ts: Boolean;
        UserSetup: Record "User Setup";
        StoreVisible: Boolean;


    procedure ValiderFeuille()
    var
        dialogMess1: Label 'Validating Supp. Hours';
        dialogMess2: Label 'Updating recorded lines.';
    begin



        //d.CLOSE;
    end;

    local procedure AbsReg(att: Record "TimeSheet Line")
    var
        recG_Abs: Record "Employee Posted Absence";
        Lineno: Integer;
    begin

        if recG_Abs.FindLast then
            Lineno := recG_Abs."Entry No."
        else
            Lineno := 1;
        att.Reset;
        att.SetFilter("Absence Hours", '<>%1', 0);
        if att.FindSet then
            repeat

                recG_Abs."Entry No." := att."Entry No";
                recG_Abs."Entry No." := Lineno + 1;
                recG_Abs."Employee No." := Rec.Employee;
                recG_Abs."Employee Full Name" := att."Employee Full Name";
                recG_Abs."From Date" := att.Date;
                recG_Abs."To Date" := att.Date;
                recG_Abs."Cause of Absence Code" := 'Absent';
                recG_Abs.Description := 'Attendance' + ' ' + Format(Rec.Date);
                recG_Abs."Posting month" := att.Month;
                recG_Abs."Posting year" := Rec.Year;
                recG_Abs.Validate(Quantity, att."Absence Hours");
                recG_Abs."Unit of Measure Code" := 'Hour';
                if recG_Abs."Unit of Measure Code" = 'hour' then
                    recG_Abs.Validate("Quantity(days)", recG_Abs.Quantity);
                if recG_Abs."Unit of Measure Code" = 'day' then
                    recG_Abs.Validate("Quantity(days)", recG_Abs.Quantity / 8);
                recG_Abs.Validate("Global Dimension 1 Code", Rec."Store Code");


                recG_Abs.Insert;

            until recG_Abs.Next = 0;
        att.Reset;
        att.DeleteAll;
    end;
}

