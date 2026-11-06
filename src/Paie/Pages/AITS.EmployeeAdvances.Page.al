page 70009 "Employee Advances"
{
    DelayedInsert = true;
    PageType = Worksheet;
    RefreshOnActivate = true;
    SourceTable = "Loan & Advance";
    SourceTableView = SORTING(Employee)
                      ORDER(Ascending)
                      WHERE(Type = FILTER(Advance));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {

                field(Employee; rec.Employee)
                {
                }
                field(Name; rec.Name)
                {
                }
                field("Starting Date"; rec."Starting Date")
                {
                    Caption = 'Starting Date';
                }
                field("End Date"; rec."End Date")
                {
                    Caption = 'End Date';
                    Visible = false;
                }
                field(Amount; rec.Amount)
                {
                }
                field("Posting Month"; Rec.Month)
                {
                    Caption = 'Posting Month';
                }
                field("Posting year"; Rec."Posting Year")
                {
                    Caption = 'Posting Year';
                }

                field("Posting Date"; rec."Posting Date")
                {
                    Caption = 'Posting Date';
                    Editable = false;
                }
                field("Job Title"; rec."Job Title")
                {
                    Visible = false;
                }
                field("Employee Posting Group"; rec."Employee Posting Group")
                {
                    Visible = false;
                }
                field("Document type"; rec."Document type")
                {
                    Visible = false;
                }
                field("Slice Amount"; rec."Slice Amount")
                {
                    Caption = 'Installement Amount';
                    Visible = false;
                }
                field("EOSB Advance"; rec."EOSB Advance")
                {
                }

                field("Total to repay"; rec."Total to repay")
                {
                    Visible = false;
                }
                field("User ID"; rec."User ID")
                {
                }
                field(Remarks; rec.Observation)
                {
                    Caption = 'Remarks';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                Visible = false;
                action("Imprimer  Avance")
                {
                    Caption = 'Imprimer  Avance';
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    //  RunObject = Report Report70030;kka
                    Visible = false;
                }
                action("Générer Liste des salarié")
                {
                    Caption = 'Générer Liste des salarié';
                    Image = Employee;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    Visible = false;

                    trigger OnAction()
                    begin
                        REPORT.RunModal(70030);
                        CurrPage.Update;
                    end;
                }
            }
            group(Validation)
            {
                Caption = 'Validation';
                action("Test Report")
                {
                    Caption = 'Test Report';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    Visible = false;

                    trigger OnAction()
                    begin
                        HumRessSetup.Get();
                        CurrPage.SetSelectionFilter(LoanAdvance);
                        REPORT.Run(70021, true, true, LoanAdvance);
                    end;
                }
                action("P&ost")
                {
                    Caption = 'P&ost';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F11';

                    trigger OnAction()
                    begin
                        //CurrPage.SetSelectionFilter(LoanAdvance);
                        LoanAdvance.RESET;
                        LoanAdvance.SetRange(LoanAdvance.Type, LoanAdvance.Type::Advance);
                        REPORT.Run(REPORT::"Payroll : Post Loan & Advance", false, false, LoanAdvance);
                        CurrPage.Update(false);
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
                        REPORT.Run(70021, false, false, LoanAdvance);
                        CurrPage.SetSelectionFilter(LoanAdvance);
                        //kka   REPORT.Run(REPORT::Report50009, false, false, LoanAdvance);
                        CurrPage.Update;
                    end;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        rec.Type := 0;
        rec."Document type" := 'Advance';
    end;

    var
        HumRessSetup: Record "Human Resources Setup";
        LoanAdvance: Record "Loan & Advance";
        FrmGEcheancier: Page "L&A Installment Schedule";
}