// Fiche devis (Request Collection) :
// - action "Close as Failed" (Clôturer) à côté de "Make Order" ;
// - champ "Salesperson PIN" : le commercial saisit son PIN, le Salesperson Code se remplit.
//   Le Salesperson Code n'est plus modifiable à la main sur le devis.
pageextension 90016 "GNC Sales Quote" extends "Sales Quote"
{
    layout
    {
        modify("Salesperson Code")
        {
            Editable = false;
        }
        addafter("Salesperson Code")
        {
            // Champ de saisie non enregistré (variable de page) : le PIN n'est jamais stocké sur le devis
            field(GNCSalespersonPIN; SalespersonPIN)
            {
                ApplicationArea = All;
                Caption = 'Salesperson PIN';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the personal PIN of the salesperson. Entering it fills in the salesperson code of the quote.';

                trigger OnValidate()
                var
                    GNCSalespersonPINMgt: Codeunit "GNC Salesperson PIN Mgt.";
                begin
                    GNCSalespersonPINMgt.ApplyPIN(Rec, SalespersonPIN);
                    SalespersonPIN := '';
                    CurrPage.Update(true);
                end;
            }
            // Indique si le commercial actuel a bien été confirmé par son PIN
            field(GNCSalespersonConfirmed; SalespersonConfirmed)
            {
                ApplicationArea = All;
                Caption = 'Salesperson Confirmed';
                Editable = false;
                ToolTip = 'Specifies whether the salesperson of the quote has been confirmed by their PIN. The quote cannot be sent for approval or converted to an order until it is confirmed.';
            }
            // Lot 7 : urgence de livraison indiquée par le commercial, recopiée sur la commande
            field("GNC Delivery Priority"; Rec."GNC Delivery Priority")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how urgent the delivery is for the customer: Normal, Urgent or Very Urgent. It is copied to the sales order and shown in the delivery plan.';
            }
        }
    }

    actions
    {
        addafter(MakeOrder)
        {
            action(GNCCloseAsFailed)
            {
                ApplicationArea = All;
                Caption = 'Close as Failed';
                Image = Cancel;
                ToolTip = 'Close the quote as a failed sale. You must select a reason. The quote is archived and removed from the list of open quotes.';

                trigger OnAction()
                var
                    GNCSalesQuoteMgt: Codeunit "GNC Sales Quote Mgt.";
                begin
                    // Si le devis a été clôturé, il n'existe plus : on ferme la fiche
                    if GNCSalesQuoteMgt.CloseQuoteAsFailed(Rec) then
                        CurrPage.Close();
                end;
            }
        }
        addafter(MakeOrder_Promoted)
        {
            actionref(GNCCloseAsFailed_Promoted; GNCCloseAsFailed)
            {
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        GNCSalespersonPINMgt: Codeunit "GNC Salesperson PIN Mgt.";
    begin
        SalespersonConfirmed := GNCSalespersonPINMgt.IsSalespersonConfirmed(Rec);
    end;

    // Mémorise le commercial du PIN et le client pour filtrer les listes de clients et d'articles
    // (codeunits 90044 / 90043)
    trigger OnAfterGetCurrRecord()
    var
        GNCRequestContext: Codeunit "GNC Request Context";
    begin
        GNCRequestContext.SetContext(Rec."GNC PIN Salesperson Code", Rec."Sell-to Customer No.");
    end;

    // Fiche fermée : plus de filtre sur les listes ouvertes ailleurs
    trigger OnClosePage()
    var
        GNCRequestContext: Codeunit "GNC Request Context";
    begin
        GNCRequestContext.ClearContext();
    end;

    var
        SalespersonPIN: Text[20];
        SalespersonConfirmed: Boolean;
}
