report 50000 "NAV Transit Folder"
{
    Caption = 'Transit Folder';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/RDL/TransitFolder.rdl';
    ApplicationArea = All;

    Permissions = tabledata "NAV Transit Folder" = RM,
                  tabledata "NAV Transit Folder Line" = RM,
                  tabledata "NAV Transit Folder Item Line" = RIMD;

    dataset
    {
        dataitem(TransitFolder; "NAV Transit Folder")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Vendor No.", Status;

            // Company
            column(Company_Name; CompanyInfo.Name) { }
            column(Company_Address; CompanyAddressText) { }
            column(Company_Picture; CompanyInfo.Picture) { }

            // Folder header
            column(Folder_No; "No.") { }
            column(Folder_Description; Description) { }
            column(Folder_VendorNo; "Vendor No.") { }
            column(Folder_VendorName; "Vendor Name") { }
            column(Folder_CurrencyCode; CurrencyCodeText) { }
            column(Folder_DocumentDate; Format("Document Date")) { }
            column(Folder_Status; Format(Status)) { }
            column(Folder_NoOfOrders; "No. of Orders") { }
            column(Folder_BaseAmount; "Base Amount (LCY)") { }
            column(Folder_TotalCharges; "Total Charges (LCY)") { }
            column(Folder_ShipmentMethod; "Shipment Method Code") { }
            column(Folder_TransportMethod; "Transport Method") { }
            column(Folder_ForwardingAgentNo; "Forwarding Agent No.") { }
            column(Folder_PortOfLoading; "Port of Loading") { }
            column(Folder_PortOfDischarge; "Port of Discharge") { }
            column(Folder_BillOfLadingNo; "Bill of Lading No.") { }
            column(Folder_ContainerNo; "Container No.") { }
            column(Folder_DepartureDate; Format("Departure Date")) { }
            column(Folder_ExpectedArrivalDate; Format("Expected Arrival Date")) { }
            column(Folder_ActualArrivalDate; Format("Actual Arrival Date")) { }
            column(Folder_CustomsDeclNo; "Customs Declaration No.") { }
            column(Folder_CustomsDeclDate; Format("Customs Declaration Date")) { }
            column(Folder_CustomsRegime; "Customs Regime") { }
            column(Folder_ShowCharges; ShowChargesInt) { }

            // Item details of the folder orders (and receipts of completed orders)
            dataitem(ItemLine; "NAV Transit Folder Item Line")
            {
                DataItemLink = "Folder No." = field("No.");
                DataItemTableView = sorting("Folder No.", "Line No.");

                column(Item_Source; Format(Source)) { }
                column(Item_DocumentNo; "Document No.") { }
                column(Item_No; "No.") { }
                column(Item_VariantCode; "Variant Code") { }
                column(Item_Description; Description) { }
                column(Item_Quantity; Quantity) { }
                column(Item_UoM; "Unit of Measure Code") { }
                column(Item_UnitCost; "Unit Cost (LCY)") { }
                column(Item_LineAmount; "Line Amount (LCY)") { }
                column(Item_AllocPct; "Allocation %") { }
                column(Item_Charges; "Charges Amount (LCY)") { }
                column(Item_UnitCharges; "Unit Charges (LCY)") { }
                column(Item_LandedUnitCost; "Landed Unit Cost (LCY)") { }
                column(Item_LandedAmount; "Landed Amount (LCY)") { }
                column(Item_Coefficient; "Landed Cost Coefficient") { }
            }

            // Landed charges of the folder
            dataitem(ChargeLine; "NAV Transit Folder Line")
            {
                DataItemLink = "Folder No." = field("No.");
                DataItemTableView = sorting("Folder No.", "Line No.");

                column(Charge_ItemChargeNo; "Item Charge No.") { }
                column(Charge_Description; Description) { }
                column(Charge_CalcType; Format("Calculation Type")) { }
                column(Charge_Percent; Percent) { }
                column(Charge_Amount; Amount) { }
                column(Charge_VendorNo; "Vendor No.") { }
                column(Charge_VendorName; "Vendor Name") { }
                column(Charge_OrderNo; "Charge Order No.") { }

                trigger OnPreDataItem()
                begin
                    if not ShowCharges then
                        CurrReport.Break();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                // Refresh the item lines and the landed cost allocation before printing
                if RefreshSimulation then
                    TransitFolderMgt.SimulateLandedCost(TransitFolder);

                CalcFields("Total Charges (LCY)", "No. of Orders");

                if "Currency Code" = '' then
                    CurrencyCodeText := GLSetup."LCY Code"
                else
                    CurrencyCodeText := "Currency Code";
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(RefreshSimulationField; RefreshSimulation)
                    {
                        ApplicationArea = All;
                        Caption = 'Refresh Landed Cost Simulation';
                        ToolTip = 'Specifies that the item lines and the landed cost allocation are recalculated before the report is printed.';
                    }
                    field(ShowChargesField; ShowCharges)
                    {
                        ApplicationArea = All;
                        Caption = 'Show Landed Charges';
                        ToolTip = 'Specifies that the list of landed charges of the folder is printed after the item details.';
                    }
                }
            }
        }
    }


    trigger OnInitReport()
    begin
        RefreshSimulation := true;
        ShowCharges := true;
    end;

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
        GLSetup.Get();
        CompanyAddressText := BuildCompanyAddress();
        if ShowCharges then
            ShowChargesInt := 1
        else
            ShowChargesInt := 0;
    end;

    local procedure BuildCompanyAddress(): Text
    var
        AddressText: Text;
    begin
        AddressText := CompanyInfo.Address;
        AppendText(AddressText, CompanyInfo."Address 2", ', ');
        AppendText(AddressText, DelChr(CompanyInfo."Post Code" + ' ' + CompanyInfo.City, '<>', ' '), ', ');
        AppendText(AddressText, CompanyInfo."Country/Region Code", ', ');
        exit(AddressText);
    end;

    local procedure AppendText(var Target: Text; Value: Text; Separator: Text)
    begin
        if Value = '' then
            exit;
        if Target <> '' then
            Target += Separator;
        Target += Value;
    end;

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        TransitFolderMgt: Codeunit "NAV Transit Folder Mgt.";
        CompanyAddressText: Text;
        CurrencyCodeText: Code[10];
        RefreshSimulation: Boolean;
        ShowCharges: Boolean;
        ShowChargesInt: Integer;
}
