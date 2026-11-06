enum 50310 "NAV Bank Facility Status"
{
    Extensible = true;
    Caption = 'Bank Facility Status';

    // Draft : entered, initial entry not generated yet
    value(0; Draft) { Caption = 'Draft'; }
    // Initial Pending : initial entry generated in the journal, waiting for posting
    value(1; "Initial Pending") { Caption = 'Initial Pending'; }
    // Open : initial entry posted, waiting for the due date
    value(2; Open) { Caption = 'Open'; }
    // Matured : due date reached, maturity entry generated in the journal, waiting for posting
    value(3; Matured) { Caption = 'Matured'; }
    // Processed : maturity entry (repayment + commission) posted
    value(4; Processed) { Caption = 'Processed'; }
}
