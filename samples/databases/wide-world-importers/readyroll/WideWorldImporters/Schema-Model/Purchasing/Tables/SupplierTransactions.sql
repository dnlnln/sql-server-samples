CREATE TABLE [Purchasing].[SupplierTransactions]
(
[SupplierTransactionID] [int] NOT NULL CONSTRAINT [DF_Purchasing_SupplierTransactions_SupplierTransactionID] DEFAULT (NEXT VALUE FOR [Sequences].[TransactionID]),
[SupplierID] [int] NOT NULL,
[TransactionTypeID] [int] NOT NULL,
[PurchaseOrderID] [int] NULL,
[PaymentMethodID] [int] NULL,
[SupplierInvoiceNumber] [nvarchar] (20) NULL,
[TransactionDate] [date] NOT NULL,
[AmountExcludingTax] [decimal] (18, 2) NOT NULL,
[TaxAmount] [decimal] (18, 2) NOT NULL,
[TransactionAmount] [decimal] (18, 2) NOT NULL,
[OutstandingBalance] [decimal] (18, 2) NOT NULL,
[FinalizationDate] [date] NULL,
[IsFinalized] AS (case  when [FinalizationDate] IS NULL then CONVERT([bit],(0),(0)) else CONVERT([bit],(1),(0)) end) PERSISTED,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Purchasing_SupplierTransactions_LastEditedWhen] DEFAULT (sysdatetime())
)
GO
ALTER TABLE [Purchasing].[SupplierTransactions] ADD CONSTRAINT [PK_Purchasing_SupplierTransactions] PRIMARY KEY CLUSTERED  ([SupplierTransactionID])
GO
CREATE NONCLUSTERED INDEX [IX_Purchasing_SupplierTransactions_IsFinalized] ON [Purchasing].[SupplierTransactions] ([IsFinalized])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_SupplierTransactions_PaymentMethodID] ON [Purchasing].[SupplierTransactions] ([PaymentMethodID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_SupplierTransactions_PurchaseOrderID] ON [Purchasing].[SupplierTransactions] ([PurchaseOrderID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_SupplierTransactions_SupplierID] ON [Purchasing].[SupplierTransactions] ([SupplierID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_SupplierTransactions_TransactionTypeID] ON [Purchasing].[SupplierTransactions] ([TransactionTypeID])
GO
ALTER TABLE [Purchasing].[SupplierTransactions] ADD CONSTRAINT [FK_Purchasing_SupplierTransactions_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Purchasing].[SupplierTransactions] ADD CONSTRAINT [FK_Purchasing_SupplierTransactions_PaymentMethodID_Application_PaymentMethods] FOREIGN KEY ([PaymentMethodID]) REFERENCES [Application].[PaymentMethods] ([PaymentMethodID])
GO
ALTER TABLE [Purchasing].[SupplierTransactions] ADD CONSTRAINT [FK_Purchasing_SupplierTransactions_PurchaseOrderID_Purchasing_PurchaseOrders] FOREIGN KEY ([PurchaseOrderID]) REFERENCES [Purchasing].[PurchaseOrders] ([PurchaseOrderID])
GO
ALTER TABLE [Purchasing].[SupplierTransactions] ADD CONSTRAINT [FK_Purchasing_SupplierTransactions_SupplierID_Purchasing_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [Purchasing].[Suppliers] ([SupplierID])
GO
ALTER TABLE [Purchasing].[SupplierTransactions] ADD CONSTRAINT [FK_Purchasing_SupplierTransactions_TransactionTypeID_Application_TransactionTypes] FOREIGN KEY ([TransactionTypeID]) REFERENCES [Application].[TransactionTypes] ([TransactionTypeID])
GO
EXEC sp_addextendedproperty N'Description', N'All financial transactions that are supplier-related', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Transaction amount (excluding tax)', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'AmountExcludingTax'
GO
EXEC sp_addextendedproperty N'Description', 'Date that this transaction was finalized (if it has been)', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'FinalizationDate'
GO
EXEC sp_addextendedproperty N'Description', 'Is this transaction finalized (invoices, credits and payments have been matched)', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'IsFinalized'
GO
EXEC sp_addextendedproperty N'Description', 'Amount still outstanding for this transaction', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'OutstandingBalance'
GO
EXEC sp_addextendedproperty N'Description', 'ID of a payment method (for transactions involving payments)', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'PaymentMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'ID of an purchase order (for transactions associated with a purchase order)', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier for this transaction', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'SupplierID'
GO
EXEC sp_addextendedproperty N'Description', 'Invoice number for an invoice received from the supplier', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'SupplierInvoiceNumber'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used to refer to a supplier transaction within the database', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'SupplierTransactionID'
GO
EXEC sp_addextendedproperty N'Description', 'Tax amount calculated', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'TaxAmount'
GO
EXEC sp_addextendedproperty N'Description', 'Transaction amount (including tax)', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'TransactionAmount'
GO
EXEC sp_addextendedproperty N'Description', 'Date for the transaction', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'TransactionDate'
GO
EXEC sp_addextendedproperty N'Description', 'Type of transaction', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'COLUMN', N'TransactionTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'INDEX', N'FK_Purchasing_SupplierTransactions_PaymentMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'INDEX', N'FK_Purchasing_SupplierTransactions_PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'INDEX', N'FK_Purchasing_SupplierTransactions_SupplierID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'INDEX', N'FK_Purchasing_SupplierTransactions_TransactionTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Index used to quickly locate unfinalized transactions', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierTransactions', 'INDEX', N'IX_Purchasing_SupplierTransactions_IsFinalized'
GO
