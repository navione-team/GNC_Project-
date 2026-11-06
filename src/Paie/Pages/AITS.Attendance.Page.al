page 70026 Attendance
{
    PageType = Card;
    SourceTable = "TimeSheet Header";
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    Enabled = ts;

                    trigger OnAssistEdit()
                    var
                        IsHandled: Boolean;
                    begin
                        // Optional: Call a custom procedure or implement AssistEdit logic
                        IsHandled := false;
                        //AssistEdit(xRec, IsHandled);
                    end;
                }
                field("Store Code"; Rec."Store Code")
                {
                    Enabled = ts;

                    trigger OnValidate()
                    begin

                        if Rec."Store Code" = 'QNTGC' then
                            BTVisible := true
                        else
                            BTVisible := false;

                        if Rec."Store Code" <> 'QNTGC' then
                            bt1visible := true
                        else
                            bt1visible := false;
                        Rec_Attendance.SetRange("Store Code", Rec."Store Code");
                    end;
                }
                field(Month; Rec.Month)
                {
                    Enabled = ts;
                }
                field(Year; Rec.Year)
                {
                    Enabled = ts;
                }
                field(Description; Rec.Description)
                {
                    Enabled = ts;
                }
                field(USER_ID; Rec.USER_ID)
                {
                    Enabled = ts;
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    Enabled = ts;
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    Enabled = ts;
                }
            }
            part(Control10014513; "TimeSheet Line")
            {
                SubPageLink = "Store Code" = FIELD("Store Code");
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Calculate  Attendance")
            {
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                Visible = BTVisible;

                trigger OnAction()
                begin

                    WIN.Open('Processing data... @@@@@@@@@@@@@@@@@@1@');


                    RhSetup.Get();
                    Rec_Attendance.Reset;
                    NoOfRecs := Rec_Attendance.Count;
                    Rec_Attendance.SetFilter(Holiday, '=%1', false);
                    Rec_Attendance.SetFilter("Absence Reason", '<>%1', Rec_Attendance."Absence Reason"::Casual);
                    Rec_Attendance.SetFilter("Store Code", Rec."Store Code");
                    if Rec_Attendance.FindFirst then
                        repeat


                            Rec_Attendance."Worked Hours" := 000000T + (Rec_Attendance."Time Out" - Rec_Attendance."Time In");
                            textH := CopyStr(Format(Rec_Attendance."Worked Hours"), 1, 2);
                            textM := CopyStr(Format(Rec_Attendance."Worked Hours"), 4, 2);
                            Evaluate(W_M, textM);
                            Evaluate(W_H, textH);

                            if Rec_Attendance.thursday = false then
                                if W_H * 60 < RhSetup."Standard Hour Per day" * 60 then begin
                                    Rec_Attendance.Validate("Absence Hours", ((RhSetup."Standard Hour Per day" * 60) - (W_H * 60 + W_M)) / 60);
                                    Rec_Attendance."Over Hours" := 0;
                                    Rec_Attendance."Absence Reason" := Rec_Attendance."Absence Reason"::Late;
                                end else
                                    if W_H * 60 > (RhSetup."Standard Hour Per day" + 1) * 60 then begin
                                        Rec_Attendance.Validate("Over Hours", ((W_H * 60 - (RhSetup."Standard Hour Per day" + 1) * 60) / 60));
                                        Rec_Attendance."Absence Reason" := Rec_Attendance."Absence Reason"::OverTime;
                                        Rec_Attendance."Absence Hours" := 0;
                                    end;
                            if Rec_Attendance.thursday = true then
                                if W_H * 60 < RhSetup."Thursday Standard Hours" * 60 then begin
                                    Rec_Attendance.Validate("Absence Hours", ((RhSetup."Thursday Standard Hours" * 60) - (W_H * 60 + W_M)) / 60);
                                    Rec_Attendance."Over Hours" := 0;
                                    Rec_Attendance."Absence Reason" := Rec_Attendance."Absence Reason"::Late;
                                end else
                                    if W_H * 60 > RhSetup."Thursday Standard Hours" * 60 then begin
                                        Rec_Attendance.Validate("Over Hours", ((W_H * 60 - RhSetup."Thursday Standard Hours" * 60) / 60));
                                        Rec_Attendance."Absence Reason" := Rec_Attendance."Absence Reason"::OverTime;
                                        Rec_Attendance."Absence Hours" := 0;
                                    end;
                            if Rec_Attendance.Holiday = true then begin
                                Rec_Attendance.Validate("Over Hours", 0);
                                Rec_Attendance.Validate("Absence Hours", 0);
                                Rec_Attendance."Absence Reason" := Rec_Attendance."Absence Reason"::Holiday;
                            end;
                            if (Rec_Attendance."Time In" = 0T) and (Rec_Attendance."Time Out" = 0T) and (Rec_Attendance.Holiday = true) then
                                Rec_Attendance."Worked Hours" := 0T;
                            Rec_Attendance."Absence Reason" := Rec_Attendance."Absence Reason"::" ";
                            if (Rec_Attendance."Time In" = 0T) and (Rec_Attendance."Time Out" = 0T) and (Rec_Attendance.Holiday = false) then
                                if Rec_Attendance."Absence Reason" = Rec_Attendance."Absence Reason"::Casual then begin
                                    Rec_Attendance."Time In" := 0T;
                                    Rec_Attendance."Time Out" := 0T;
                                    Rec_Attendance."Worked Hours" := 0T;
                                end else begin
                                    Rec_Attendance.Validate("Absence Hours", 8);
                                    Rec_Attendance.Validate("Over Hours", 0);
                                    Rec_Attendance.Validate("Absence Reason", Rec_Attendance."Absence Reason"::Absent);
                                end;
                            if Rec_Attendance.Holiday = true then begin
                                Rec_Attendance."Worked Hours" := 0T;
                                Rec_Attendance."Time In" := 0T;
                                Rec_Attendance."Time Out" := 0T;
                            end;
                            //check absence
                            if (Rec_Attendance."Time In" = 0T) and (Rec_Attendance."Time Out" = 0T) and (Rec_Attendance.Holiday = false) then begin
                                Rec_Attendance."Absence Hours" := 8;
                                Rec_Attendance.Validate("Worked Hours", 0T);
                            end;
                            //Check Annual Leave
                            Abs_rec.Reset;
                            Abs_rec.SetRange("Employee No.", Rec_Attendance.Employee);
                            Abs_rec.SetRange("From Date", Rec_Attendance.Date);
                            if Abs_rec.FindSet then begin
                                Rec_Attendance."Absence Reason" := Rec_Attendance."Absence Reason"::Casual;
                                Rec_Attendance.Comment := Format(Rec_Attendance."Absence Reason");
                                Rec_Attendance."Worked Hours" := 0T;
                                Rec_Attendance."Time In" := 0T;
                                Rec_Attendance."Time Out" := 0T;
                            end;


                            Rec_Attendance.Modify(true);

                            i += 1;
                            if NoOfRecs <= 100 then
                                WIN.Update(1, (i / NoOfRecs * 10000) div 1)
                            else
                                if i mod (NoOfRecs div 100) = 0 then
                                    WIN.Update(1, (i / NoOfRecs * 10000) div 1);
                            Sleep(100);

                        until Rec_Attendance.Next = 0;
                    WIN.Close;
                    Message('Attendance Sucessfully Calculated');

                end;
            }
            action("Calculate Store  Attendance")
            {
                Image = CalculateCalendar;
                Promoted = true;
                PromotedCategory = Process;
                Visible = bt1visible;

                trigger OnAction()
                begin
                    RhSetup.Get();
                    if Rec."Store Code" <> 'QNTGC' then begin
                        Store_Cal.Reset;
                        Store_Cal.SetRange("Date off", Rec_Attendance.Date);
                        Store_Cal.SetRange("Employee No", Rec_Attendance.Employee);
                        Store_Cal.SetRange("Store code", Rec."Store Code");
                        if Store_Cal.FindSet then
                            Rec_Attendance.Holiday := true;

                    end;


                    if Rec."Store Code" <> 'QNTGC' then
                        RhSetup.Get();
                    Rec_Attendance.Reset;
                    NoOfRecs := Rec_Attendance.Count;
                    WIN.Open('Processing data... @@@@@@@@@@@@@@@@@@1@');
                    Rec_Attendance.SetFilter("Store Code", Rec."Store Code");
                    if Rec_Attendance.FindFirst then
                        repeat
                            if Rec."Store Code" <> 'QNTGC' then
                                Rec_Attendance."Worked Hours" := (000000T + (Rec_Attendance."Time Out" - Rec_Attendance."Time In")) + ((000000T - (Rec_Attendance."Time In1" - Rec_Attendance."Time Out1")) - 000000T);
                            textH := CopyStr(Format(Rec_Attendance."Worked Hours"), 1, 2);
                            textM := CopyStr(Format(Rec_Attendance."Worked Hours"), 4, 2);
                            Evaluate(W_H, textH);
                            Evaluate(W_M, textM);


                            if (RhSetup."Store Standard Hours" * 60) > (W_H * 60 + W_M) then begin
                                Rec_Attendance.Validate("Absence Hours", (((RhSetup."Store Standard Hours") * 60) - (W_H * 60 + W_M)) / 60);
                                Rec_Attendance.Validate("Over Hours", 0);
                            end else begin
                                if (RhSetup."Store Standard Hours") * 60 < (W_H * 60 + W_M) then
                                    Rec_Attendance.Validate("Over Hours", ((W_H * 60 + W_M) - (RhSetup."Store Standard Hours") * 60) / 60);
                                Rec_Attendance.Validate("Absence Hours", 0);
                            end;
                            if Rec_Attendance.Holiday = true then begin
                                Rec_Attendance."Worked Hours" := 0T;
                                Rec_Attendance."Time Out" := 0T;
                                Rec_Attendance."Time In" := 0T;
                                Rec_Attendance."Time In1" := 0T;
                                Rec_Attendance."Time Out1" := 0T;
                                Rec_Attendance."Absence Hours" := 0;
                                Rec_Attendance."Over Hours" := 0;
                            end;

                            Rec.Month := Date2DMY(Rec_Attendance.Date, 2);
                            Rec.Year := Format(Date2DMY(Rec_Attendance.Date, 3));

                            Rec_Attendance.Modify(true);

                            i += 1;
                            if NoOfRecs <= 100 then
                                WIN.Update(1, (i / NoOfRecs * 10000) div 1)
                            else
                                if i mod (NoOfRecs div 100) = 0 then
                                    WIN.Update(1, (i / NoOfRecs * 10000) div 1);
                            Sleep(100);
                        until Rec_Attendance.Next = 0;
                    WIN.Close;
                    Message('Attendance Sucessfully Calculated');
                end;
            }
            action("Post TimeSheet Entries")
            {
                Image = Timesheet;
                Promoted = true;
                PromotedCategory = Process;
                Visible = ts;

                trigger OnAction()
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    //  IF Rec.Status=Rec.Status::Open THEN
                    //  ERROR('Please Release Attentance');
                    if Confirm('Are you sure you want to proceed posting') then begin
                        WIND.Open('Posting :  #1############################# \' +
                            'Employee   #2############################################################### \' +
                            'Progress:                                           \' +
                            '@3@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ');
                        WIND.Update(1, Rec_Att_);


                        Rec.Reset;

                        if Rec_Att_.FindLast then
                            Rec_Att_.Init;
                        begin

                            Rec_Att_.TransferFields(Rec);
                            Rec_Att_.Insert;

                        end;

                        TSL.Reset;
                        CurrPage.SetSelectionFilter(Rec);

                        if TSL.FindSet then
                            repeat

                                RecordedAttendanceTimeSheet.Init;
                                WIND.Update(2, TSL.Employee + ' ' + TSL."Employee Full Name");
                                cpt := Round(h / TSL.Count, 0.01) * 10000;
                                WIND.Update(3, cpt);
                                Sleep(25);
                                RecordedAttendanceTimeSheet.TransferFields(TSL);
                                RecordedAttendanceTimeSheet.Insert;


                            until TSL.Next = 0;
                        WIND.Close;
                        AbsReg(TSL);
                        TSL.Reset;

                        Attendance.DeleteAll;
                        Message('Operation Finished');
                    end else
                        Message('Cancelled');
                end;
            }
            action("Release Attendance")
            {
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                Visible = ts;

                trigger OnAction()
                begin

                    TSL.Reset;
                    Rec.Status := Rec.Status::Released;


                    if TSL.FindSet then
                        repeat
                            /*
                             TSL.VALIDATE("Time Out");
                         IF TSL."Absence Hours" =0 THEN TSL."Absence Reason":=TSL."Absence Reason"::" ";
                         IF TSL."Absence Hours">0 THEN TSL."Absence Reason":=TSL."Absence Reason"::Late;
                         IF TSL."Absence Hours"=8 THEN TSL."Absence Reason":=TSL."Absence Reason"::Absent;
                          TSL."Store Code":=Rec."Store Code";
                          TSL."Attendance No":=Rec."No.";
                           TSL.Month:=Rec.Month;*/

                            TSL.Description := 'Attendance' + ' ' + Rec."Store Code" + ' ' + Format(Rec.Month) + ' ' + Rec.Year;



                            TSL.Modify(true);
                        until TSL.Next = 0;



                end;
            }
            action("Print Attendance")
            {
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                //RunObject = Report PrintAttendance; SBN
                Visible = ts;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin

        if Rec."Store Code" = 'QNTGC' then
            BTVisible := true
        else
            BTVisible := false;

        if Rec."Store Code" <> 'QNTGC' then
            bt1visible := true
        else
            bt1visible := false;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec_Attendance."Attendance No" := Attendance."No.";
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
        RecordedAttendanceTimeSheet: Record "Recorded Attendance TimeSheet";
        TSL: Record "TimeSheet Line";
        Attendance: Record "TimeSheet Header";
        Rec_Att_: Record "Rec TimeSheet Header";
        WIND: Dialog;
        i: Integer;
        cpt: Integer;
        h: Integer;
        BaseCal: Record "Base Calendar Change";
        cal: Integer;
        UserSetup: Record "User Setup";
        ts: Boolean;
        RhSetup: Record "Human Resources Setup";
        Rec_Attendance: Record "TimeSheet Line";
        W_H: Integer;
        W_M: Integer;
        W_S: Integer;
        textM: Text;
        textH: Text;
        WIN: Dialog;
        textDialog: Label 'Calculating.............';
        VarAtt1: Time;
        VarAtt2: Time;
        Store_Cal: Record "Store Calendar";
        textAnn: Text;
        NoOfRecs: Integer;
        BTVisible: Boolean;
        bt1visible: Boolean;
        CustomizedCalendarChange: Record "Customized Calendar Change";
        CalendarMgmt: Codeunit "Calendar Management";
        //PeriodFormMgt: Codeunit PeriodFormManagement;SBN
        dt: Record Date;
        Abs_rec: Record "Employee Posted Absence";
        Absence_h: Decimal;

    local procedure AbsReg(att: Record "TimeSheet Line")
    var
        recG_Abs: Record "Employee Posted Absence";
        Lineno: Integer;
    begin

        att.Reset;
        att.SetFilter("Absence Hours", '<>%1', 0);

        if att.FindSet then
            repeat

                if recG_Abs.FindLast then
                    Lineno := recG_Abs."Entry No." + 1
                else
                    Lineno := 1;

                begin

                    recG_Abs."Entry No." := att."Entry No";
                    //recG_Abs."Entry No.":=Lineno;

                    recG_Abs."Employee No." := att.Employee;
                    recG_Abs."Employee Full Name" := att."Employee Full Name";
                    recG_Abs."From Date" := att.Date;
                    recG_Abs."To Date" := att.Date;
                    recG_Abs."Cause of Absence Code" := 'Absent';
                    recG_Abs.Description := Rec.Description;
                    recG_Abs.Validate("Posting month", att.Month);
                    recG_Abs."Posting year" := att.Year;
                    recG_Abs.Validate(Quantity, att."Absence Hours");
                    recG_Abs.Validate("Quantity(days)", recG_Abs.Quantity / 8);
                    recG_Abs."Line type" := recG_Abs."Line type"::"Deductible of Salary";
                    recG_Abs.Validate("Global Dimension 1 Code", Rec."Store Code");
                    recG_Abs.Insert;
                end;

            until att.Next = 0;
        att.Reset;
        att.DeleteAll;

    end;
}

