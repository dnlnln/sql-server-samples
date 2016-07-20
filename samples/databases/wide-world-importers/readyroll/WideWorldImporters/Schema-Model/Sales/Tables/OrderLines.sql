CREATE TABLE [Sales].[OrderLines]
(
[OrderLineID] [int] NOT NULL CONSTRAINT [DF_Sales_OrderLines_OrderLineID] DEFAULT (NEXT VALUE FOR [Sequences].[OrderLineID]),
[OrderID] [int] NOT NULL,
[StockItemID] [int] NOT NULL,
[Description] [nvarchar] (100) NOT NULL,
[PackageTypeID] [int] NOT NULL,
[Quantity] [int] NOT NULL,
[UnitPrice] [decimal] (18, 2) NULL,
[TaxRate] [decimal] (18, 3) NOT NULL,
[PickedQuantity] [int] NOT NULL,
[PickingCompletedWhen] [datetime2] NULL,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Sales_OrderLines_LastEditedWhen] DEFAULT (sysdatetime())
)
CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCX_Sales_OrderLines] ON [Sales].[OrderLines] ([OrderID], [StockItemID], [Description], [Quantity], [UnitPrice], [PickedQuantity])

GO
ALTER TABLE [Sales].[OrderLines] ADD CONSTRAINT [PK_Sales_OrderLines] PRIMARY KEY CLUSTERED  ([OrderLineID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_OrderLines_OrderID] ON [Sales].[OrderLines] ([OrderID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_OrderLines_PackageTypeID] ON [Sales].[OrderLines] ([PackageTypeID])
GO
CREATE NONCLUSTERED INDEX [IX_Sales_OrderLines_Perf_20160301_01] ON [Sales].[OrderLines] ([PickingCompletedWhen], [OrderID], [OrderLineID]) INCLUDE ([Quantity], [StockItemID])
GO
CREATE NONCLUSTERED INDEX [IX_Sales_OrderLines_AllocatedStockItems] ON [Sales].[OrderLines] ([StockItemID]) INCLUDE ([PickedQuantity])
GO
CREATE NONCLUSTERED INDEX [IX_Sales_OrderLines_Perf_20160301_02] ON [Sales].[OrderLines] ([StockItemID], [PickingCompletedWhen]) INCLUDE ([OrderID], [PickedQuantity])
GO
ALTER TABLE [Sales].[OrderLines] ADD CONSTRAINT [FK_Sales_OrderLines_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[OrderLines] ADD CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders] FOREIGN KEY ([OrderID]) REFERENCES [Sales].[Orders] ([OrderID])
GO
ALTER TABLE [Sales].[OrderLines] ADD CONSTRAINT [FK_Sales_OrderLines_PackageTypeID_Warehouse_PackageTypes] FOREIGN KEY ([PackageTypeID]) REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID])
GO
ALTER TABLE [Sales].[OrderLines] ADD CONSTRAINT [FK_Sales_OrderLines_StockItemID_Warehouse_StockItems] FOREIGN KEY ([StockItemID]) REFERENCES [Warehouse].[StockItems] ([StockItemID])
GO
EXEC sp_addextendedproperty N'Description', N'Detail lines from customer orders', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Description of the item supplied (Usually the stock item name but can be overridden)', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'Description', 'Order that this line is associated with', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'COLUMN', N'OrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a line on an Order within the database', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'COLUMN', N'OrderLineID'
GO
EXEC sp_addextendedproperty N'Description', 'Type of package to be supplied', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'COLUMN', N'PackageTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Quantity picked from stock', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'COLUMN', N'PickedQuantity'
GO
EXEC sp_addextendedproperty N'Description', 'When was picking of this line completed?', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'COLUMN', N'PickingCompletedWhen'
GO
EXEC sp_addextendedproperty N'Description', 'Quantity to be supplied', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'COLUMN', N'Quantity'
GO
EXEC sp_addextendedproperty N'Description', 'Stock item for this order line (FK not indexed as separate index exists)', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'COLUMN', N'StockItemID'
GO
EXEC sp_addextendedproperty N'Description', 'Tax rate to be applied', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'COLUMN', N'TaxRate'
GO
EXEC sp_addextendedproperty N'Description', 'Unit price to be charged', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'COLUMN', N'UnitPrice'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'INDEX', N'FK_Sales_OrderLines_OrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'INDEX', N'FK_Sales_OrderLines_PackageTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Allows quick summation of stock item quantites already allocated to uninvoiced orders', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'INDEX', N'IX_Sales_OrderLines_AllocatedStockItems'
GO
EXEC sp_addextendedproperty N'Description', 'Improves performance of order picking and invoicing', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'INDEX', N'IX_Sales_OrderLines_Perf_20160301_01'
GO
EXEC sp_addextendedproperty N'Description', 'Improves performance of order picking and invoicing', 'SCHEMA', N'Sales', 'TABLE', N'OrderLines', 'INDEX', N'IX_Sales_OrderLines_Perf_20160301_02'
GO
