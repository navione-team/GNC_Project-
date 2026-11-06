page 50008 NavioneCueForAccounting
{
    Caption = 'Navione Cue For Accounting';
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "Activities Cue";
    ApplicationArea = all;

    layout
    {
        area(Content)
        {
            cuegroup("Notification & Alert")
            {
                field("Prepaid Stand By"; Rec."Prepaid Stand By")
                {
                    trigger OnDrillDown()
                    var
                        GenneralJournalLine: Record "Gen. Journal Line";
                    begin
                        GenneralJournalLine.SetRange(Prepaid, true);
                        GenneralJournalLine.setfilter("Account No.", '<>%1', '');
                        Page.RunModal(page::"General Journal", GenneralJournalLine);
                    end;
                }
            }
        }
    }
    var CostAmount: Decimal;
    Startdateofweek1: Date;
    EnddateofWeek1: Date;
    TodayDateNo: Integer;
    vendledentry: Record 25;
    ItemLedgerEntry: Record 32;
    CustLedgerEntry: Record "Cust. Ledger Entry";
    MargeGlobal: Decimal;
    TxtMargeGlobal: Text;
    PCTObjectifRealized: Decimal;
    OverdueCount: Integer;
    OverdueCount2: Integer;
    OverdueStyle: Text;
    OverdueStyle2: Text;
}
