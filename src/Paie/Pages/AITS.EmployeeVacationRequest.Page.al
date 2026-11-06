page 70002 "Employee Vacation Request"
{
    PageType = List;
    SourceTable = "Employee Vacation Request";
    SourceTableView = SORTING(Employee)
                      ORDER(Ascending)
                      WHERE(Hide = FILTER(false));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; rec."Entry Type") { }
                field(Employee; rec.Employee) { }
                field("Full Name"; rec."Full Name") { }
                field(Store; rec.Store) { }
                field(Departement; rec.Departement) { }
                field("Employment Date"; rec."Employment Date")
                {
                    Editable = false;
                }
                field("Vacation Start Date"; rec."Vacation Start Date") { }
                field("Vacation End Date"; rec."Vacation End Date") { }
                field("Last Working Date"; rec."Last Working Date")
                {
                    Editable = false;
                }
                field("Resume Date"; rec."Resume Date") { }
                field("Number of Days"; rec."Number of Days")
                {
                    Caption = 'Quantity';
                    Editable = false;
                }
                field("Reason For Leave"; rec."Reason For Leave") { }
                field("Grant Exception"; rec."Grant Exception")
                {
                    Editable = ExceptEdit;
                }
                field(Control10; rec."Manager Approve") { Editable = false; }
                field(Control11; rec."HR Approve") { Editable = false; }
                field(Control12; rec."CEO Approve") { Editable = false; }
                field(Status; rec.Status)
                {
                    Editable = false;
                    StyleExpr = style;
                }
                field("Total Vacation token"; rec."Total Vacation token")
                {
                    Editable = false;
                    Style = Unfavorable;
                    StyleExpr = true;
                }
                field("Document Date"; rec."Document Date") { }
                field("User ID"; rec."User ID") { }
                field(Comment; rec.Comment) { }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("CEO Approve")
            {
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                //  Visible = CEO;

                trigger OnAction()
                begin
                    if Rec.Get(rec.RecordId) then begin
                        rec.Status := rec.Status::Approved;
                        rec."CEO Approve" := true;
                    end;
                end;
            }

            action("HR Approve")
            {
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                // Visible = HR;

                trigger OnAction()
                begin
                    if Rec.Get(rec.RecordId) then begin
                        rec.Status := rec.Status::Pending;
                        rec."HR Approve" := true;
                    end;
                end;
            }

            action("Manager Approve")
            {
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                //  Visible = MANAGER;

                trigger OnAction()
                begin
                    if Rec.Get(rec.RecordId) then begin
                        rec.Status := rec.Status::Released;
                        rec."Manager Approve" := true;
                    end;
                end;
            }

            action(Reject)
            {
                Image = CancelApprovalRequest;
                Promoted = true;
                PromotedCategory = Process;
                //  Visible = CEO;

                trigger OnAction()
                begin
                    if Rec.Get(rec.RecordId) then begin
                        rec.Status := rec.Status::Rejected;
                        rec."CEO Approve" := false;
                    end;
                end;
            }

            action("Check Vacation Elegibility")
            {
                Image = Confirm;
                Promoted = true;
                PromotedCategory = Process;
                // Visible = false;

                trigger OnAction()
                begin
                    // implementation commented
                end;
            }

            action("Cancel Approve")
            {
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                // Visible = CEO;

                trigger OnAction()
                begin
                    rec.Status := rec.Status::Open;
                    rec.Modify(true);
                end;
            }

            action("Print Request")
            {
                Image = PrintForm;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    rec.Reset;
                    rec.SetFilter(Employee, rec.Employee);
                    if rec.FindSet then
                        REPORT.Run(50037, true, true, rec);
                    rec.Reset;
                end;
            }

            action("Post Approved Request")
            {
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                //  Visible = HR;

                trigger OnAction()
                begin
                    Vac_history.Reset;
                    rec.SetFilter(Status, '%1', rec.Status::Approved);
                    if not rec.FindSet then begin
                        Message('Nothing To post');
                        rec.Reset;
                    end else if not Confirm('Do you want to Proceed') then begin
                        Message('Posting Cancelled!');
                        rec.Reset;
                    end else begin
                        if Vac_history.FindLast then
                            Vac_history.Init;
                        repeat
                            Vac_history.TransferFields(rec);
                            Vac_history."Entry No" := Vac_history."Entry No" + 1;
                            Vac_history.Insert;
                            if Rec_Employee.Get(rec.Employee) then begin
                                Rec_Employee."Last Working Date" := rec."Last Working Date";
                                Rec_Employee."Vacation Resume Date" := rec."Resume Date";
                                Rec_Employee."Vacation Start Date" := rec."Vacation Start Date";
                                Rec_Employee."Vacation End Date" := rec."Vacation End Date";
                                Rec_Employee."Leave Status" := Rec_Employee."Leave Status"::"On Vacation";
                                Rec_Employee.Modify(true);
                            end;
                            rec.Delete;
                        until rec.Next = 0;
                        Message('Successfully Posted');
                        rec.Reset;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        case rec.Status of
            rec.Status::Pending:
                style := 'strong';
            rec.Status::Approved:
                style := 'Favorable';
            rec.Status::Rejected:
                style := 'Unfavorable';
        end;
    end;

    trigger OnOpenPage()
    begin
        User_setup.Get(UserId);
        CEO := User_setup."CEO Approve";
        HR := User_setup."HR APPROVE";
        Manager := User_setup."MANAGER APPROVE";
        ExceptEdit := CEO or HR;
    end;

    var
        style: Text;
        Rec_vacation_: Record "Employee Vacation Request";
        User_setup: Record "User Setup";
        Rec_Employee: Record Employee;
        net_days: Decimal;
        recG_Recorded_paid_anuel_L: Record "Rec TimeSheet Header";
        TOTVAC: Decimal;
        SD: Decimal;
        SY: Decimal;
        tenure: Decimal;
        Total_entitlement_Leave_Days: Decimal;
        Total_Romaining: Decimal;
        Total_Leave_Taken: Decimal;
        "Quantity Days": Decimal;
        totabs: Decimal;
        ExceptEdit: Boolean;
        Vac_history: Record "Vacation Request History";
        lino: Integer;
        CEO: Boolean;
        Manager: Boolean;
        HR: Boolean;
}