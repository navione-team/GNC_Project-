// Détail « quelle ligne de commande vient de quelle ligne de demande » (FRD 1.4–1.6, REQ-SO-002).
// Une ligne de commande cumulée (ex. 120 = 100 de la demande 1016 + 20 de la demande 1018)
// a ici une ligne par demande. Rempli au Make Order (codeunit 90054) et au regroupement (codeunit 90056).
// Gardé après la validation : les lignes expédiées / facturées le retrouvent par "Order No." + "Order Line No.".
table 90058 "GNC Grouped Request Line"
{
    Caption = 'Grouped Request Line';
    DataClassification = CustomerContent;
    DrillDownPageId = "GNC Grouped Request Lines";
    LookupPageId = "GNC Grouped Request Lines";

    fields
    {
        field(1; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            TableRelation = "Sales Header"."No." where("Document Type" = const(Order));
            ValidateTableRelation = false; // la commande peut être supprimée après facturation
        }
        field(2; "Order Line No."; Integer)
        {
            Caption = 'Order Line No.';
        }
        field(3; "Request No."; Code[20])
        {
            Caption = 'Request No.';
        }
        field(4; "Request Line No."; Integer)
        {
            Caption = 'Request Line No.';
        }
        field(10; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            TableRelation = "Salesperson/Purchaser".Code;
        }
        field(11; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."No.";
        }
        field(12; "Request Date"; Date)
        {
            Caption = 'Request Date';
        }
        field(13; Type; Enum "Sales Line Type")
        {
            Caption = 'Type';
        }
        field(14; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(16; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(17; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(18; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            AutoFormatType = 2;
        }
        field(19; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key(PK; "Order No.", "Order Line No.", "Request No.", "Request Line No.")
        {
            Clustered = true;
        }
        key(Request; "Request No.", "Request Line No.")
        {
        }
    }
}
