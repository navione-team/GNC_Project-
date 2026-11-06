table 70005 "TimeSheet Header"
{

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Store Code"; Code[20])
        {
            TableRelation = Location;

            trigger OnValidate()
            begin
                Description := "Store Code" + '  ' + 'TimeSheet' + '  ' + Format(Month) + ' ' + Year
            end;
        }
        field(3; Month; Option)
        {
            OptionMembers = " ",January,February,March,April,May,June,July,August,September,October,November,December;

            trigger OnValidate()
            begin
                Description := "Store Code" + '  ' + 'TimeSheet' + '  ' + Format(Month) + ' ' + Year
            end;
        }
        field(4; Year; Code[4])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Description; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Creation Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "No Serie"; Code[10])
        {
            DataClassification = ToBeClassified;
            TableRelation = "No. Series";
        }
        field(8; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = ,Open,Released;
        }
        field(9; USER_ID; Code[25])
        {
            DataClassification = ToBeClassified;
            TableRelation = User;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        Rec_Attendance.SetRange("Attendance No", "No.");
        if Rec_Attendance.FindSet then
            if Confirm('This Action will delete the attendance line related') then
                Rec_Attendance.DeleteAll;
    end;

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        HumanRsetup.Get();
        if "No." = '' then begin
            HumanRsetup.TestField("Attendance No");
            // Assign the default number series
            "No Serie" := HumanRsetup."Attendance No";
            // Retain related series if previously used
            if NoSeries.AreRelated(HumanRsetup."Attendance No", xRec."No Serie") then
                "No Serie" := xRec."No Serie";
            // Generate and assign the next number
            "No." := NoSeries.GetNextNo("No Serie", WorkDate());
        end;
        "Creation Date" := WorkDate;
        Year := Format(Date2DWY("Creation Date", 3));
        Description := "Store Code" + '  ' + 'TimeSheet' + '  ' + Format(Month) + ' ' + Year;
        USER_ID := UserId;
        Status := Status::Open;
    end;


    var
        HumanRsetup: Record "Human Resources Setup";
        NoSerieMGT: Codeunit "No. Series - Setup";
        header: Record "TimeSheet Header";
        Rec_Attendance: Record "TimeSheet Line";


    procedure AssistEdit(Oldheader: Record "TimeSheet Header"): Boolean
    var
        NoSeries: Codeunit "No. Series";
        header: Record "TimeSheet Header";
    begin
        header := Rec;

        HumanRsetup.Get();
        HumanRsetup.TestField("Attendance No");

        // Let the user select a related number series
        if NoSeries.LookupRelatedNoSeries(
               HumanRsetup."Attendance No",
               Oldheader."No Serie",
               Rec."No Serie")
        then begin
            // Generate the next document number using the selected series
            "No." := NoSeries.GetNextNo("No Serie");

            Rec := header;
            exit(true);
        end;

        exit(false);
    end;

}

