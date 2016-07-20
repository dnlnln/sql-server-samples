CREATE TABLE [Sales].[InvoiceLines]
(
[InvoiceLineID] [int] NOT NULL CONSTRAINT [DF_Sales_InvoiceLines_InvoiceLineID] DEFAULT (NEXT VALUE FOR [Sequences].[InvoiceLineID]),
[InvoiceID] [int] NOT NULL,
[StockItemID] [int] NOT NULL,
[Description] [nvarchar] (100) NOT NULL,
[PackageTypeID] [int] NOT NULL,
[Quantity] [int] NOT NULL,
[UnitPrice] [decimal] (18, 2) NULL,
[TaxRate] [decimal] (18, 3) NOT NULL,
[TaxAmount] [decimal] (18, 2) NOT NULL,
[LineProfit] [decimal] (18, 2) NOT NULL,
[ExtendedPrice] [decimal] (18, 2) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Sales_InvoiceLines_LastEditedWhen] DEFAULT (sysdatetime())
)
CREATE NONCLUSTERED COLUMNSTORE INDEX [NCCX_Sales_InvoiceLines] ON [Sales].[InvoiceLines] ([InvoiceID], [StockItemID], [Quantity], [UnitPrice], [LineProfit], [LastEditedWhen])

GO
ALTER TABLE [Sales].[InvoiceLines] ADD CONSTRAINT [PK_Sales_InvoiceLines] PRIMARY KEY CLUSTERED  ([InvoiceLineID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_InvoiceLines_InvoiceID] ON [Sales].[InvoiceLines] ([InvoiceID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_InvoiceLines_PackageTypeID] ON [Sales].[InvoiceLines] ([PackageTypeID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_InvoiceLines_StockItemID] ON [Sales].[InvoiceLines] ([StockItemID])
GO
ALTER TABLE [Sales].[InvoiceLines] ADD CONSTRAINT [FK_Sales_InvoiceLines_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[InvoiceLines] ADD CONSTRAINT [FK_Sales_InvoiceLines_InvoiceID_Sales_Invoices] FOREIGN KEY ([InvoiceID]) REFERENCES [Sales].[Invoices] ([InvoiceID])
GO
ALTER TABLE [Sales].[InvoiceLines] ADD CONSTRAINT [FK_Sales_InvoiceLines_PackageTypeID_Warehouse_PackageTypes] FOREIGN KEY ([PackageTypeID]) REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID])
GO
ALTER TABLE [Sales].[InvoiceLines] ADD CONSTRAINT [FK_Sales_InvoiceLines_StockItemID_Warehouse_StockItems] FOREIGN KEY ([StockItemID]) REFERENCES [Warehouse].[StockItems] ([StockItemID])
GO
EXEC sp_addextendedproperty N'Description', N'Detail lines from customer invoices', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Description of the item supplied (Usually the stock item name but can be overridden)', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'Description'
GO
EXEC sp_addextendedproperty N'Description', 'Extended line price charged', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'ExtendedPrice'
GO
EXEC sp_addextendedproperty N'Description', 'Invoice that this line is associated with', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'InvoiceID'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a line on an invoice within the database', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'InvoiceLineID'
GO
EXEC sp_addextendedproperty N'Description', 'Profit made on this line item at current cost price', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'LineProfit'
GO
EXEC sp_addextendedproperty N'Description', 'Type of package supplied', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'PackageTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Quantity supplied', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'Quantity'
GO
EXEC sp_addextendedproperty N'Description', 'Stock item for this invoice line', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'StockItemID'
GO
EXEC sp_addextendedproperty N'Description', 'Tax amount calculated', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'TaxAmount'
GO
EXEC sp_addextendedproperty N'Description', 'Tax rate to be applied', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'TaxRate'
GO
EXEC sp_addextendedproperty N'Description', 'Unit price charged', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'COLUMN', N'UnitPrice'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'INDEX', N'FK_Sales_InvoiceLines_InvoiceID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'INDEX', N'FK_Sales_InvoiceLines_PackageTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'InvoiceLines', 'INDEX', N'FK_Sales_InvoiceLines_StockItemID'
GO
