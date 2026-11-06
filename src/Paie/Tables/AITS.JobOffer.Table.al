table 70000 "Job Offer"
{
    Permissions = TableData "Job Offer" = rimd;

    fields
    {
        field(1; "Job Offer No"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if "Job Offer No" <> xRec."Job Offer No" then begin
                    HumanResSetup.Get;
                    NoSeriesMgt.TestManual(HumanResSetup."Job Offer Nos");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Date; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(3; Name; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Designation; Text[100])
        {
        }
        field(5; "Passport/QID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Approval Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Active,Pending,Approved,Rejected;
        }
        field(7; "Employee Localisation"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,"Inside Country","Outside Country";
        }
        field(8; "Visa Status"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Contact Number"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Notice Period"; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(11; Departement; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,Sale,Marketing,Accounting,IT,Administration;
        }
        field(12; "Basic Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(13; Accommodation; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(14; Transportation; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(15; "Mobile allowance"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Others allowances"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Gross Salary"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = "No. Series";
        }
        field(20; "Employee Contract Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ","Full-Time","Part-time","Temporary",Permanent,"Fixed-Term",Contractor,Internship,FreeLance,Casual;
        }
        field(21; "Job Offer Validity"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Request Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,"Job Offer","Hiring Request";
        }
        field(23; "Request Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Requested By"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Expected Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Salary range"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Approval date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Comment/Notes"; Text[300])
        {
            DataClassification = ToBeClassified;
        }
        field(29; "User Id"; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = "User Setup"."User ID";
        }
        field(30; "Number Of Employee To Hire"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(31; "Linked Request ID"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Job Offer"."Job Offer No" WHERE("Request Type" = FILTER("Hiring Request"),
                                                              "Approval Status" = FILTER(Approved));
        }
        field(32; "Employee CV"; Media)
        {
            DataClassification = ToBeClassified;
        }
        field(33; "Work Hours"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(34; "Annual Leave Days"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(35; "Probation Periode"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(36; MedicalInsurance; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        field(37; "Airline Ticket"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Every Year","Two Year";
        }
        field(38; "Medical Insurance"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(39; Sponsor; Code[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Union.Code;

            trigger OnValidate()
            begin
                if RecSponsor.Get(Sponsor) then
                    Sponsor := RecSponsor.Description;
            end;
        }
        field(40; Periority; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",Critical,High,Normal,Low;
        }
        field(41; Country; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Country/Region".Code;

            trigger OnValidate()
            begin
                if Rec_Country.Get(Country) then
                    "Country Name" := Rec_Country.Name;
            end;
        }
        field(42; "Country Name"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Job Offer No")
        {
            Clustered = true;
        }
        key(Key2; Designation)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        HumanResSetup.Get;
        if "Job Offer No" = '' then begin
            HumanResSetup.TestField("Job Offer Nos");
            // Assign the default series from setup
            "No. Series" := HumanResSetup."Job Offer Nos";
            // If a related series was previously used, keep that
            if NoSeriesMgt.AreRelated(HumanResSetup."Job Offer Nos", xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            // Get the next number and assign it
            "Job Offer No" := NoSeriesMgt.GetNextNo("No. Series");
            "Approval Status" := "Approval Status"::Active;
            Date := WorkDate;
            "Request Date" := WorkDate;
            if UserSetUp.Get(UserId) then
                "User Id" := UserId;
        end;
    End;

    var
        RecgEmp: Record Employee;
        HumanResSetup: Record "Human Resources Setup";
        NoSeriesMgt: Codeunit "No. Series";
        Joboffer: Record "Job Offer";
        UserSetUp: Record "User Setup";
        Instr: InStream;
        testfile: Text[250];
        Rec_Country: Record "Country/Region";
        RecSponsor: Record "Employee Sponsor/Payer";


    procedure AssistEdit(OldJobOffer: Record "Job Offer"): Boolean
    begin
        Joboffer := Rec;
        OldJobOffer := Rec; // capture previous values
        HumanResSetup.Get();
        HumanResSetup.TestField("Job Offer Nos");
        // Show the user the No. Series lookup dialog and capture selection
        if NoSeriesMgt.LookupRelatedNoSeries(HumanResSetup."Job Offer Nos", OldJobOffer."No. Series", Rec."No. Series")
        then begin
            // Generate next document number using the selected series
            Rec."Job Offer No" := NoSeriesMgt.GetNextNo(Rec."No. Series");
            Rec := Joboffer;
            exit(true);
        end;
    end;
}

