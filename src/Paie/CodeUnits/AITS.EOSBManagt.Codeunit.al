// Codeunit: Calculate EOSB (End Of Service Benefits) for Saudi Labor Law
// BC version: compatible with BC 19+ (adjust object ids as needed)
// Place in an extension and adapt field names to your Employee table schema.

codeunit 70001 "EOSB Calculator "
{
    SingleInstance = true;


    procedure CalcFinalSettlement(var RecLeave: Record "Leave Entries"; var TotalEOSB: decimal; var Syear: Decimal)
    var
        GrossSalary: Decimal;
        EmploymentDate: Date;
        TerminationDate: Date;
        ServiceDays: Integer;
        YearsWorked: Decimal;
        DailyRate: Decimal;
        FullEOSB: Decimal;
        ProRatedEOSB: Decimal;
        ResignationFactor: Decimal;
        UnusedLeaveDays: Decimal;
        Deductions: Decimal;
        UnusedLeaveAmount: Decimal;
        TotalSettlement: Decimal;
        EOSBAmount: Decimal;
        EmpRec: Record employee;
    begin


        if EmpRec.get(RecLeave.Employee) then
            EmploymentDate := EmpRec."Employment Date";
        TerminationDate := emprec."Termination Date";
        GrossSalary := RecLeave."Gross Salary";



        // Use employment date as start; if missing raise
        IF EmploymentDate = 0D then
            Error('Employment (Join) Date is missing on employee record.');

        // Termination date must be present for final settlement
        if TerminationDate = 0D then
            Error('Termination / Last Working Date is missing on employee record.');

        // --- Calculate service days (inclusive) ---
        // Guard against invalid dates
        IF TerminationDate < EmploymentDate then
            Error('Termination date must be on or after employment date.');

        ServiceDays := TerminationDate - EmploymentDate + 1;

        // Years worked as decimal
        YearsWorked := ServiceDays / 365.0;


        // Daily rate uses 30-day month as per Saudi payroll practice
        DailyRate := ROUND(GrossSalary / 30.0, 2);

        // --- Calculate full EOSB (before resignation reduction) per Saudi law ---
        // First 5 years => 0.5 month per year. After 5 => 1 month per year.
        // Handle prorated years (decimal years) by applying the same factor to fractional part.


        IF YearsWorked <= 5 then begin
            YearsFirstSegment := YearsWorked;
            YearsSecondSegment := 0;
        end else begin
            YearsFirstSegment := 5;
            YearsSecondSegment := YearsWorked - 5;
        end;

        // Full EOSB value (without resignation/termination adjustment)
        // First segment: half month per year => BasicSalary / 2 * YearsFirstSegment
        // Second segment: full month per year => BasicSalary * YearsSecondSegment
        FullEOSB := ROUND((GrossSalary / 2.0) * YearsFirstSegment + (GrossSalary * YearsSecondSegment), 2);

        // --- Apply resignation rules if applicable ---
        // According to Saudi Labor Law:
        // Resignation: <2 years => 0 ; 2-5 => 1/3 ; 5-10 => 2/3 ; >=10 => full
        if RecLeave."Grounds for Term. Code" = 'RESIGNED' then begin
            if YearsWorked < 2 then
                ResignationFactor := 0
            else if (YearsWorked >= 2) and (YearsWorked < 5) then
                ResignationFactor := 1 / 3
            else if (YearsWorked >= 5) and (YearsWorked < 10) then
                ResignationFactor := 2 / 3
            else
                ResignationFactor := 1;

            ProRatedEOSB := ROUND(FullEOSB * ResignationFactor, 2);

        end else begin
            // For terminations (unless for-cause/misconduct), full EOSB applies
            if RecLeave."Grounds for Term. Code" <> 'RESIGNED' then begin
                // If dismissal for gross misconduct — company may be entitled to deny EOSB per law.
                // Implement your company's policy: here, we set to 0 and raise a warning.
                ProRatedEOSB := 0;
                // Consider logging an event or notification for manual review
            end else
                ProRatedEOSB := FullEOSB;
        end;

        // --- Unused leave payout (if any) ---

        UnusedLeaveAmount := ROUND(RecLeave."Unpaid Leave" * DailyRate, 2);



        // --- Total settlement ---
        EOSBAmount := ProRatedEOSB;
        TotalSettlement := ROUND(EOSBAmount + RecLeave."Unpaid Leave" - RecLeave."Other Deduction", 2);
        TotalEOSB := TotalSettlement;
        Syear := YearsWorked;

        // Return values set via VAR params
    end;



    var
        YearsFirstSegment: Decimal;
        YearsSecondSegment: Decimal;

}
