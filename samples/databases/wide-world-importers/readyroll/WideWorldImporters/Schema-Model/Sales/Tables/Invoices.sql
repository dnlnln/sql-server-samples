CREATE TABLE [Sales].[Invoices]
(
[InvoiceID] [int] NOT NULL CONSTRAINT [DF_Sales_Invoices_InvoiceID] DEFAULT (NEXT VALUE FOR [Sequences].[InvoiceID]),
[CustomerID] [int] NOT NULL,
[BillToCustomerID] [int] NOT NULL,
[OrderID] [int] NULL,
[DeliveryMethodID] [int] NOT NULL,
[ContactPersonID] [int] NOT NULL,
[AccountsPersonID] [int] NOT NULL,
[SalespersonPersonID] [int] NOT NULL,
[PackedByPersonID] [int] NOT NULL,
[InvoiceDate] [date] NOT NULL,
[CustomerPurchaseOrderNumber] [nvarchar] (20) NULL,
[IsCreditNote] [bit] NOT NULL,
[CreditNoteReason] [nvarchar] (max) NULL,
[Comments] [nvarchar] (max) NULL,
[DeliveryInstructions] [nvarchar] (max) NULL,
[InternalComments] [nvarchar] (max) NULL,
[TotalDryItems] [int] NOT NULL,
[TotalChillerItems] [int] NOT NULL,
[DeliveryRun] [nvarchar] (5) NULL,
[RunPosition] [nvarchar] (5) NULL,
[ReturnedDeliveryData] [nvarchar] (max) NULL,
[ConfirmedDeliveryTime] AS (TRY_CONVERT([datetime2](7),[json_value]([ReturnedDeliveryData],N'$.DeliveredWhen'),(126))),
[ConfirmedReceivedBy] AS ([json_value]([ReturnedDeliveryData],N'$.ReceivedBy')),
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Sales_Invoices_LastEditedWhen] DEFAULT (sysdatetime())
)
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [CK_Sales_Invoices_ReturnedDeliveryData_Must_Be_Valid_JSON] CHECK (([ReturnedDeliveryData] IS NULL OR [isjson]([ReturnedDeliveryData])<>(0)))
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [PK_Sales_Invoices] PRIMARY KEY CLUSTERED  ([InvoiceID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_AccountsPersonID] ON [Sales].[Invoices] ([AccountsPersonID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_BillToCustomerID] ON [Sales].[Invoices] ([BillToCustomerID])
GO
CREATE NONCLUSTERED INDEX [IX_Sales_Invoices_ConfirmedDeliveryTime] ON [Sales].[Invoices] ([ConfirmedDeliveryTime]) INCLUDE ([ConfirmedReceivedBy])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_ContactPersonID] ON [Sales].[Invoices] ([ContactPersonID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_CustomerID] ON [Sales].[Invoices] ([CustomerID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_DeliveryMethodID] ON [Sales].[Invoices] ([DeliveryMethodID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_OrderID] ON [Sales].[Invoices] ([OrderID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_PackedByPersonID] ON [Sales].[Invoices] ([PackedByPersonID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Invoices_SalespersonPersonID] ON [Sales].[Invoices] ([SalespersonPersonID])
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [FK_Sales_Invoices_AccountsPersonID_Application_People] FOREIGN KEY ([AccountsPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [FK_Sales_Invoices_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [FK_Sales_Invoices_BillToCustomerID_Sales_Customers] FOREIGN KEY ([BillToCustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [FK_Sales_Invoices_ContactPersonID_Application_People] FOREIGN KEY ([ContactPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [FK_Sales_Invoices_CustomerID_Sales_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [FK_Sales_Invoices_DeliveryMethodID_Application_DeliveryMethods] FOREIGN KEY ([DeliveryMethodID]) REFERENCES [Application].[DeliveryMethods] ([DeliveryMethodID])
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders] FOREIGN KEY ([OrderID]) REFERENCES [Sales].[Orders] ([OrderID])
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [FK_Sales_Invoices_PackedByPersonID_Application_People] FOREIGN KEY ([PackedByPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[Invoices] ADD CONSTRAINT [FK_Sales_Invoices_SalespersonPersonID_Application_People] FOREIGN KEY ([SalespersonPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Details of customer invoices', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Customer accounts contact for this invoice', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'AccountsPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Bill to customer for this invoice (invoices might be billed to a head office)', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'BillToCustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Any comments related to this invoice (sent to customer)', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'Comments'
GO
EXEC sp_addextendedproperty N'Description', 'Confirmed delivery date and time promoted from JSON delivery data', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'ConfirmedDeliveryTime'
GO
EXEC sp_addextendedproperty N'Description', 'Confirmed receiver promoted from JSON delivery data', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'ConfirmedReceivedBy'
GO
EXEC sp_addextendedproperty N'Description', 'Customer contact for this invoice', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'ContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Reason that this credit note needed to be generated (if applicable)', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'CreditNoteReason'
GO
EXEC sp_addextendedproperty N'Description', 'Customer for this invoice', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Purchase Order Number received from customer', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'CustomerPurchaseOrderNumber'
GO
EXEC sp_addextendedproperty N'Description', 'Any comments related to delivery (sent to customer)', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'DeliveryInstructions'
GO
EXEC sp_addextendedproperty N'Description', 'How these stock items are beign delivered', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'DeliveryMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Delivery run for this shipment', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'DeliveryRun'
GO
EXEC sp_addextendedproperty N'Description', 'Any internal comments related to this invoice (not sent to the customer)', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'InternalComments'
GO
EXEC sp_addextendedproperty N'Description', 'Date that this invoice was raised', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'InvoiceDate'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to an invoice within the database', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'InvoiceID'
GO
EXEC sp_addextendedproperty N'Description', 'Is this a credit note (rather than an invoice)', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'IsCreditNote'
GO
EXEC sp_addextendedproperty N'Description', 'Sales order (if any) for this invoice', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'OrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Person who packed this shipment (or checked the packing)', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'PackedByPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'JSON-structured data returned from delivery devices for deliveries made directly by the organization', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'ReturnedDeliveryData'
GO
EXEC sp_addextendedproperty N'Description', 'Position in the delivery run for this shipment', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'RunPosition'
GO
EXEC sp_addextendedproperty N'Description', 'Salesperson for this invoice', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'SalespersonPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Total number of chiller packages (information for the delivery driver)', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'TotalChillerItems'
GO
EXEC sp_addextendedproperty N'Description', 'Total number of dry packages (information for the delivery driver)', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'COLUMN', N'TotalDryItems'
GO
EXEC sp_addextendedproperty N'Description', 'Ensures that if returned delivery data is present that it is valid JSON', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'CONSTRAINT', N'CK_Sales_Invoices_ReturnedDeliveryData_Must_Be_Valid_JSON'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'INDEX', N'FK_Sales_Invoices_AccountsPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'INDEX', N'FK_Sales_Invoices_BillToCustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'INDEX', N'FK_Sales_Invoices_ContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'INDEX', N'FK_Sales_Invoices_CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'INDEX', N'FK_Sales_Invoices_DeliveryMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'INDEX', N'FK_Sales_Invoices_OrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'INDEX', N'FK_Sales_Invoices_PackedByPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'INDEX', N'FK_Sales_Invoices_SalespersonPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Allows quick retrieval of invoices confirmed to have been delivered in a given time period', 'SCHEMA', N'Sales', 'TABLE', N'Invoices', 'INDEX', N'IX_Sales_Invoices_ConfirmedDeliveryTime'
GO
