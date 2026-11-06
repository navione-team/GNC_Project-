page 70008 "Employee Loans"
{
    DeleteAllowed = true;
    PageType = Card;
    SourceTable = "Loan & Advance";
    SourceTableView = WHERE(Type = FILTER(Loan));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(General)
            {
                group("Employee Line")
                {
                    Caption = 'Employee';
                    field("No."; rec."No.")
                    {
                        trigger OnAssistEdit()
                        begin
                            rec.AssistEdit(xRec);
                            CurrPage.Update;
                        end;
                    }
                    field(Employee; rec.Employee) { }
                    field(Name; rec.Name) { }
                    field("Job Title"; rec."Job Title") { }
                    field(Observation; rec.Observation) { }
                }

                group("DocumentType")
                {
                    Caption = 'Document Type';
                    field("Document type"; rec."Document type")
                    {
                        Visible = false;
                    }
                }

                group(Loan)
                {
                    Caption = 'Loan';

                    field(Amount; rec.Amount)
                    {
                        trigger OnValidate()
                        begin
                            CurrPage."Loan TimeLine".PAGE.EtablirEcheancier(rec."No.", rec."Starting Date", rec."End Date", rec."Slice Amount", rec."Repayment slices", 0);
                            CurrPage."Loan TimeLine".PAGE.Refresh;
                        end;
                    }

                    field("Total to repay"; rec."Total to repay") { }

                    field("Repayment slices"; rec."Repayment slices")
                    {
                        trigger OnValidate()
                        begin
                            CurrPage."Loan TimeLine".PAGE.EtablirEcheancier(rec."No.", rec."Starting Date", rec."End Date", rec."Slice Amount", rec."Repayment slices", 0);
                            CurrPage."Loan TimeLine".PAGE.Refresh;
                        end;
                    }

                    field("Slice Amount"; rec."Slice Amount") { }

                    field("Posting Date"; rec."Posting Date")
                    {
                        Editable = false;
                    }

                    field("Starting Date"; rec."Starting Date")
                    {
                        trigger OnValidate()
                        begin
                            CurrPage."Loan TimeLine".PAGE.EtablirEcheancier(rec."No.", rec."Starting Date", rec."End Date", rec."Slice Amount", rec."Repayment slices", 0);
                            CurrPage."Loan TimeLine".PAGE.Refresh;
                        end;
                    }

                    field("End Date"; rec."End Date")
                    {
                        Editable = false;
                    }
                }
            }

            part("Loan TimeLine"; "L&A Installment Schedule")
            {
                Caption = 'Loan TimeLine';
                SubPageLink = "N° Loan" = FIELD("No.");
            }
        }

        area(factboxes)
        {
            part("loan info"; "Loan.FactBox")
            {
                Caption = 'loan info';
                SubPageLink = "No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Action1000000023)
            {
                Caption = 'Loan';
                action("Print Loan Request")
                {
                    Caption = 'Print Loan Request';
                    Image = PrintAttachment;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                }
            }

            group(Validate)
            {
                Caption = 'Validate';

                action("Test Report")
                {
                    Caption = 'Test Report';
                    Image = PrintCheck;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        HumRessSetup.Get();
                        LoanAdvance.SetRange("No.", rec."No.");
                        //  REPORT.Run(8099021, true, true, LoanAdvance);
                    end;
                }

                action("P&ost")
                {
                    Caption = 'P&ost';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        rec.SetRecFilter();
                        if rec."Document type" <> '' then
                            REPORT.Run(70002, true, true, Rec)
                        else
                            Error(Text001);
                    end;
                }

                action("Post and &Print")
                {
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;

                    trigger OnAction()
                    begin
                        HumRessSetup.Get();
                        LoanAdvance.SetRange("No.", rec."No.");
                        //  REPORT.Run(8099021, false, false, LoanAdvance);

                        if LoanAdvance.Find('-') then //begin
                            if MgmtLoansAdvances.TestValiditeDocument(LoanAdvance) then
                                //     REPORT.Run(REPORT::Report8099010, true, true, LoanAdvance);KKA
                                // end;

                                CurrPage.Update;
                    end;
                }

                action(Timeline)
                {
                    Caption = 'Timeline';
                    Image = Timeline;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;

                    trigger OnAction()
                    begin
                        //    with LoanAdvance do begin
                        if LoanAdvance.FindFirst() then
                            Error('Echéancier Déja Lancé')
                        else begin
                            repeat
                                CurrPage."Loan TimeLine".PAGE.EtablirEcheancier(rec."No.", rec."Starting Date", rec."End Date", rec."Slice Amount", rec."Repayment slices", 0);
                                CurrPage."Loan TimeLine".PAGE.Refresh;
                            until LoanAdvance.Next = 0;
                        end;
                    end;
                    //  end;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        rec.Type := 1;
        REC."Document type" := 'LOAN';
    end;

    trigger OnOpenPage()
    begin
        CurrPage."Loan TimeLine".PAGE.ValideInvisible(false);
    end;

    var
        MgmtLoansAdvances: Codeunit "Mgmt. of Loans and Advances";
        HumRessSetup: Record "Human Resources Setup";
        LoanAdvance: Record "Loan & Advance";
        Text001: Label 'Vous devez renseigner le Type du document !';
        GenJourLine: Record "Gen. Journal Line";
}
