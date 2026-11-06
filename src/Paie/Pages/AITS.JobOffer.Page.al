page 70000 "Job Offer"
{
    PageType = Card;
    SourceTable = "Job Offer";
    SourceTableView = WHERE("Request Type" = FILTER("Job Offer"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Job Offer No"; rec."Job Offer No")
                {
                    Caption = 'Document ID';

                    trigger OnAssistEdit()
                    begin
                        if rec.AssistEdit(rec) then
                            CurrPage.Update;
                    end;

                    trigger OnValidate()
                    begin
                        /*IF AssistEdit(xRec) THEN
                          CurrPage.UPDATE;*/

                    end;
                }
                field("Request Type"; rec."Request Type")
                {
                }
                field(Country; rec.Country)
                {
                }
                field(Sponsor; rec.Sponsor)
                {
                }
                field(Designation; rec.Designation)
                {
                }
                field(Date; rec.Date)
                {
                }
                field(Name; rec.Name)
                {
                }
                field(Departement; rec.Departement)
                {
                }
                field("Employee Contract Type"; rec."Employee Contract Type")
                {
                }
                field("Linked Request ID"; rec."Linked Request ID")
                {
                    LookupPageID = "Hiring Request";
                }
                field("Gross Salary"; rec."Gross Salary")
                {

                    trigger OnValidate()
                    begin
                        NetSalary(Rec);
                    end;
                }
                field("Basic Salary"; rec."Basic Salary")
                {
                    Editable = false;
                }
                field(Accommodation; rec.Accommodation)
                {
                    Editable = false;
                }
                field(Transportation; rec.Transportation)
                {
                    Editable = false;

                    trigger OnValidate()
                    begin
                        //VALIDATE("Gross Salary",("Gross Salary"-xRec.Transportation)+Rec.Transportation);
                        NetSalary(Rec);
                        rec.Validate("Gross Salary");
                        Rec.Modify;
                    end;
                }
                field("Mobile allowance"; rec."Mobile allowance")
                {

                    trigger OnValidate()
                    var
                        newnet: Decimal;
                    begin
                        rec.Transportation := rec.Transportation - rec."Mobile allowance";
                        Rec.Modify;
                    end;
                }
                field("Others allowances"; rec."Others allowances")
                {

                    trigger OnValidate()
                    begin
                        rec.Validate("Gross Salary", rec."Gross Salary" + rec."Others allowances");
                        NetSalary(Rec);
                        rec.Validate("Gross Salary");
                        rec."Mobile allowance" := 0;
                        Rec.Modify;
                    end;
                }
                field("Approval Status"; rec."Approval Status")
                {
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field("Passport/QID"; rec."Passport/QID")
                {
                }
                field("Employee Localisation"; rec."Employee Localisation")
                {
                }
                field("Visa Status"; rec."Visa Status")
                {
                }
                field("Contact Number"; rec."Contact Number")
                {
                }
                field("Job Offer Validity"; rec."Job Offer Validity")
                {
                }
                field("Notice Period"; rec."Notice Period")
                {
                }
                field("Probation Periode"; rec."Probation Periode")
                {
                }
                field("Medical Insurance"; rec."Medical Insurance")
                {
                }
                field("Airline Ticket"; rec."Airline Ticket")
                {
                }
                field("Work Hours"; rec."Work Hours")
                {
                }
                field("Annual Leave Days"; rec."Annual Leave Days")
                {
                }
            }
            part("Job Offer"; "Job Offer List")
            {
                Caption = 'Job Offer';
                SubPageLink = "Job Offer No" = FIELD("Job Offer No");
            }
        }
    }

    actions
    {
        area(creation)
        {
            group(Action10014500)
            {
            }
            action("Print Job Offer")
            {
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.SetRange("Job Offer No", rec."Job Offer No");
                    if Rec.FindSet then
                        REPORT.Run(50031, true, true, Rec);
                end;
            }
            action(Release)
            {
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    rec."Approval Status" := rec."Approval Status"::Pending;
                    rec.Modify;
                end;
            }
            action(Reopen)
            {
                Image = ReopenCancelled;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    rec."Approval Status" := rec."Approval Status"::Active;
                    rec.Modify;
                end;
            }
            action(Appove)
            {
                Image = Agreement;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    rec."Approval Status" := rec."Approval Status"::Approved;
                    rec.Modify;
                end;
            }
            action(Rejected)
            {
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    rec."Approval Status" := rec."Approval Status"::Rejected;
                    rec.Modify;
                end;
            }
            action(DocAttach)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.Run;
                end;
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        if rec."Approval Status" = rec."Approval Status"::Approved then
            Error('You can''t modify Approved record');
    end;

    trigger OnOpenPage()
    begin
        if Rec."Approval Status" <> Rec."Approval Status"::Active then
            Edit := false;
        if rec."Request Type" = rec."Request Type"::"Job Offer" then
            HR := false;
        if rec."Request Type" = rec."Request Type"::"Job Offer" then
            JO := false;
    end;

    var
        Edit: Boolean;
        HR: Boolean;
        JO: Boolean;
        b1: Text;
        base: Decimal;

    local procedure NetSalary(RecJo: Record "Job Offer")
    begin
        /*b1:='5,500.00';
        
         "Basic Salary":="Gross Salary"*50/100;
         EVALUATE(base,b1);
           IF "Basic Salary">base THEN*/
        begin
            rec."Basic Salary" := rec."Gross Salary" * 50 / 100;
            rec.Accommodation := rec."Gross Salary" * 30 / 100;
            rec.Transportation := rec."Gross Salary" * 20 / 100;
            rec.Validate("Gross Salary");
        end;


    end;
}

