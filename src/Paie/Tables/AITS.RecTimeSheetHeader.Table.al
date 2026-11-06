table 70015 "Rec TimeSheet Header"
{

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Store Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Location;
        }
        field(3; Month; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",January,February,March,April,May,June,July,August,September,October,November,December;
        }
        field(4; Year; Code[4])
        {
            DataClassification = ToBeClassified;
        }
        field(5; Description; Text[100])
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
}

