// Lot 7 – Liste des chauffeurs.
page 90073 "GNC Drivers"
{
    Caption = 'Drivers';
    PageType = List;
    SourceTable = "GNC Driver";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Drivers)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code of the driver.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the driver.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the phone number of the driver.';
                }
                field(Vehicle; Rec.Vehicle)
                {
                    ToolTip = 'Specifies the vehicle of the driver (for example the plate number).';
                }
                field("Vehicle Capacity"; Rec."Vehicle Capacity")
                {
                    ToolTip = 'Specifies how many units the vehicle can carry. Leave 0 if you do not want to check the load on the delivery round.';
                }
                field(Refrigerated; Rec.Refrigerated)
                {
                    ToolTip = 'Specifies that the vehicle is refrigerated and can carry cold chain items.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies that the driver can no longer be selected on orders.';
                }
            }
        }
    }
}
