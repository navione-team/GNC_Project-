page 70023 "Employee.List"
{
    PageType = List;
    SourceTable = Employee;
    Editable = false;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; rec."No.") { }
                field(Name; rec."Full Name") { }
                field("Job Title"; rec."Job Title") { }
                field(Address; rec.Address) { }
                field("Address 2"; rec."Address 2") { }
                field(City; rec.City) { }
                field("Post Code"; rec."Post Code") { }
                field(Country; rec.County) { }
                field("Phone No."; rec."Phone No.") { }
                field("Mobile Phone No."; rec."Mobile Phone No.") { }
                field("E-Mail"; rec."E-Mail") { }
                field("Alt. Address Code"; rec."Alt. Address Code") { }
                field("Alt. Address Start Date"; rec."Alt. Address Start Date") { }
                field("Alt. Address End Date"; rec."Alt. Address End Date") { }
                //  field(Picture; rec.Picture) { }
                field("Birth Date"; rec."Birth Date") { }
                field("Social Security No."; rec."Social Security No.") { }
                //  field("Payer Code"; rec."Payer Code") { }kka
                field("Union Membership No."; rec."Union Membership No.") { }
                field(Gender; rec.Gender) { }
                field("Country/Region Code"; rec."Country/Region Code") { }
                field("Manager No."; rec."Manager No.") { }
                field("Emplymt. Contract Code"; rec."Emplymt. Contract Code") { }
                field("Statistics Group Code"; rec."Statistics Group Code") { }
                field("Employment Date"; rec."Employment Date") { }
                field(Status; rec.Status) { }
                field("Inactive Date"; rec."Inactive Date") { }
                field("Cause of Inactivity Code"; rec."Cause of Inactivity Code") { }
                field("Termination Date"; rec."Termination Date") { }
                field("Grounds for Term. Code"; rec."Grounds for Term. Code") { }
                field("Global Dimension 1 Code"; rec."Global Dimension 1 Code") { }
                field("Global Dimension 2 Code"; rec."Global Dimension 2 Code") { }
                field("Resource No."; rec."Resource No.") { }
                field(Comment; rec.Comment) { }
                field("Last Date Modified"; rec."Last Date Modified") { }
                field("Date Filter"; rec."Date Filter") { }
                field("Global Dimension 1 Filter"; rec."Global Dimension 1 Filter") { }
                field("Global Dimension 2 Filter"; rec."Global Dimension 2 Filter") { }
                field("Cause of Absence Filter"; rec."Cause of Absence Filter") { }
                field("Total Absence (Base)"; rec."Total Absence (Base)") { }
                field(Extension; rec.Extension) { }
                field("Employee No. Filter"; rec."Employee No. Filter") { }
                field(Pager; rec.Pager) { }
                field("Fax No."; rec."Fax No.") { }
                field("Company E-Mail"; rec."Company E-Mail") { }
                field(Title; rec.Title) { }
                field("Salespers./Purch. Code"; rec."Salespers./Purch. Code") { }
                field("No. Series"; rec."No. Series") { }
                field("Last Modified Date Time"; rec."Last Modified Date Time") { }
                field("Employee Posting Group"; rec."Employee Posting Group") { }
                field("Bank Branch No."; rec."Bank Branch No.") { }
                field("Bank Account No."; rec."Bank Account No.") { }
                field(IBAN; rec.IBAN) { }
                field(Balance; rec.Balance) { }
                field("SWIFT Code"; rec."SWIFT Code") { }
                field("Application Method"; rec."Application Method") { }
                field(Image; rec.Image) { }
                field("Privacy Blocked"; rec."Privacy Blocked") { }
                field("Cost Center Code"; rec."Cost Center Code") { }
                field("Cost Object Code"; rec."Cost Object Code") { }
                //field(Id; rec.Id) { } SBN
                field("Passport No."; rec."Passport No.") { }
                field("Passport Expiry Date"; rec."Passport Expiry Date") { }
                field("SID No."; rec."SID") { }
                field("SID Expiry Date"; rec."SID Expiry Date") { }
                field(Nationality; rec."Country of Origin") { }
                field("HCard No."; rec."HCard No.") { }
                field("HCard Expiry Date"; rec."HCard Expiry Date") { }
                field(Bank; rec.Bank) { }
                field("IBAN No."; rec."IBAN No.") { }
                field("Travel Tickets"; rec."Travel Tickets") { }
                field("Gross Salary"; rec."Gross Salary") { }
                //field("reseved Field"; rec."reseved Field") { }
                //field("Reserved field 2"; rec."Reserved field 2") { }
                field("Joining Date"; rec."Joining Date") { }
                field("Basic Salary"; rec."Basic Salary") { }
                field("Payment Method Code"; rec."Payment Method Code") { }
            }
        }
    }

    actions
    {
    }
}
