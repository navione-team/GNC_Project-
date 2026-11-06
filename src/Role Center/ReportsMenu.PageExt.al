// Purchase and Stock reports (standard + specific) added to the navigation menu
// of the Business Manager Role Center. To add the same menu to another role
// center, copy this extension and change "extends" (e.g. "Purchasing Agent Role
// Center", "Order Processor Role Center"), with a new object ID and name.
//
// Reports are referenced by ID (stable across versions and localizations).
pageextension 50280 "NAV Reports Menu" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group(NAVPurchaseReports)
            {
                Caption = 'Purchase Reports';

                action(NAVPurchaseOrder)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Order';
                    RunObject = report 1322; // Standard Purchase - Order
                    ToolTip = 'Prints purchase orders.';
                }
                action(NAVPurchaseReceipt)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Receipt';
                    RunObject = report 408; // Purchase - Receipt
                    ToolTip = 'Prints posted purchase receipts.';
                }
                action(NAVPurchaseByProduct)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase by Product';
                    RunObject = report 714; // Inventory - Vendor Purchases
                    ToolTip = 'Shows the purchases of each item, by vendor, for a period.';
                }
                action(NAVOpenPurchaseByProduct)
                {
                    ApplicationArea = All;
                    Caption = 'Open Purchase Orders by Product';
                    RunObject = report 709; // Inventory Purchase Orders
                    ToolTip = 'Shows the outstanding purchase order quantities of each item.';
                }
                action(NAVPurchaseByVendor)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase by Vendor';
                    RunObject = report 313; // Vendor/Item Purchases
                    ToolTip = 'Shows, for each vendor, the items purchased with quantities and amounts.';
                }
                action(NAVPurchaseStatistics)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Statistics by Vendor';
                    RunObject = report 312; // Purchase Statistics
                    ToolTip = 'Shows purchase amounts, discounts and payments by vendor and period.';
                }
                action(NAVLandedCostByItem)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase by Landed Cost';
                    RunObject = report 50201; // NAV Landed Cost by Item
                    ToolTip = 'Shows, per item, the purchase cost, the landed charges and the landed cost of the transit folders.';
                }
                action(NAVTransitFolder)
                {
                    ApplicationArea = All;
                    Caption = 'Transit Folder';
                    RunObject = report "NAV Transit Folder"; // NAV Transit Folder
                    ToolTip = 'Prints a transit folder with the item details and the landed cost per item.';
                }
                action(NAVItemChargesSpec)
                {
                    ApplicationArea = All;
                    Caption = 'Item Charges - Specification';
                    RunObject = report 5806; // Item Charges - Specification
                    ToolTip = 'Shows the item charges posted per item and document.';
                }
                action(NAVTransitFolderStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Transit Folder Status';
                    RunObject = report 50213; // NAV Transit Folder Status
                    ToolTip = 'Shows the import folders with ETA, delay, estimated, accrued and invoiced charges.';
                }
                action(NAVLandedCostVariance)
                {
                    ApplicationArea = All;
                    Caption = 'Landed Cost Variance';
                    RunObject = report 50214; // NAV Landed Cost Variance
                    ToolTip = 'Compares, per folder and item charge, the estimated, accrued and actual charges.';
                }
                action(NAVVendorPerformance)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Performance';
                    RunObject = report 50215; // NAV Vendor Performance
                    ToolTip = 'Shows on-time rate, delay, lead time, fill rate and damaged quantities per vendor.';
                }
                action(NAVOverduePurchaseOrders)
                {
                    ApplicationArea = All;
                    Caption = 'Overdue Purchase Orders';
                    RunObject = report 50216; // NAV Overdue Purchase Orders
                    ToolTip = 'Lists the purchase order lines not received after their expected receipt date.';
                }
                action(NAVPurchasePriceTrend)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Price Trend';
                    RunObject = report 50217; // NAV Purchase Price Trend
                    ToolTip = 'Shows the evolution of the purchase cost per item and vendor.';
                }
                action(NAVPurchaseVsSales)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase vs Sales by Product Group';
                    RunObject = report 50218; // NAV Purchase vs Sales by Group
                    ToolTip = 'Compares purchased and sold quantities and amounts by product group and item family.';
                }
            }
            group(NAVStockReports)
            {
                Caption = 'Stock Reports';

                action(NAVStockMovement)
                {
                    ApplicationArea = All;
                    Caption = 'Stock Movement (Quantity and Value)';
                    RunObject = report 1001; // Inventory Valuation
                    ToolTip = 'Shows, for a period, the opening stock, the increases, the decreases and the closing stock in quantity and value.';
                }
                action(NAVStockTransactions)
                {
                    ApplicationArea = All;
                    Caption = 'Stock Movement Details';
                    RunObject = report 704; // Inventory - Transaction Detail
                    ToolTip = 'Lists every stock movement per item with the running balance.';
                }
                action(NAVStockValue)
                {
                    ApplicationArea = All;
                    Caption = 'Stock Value';
                    RunObject = report 1001; // Inventory Valuation
                    ToolTip = 'Shows the inventory value at a date.';
                }
                action(NAVStockQuantity)
                {
                    ApplicationArea = All;
                    Caption = 'Stock Quantity';
                    RunObject = report 705; // Inventory Availability
                    ToolTip = 'Shows the inventory, the expected receipts and issues, and the available quantity per item.';
                }
                action(NAVStockByBin)
                {
                    ApplicationArea = All;
                    Caption = 'Stock by Bin';
                    RunObject = report 7319; // Warehouse Bin List
                    ToolTip = 'Shows the stock per location and bin.';
                }
                action(NAVStockAging)
                {
                    ApplicationArea = All;
                    Caption = 'Stock Aging';
                    RunObject = report 5808; // Item Age Composition - Value
                    ToolTip = 'Shows the inventory value by age bracket.';
                }
                action(NAVNonMovingStock)
                {
                    ApplicationArea = All;
                    Caption = 'Non-Moving Stock';
                    RunObject = report 50202; // NAV Non-Moving Stock
                    ToolTip = 'Shows the stock without any receipt or issue for a number of days.';
                }
                action(NAVSoldStock)
                {
                    ApplicationArea = All;
                    Caption = 'Sold Stock';
                    RunObject = report 713; // Inventory - Customer Sales
                    ToolTip = 'Shows the quantities and amounts sold per item and customer.';
                }
                action(NAVTopItems)
                {
                    ApplicationArea = All;
                    Caption = 'Top Selling Items';
                    RunObject = report 711; // Inventory - Top 10 List
                    ToolTip = 'Shows the items with the highest sales or inventory.';
                }
                action(NAVDamagedStock)
                {
                    ApplicationArea = All;
                    Caption = 'Damaged Stock';
                    RunObject = report 50203; // NAV Damaged Stock
                    ToolTip = 'Shows the stock in damaged bins and the damage transfer history.';
                }
                action(NAVReservedStock)
                {
                    ApplicationArea = All;
                    Caption = 'Reserved Stock';
                    RunObject = report 50204; // NAV Reserved Stock
                    ToolTip = 'Shows the quantities reserved for sales orders with their expiry date.';
                }
                action(NAVStockByProductGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Stock by Product Group';
                    RunObject = report 50209; // NAV Stock by Product Group
                    ToolTip = 'Shows the stock in tablets, packs and value by product group and item family.';
                }
                action(NAVOpenPacks)
                {
                    ApplicationArea = All;
                    Caption = 'Open Packs (Loose Tablets)';
                    RunObject = report 50210; // NAV Open Packs
                    ToolTip = 'Lists the items with opened packs (loose tablets) by location.';
                }
                action(NAVStockCoverage)
                {
                    ApplicationArea = All;
                    Caption = 'Stock Coverage';
                    RunObject = report 50211; // NAV Stock Coverage
                    ToolTip = 'Shows the days of stock per item and location, with alerts.';
                }
                action(NAVInterStoreTransfers)
                {
                    ApplicationArea = All;
                    Caption = 'Inter-Store Transfers';
                    RunObject = report 50212; // NAV Inter-Store Transfers
                    ToolTip = 'Lists the transfers between stores and the quantities in transit.';
                }
                action(NAVABCAnalysis)
                {
                    ApplicationArea = All;
                    Caption = 'ABC Analysis';
                    RunObject = report 723; // Item - ABC Analysis
                    ToolTip = 'Classifies the items into A, B and C by value.';
                }
            }
            group(NAVBatchReports)
            {
                Caption = 'Batch & Expiry Reports';

                action(NAVNearExpiry)
                {
                    ApplicationArea = All;
                    Caption = 'Near-Expiry Stock';
                    RunObject = report 50205; // NAV Near-Expiry Stock
                    ToolTip = 'Lists the batches expiring within N days and the expired batches, in tablets, packs and value.';
                }
                action(NAVBatchRecall)
                {
                    ApplicationArea = All;
                    Caption = 'Batch Recall / Traceability';
                    RunObject = report 50206; // NAV Batch Recall
                    ToolTip = 'Shows, for one batch, its receipts, its current stock and every customer delivered.';
                }
                action(NAVBatchStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Stock by Batch Status';
                    RunObject = report 50207; // NAV Stock by Batch Status
                    ToolTip = 'Shows the stock of each batch by status: Available, Quarantine, Blocked, Expired.';
                }
                action(NAVExpiredDestruction)
                {
                    ApplicationArea = All;
                    Caption = 'Expired Stock for Destruction';
                    RunObject = report 50208; // NAV Expired Stock Destruction
                    ToolTip = 'Lists the expired stock to destroy, with value and signature block.';
                }
                action(NAVExpiringStock2)
                {
                    ApplicationArea = All;
                    Caption = 'Stock by Expiry Date';
                    RunObject = report 5809; // Item Expiration - Quantity
                    ToolTip = 'Shows the stock of batches by expiry period.';
                }
            }
        }
    }
}
