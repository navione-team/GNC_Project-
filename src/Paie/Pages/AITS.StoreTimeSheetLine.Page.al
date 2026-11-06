page 70038 "Store TimeSheet Line"
{
    Caption = 'Attendance TimeSheet';
    PageType = ListPart;
    Permissions = TableData "Employee Posted Absence" = rimd;
    SourceTable = "TimeSheet Line";
    //SourceTableView = WHERE ("Store Code" = FILTER (<> 'QNTGC'));
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

                        if att.Get() then
                            Rec."Attendance No" := att."No.";
                    end;
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
                field("Time In"; Rec."Time In")
                {
                    Editable = ts;

                    trigger OnValidate()
                    begin
                        /*RhSetup.GET();
                        "Worked Hours":=000000T + ("Time Out"-"Time In")-3600000;
                        textH:=COPYSTR(FORMAT("Worked Hours"),1,2);
                        textM:=COPYSTR(FORMAT("Worked Hours"),4,2);
                        EVALUATE(W_M,textM);
                        EVALUATE(W_H,textH);
                        IF W_H*60<RhSetup."Standard Hour Per day"*60 THEN
                          BEGIN
                        VALIDATE("Absence Hours",((RhSetup."Standard Hour Per day"*60)-(W_H*60+W_M))/60);
                          "Over Hours":=0;
                           Status:=Status::Late;
                        END ELSE IF W_H*60>RhSetup."Standard Hour Per day"*60 THEN
                          BEGIN
                          VALIDATE("Over Hours",((W_H*60-RhSetup."Standard Hour Per day"*60)/60));
                            Status:=Status::OverTime;
                            "Absence Hours":=0;
                            END;
                        
                        IF ("Time In"=0T) AND ("Time Out"=0T) THEN
                          "Absence Hours":=8;
                        IF "Absence Hours"<0 THEN
                           "Absence Hours":=0;
                        IF "Absence Hours"=8 THEN
                          BEGIN
                          Status:=Status::Absent
                          END ELSE
                          Status:=Status::" ";
                        IF ("Time In"=0T) AND ("Time Out"=0T) THEN
                          BEGIN
                         VALIDATE("Absence Hours",8);
                            "Worked Hours":=0T;
                            "Over Hours":=0;
                            END;*/

                    end;
                }
                field("Time Out"; Rec."Time Out")
                {
                    Editable = ts;

                    trigger OnValidate()
                    begin
                        Rec.Validate("Time Out");

                        if Rec."Absence Hours" = 0 then Rec."Absence Reason" := Rec."Absence Reason"::" ";
                        if Rec."Absence Hours" > 0 then Rec."Absence Reason" := Rec."Absence Reason"::Late;
                        if Rec."Absence Hours" = 8 then Rec."Absence Reason" := Rec."Absence Reason"::Absent;
                        Rec."Store Code" := Storeno;
                        Rec."Attendance No" := ATTNO;
                        Rec.Month := Date2DMY(Rec.Date, 2);
                        ;
                        Rec.Validate(Rec."Attendance No", att."No.");
                        Rec.Validate(Rec."Store Code", att."Store Code");
                    end;
                }
                field("Time In1"; Rec."Time In1")
                {
                }
                field("Time Out1"; Rec."Time Out1")
                {
                }
                field("Employee Full Name"; Rec."Employee Full Name")
                {
                    Editable = ts;
                }
                field(Description; Rec.Description)
                {
                    Editable = ts;
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
                field("Store Code"; Rec."Store Code")
                {
                    Editable = ts;
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
                    //   PromotedCategory = Process;

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
                    // Promoted = true;
                    // PromotedCategory = Process;
                    // RunObject = Report "Employee Certificate";
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        /*att.RESET;
        IF att.FINDSET THEN
         VALIDATE("Attendance No",att."No.");*/
        if att.Get() then
            Rec."Attendance No" := att."No.";
        Rec.Validate(Employee);

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

