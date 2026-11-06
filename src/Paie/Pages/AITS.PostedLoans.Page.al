page 70011 "Posted Loans"
{
    PageType = Document;
    SourceTable = "Rec. Loan & Advance";
    ApplicationArea = all;
    Editable = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; rec."No.")
                {
                }
                field(Employee; rec.Employee)
                {
                }
                field(Name; rec.Name)
                {
                    Editable = VEchan_G;
                }
                field("Job Title"; rec."Job Title")
                {
                    Editable = VEchan_G;
                }
                field(Type; rec.Type)
                {
                }
                field(Status; rec.Status)
                {
                }
                field(Observation; rec.Observation)
                {
                }
            }
            group("Loan Payment")
            {
                field(Amount; rec.Amount)
                {
                    Visible = false;
                }
                field("Total to repay"; rec."Total to repay")
                {
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field("Paid amount"; rec."Paid amount")
                {
                    Caption = 'Paid amount';
                    Style = Favorable;
                    StyleExpr = TRUE;
                }
                field("Remaining Amount"; rec."Remaining Amount")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Repayment slices"; rec."Repayment slices")
                {
                }
                field("Document Date"; rec."Document Date")
                {
                }
                field("Start Date"; rec."Start Date")
                {
                }
                field("Repaiment lines"; rec."Repaiment lines")
                {
                }
            }

            /* part("Loan Advance lines"; "L&A Installment Schedule")
             {
                 Caption = 'Lignes';
                 SubPageLink = "No." = FIELD("No.");
             }*/
            part(Schedules; "L&A Installment Schedule")
            {
                Caption = 'Installments';
                SubPageLink = "N° Loan" = FIELD("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Impression)
            {
                Caption = 'Impression';
                action(Print)
                {
                    Caption = 'Print';
                    Image = Print;

                    trigger OnAction()
                    begin

                        LoanAdvHeader.Reset;
                        LoanAdvHeader.SetRange("No.", Rec."No.");
                        // if LoanAdvHeader.Find('-') ;
                        //  REPORT.RUN(REPORT::"Loan & Advance : Echéancier",TRUE,TRUE,LoanAdvHeader);
                    end;
                }
                action(settle)
                {
                    Caption = 'settle';
                    Image = SettleOpenTransactions;

                    trigger OnAction()
                    begin
                        if rec.Observation = '' then begin
                            Message(TXT001);
                            exit;
                        end else
                            CodGLoanAdvance.Solder(Rec, rec."End Date", rec.Name, rec."No.");
                        CodGLoanAdvance.CloturerDocument(Rec);
                        //SETRECFILTER;
                        //REPORT.RUNMODAL(70057,TRUE,FALSE,Rec);
                    end;
                }
                action(Loan)
                {
                    Caption = 'Loan';
                    Image = Loaner;

                    trigger OnAction()
                    var
                        LoanAdvanceHeader_L: Record "Rec. Loan & Advance";
                    begin
                        //LoanAdvanceHeader_L.RESET;//sba ---- 19/03/2023
                        //LoanAdvanceHeader_L.SETRANGE("No.","No.");//sba ---- 19/03/2023
                        //REPORT.RUN(50012,TRUE,FALSE,LoanAdvanceHeader_L);//sba ---- 19/03/2023
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        rec.CalcFields("Paid amount");
        //CALCFIELDS ("Repaid amount","Repaid %");
        if ((rec."Paid amount" <> 0) and (rec."Repaid %" <> 0)) then begin
            "%Amont" := Round((rec."Paid amount" / rec.Amount) * 10000, 1);
            "%Repaid" := Round((rec."Repaid %" / 100) * 10000, 1);
        end
        else begin
            "%Amont" := 0;
            "%Repaid" := 0;
        end;
        rec."Remaining Amount" := rec.Amount - rec."Paid amount";
    end;

    trigger OnInit()
    begin
        /*IF FIND ('+') THEN;*/

    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        rec.Type := rec.Type::Loan;
    end;

    trigger OnOpenPage()
    begin
        //TableEchéancier_G.ValideInvisible(TRUE);

        /*Role.RESET;
        Role.SETRANGE("User Name",USERID);
        Role.SETFILTER("Role ID",'SUPER');
        IF NOT Role.FIND('-') THEN
        BEGIN
            VEchan_G:=FALSE;
        END;
        */
        rec.CalcFields(rec."Paid amount");

    end;

    var
        "%Amont": Integer;
        "%Repaid": Integer;
        Line: Record "Rec. Loan & Advance";
        LoanAdvHeader: Record "Loan & Advance Lines";
        DecGMontant: Decimal;
        Role: Record "Access Control";
        CodGLoanAdvance: Codeunit "Mgmt. of Loans and Advances";
        "TableEchéancier_G": Page "L&A Installment Schedule";
        VEchan_G: Boolean;
        TXT001: Label 'Veuillez Remplir  le champs Observation ';
}

