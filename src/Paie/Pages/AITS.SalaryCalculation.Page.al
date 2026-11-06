page 70013 "Salary Calculation"
{
    PageType = Card;
    SourceTable = "Salary Header";
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            //  group("Payroll Filters")
            // {
            //  field("Employer EID"; Rec."Employer EID")
            //   {
            //  }
            //   field("Payer Name"; Rec."Payer Name")
            //  {
            //   }
            //  }
            group("Payroll Details")
            {
                field(No; Rec.No)
                {
                    Style = Strong;
                    StyleExpr = TRUE;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(xRec);
                        CurrPage.Update;
                    end;
                }
                field("Posting Month"; Rec."Posting Month")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Posting Year"; Rec."Posting Year")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field(Description; Rec.Description)
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Document Date"; Rec."Document Date")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Payroll Status"; Rec."Payroll Status")
                {
                    Editable = false;
                }
                field("Total Gross Salary"; Rec."Total Gross Salary")
                {
                    Editable = false;
                    Style = Unfavorable;
                }
                field("Total Advance"; Rec."Total Advance")
                {
                    Editable = false;
                    Style = Unfavorable;
                }

                field("Total Loan"; Rec."Total Loan")
                {
                    Editable = false;
                    Style = Unfavorable;
                }

                field("Total Net Pay"; Rec."Total Net Pay")
                {
                    Editable = false;
                    Style = Unfavorable;
                }
            }
            group(Control10014522)
            {
                ShowCaption = false;
            }
            part(Control10014508; "Salary Calculation Lines")
            {
                SubPageLink = "Document No." = FIELD(No);
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Import Salary Lines")
            {
                Image = SuggestLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    Salary_header.Reset;
                    Salary_header.SetRange(No, Rec.No);
                    if Salary_header.FindSet then
                        REPORT.Run(70000, true, true, Salary_header);
                    CurrPage.Update(true);
                end;
            }
            action("Calculate Salary Lines")
            {
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin


                    Salary_header.Reset;
                    Salary_header.SetRange(No, Rec.No);
                    if Salary_header.FindSet then
                        REPORT.Run(70001, true, true, Salary_header);
                    CurrPage.Update(true);
                end;
            }
            action("Print Pay Slip")

            {
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin


                    Salary_header.Reset;
                    Salary_header.SetRange(No, Rec.No);
                    if Salary_header.FindSet then
                        REPORT.Run(70003, true, true, Salary_header);
                    CurrPage.Update(true);
                end;
            }
            action("Bank Transfer File")
            {
                Image = BankAccountStatement;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Salary_header.Reset;
                    Salary_header.SetFilter(No, '<>%1', '');
                    if Salary_header.FindSet then
                        Salary_line.SetRange(Salary_line."Document No.", Salary_header.No);

                    XMLPORT.Run(50004, true, false, Salary_line);
                end;
            }
            action("Post Payroll")
            {
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    rec.TestField("Posting Date");

                    if Confirm('Are you sure you want to proceed') then begin
                        PostPayrollToAcc.PostGroupedToSalaryJournal(Rec);
                        PostPayroll(Rec);
                    end;

                end;
            }
            action("Payroll List")
            {
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Salary_header.Reset;
                    Salary_header.SetRange(No, Rec.No);
                    if Salary_header.FindSet then
                        REPORT.Run(50043, true, false);
                end;
            }
            action("Leave Payment Report")
            {
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                //RunObject = Report Report50045;SBN
            }
            action("Payroll Journal List")
            {
                Image = PaymentPeriod;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Report "Payroll Summary";
            }
            action("Payroll By Company")
            {
                Image = Payment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Salary_header.Reset;
                    Salary_header.SetRange(No, Rec.No);
                    if Salary_header.FindSet then
                        REPORT.Run(50044, true, false);
                end;
            }
            action("Close Payroll")
            {
                Image = Close;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = visible;

                trigger OnAction()
                begin
                    Salary_header.Reset;
                    Salary_header.SetRange(No, Rec.No);
                    if Salary_header.FindSet then
                        if Confirm('Do you want to Close Payroll') = true then
                            Salary_header."Payroll Status" := Salary_header."Payroll Status"::Released;
                    Salary_header.Modify(true);
                end;
            }
            action("Reopen Payroll")
            {
                Image = OpenWorksheet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = visible;

                trigger OnAction()
                begin
                    Salary_header."Payroll Status" := Salary_header."Payroll Status"::Open;
                    Salary_header.Modify(true);
                end;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        //Rec_Salary_line."Document No.":=Rec_Salary_header.No;
        //Rec_Salary_line.MODIFY(TRUE);
    end;

    trigger OnOpenPage()
    begin
        UserSetup.Get(UserId);
        if UserSetup."HR APPROVE" = true then
            Visible := true
        else
            Visible := false;
    end;

    var
        HumanResSetup: Record "Human Resources Setup";
        NoSeriesMgt: Codeunit "No. Series";
        Salary_line: Record "Salary Line";
        Salary_header: Record "Salary Header";
        PageSalLine: Page "Salary Calculation Lines";
        RecSponsor: Record Union;
        UserSetup: Record "User Setup";
        Visible: Boolean;
        PostPayrollToAcc: Codeunit "Payroll Posting (Grouped)";

    local procedure PostPayroll(SalaryHeader: Record "Salary Header")
    var
        i: Integer;
        h: Integer;
        cpt: Integer;
        RecSalaryHeader: Record "Rec.Salary Header";
        RecSalaryLine: Record "Rec.Salary Line";
        wind: Dialog;
    begin
        RecSalaryHeader.Init;
        wind.Open('Posting :  #1############################# \' +
                  'Employee   #2############################################################### \' +
                  'Progress:                                           \' +
                  '@3@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ');
        wind.Update(1, SalaryHeader.No);
        RecSalaryHeader.SetFilter(No, '=%1', '');
        if RecSalaryHeader.FindLast then
            RecSalaryHeader.TransferFields(SalaryHeader);
        RecSalaryHeader.No := SalaryHeader.No;
        RecSalaryHeader.Description := SalaryHeader.Description;
        RecSalaryHeader."Posting Month" := SalaryHeader."Posting Month";
        RecSalaryHeader."Posting Year" := SalaryHeader."Posting Year";
        RecSalaryHeader."Posting Date" := SalaryHeader."Posting Date";
        RecSalaryHeader."Document Date" := SalaryHeader."Document Date";
        RecSalaryHeader."No Serie" := SalaryHeader."No Serie";
        RecSalaryHeader."Paid Days" := SalaryHeader."Paid Days";
        RecSalaryHeader.Insert;



        h := 0;

        RecSalaryLine.Reset;
        Salary_line.SetRange("Document No.", SalaryHeader.No);
        Salary_line.SetFilter("Document No.", '<>%1', '');
        if Salary_line.FindSet then
            repeat
                h := h + 1;
                RecSalaryLine.Init;
                Salary_line.CalcFields("Accomodation Allowance", "Transport Allowance", "Mobile Allowance", "Other Allowance",
                 "Education Allowance", "Bonus Allowance");
                wind.Update(2, Salary_line.Employee + ' ' + Salary_line."Full Name");
                cpt := Round(h / Salary_line.Count, 0.01) * 10000;
                wind.Update(3, cpt);
                Sleep(25);
                RecSalaryLine.TransferFields(Salary_line);

                RecSalaryLine."Accomodation Allowance" := Salary_line."Accomodation Allowance";
                RecSalaryLine."Transport Allowance" := Salary_line."Transport Allowance";
                RecSalaryLine."Mobile Allowance" := Salary_line."Mobile Allowance";
                RecSalaryLine."Other Allowance" := Salary_line."Other Allowance";
                RecSalaryLine."Education Allowance" := Salary_line."Education Allowance";
                RecSalaryLine."Bonus Allowance" := Salary_line."Bonus Allowance";
                if RecSalaryLine.Insert then
                    Salary_line.Delete;
            until Salary_line.Next = 0;

        wind.Close;
        Message('Payroll Succesuffly Posted');

        SalaryHeader.Delete;
    end;
}

