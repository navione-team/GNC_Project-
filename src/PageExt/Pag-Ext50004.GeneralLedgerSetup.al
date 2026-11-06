pageextension 50004 "General Ledger Setup" extends "General Ledger Setup" //118
{
    layout
    {

        addafter("Local Currency Description")
        {

        }

        addafter(Application)

        {
            group(NAVIONE)
            {


                group(WHT)
                {
                    field("WHT Journal Template Code"; Rec."WHT Journal Template Code")
                    {
                        ApplicationArea = all;
                    }
                    field("WHT Journal Batch Code"; Rec."WHT Journal Batch Code")
                    {
                        ApplicationArea = all;
                    }
                    field("WHT Debit Account"; Rec."WHT Debit Account")
                    {
                        ApplicationArea = all;
                    }
                    field("WHT Credit Account"; Rec."WHT Credit Account")
                    {
                        ApplicationArea = all;

                    }
                }

                group(Prepaid)
                {
                    field("Prepaid Serial No."; Rec."Prepaid Serial No.")
                    {
                        ApplicationArea = all;
                    }
                    field("Default Gen. Jrnl Prepaid Temp"; Rec."Default Gen. Jrnl Prepaid Temp")
                    {
                        ApplicationArea = all;
                    }

                    field("Default Gen. Jrnl Prep Batch"; Rec."Default Gen. Jrnl Prep Batch")
                    {
                        ApplicationArea = all;
                    }
                    field("Debit Global Amount Account"; Rec."Prepaid Debit Global Amnt Acc")
                    {
                        ApplicationArea = all;
                    }
                    field("Credit Global Amount Account"; Rec."Prepaid Credit Global Amnt Acc")
                    {
                        ApplicationArea = all;
                    }
                    field("Debit Amount Account"; Rec."Prepaid Debit Amount Account")
                    {
                        ApplicationArea = all;
                    }
                    field("Credit Amount Account"; Rec."Prepaid Credit Amount Account")
                    {
                        ApplicationArea = all;
                    }

                    field("Prepaid Source Code"; Rec."Prepaid Source Code")
                    {
                        ApplicationArea = all;
                    }
                }


                group("Bank Reconciliation")
                {
                    field("Bank Acc. Recon. Template Name "; Rec."Bank Acc. Recon. Template Name")
                    {
                        ApplicationArea = all;
                    }

                    field("Bank Acc. Recon. Batch Name "; Rec."Bank Acc. Recon. Batch Name")
                    {
                        ApplicationArea = all;
                    }
                }


            }



        }
    }

}
