page 70029 "Hiring Request SubPage"
{
    PageType = ListPart;
    SourceTable = "Job Offer";
    SourceTableView = WHERE("Request Type" = FILTER("Hiring Request"));
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Job Offer No"; rec."Job Offer No")
                {
                    Caption = 'Request ID';
                }
                field("Request Type"; rec."Request Type")
                {
                }
                field(Periority; rec.Periority)
                {
                }
                field(Departement; rec.Departement)
                {
                }
                field("Requested By"; rec."Requested By")
                {
                }
                field("Expected Start Date"; rec."Expected Start Date")
                {
                }
                field("Salary range"; rec."Salary range")
                {
                }
                field("Approval date"; rec."Approval date")
                {
                }
                field("Approval Status"; rec."Approval Status")
                {
                }
                field("Number Of Employee To Hire"; rec."Number Of Employee To Hire")
                {
                }
                field("Comment/Notes"; rec."Comment/Notes")
                {
                }
                field("User Id"; rec."User Id")
                {
                }
                field("Request Date"; rec."Request Date")
                {
                }
            }
        }
    }

    actions
    {
    }

    var
        hr: Boolean;
        jo: Boolean;
}

