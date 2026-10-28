// Petite fenêtre (OK / Annuler) ouverte par l'action "Close as Failed" du devis :
// l'utilisateur choisit le motif (obligatoire) et peut ajouter un commentaire.
page 90013 "GNC Close Quote"
{
    Caption = 'Close Quote as Failed';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Failed Sale';
                InstructionalText = 'The quote will be archived with this reason and removed from the list of open quotes. You can restore it later from Sales Quote Archives.';

                field(QuoteNo; QuoteNo)
                {
                    ApplicationArea = All;
                    Caption = 'Quote No.';
                    Editable = false;
                    ToolTip = 'Specifies the quote that will be closed.';
                }
                field(ReasonCode; ReasonCode)
                {
                    ApplicationArea = All;
                    Caption = 'Failed Reason Code';
                    TableRelation = "GNC Failed Sale Reason";
                    ShowMandatory = true;
                    ToolTip = 'Specifies why the sale failed. A reason is required.';
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comment';
                    MultiLine = true;
                    ToolTip = 'Specifies an optional comment about the failed sale.';
                }
            }
        }
    }

    var
        QuoteNo: Code[20];
        ReasonCode: Code[10];
        Comment: Text[250];
        ReasonMandatoryMsg: Label 'You must select a failed reason code to close the quote.';

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        // Motif obligatoire seulement si l'utilisateur clique sur OK (Annuler ferme sans contrôle)
        if (CloseAction = Action::OK) and (ReasonCode = '') then begin
            Message(ReasonMandatoryMsg);
            exit(false);
        end;
        exit(true);
    end;

    procedure SetQuoteNo(NewQuoteNo: Code[20])
    begin
        QuoteNo := NewQuoteNo;
    end;

    procedure GetReasonCode(): Code[10]
    begin
        exit(ReasonCode);
    end;

    procedure GetComment(): Text[250]
    begin
        exit(Comment);
    end;
}
