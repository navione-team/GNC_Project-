page 70030 "Hiring Request"
{
    PageType = Card;
    SourceTable = "Job Offer";
    SourceTableView = WHERE("Request Type" = FILTER("Hiring Request"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Job Offer No"; rec."Job Offer No")
                {
                    Caption = 'Request ID';

                    trigger OnAssistEdit()
                    begin
                        if rec.AssistEdit(xRec) then
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
                field(Periority; rec.Periority)
                {
                }
                field("Requested By"; rec."Requested By")
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
                    Visible = false;
                }
                field(Departement; rec.Departement)
                {
                }
                field("Salary range"; rec."Salary range")
                {
                }
                field("Expected Start Date"; rec."Expected Start Date")
                {
                }
                field("Number Of Employee To Hire"; rec."Number Of Employee To Hire")
                {
                }
                field("Employee Contract Type"; rec."Employee Contract Type")
                {
                    Visible = false;
                }
                field("User Id"; rec."User Id")
                {
                }
                field("Notice Period"; rec."Notice Period")
                {
                    Visible = false;
                }
                field("Gross Salary"; rec."Gross Salary")
                {
                    Visible = false;

                    trigger OnValidate()
                    begin

                        rec."Basic Salary" := rec."Gross Salary" * 50 / 100;
                        rec.Accommodation := rec."Gross Salary" * 30 / 100;
                        rec.Transportation := rec."Gross Salary" * 15 / 100;
                        rec."Mobile allowance" := rec."Gross Salary" * 5 / 100;
                        //"Others allowances":=Net*5/100;

                        rec.Validate("Gross Salary");
                    end;
                }
                field("Basic Salary"; rec."Basic Salary")
                {
                    Visible = false;
                }
                field(Accommodation; rec.Accommodation)
                {
                    Visible = false;

                    trigger OnValidate()
                    begin
                        rec.Validate(rec."Gross Salary", rec."Gross Salary" - xRec.Accommodation + Rec.Accommodation);
                        rec.Validate("Gross Salary");

                        rec."Basic Salary" := rec."Gross Salary" * 50 / 100;
                        rec.Accommodation := rec."Gross Salary" * 30 / 100;
                        rec.Transportation := rec."Gross Salary" * 15 / 100;
                        rec."Mobile allowance" := rec."Gross Salary" * 5 / 100;
                    end;
                }
                field(Transportation; rec.Transportation)
                {
                    Visible = false;

                    trigger OnValidate()
                    begin
                        rec.Validate("Gross Salary", (rec."Gross Salary" - xRec.Transportation) + Rec.Transportation);
                        rec.Validate("Gross Salary");

                        rec."Basic Salary" := rec."Gross Salary" * 50 / 100;
                        rec.Accommodation := rec."Gross Salary" * 30 / 100;
                        rec.Transportation := rec."Gross Salary" * 15 / 100;
                        rec."Mobile allowance" := rec."Gross Salary" * 5 / 100;
                    end;
                }
                field("Mobile allowance"; rec."Mobile allowance")
                {
                    Visible = false;

                    trigger OnValidate()
                    var
                        newnet: Decimal;
                    begin
                        rec.Validate("Gross Salary", (rec."Gross Salary" - xRec."Mobile allowance") + Rec."Mobile allowance");

                        rec.Validate(Rec."Gross Salary");

                        rec."Basic Salary" := rec."Gross Salary" * 50 / 100;
                        rec.Accommodation := rec."Gross Salary" * 30 / 100;
                        rec.Transportation := rec."Gross Salary" * 15 / 100;
                        rec."Mobile allowance" := rec."Gross Salary" * 5 / 100;
                    end;
                }
                field("Others allowances"; rec."Others allowances")
                {
                    Visible = false;

                    trigger OnValidate()
                    begin
                        rec.Validate("Gross Salary", (rec."Gross Salary" - xRec."Others allowances") + Rec."Others allowances");
                        rec.Validate("Gross Salary");

                        rec."Basic Salary" := rec."Gross Salary" * 50 / 100;
                        rec.Accommodation := rec."Gross Salary" * 30 / 100;
                        rec.Transportation := rec."Gross Salary" * 15 / 100;
                        rec."Mobile allowance" := rec."Gross Salary" * 5 / 100;
                    end;
                }
                field("Approval Status"; rec."Approval Status")
                {
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field("Passport/QID"; rec."Passport/QID")
                {
                    Visible = false;
                }
                field("Employee Localisation"; rec."Employee Localisation")
                {
                }
                field("Visa Status"; rec."Visa Status")
                {
                    Visible = false;
                }
                field("Contact Number"; rec."Contact Number")
                {
                    Visible = false;
                }
                field("Job Offer Validity"; rec."Job Offer Validity")
                {
                    Visible = false;
                }
            }
            part("Hiring Request"; "Hiring Request SubPage")
            {
                Caption = 'Hiring Request';
                SubPageLink = "Job Offer No" = FIELD("Job Offer No"),
                              "Request Type" = FIELD("Request Type");
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
                Visible = false;

                trigger OnAction()
                begin
                    Rec.SetRange("Job Offer No", rec."Job Offer No");
                    if Rec.FindSet then
                        REPORT.Run(50026, true, true, Rec);
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
                    rec."Approval date" := WorkDate;
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
}

