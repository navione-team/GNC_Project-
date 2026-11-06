pageextension 70049 "EmployeeCardExt" extends "Employee Card"
{
    layout
    {
        addafter("Balance (LCY)")
        {


            field("Passport No."; Rec."Passport No.") { ApplicationArea = all; }
            field("Passport Expiry Date"; Rec."Passport Expiry Date") { ApplicationArea = all; }
            field("SID"; Rec."SID") { ApplicationArea = all; }
            field("SID Expiry Date"; Rec."SID Expiry Date") { ApplicationArea = all; }
            field("HCard No."; Rec."HCard No.") { ApplicationArea = all; }
            field("HCard Expiry Date"; Rec."HCard Expiry Date") { ApplicationArea = all; }
            field(CountryOfOrigin; Rec."Country of Origin") { ApplicationArea = all; }
        }
        addafter("SWIFT Code")
        {
            field("Gross Salary"; Rec."Gross Salary")
            {
                ApplicationArea = all;
                Editable = FALSE;
            }
            field("Basic Salary"; Rec."Basic Salary")

            {
                ApplicationArea = all;
                Editable = FALSE;
            }

            field("Payment Method Code"; Rec."Payment Method Code")
            {
                TableRelation = "Payment Method";
                ApplicationArea = all;
            }
            field(Bank; Rec.Bank) { ApplicationArea = all; }
            field("IBAN No."; Rec."IBAN No.") { ApplicationArea = all; }
            field(IBAN2; Rec.IBAN2) { ApplicationArea = all; }
        }
        addafter("Union Code")
        {
            field("Full Name"; Rec."Full Name") { ApplicationArea = all; }
            field("Marital Status"; Rec."Marital Status") { ApplicationArea = all; }
            field("Family Chief"; Rec."Family Chief") { ApplicationArea = all; }
            field("Childs In Charge"; Rec."Childs In Charge") { ApplicationArea = all; }
            field("Special Comment"; Rec."Special Comment") { ApplicationArea = all; }
        }
        addlast(Content)
        {
            group("Employment & Leave Info")
            {
                field("Joining Date"; Rec."Joining Date") { ApplicationArea = all; }
                field("Last Working Date"; Rec."Last Working Date") { ApplicationArea = all; }
                field("Vacation Resume Date"; Rec."Vacation Resume Date") { ApplicationArea = all; }
                field("Vacation Start Date"; Rec."Vacation Start Date") { ApplicationArea = all; }
                field("Vacation End Date"; Rec."Vacation End Date") { ApplicationArea = all; }
                field("Contract Vacation Days"; Rec."Contract Vacation Days") { ApplicationArea = all; }
                field("Punishment Days"; Rec."Punishment Days") { ApplicationArea = all; }
                field("Orverdue Resume date"; Rec."Orverdue Resume date") { ApplicationArea = all; }
                field("Overdue"; Rec.Overdue) { ApplicationArea = all; }
                field("Employee Contract Type"; Rec."Employee Contract Type") { ApplicationArea = all; }
                field("Contract Type"; Rec."Contract Type") { ApplicationArea = all; }
                field("Employee Calendar"; Rec."Employee Calendar") { ApplicationArea = all; }
                field("Leave Status"; Rec."Leave Status") { ApplicationArea = all; }
                field("Work Authorisation"; Rec."Work Authorisation") { ApplicationArea = all; }
                field("End Probation Date"; Rec."End Probation Date") { ApplicationArea = all; }
            }


            group("Transfer & Assignment")
            {
                field("Transfert date"; Rec."Transfert date") { ApplicationArea = all; }
                field("Transfert from date"; Rec."Transfert from date") { ApplicationArea = all; }
                field("Transfert to date"; Rec."Transfert to date") { ApplicationArea = all; }
                field("Work Company"; Rec."Work Company") { ApplicationArea = all; }
                field("Work Company Name"; Rec."Work Company Name") { ApplicationArea = all; }
                field("Office Manager"; Rec."Office Manager") { ApplicationArea = all; }
                field("Direct Manager Name"; Rec."Direct Manager Name") { ApplicationArea = all; }
                field("Employee Department"; Rec."Employee Department") { ApplicationArea = all; }
            }

            group("Sponsorship & Legal")
            {
                field(Sponsor; Rec.Sponsor) { ApplicationArea = all; }
                field("Sponsor Name"; Rec."Sponsor Name") { ApplicationArea = all; }
                field("Payer ID"; Rec."Payer ID") { ApplicationArea = all; }
                field("GOSI Applied"; Rec."GOSI Applied") { ApplicationArea = all; }
                field("Insurance Affiliated"; Rec."Insurance Affiliated")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    begin
                        BoolInsVis := Rec."Insurance Affiliated";
                        CurrPage.Update();


                    end;

                }
                field("Insurance Amount per Year"; Rec."Insurance Amount per Year")
                {
                    ApplicationArea = all;
                }

            }



            group("Emergency & Contact Info")
            {
                field("Saudi Emergency Contact Name"; Rec."SA Emergency Contact Name") { ApplicationArea = all; }
                field(Relationship; Rec.Relationship) { ApplicationArea = all; }
                field("Mobile Number"; Rec."Mobile Number") { ApplicationArea = all; }
                field("Home Adress"; Rec."Home Adress") { ApplicationArea = all; }
                field("Home Co Emergency Contact Name"; Rec."Home Co Emergency Contact Name") { ApplicationArea = all; }
                field("Home Co RelationShip"; Rec."Home Co RelationShip") { ApplicationArea = all; }
                field("Country Mobile Number"; Rec."Country Mobile Number") { ApplicationArea = all; }
                field("Country Home Adress"; Rec."Country Home Adress") { ApplicationArea = all; }
                field("last resume date"; Rec."last resume date") { ApplicationArea = all; }
            }

            group("Travel Info")
            {
                field("Travel Tickets"; Rec."Travel Tickets") { ApplicationArea = all; }
                field("Last Travel Ticket Amount"; Rec."Travel Ticket Amount") { ApplicationArea = all; }
            }
        }
    }

    actions
    {
        addafter("F&unctions")
        {
            action("Employment Contract")

            {
                Caption = 'Contract';
                Image = EmployeeAgreement;
                RunObject = page "Employment Contract Card";
                RunPageLink = Code = FIELD("Emplymt. Contract Code");
                ApplicationArea = all;

            }
        }
    }

    var
        BoolInsVis: Boolean;
}
