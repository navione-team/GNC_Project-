// Lignes de la commande : affiche la demande d'origine et le commercial de chaque ligne.
// Le commercial n'est modifiable que sur une ligne ajoutée à la main (sans Request No.).
pageextension 90050 "GNC Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("GNC Request No."; Rec."GNC Request No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the request collection (sales quote) that this line comes from. Empty if the line was added manually.';
            }
            field("GNC Salesperson Code"; Rec."GNC Salesperson Code")
            {
                ApplicationArea = All;
                Editable = IsManualLine;
                ToolTip = 'Specifies the salesperson who collected the request for this line.';
            }
            // Lot 4 : 2 et plus = ligne cumulée depuis plusieurs demandes ; cliquer ouvre le détail
            field("GNC Grouped Requests"; Rec."GNC Grouped Requests")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how many request lines this order line comes from. Choose the number to see the quantity of each request.';
            }
            // Lot 5 : ligne gratuite ajoutée par la règle Bonus Setup
            field("GNC Bonus Line"; Rec."GNC Bonus Line")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the line is a free bonus line (100% discount) added automatically from the bonus setup. It is attached to the ordered line.';
            }
        }
    }

    var
        IsManualLine: Boolean;

    trigger OnAfterGetRecord()
    begin
        IsManualLine := Rec."GNC Request No." = '';
    end;

    // Nouvelle ligne (encore vide) : modifiable
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsManualLine := true;
    end;
}
