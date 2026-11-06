tableextension 60006 "Exte-Activity Cue" extends "Activities Cue"
{
    fields
    {
        field(50038; "Net Invoicing this Week"; Decimal)
        {
            Caption = 'Net Invoicing this Week';
            AutoFormatType = 0;
            DecimalPlaces = 0;
        }
        field(50039; "Net Invoicing MTD"; Decimal)
        {
            Caption = 'Net Invoicing MTD';
            AutoFormatType = 0;
            DecimalPlaces = 0;
        }
        field(50040; "Net Purchase Invoicing YTD"; Decimal)
        {
            Caption = 'Net Purchase Invoicing YTD';
            AutoFormatType = 0;
            DecimalPlaces = 0;
        }
        field(50041; "Payment Recieved this week"; Decimal)
        {
            Caption = 'Payment Recieved this week';
            AutoFormatType = 0;
            DecimalPlaces = 0;
        }
        field(50042; "Payment Received this month"; Decimal)
        {
            Caption = 'Payment Received this month';
            AutoFormatType = 0;
            DecimalPlaces = 0;
        }
        field(50043; "Payment received YTD"; Decimal)
        {
            Caption = 'Payment received YTD';
            AutoFormatType = 0;
            DecimalPlaces = 0;
        }
        field(50049; "Filtre Date"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(50081; "Net Sales this Week"; Decimal)
        {
            // Caption = 'Net Vente Cette Semaine';
            AutoFormatType = 0;
            DecimalPlaces = 0;
        }
        field(50082; "Net Sales MTD"; Decimal)
        {
            Caption = 'Net Sales This Month';
            AutoFormatType = 0;
            DecimalPlaces = 0;
        }
        field(50083; "Net Sales YTD"; Decimal)
        {
            Caption = 'Net Sales This Year';
            AutoFormatType = 0;
            DecimalPlaces = 0;
        }
        field(50084; "Net Ventes"; Decimal)
        {
            CalcFormula = sum("Sales Invoice Line".Amount);
            //  Caption = 'Dataverse Integration Errors';
            FieldClass = FlowField;
            DecimalPlaces = 0;
        }
        field(50085; "Net Credit Memo"; Decimal)
        {
            CalcFormula = sum("Sales Cr.Memo line".Amount);
            //  Caption = 'Dataverse Integration Errors';
            FieldClass = FlowField;
            DecimalPlaces = 0;
        }
        field(50086; "Prepaid Stand By"; Integer)
        {
            Caption = 'Prepaid Stand By';
            FieldClass = FlowField;
            CalcFormula = count("Gen. Journal Line" where(Prepaid=const(true), "Account No."=filter(<>'')));
        }
        field(60150; "Sales Week Date Filter"; Date)
        {
            Caption = 'Sales Week Date Filter';
            FieldClass = FlowFilter;
        }
        field(60151; "Sales Month Date Filter"; Date)
        {
            Caption = 'Sales Month Date Filter';
            FieldClass = FlowFilter;
        }
        field(60152; "Sales Quarter Date Filter"; Date)
        {
            Caption = 'Sales Quarter Date Filter';
            FieldClass = FlowFilter;
        }
        field(60153; "Sales Semester Date Filter"; Date)
        {
            Caption = 'Sales Semester Date Filter';
            FieldClass = FlowFilter;
        }
        field(60154; "Sales Year Date Filter"; Date)
        {
            Caption = 'Sales Year Date Filter';
            FieldClass = FlowFilter;
        }
        field(60155; "Week Subscription Count"; Integer)
        {
            Caption = 'Number of Subscriptions This Week';
            FieldClass = FlowField;
            CalcFormula = count("Sales Invoice Header" where("Posting Date"=field("Sales Week Date Filter")));
        }
        field(60156; "Month Subscription Count"; Integer)
        {
            Caption = 'Number of Subscriptions This Month';
            FieldClass = FlowField;
            CalcFormula = count("Sales Invoice Header" where("Posting Date"=field("Sales Month Date Filter")));
        }
        field(60157; "Quarter Subscription Count"; Integer)
        {
            Caption = 'Number of Subscriptions This Quarter';
            FieldClass = FlowField;
            CalcFormula = count("Sales Invoice Header" where("Posting Date"=field("Sales Quarter Date Filter")));
        }
        field(60158; "Semester Subscription Count"; Integer)
        {
            Caption = 'Number of Subscriptions This Semester';
            FieldClass = FlowField;
            CalcFormula = count("Sales Invoice Header" where("Posting Date"=field("Sales Semester Date Filter")));
        }
        field(60159; "Year Subscription Count"; Integer)
        {
            Caption = 'Number of Subscriptions This Year';
            FieldClass = FlowField;
            CalcFormula = count("Sales Invoice Header" where("Posting Date"=field("Sales Year Date Filter")));
        }
        field(60160; "Week Sales Amount Excl VAT"; Decimal)
        {
            Caption = 'Sales Amount Excl. VAT This Week';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Invoice Line".Amount where("Posting Date"=field("Sales Week Date Filter")));
            DecimalPlaces = 0: 2;
        }
        field(60161; "Month Sales Amount Excl VAT"; Decimal)
        {
            Caption = 'Sales Amount Excl. VAT This Month';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Invoice Line".Amount where("Posting Date"=field("Sales Month Date Filter")));
            DecimalPlaces = 0: 2;
        }
        field(60162; "Quarter Sales Amt Excl VAT"; Decimal)
        {
            Caption = 'Sales Amount Excl. VAT This Quarter';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Invoice Line".Amount where("Posting Date"=field("Sales Quarter Date Filter")));
            DecimalPlaces = 0: 2;
        }
        field(60163; "Semester Sales Amt Excl VAT"; Decimal)
        {
            Caption = 'Sales Amount Excl. VAT This Semester';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Invoice Line".Amount where("Posting Date"=field("Sales Semester Date Filter")));
            DecimalPlaces = 0: 2;
        }
        field(60164; "Year Sales Amount Excl VAT"; Decimal)
        {
            Caption = 'Sales Amount Excl. VAT This Year';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Invoice Line".Amount where("Posting Date"=field("Sales Year Date Filter")));
            DecimalPlaces = 0: 2;
        }
    }
}
