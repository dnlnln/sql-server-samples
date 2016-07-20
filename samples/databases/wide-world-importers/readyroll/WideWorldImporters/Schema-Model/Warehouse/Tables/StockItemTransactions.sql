CREATE TABLE [Warehouse].[StockItemTransactions]
(
[StockItemTransactionID] [int] NOT NULL CONSTRAINT [DF_Warehouse_StockItemTransactions_StockItemTransactionID] DEFAULT (NEXT VALUE FOR [Sequences].[TransactionID]),
[StockItemID] [int] NOT NULL,
[TransactionTypeID] [int] NOT NULL,
[CustomerID] [int] NULL,
[InvoiceID] [int] NULL,
[SupplierID] [int] NULL,
[PurchaseOrderID] [int] NULL,
[TransactionOccurredWhen] [datetime2] NOT NULL,
[Quantity] [decimal] (18, 3) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Warehouse_StockItemTransactions_LastEditedWhen] DEFAULT (sysdatetime())
)
CREATE CLUSTERED COLUMNSTORE INDEX [CCX_Warehouse_StockItemTransactions] ON [Warehouse].[StockItemTransactions]

ALTER TABLE [Warehouse].[StockItemTransactions] ADD CONSTRAINT [PK_Warehouse_StockItemTransactions] PRIMARY KEY NONCLUSTERED  ([StockItemTransactionID])

GO
CREATE NONCLUSTERED INDEX [FK_Warehouse_StockItemTransactions_CustomerID] ON [Warehouse].[StockItemTransactions] ([CustomerID])
GO
CREATE NONCLUSTERED INDEX [FK_Warehouse_StockItemTransactions_InvoiceID] ON [Warehouse].[StockItemTransactions] ([InvoiceID])
GO
CREATE NONCLUSTERED INDEX [FK_Warehouse_StockItemTransactions_PurchaseOrderID] ON [Warehouse].[StockItemTransactions] ([PurchaseOrderID])
GO
CREATE NONCLUSTERED INDEX [FK_Warehouse_StockItemTransactions_StockItemID] ON [Warehouse].[StockItemTransactions] ([StockItemID])
GO
CREATE NONCLUSTERED INDEX [FK_Warehouse_StockItemTransactions_SupplierID] ON [Warehouse].[StockItemTransactions] ([SupplierID])
GO
CREATE NONCLUSTERED INDEX [FK_Warehouse_StockItemTransactions_TransactionTypeID] ON [Warehouse].[StockItemTransactions] ([TransactionTypeID])
GO
ALTER TABLE [Warehouse].[StockItemTransactions] ADD CONSTRAINT [FK_Warehouse_StockItemTransactions_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Warehouse].[StockItemTransactions] ADD CONSTRAINT [FK_Warehouse_StockItemTransactions_CustomerID_Sales_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
ALTER TABLE [Warehouse].[StockItemTransactions] ADD CONSTRAINT [FK_Warehouse_StockItemTransactions_InvoiceID_Sales_Invoices] FOREIGN KEY ([InvoiceID]) REFERENCES [Sales].[Invoices] ([InvoiceID])
GO
ALTER TABLE [Warehouse].[StockItemTransactions] ADD CONSTRAINT [FK_Warehouse_StockItemTransactions_PurchaseOrderID_Purchasing_PurchaseOrders] FOREIGN KEY ([PurchaseOrderID]) REFERENCES [Purchasing].[PurchaseOrders] ([PurchaseOrderID])
GO
ALTER TABLE [Warehouse].[StockItemTransactions] ADD CONSTRAINT [FK_Warehouse_StockItemTransactions_StockItemID_Warehouse_StockItems] FOREIGN KEY ([StockItemID]) REFERENCES [Warehouse].[StockItems] ([StockItemID])
GO
ALTER TABLE [Warehouse].[StockItemTransactions] ADD CONSTRAINT [FK_Warehouse_StockItemTransactions_SupplierID_Purchasing_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [Purchasing].[Suppliers] ([SupplierID])
GO
ALTER TABLE [Warehouse].[StockItemTransactions] ADD CONSTRAINT [FK_Warehouse_StockItemTransactions_TransactionTypeID_Application_TransactionTypes] FOREIGN KEY ([TransactionTypeID]) REFERENCES [Application].[TransactionTypes] ([TransactionTypeID])
GO
EXEC sp_addextendedproperty N'Description', N'Transactions covering all movements of all stock items', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Customer for this transaction (if applicable)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'COLUMN', N'CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'ID of an invoice (for transactions associated with an invoice)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'COLUMN', N'InvoiceID'
GO
EXEC sp_addextendedproperty N'Description', 'ID of an purchase order (for transactions associated with a purchase order)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'COLUMN', N'PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Quantity of stock movement (positive is incoming stock, negative is outgoing)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'COLUMN', N'Quantity'
GO
EXEC sp_addextendedproperty N'Description', 'StockItem for this transaction', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'COLUMN', N'StockItemID'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used to refer to a stock item transaction within the database', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'COLUMN', N'StockItemTransactionID'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier for this stock transaction (if applicable)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'COLUMN', N'SupplierID'
GO
EXEC sp_addextendedproperty N'Description', 'Date and time when the transaction occurred', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'COLUMN', N'TransactionOccurredWhen'
GO
EXEC sp_addextendedproperty N'Description', 'Type of transaction', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'COLUMN', N'TransactionTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'INDEX', N'FK_Warehouse_StockItemTransactions_CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'INDEX', N'FK_Warehouse_StockItemTransactions_InvoiceID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'INDEX', N'FK_Warehouse_StockItemTransactions_PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'INDEX', N'FK_Warehouse_StockItemTransactions_StockItemID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'INDEX', N'FK_Warehouse_StockItemTransactions_SupplierID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemTransactions', 'INDEX', N'FK_Warehouse_StockItemTransactions_TransactionTypeID'
GO
