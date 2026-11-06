enum 50300 "NAV Rebate Type"
{
    Extensible = true;
    Caption = 'Rebate Type';

    value(0; "End of Deal") { Caption = 'End of Deal'; }
    value(1; "Core Rebate") { Caption = 'Core Rebate'; }
    value(2; "Cash Discount") { Caption = 'Cash Discount'; }
}

enum 50301 "NAV Rebate Status"
{
    Extensible = true;
    Caption = 'Rebate Status';

    // Calculated : preliminary amount computed, nothing posted yet
    value(0; Calculated) { Caption = 'Calculated'; }
    // Provisioned : preliminary provision posted (Expense / Accrued)
    value(1; Provisioned) { Caption = 'Provisioned'; }
    // Validated : final negotiated amount confirmed with the customer
    value(2; Validated) { Caption = 'Validated'; }
    // Credited : final financial credit memo posted
    value(3; Credited) { Caption = 'Credited'; }
    // Closed : final amount = 0, provision fully reversed, no credit memo
    value(4; Closed) { Caption = 'Closed'; }
}

enum 50302 "NAV Rebate Source Doc. Type"
{
    Extensible = true;
    Caption = 'Source Document Type';

    value(0; Invoice) { Caption = 'Invoice'; }
    value(1; "Credit Memo") { Caption = 'Credit Memo'; }
    value(2; Adjustment) { Caption = 'Adjustment'; }
}
