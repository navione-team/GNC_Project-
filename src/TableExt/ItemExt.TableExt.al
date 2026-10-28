tableextension 90022 "Item Ext" extends Item
{
    fields
    {
        field(90040; "Product Group Code"; Code[20])
        {
            Caption = 'Product Group Code';
            DataClassification = CustomerContent;
            TableRelation = "Product Group".Code;
        }
        field(90041; "Item Family Code"; Code[30])
        {
            Caption = 'Item Family Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Family".Code;
        }
        field(90042; "Arabic Description"; Text[250])
        {
            Caption = 'Arabic Description';
            DataClassification = CustomerContent;
        }
        field(90043; "Units per Pack"; Decimal)
        {
            Caption = 'Units per Pack';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(90044; "Tablets per Pack"; Decimal)
        {
            Caption = 'Tablets per Pack';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(90045; "Sales Price per Pack"; Decimal)
        {
            Caption = 'Sales Price per Pack';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(90046; "Sales Price per Tablet"; Decimal)
        {
            Caption = 'Sales Price per Tablet';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(90047; "Default Location Code"; Code[10])
        {
            Caption = 'Default Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(90048; Remarks; Text[250])
        {
            Caption = 'Remarks';
            DataClassification = CustomerContent;
        }
    }
}
