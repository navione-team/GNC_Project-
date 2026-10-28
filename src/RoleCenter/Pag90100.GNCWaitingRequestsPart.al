// Petite liste « Requests waiting » de la page d'accueil : demandes approuvées pas encore regroupées,
// avec leur commercial (« no PIN » en jaune : la demande ne sera pas regroupée). Cliquer ouvre la demande.
page 90100 "GNC Waiting Requests Part"
{
    Caption = 'Requests Waiting';
    PageType = ListPart;
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Quote), Status = const(Released), "GNC Closed" = const(false));
    CardPageId = "Sales Quote";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Requests)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the request (sales quote) number.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer';
                    ToolTip = 'Specifies the customer.';
                }
                field(SalespersonText; SalespersonText)
                {
                    ApplicationArea = All;
                    Caption = 'Salesperson';
                    StyleExpr = SalespersonStyle;
                    ToolTip = 'Specifies the salesperson. "no PIN" means the salesperson is not confirmed and the request cannot be grouped.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount of the request excluding VAT.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenRequestsToGroup)
            {
                ApplicationArea = All;
                Caption = 'Requests to Group';
                Image = List;
                RunObject = page "GNC Requests to Group Board";
                ToolTip = 'Group the approved requests into sales orders.';
            }
        }
    }

    var
        SalespersonText: Text;
        SalespersonStyle: Text;
        NoPINTxt: Label '%1 · no PIN', Comment = '%1 = salesperson code';

    trigger OnAfterGetRecord()
    var
        GNCSalespersonPINMgt: Codeunit "GNC Salesperson PIN Mgt.";
    begin
        if GNCSalespersonPINMgt.IsSalespersonConfirmed(Rec) then begin
            SalespersonText := Rec."GNC PIN Salesperson Code";
            SalespersonStyle := 'Standard';
        end else begin
            SalespersonText := StrSubstNo(NoPINTxt, Rec."Salesperson Code");
            SalespersonStyle := 'Ambiguous';
        end;
    end;
}
