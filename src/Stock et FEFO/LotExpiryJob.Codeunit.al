codeunit 50251 "NAV Lot Expiry Job"
{
    // Rule 18: run daily from the Job Queue. Every batch whose expiry date is earlier
    // than or equal to today gets the status Expired (and is therefore blocked).

    Permissions = tabledata "Lot No. Information" = RM;

    trigger OnRun()
    begin
        UpdateExpiredLots(false);
    end;

    procedure UpdateExpiredLots(ShowResult: Boolean)
    var
        LotNoInfo: Record "Lot No. Information";
        LotManagement: Codeunit "NAV Lot Management";
        Counter: Integer;
    begin
        LotNoInfo.SetFilter("Lot Status", '<>%1', LotNoInfo."Lot Status"::Expired);
        if LotNoInfo.FindSet(true) then
            repeat
                if LotManagement.IsLotExpired(LotNoInfo) then begin
                    LotNoInfo."Lot Status" := LotNoInfo."Lot Status"::Expired;
                    LotManagement.ApplyStatus(LotNoInfo);
                    LotNoInfo.Modify();
                    Counter += 1;
                end;
            until LotNoInfo.Next() = 0;

        if ShowResult and GuiAllowed() then
            Message(ResultMsg, Counter);
    end;

    var
        ResultMsg: Label '%1 batch(es) set to Expired.', Comment = '%1 = number of batches';
}
