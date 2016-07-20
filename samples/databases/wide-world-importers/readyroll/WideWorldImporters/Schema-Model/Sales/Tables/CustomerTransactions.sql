CREATE TABLE [Sales].[CustomerTransactions]
(
[CustomerTransactionID] [int] NOT NULL CONSTRAINT [DF_Sales_CustomerTransactions_CustomerTransactionID] DEFAULT (NEXT VALUE FOR [Sequences].[TransactionID]),
[CustomerID] [int] NOT NULL,
[TransactionTypeID] [int] NOT NULL,
[InvoiceID] [int] NULL,
[PaymentMethodID] [int] NULL,
[TransactionDate] [date] NOT NULL,
[AmountExcludingTax] [decimal] (18, 2) NOT NULL,
[TaxAmount] [decimal] (18, 2) NOT NULL,
[TransactionAmount] [decimal] (18, 2) NOT NULL,
[OutstandingBalance] [decimal] (18, 2) NOT NULL,
[FinalizationDate] [date] NULL,
[IsFinalized] AS (case  when [FinalizationDate] IS NULL then CONVERT([bit],(0),(0)) else CONVERT([bit],(1),(0)) end) PERSISTED,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Sales_CustomerTransactions_LastEditedWhen] DEFAULT (sysdatetime())
)
CREATE CLUSTERED INDEX [CX_Sales_CustomerTransactions] ON [Sales].[CustomerTransactions] ([TransactionDate])

ALTER TABLE [Sales].[CustomerTransactions] ADD CONSTRAINT [PK_Sales_CustomerTransactions] PRIMARY KEY NONCLUSTERED  ([CustomerTransactionID])

GO
CREATE NONCLUSTERED INDEX [FK_Sales_CustomerTransactions_CustomerID] ON [Sales].[CustomerTransactions] ([CustomerID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_CustomerTransactions_InvoiceID] ON [Sales].[CustomerTransactions] ([InvoiceID])
GO
CREATE NONCLUSTERED INDEX [IX_Sales_CustomerTransactions_IsFinalized] ON [Sales].[CustomerTransactions] ([IsFinalized])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_CustomerTransactions_PaymentMethodID] ON [Sales].[CustomerTransactions] ([PaymentMethodID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_CustomerTransactions_TransactionTypeID] ON [Sales].[CustomerTransactions] ([TransactionTypeID])
GO
ALTER TABLE [Sales].[CustomerTransactions] ADD CONSTRAINT [FK_Sales_CustomerTransactions_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[CustomerTransactions] ADD CONSTRAINT [FK_Sales_CustomerTransactions_CustomerID_Sales_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
ALTER TABLE [Sales].[CustomerTransactions] ADD CONSTRAINT [FK_Sales_CustomerTransactions_InvoiceID_Sales_Invoices] FOREIGN KEY ([InvoiceID]) REFERENCES [Sales].[Invoices] ([InvoiceID])
GO
ALTER TABLE [Sales].[CustomerTransactions] ADD CONSTRAINT [FK_Sales_CustomerTransactions_PaymentMethodID_Application_PaymentMethods] FOREIGN KEY ([PaymentMethodID]) REFERENCES [Application].[PaymentMethods] ([PaymentMethodID])
GO
ALTER TABLE [Sales].[CustomerTransactions] ADD CONSTRAINT [FK_Sales_CustomerTransactions_TransactionTypeID_Application_TransactionTypes] FOREIGN KEY ([TransactionTypeID]) REFERENCES [Application].[TransactionTypes] ([TransactionTypeID])
GO
EXEC sp_addextendedproperty N'Description', N'All financial transactions that are customer-related', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Transaction amount (excluding tax)', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'AmountExcludingTax'
GO
EXEC sp_addextendedproperty N'Description', 'Customer for this transaction', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used to refer to a customer transaction within the database', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'CustomerTransactionID'
GO
EXEC sp_addextendedproperty N'Description', 'Date that this transaction was finalized (if it has been)', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'FinalizationDate'
GO
EXEC sp_addextendedproperty N'Description', 'ID of an invoice (for transactions associated with an invoice)', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'InvoiceID'
GO
EXEC sp_addextendedproperty N'Description', 'Is this transaction finalized (invoices, credits and payments have been matched)', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'IsFinalized'
GO
EXEC sp_addextendedproperty N'Description', 'Amount still outstanding for this transaction', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'OutstandingBalance'
GO
EXEC sp_addextendedproperty N'Description', 'ID of a payment method (for transactions involving payments)', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'PaymentMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Tax amount calculated', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'TaxAmount'
GO
EXEC sp_addextendedproperty N'Description', 'Transaction amount (including tax)', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'TransactionAmount'
GO
EXEC sp_addextendedproperty N'Description', 'Date for the transaction', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'TransactionDate'
GO
EXEC sp_addextendedproperty N'Description', 'Type of transaction', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'COLUMN', N'TransactionTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'INDEX', N'FK_Sales_CustomerTransactions_CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'INDEX', N'FK_Sales_CustomerTransactions_InvoiceID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'INDEX', N'FK_Sales_CustomerTransactions_PaymentMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'INDEX', N'FK_Sales_CustomerTransactions_TransactionTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Allows quick location of unfinalized transactions', 'SCHEMA', N'Sales', 'TABLE', N'CustomerTransactions', 'INDEX', N'IX_Sales_CustomerTransactions_IsFinalized'
GO
