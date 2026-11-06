page 70037 Store_Attendance
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
                    begin
                        //    Rec.AssistEdit(xRec);
                        CurrPage.Update;
                    end;
                }
                field("Store Code"; Rec."Store Code")
                {
                    Enabled = ts;
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
            part(Control10014513; "Store TimeSheet Line")
            {
                SubPageLink = "Attendance No" = FIELD("No."),
                              "Store Code" = FIELD("Store Code");
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Calculate Store  Attendance")
            {
                Image = CalculateCalendar;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin

                    Store_Cal.Reset;
                    Store_Cal.SetRange("Date off", Rec_Attendance.Date);
                    Store_Cal.SetRange("Employee No", Rec_Attendance.Employee);
                    if Store_Cal.FindSet then begin
                        Rec_Attendance.Holiday := true;
                        Rec_Attendance.Modify(true);
                    end;



                    if Rec."Store Code" <> 'QNTGC' then
                        RhSetup.Get();
                    Rec_Attendance.Reset;
                    WIN.Open('Processing data... @@@@@@@@@@@@@@@@@@1@');

                    if Rec_Attendance.FindFirst then
                        repeat

                            VarAtt1 := 000000T + (Rec_Attendance."Time In" - Rec_Attendance."Time Out");
                            VarAtt2 := 000000T + (Rec_Attendance."Time In1" - Rec_Attendance."Time Out1");
                            Rec_Attendance."Worked Hours" := VarAtt1 + (VarAtt2 - 000000T);
                            Message('%1', Rec_Attendance."Worked Hours");
                            Message('%1', VarAtt1);
                            Message('%1', VarAtt2);

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
                                    if W_H * 60 > RhSetup."Standard Hour Per day" * 60 then begin
                                        Rec_Attendance.Validate("Over Hours", ((W_H * 60 - RhSetup."Standard Hour Per day" * 60) / 60));
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

                            //
                            if (Rec_Attendance."Time In" = 0T) and (Rec_Attendance."Time Out" = 0T) then
                                Rec_Attendance."Absence Hours" := 8;
                            if Rec_Attendance."Absence Hours" < 0 then
                                Rec_Attendance."Absence Hours" := 0;
                            if Rec_Attendance."Absence Hours" = 8 then begin
                                Rec_Attendance."Absence Reason" := Rec_Attendance."Absence Reason"::Absent
                            end else
                                Rec_Attendance."Absence Reason" := Rec_Attendance."Absence Reason"::" ";
                            if (Rec_Attendance."Time In" = 0T) and (Rec_Attendance."Time Out" = 0T) then begin
                                Rec_Attendance.Validate("Absence Hours", 8);
                                Rec_Attendance."Worked Hours" := 0T;
                                Rec_Attendance."Over Hours" := 0;
                            end;
                            Rec.Month := Date2DMY(Rec_Attendance.Date, 2);
                            Rec.Year := Format(Date2DMY(Rec_Attendance.Date, 3));

                            //Day:=DATE2DMY(Date,1);
                            /////////////////////////////////
                            if Rec_Attendance."Absence Reason" = Rec_Attendance."Absence Reason"::Casual then
                                Rec_Attendance."Time In" := 0T;
                            Rec_Attendance."Time Out" := 0T;
                            Rec_Attendance."Worked Hours" := 0T;

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

                    if Rec.Status = Rec.Status::Open then
                        Error('Please Release Attentance');
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
                //    RunObject = Report PrintAttendance;
                Visible = ts;
            }
        }
    }

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
                    recG_Abs."Unit of Measure Code" := 'Hour';
                    if recG_Abs."Unit of Measure Code" = 'hour' then
                        recG_Abs.Validate("Quantity(days)", recG_Abs.Quantity);
                    if recG_Abs."Unit of Measure Code" = 'day' then
                        recG_Abs.Validate("Quantity(days)", recG_Abs.Quantity / 8);
                    recG_Abs.Validate("Global Dimension 1 Code", Rec."Store Code");
                    recG_Abs.Insert;
                end;

            until att.Next = 0;
        att.Reset;
        att.DeleteAll;
    end;
}

