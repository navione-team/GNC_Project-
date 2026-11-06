page 70025 "Job Offer List"
{
    PageType = ListPart;
    SourceTable = "Job Offer";
    SourceTableView = WHERE("Request Type" = FILTER("Job Offer"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Job Offer No"; rec."Job Offer No")
                {
                }
                field("Request Type"; rec."Request Type")
                {
                }
                field(Date; rec.Date)
                {
                }
                field(Name; rec.Name)
                {
                }
                field(Designation; rec.Designation)
                {
                }
                field("Passport/QID"; rec."Passport/QID")
                {
                }
                field("Approval Status"; rec."Approval Status")
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
                field("Notice Period"; rec."Notice Period")
                {
                }
                field(Departement; rec.Departement)
                {
                }
                field("Basic Salary"; rec."Basic Salary")
                {
                }
                field(Accommodation; rec.Accommodation)
                {
                }
                field(Transportation; rec.Transportation)
                {
                }
                field("Mobile allowance"; rec."Mobile allowance")
                {
                }
                field("Others allowances"; rec."Others allowances")
                {
                }
                field("Gross Salary"; rec."Gross Salary")
                {
                }
                field("No. Series"; rec."No. Series")
                {
                }
            }
        }
    }

    actions
    {
    }

    var
        jo: Boolean;
}

