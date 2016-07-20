CREATE TABLE [Purchasing].[PurchaseOrderLines]
(
[PurchaseOrderLineID] [int] NOT NULL CONSTRAINT [DF_Purchasing_PurchaseOrderLines_PurchaseOrderLineID] DEFAULT (NEXT VALUE FOR [Sequences].[PurchaseOrderLineID]),
[PurchaseOrderID] [int] NOT NULL,
[StockItemID] [int] NOT NULL,
[OrderedOuters] [int] NOT NULL,
[Description] [nvarchar] (100) NOT NULL,
[ReceivedOuters] [int] NOT NULL,
[PackageTypeID] [int] NOT NULL,
[ExpectedUnitPricePerOuter] [decimal] (18, 2) NULL,
[LastReceiptDate] [date] NULL,
[IsOrderLineFinalized] [bit] NOT NULL,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Purchasing_PurchaseOrderLines_LastEditedWhen] DEFAULT (sysdatetime())
)
GO
ALTER TABLE [Purchasing].[PurchaseOrderLines] ADD CONSTRAINT [PK_Purchasing_PurchaseOrderLines] PRIMARY KEY CLUSTERED  ([PurchaseOrderLineID])
GO
CREATE NONCLUSTERED INDEX [IX_Purchasing_PurchaseOrderLines_Perf_20160301_4] ON [Purchasing].[PurchaseOrderLines] ([IsOrderLineFinalized], [StockItemID]) INCLUDE ([OrderedOuters], [ReceivedOuters])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_PurchaseOrderLines_PackageTypeID] ON [Purchasing].[PurchaseOrderLines] ([PackageTypeID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_PurchaseOrderLines_PurchaseOrderID] ON [Purchasing].[PurchaseOrderLines] ([PurchaseOrderID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_PurchaseOrderLines_StockItemID] ON [Purchasing].[PurchaseOrderLines] ([StockItemID])
GO
ALTER TABLE [Purchasing].[PurchaseOrderLines] ADD CONSTRAINT [FK_Purchasing_PurchaseOrderLines_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Purchasing].[PurchaseOrderLines] ADD CONSTRAINT [FK_Purchasing_PurchaseOrderLines_PackageTypeID_Warehouse_PackageTypes] FOREIGN KEY ([PackageTypeID]) REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID])
GO
ALTER TABLE [Purchasing].[PurchaseOrderLines] ADD CONSTRAINT [FK_Purchasing_PurchaseOrderLines_PurchaseOrderID_Purchasing_PurchaseOrders] FOREIGN KEY ([PurchaseOrderID]) REFERENCES [Purchasing].[PurchaseOrders] ([PurchaseOrderID])
GO
ALTER TABLE [Purchasing].[PurchaseOrderLines] ADD CONSTRAINT [FK_Purchasing_PurchaseOrderLines_StockItemID_Warehouse_StockItems] FOREIGN KEY ([StockItemID]) REFERENCES [Warehouse].[StockItems] ([StockItemID])
GO
EXEC sp_addextendedproperty N'Description', N'Detail lines from supplier purchase orders', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Description of the item to be supplied (Often the stock item name but could be supplier description)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'Description', 'The unit price that we expect to be charged', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'COLUMN', N'ExpectedUnitPricePerOuter'
GO
EXEC sp_addextendedproperty N'Description', 'Is this purchase order line now considered finalized? (Receipted quantities and weights are often not precise)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'COLUMN', N'IsOrderLineFinalized'
GO
EXEC sp_addextendedproperty N'Description', 'The last date on which this stock item was received for this purchase order', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'COLUMN', N'LastReceiptDate'
GO
EXEC sp_addextendedproperty N'Description', 'Quantity of the stock item that is ordered', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'COLUMN', N'OrderedOuters'
GO
EXEC sp_addextendedproperty N'Description', 'Type of package received', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'COLUMN', N'PackageTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Purchase order that this line is associated with', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'COLUMN', N'PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a line on a purchase order within the database', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'COLUMN', N'PurchaseOrderLineID'
GO
EXEC sp_addextendedproperty N'Description', 'Total quantity of the stock item that has been received so far', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'COLUMN', N'ReceivedOuters'
GO
EXEC sp_addextendedproperty N'Description', 'Stock item for this purchase order line', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'COLUMN', N'StockItemID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'INDEX', N'FK_Purchasing_PurchaseOrderLines_PackageTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'INDEX', N'FK_Purchasing_PurchaseOrderLines_PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'INDEX', N'FK_Purchasing_PurchaseOrderLines_StockItemID'
GO
EXEC sp_addextendedproperty N'Description', 'Improves performance of order picking and invoicing', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrderLines', 'INDEX', N'IX_Purchasing_PurchaseOrderLines_Perf_20160301_4'
GO
