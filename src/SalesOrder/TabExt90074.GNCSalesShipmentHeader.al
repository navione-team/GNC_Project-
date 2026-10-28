// Lot 7 – Mêmes champs que sur "Sales Header" (tableextension 90014), mêmes numéros :
// recopiés automatiquement à la validation de l'expédition (TransferFields).
tableextension 90074 "GNC Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(90005; "GNC Delivery Priority"; Enum "GNC Delivery Priority")
        {
            Caption = 'Delivery Priority';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(90006; "GNC Driver Code"; Code[20])
        {
            Caption = 'Driver Code';
            DataClassification = CustomerContent;
            TableRelation = "GNC Driver".Code;
            Editable = false;
        }
        field(90008; "GNC Driver Name"; Text[100])
        {
            Caption = 'Driver Name';
            FieldClass = FlowField;
            CalcFormula = lookup("GNC Driver".Name where("Code" = field("GNC Driver Code")));
            Editable = false;
        }
        field(90009; "GNC Stop No."; Integer)
        {
            Caption = 'Stop No.';
            DataClassification = CustomerContent;
            Editable = false;
            BlankZero = true;
        }
    }
}
