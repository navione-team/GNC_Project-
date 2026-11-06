page 70031 "Vacation Traking"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = Employee;
    SourceTableView = WHERE(Status = FILTER(Active),
                            "Leave Status" = FILTER("On Vacation"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                }
                field(Name; Rec.FullName())
                {
                }
                field("Middle Name"; Rec."Middle Name")
                {
                }
                field("Last Name"; Rec."Last Name")
                {
                    // }
                    //field("Payer Code";  Rec."Payer Code")kka
                    //    {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Emplymt. Contract Code"; Rec."Emplymt. Contract Code")
                {
                }
                field("Employment Date"; Rec."Employment Date")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                }
                //   field("Global Dimension 2 Code";  Rec." Rec.Global Dimension 2 Code")
                //  {
                //  }
                field(Nationality; Rec."Country of Origin")
                {
                }
                field("Last Working Date"; Rec."Last Working Date")
                {
                }
                field("Vacation Start Date"; Rec."Vacation Start Date")
                {
                }
                field("Vacation End Date"; Rec."Vacation End Date")
                {
                }
                field("Vacation Resume Date"; Rec."Vacation Resume Date")
                {
                }
                field(Overdue; Rec.Overdue)
                {
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field("Punishment Days"; Rec."Punishment Days")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Orverdue Resume date"; Rec."Orverdue Resume date")
                {
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field("Leave Status"; Rec."Leave Status")
                {
                    Editable = false;
                }
                field("Work Authorisation"; Rec."Work Authorisation")
                {
                }
                field("Special Comment"; Rec."Special Comment")
                {
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Employee Resume Duty")
            {
                Image = Reuse;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec."Punishment Days" = 0 then begin
                        Rec."Work Authorisation" := true;
                        rec."Leave Status" := rec."Leave Status"::" ";
                        Rec.Modify;
                    end;
                    if Rec."Punishment Days" > 0 then begin
                        if not Confirm('Do you want to proceed with Punishement Action') then begin
                            Rec."Work Authorisation" := true;
                            Rec.Modify;
                            exit
                        end else begin
                            Message('%1 absence days will be registred for this employee', Rec."Punishment Days");
                            RecABS.Reset;
                            RecABS.SetCurrentKey("Entry No.");
                            if RecABS.FindLast then
                                lastno := RecABS."Entry No.";
                            RecABS.Init;
                            begin
                                RecABS."Entry No." := lastno + 1;
                                RecABS."Employee No." := Rec."No.";
                                RecABS."From Date" := Rec."Orverdue Resume date";
                                RecABS."To Date" := Rec."Orverdue Resume date" + Rec."Punishment Days";
                                RecABS."Line type" := RecABS."Line type"::"Deductible of Salary";
                                RecABS."Unit of Measure Code" := 'DAY';
                                RecABS.Validate(Quantity, Rec."Punishment Days");
                                RecABS.Validate("Quantity(days)", RecABS.Quantity);
                                RecABS.Insert;
                                //   Rec."Leave Status" :=  Rec."Leave Status"::"";
                            end;
                            Message('Sucessfully Resgistred');

                        end;
                    end;
                end;
            }
            action("Apply Employee Resume")
            {
                Image = Receipt;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin

                    CurrPage.SetSelectionFilter(Rec);
                    if Confirm('Confirm employee resume date') = true then
                        if Rec.FindSet then begin
                            // Rec. "Leave Status" :=  Rec."Leave Status"::" ";
                            Rec."Work Authorisation" := true;
                            Rec."last resume date" := Rec."Vacation Resume Date";
                            Rec.Modify(true);

                        end;
                    Rec.SetFilter("Leave Status", '=%1', Rec."Leave Status"::"On Vacation");
                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin

        Rec.Overdue := Rec."Vacation Resume Date" - Rec."Vacation End Date";
        //  Rec.MODIFY(TRUE);
        // FilterGroup(0);
    end;

    var
        RecABS: Record "Employee Posted Absence";
        lastno: Integer;
        Recemp: Record Employee;
}

