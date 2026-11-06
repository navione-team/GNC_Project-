report 70002 "Payroll : Post Loan & Advance"
{
    ProcessingOnly = true;
    ShowPrintStatus = false;
    ApplicationArea = All;

    dataset
    {
        dataitem("Loan & Advance"; "Loan & Advance")
        {

            dataitem("Loan & Advance Type"; "Loan & Advance Type")
            { }


            trigger OnAfterGetRecord()
            begin

                window.Update(1, "Loan & Advance"."No.");
                window.Update(2, "Loan & Advance".Employee + ' - ' + "Loan & Advance".Name);
                window.Update(3, 'Cheching posting Documents');
            end;

            trigger OnPostDataItem()
            var
                RecLTemplateJournal: Record "Gen. Journal Template";
            begin

                if "Loan & Advance".FIND('-') then
                    repeat
                        "Loan & Advance".TESTFIELD("Loan & Advance"."Slice Amount");
                        CduGMgmtLoansAdvances.EnregDocument("Loan & Advance");
                        window.Update(3, 'Posting Document');
                    until "Loan & Advance".NEXT = 0;

                //  CurrReport.ShowOutput(false);
                RecGHumResSetup.Get();
                /*
                IF (("Loan & Advance Type"."Account No." = '')
                    OR
                    ("Loan & Advance Type"."Bal. Account No." = ''))
                  THEN ERROR (errWrongParam);
                
                IF (RecGHumResSetup."Payroll Gen.Journal template" = '')
                  THEN ERROR (errConfig);
                DatGPostingDate:="Loan & Advance"."Posting Date";
                IF DatGPostingDate = 0D
                  THEN ERROR (errDateMissing);
                  */
                /*
                RecGGenJournalLine.SETRANGE ("Journal Template Name",RecGHumResSetup."Payroll Gen.Journal template");
                RecGGenJournalLine.SETRANGE ("Journal Batch Name",RecGHumResSetup."LA.Gen.Journal Batch");//ADDED BY SBN 300510
                IF RecGGenJournalLine.FIND ('+') THEN
                BEGIN
                    IntGLine := RecGGenJournalLine."Line No." + 10000;
                END
                ELSE
                  IntGLine := 10000;
                
                RecGGenJournalLine.RESET;
                RecGGenJournalLine.INIT;
                RecGGenJournalLine."Journal Template Name"     := RecGHumResSetup."Payroll Gen.Journal template";
                IF RecGHumResSetup."LA.Gen.Journal Batch" <> '' THEN
                  RecGGenJournalLine."Journal Batch Name"      := RecGHumResSetup."LA.Gen.Journal Batch"
                 ELSE
                  BEGIN
                    RecGGenJournalBatch.SETRANGE ("Journal Template Name",RecGHumResSetup."Payroll Gen.Journal template");
                    IF RecGGenJournalBatch.FIND ('-') THEN
                      RecGGenJournalLine."Journal Batch Name"  := RecGGenJournalBatch.Name;
                  END;
                
                RecGGenJournalLine.VALIDATE ("Line No."         ,IntGLine);
                CASE "Loan & Advance Type"."Account Type" OF
                  0: RecGGenJournalLine.VALIDATE ("Account Type",0);
                  1: BEGIN
                       RecGGenJournalLine.VALIDATE ("Account Type",3);
                       IF RecGBankAccount.GET ("Loan & Advance Type"."Bal. Account No.") THEN
                         RecGGenJournalLine.VALIDATE ("Currency Code"  ,RecGBankAccount."Currency Code");
                     END;
                END;
                RecGGenJournalLine.VALIDATE ("Account No."      ,"Loan & Advance Type"."Account No.");
                RecGGenJournalLine.VALIDATE ("Posting Date"     ,DatGPostingDate);
                RecGGenJournalLine.VALIDATE ("Document Type"    ,0);
                RecGGenJournalLine.VALIDATE ("Document No."     ,"Loan & Advance"."No.");
                CASE "Loan & Advance Type"."Bal. Account Type" OF
                  0: BEGIN
                       RecGGenJournalLine.VALIDATE ("Bal. Account Type",0);
                       RecGGenJournalLine.VALIDATE ("Currency Code"    ,'');
                     END;
                  1: BEGIN
                       RecGGenJournalLine.VALIDATE ("Bal. Account Type",3);
                       IF RecGBankAccount.GET ("Loan & Advance Type"."Bal. Account No.") THEN
                         RecGGenJournalLine.VALIDATE ("Currency Code",RecGBankAccount."Currency Code");
                     END;
                END;
                IF RecLTemplateJournal.GET(RecGHumResSetup."Payroll Gen.Journal template") THEN
                 RecGGenJournalLine.VALIDATE("Source Code",RecLTemplateJournal."Source Code");
                IF "Loan & Advance Type".GET("Loan & Advance"."Document type") THEN;//ALH
                RecGGenJournalLine.VALIDATE ("Bal. Account No." ,"Loan & Advance Type"."Bal. Account No.");
                RecGGenJournalLine.VALIDATE("Account No.","Loan & Advance Type"."Account No.");//ALH
                RecGGenJournalLine.VALIDATE ("Debit Amount"     ,"Total to repay");
                RecGGenJournalLine.INSERT;
                window.UPDATE(3,'Création de l''écriture comptable');
                CASE OptGPostingMode OF
                 1 : BEGIN
                       RecGGenJournalLine.SETRANGE ("Journal Template Name",RecGHumResSetup."Payroll Gen.Journal template");
                       RecGGenJournalLine.SETRANGE ("Journal Batch Name",RecGGenJournalLine."Journal Batch Name");
                       RecGGenJournalLine.SETRANGE ("Line No.",IntGLine);
                       RecGGenJournalLine.SETRANGE  ("Document No.","Loan & Advance"."No.");
                       IF RecGGenJournalLine.FIND ('-') THEN
                         CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post",RecGGenJournalLine);
                     END;
                END;
                */

            end;

            trigger OnPreDataItem()
            begin

                LastFieldNo := FIELDNO("Document type");
                window.Open('Posting Loans && Advances in progress ...\' +
                             'N° document : ########################1####\' +
                             "Loan & Advance".FIELDCAPTION(Employee) + '     : ########################2####\' +
                             '######################################3####');
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control1000000000)
                {
                    Caption = 'Option';
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        DatGPostingDate := "Loan & Advance"."Posting Date";
    end;

    trigger OnPreReport()
    begin
        DatGPostingDate := "Loan & Advance"."Posting Date";
    end;

    var
        LastFieldNo: Integer;
        FooterPrinted: Boolean;
        CduGMgmtLoansAdvances: Codeunit "Mgmt. of Loans and Advances";
        DatGPostingDate: Date;
        OptGPostingMode: Option "Par Feuille de saisie",Directe;
        RecGHumResSetup: Record "Human Resources Setup";
        RecGGenJournalLine: Record "Gen. Journal Line";
        RecGGenJournalBatch: Record "Gen. Journal Batch";
        CduGGenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        IntGLine: Integer;
        RecGBankAccount: Record "Bank Account";
        window: Dialog;
        RecGLA: Record "Loan & Advance";
        Manufacturer_G: Record Manufacturer;
        TotalFor: Label 'Total ';
        errConfig: Label 'General Journal Template empty in Human Resource Parameter.';
        errLATypeMissing: Label 'Loan & Advance Type missing.';
        errWrongParam: Label 'Account No. or Bal. Account No. empty in Loan & Advance type parameter.';
        success: Label 'Document posting operation successfull.\Lines inserted on Journal : %1 - %2.';
        errDateMissing: Label 'Posting date must be mentionned.';
        errDoc: Label '%1 is not a valid document. Some needed informations are missing.';
}

