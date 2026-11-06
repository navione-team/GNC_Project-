permissionset 50290 "NAV GNC Reports"
{
    Assignable = true;
    Caption = 'GNC Purchase and Stock Reports';

    Permissions =
        codeunit "NAV Report Helper" = X,
        report "NAV Landed Cost by Item" = X,
        report "NAV Non-Moving Stock" = X,
        report "NAV Damaged Stock" = X,
        report "NAV Reserved Stock" = X,
        report "NAV Near-Expiry Stock" = X,
        report "NAV Batch Recall" = X,
        report "NAV Stock by Batch Status" = X,
        report "NAV Expired Stock Destruction" = X,
        report "NAV Stock by Product Group" = X,
        report "NAV Open Packs" = X,
        report "NAV Stock Coverage" = X,
        report "NAV Inter-Store Transfers" = X,
        report "NAV Transit Folder Status" = X,
        report "NAV Landed Cost Variance" = X,
        report "NAV Vendor Performance" = X,
        report "NAV Overdue Purchase Orders" = X,
        report "NAV Purchase Price Trend" = X,
        report "NAV Purchase vs Sales by Group" = X;
}
