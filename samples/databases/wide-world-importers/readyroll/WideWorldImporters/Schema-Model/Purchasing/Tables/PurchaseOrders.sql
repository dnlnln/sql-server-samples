CREATE TABLE [Purchasing].[PurchaseOrders]
(
[PurchaseOrderID] [int] NOT NULL CONSTRAINT [DF_Purchasing_PurchaseOrders_PurchaseOrderID] DEFAULT (NEXT VALUE FOR [Sequences].[PurchaseOrderID]),
[SupplierID] [int] NOT NULL,
[OrderDate] [date] NOT NULL,
[DeliveryMethodID] [int] NOT NULL,
[ContactPersonID] [int] NOT NULL,
[ExpectedDeliveryDate] [date] NULL,
[SupplierReference] [nvarchar] (20) NULL,
[IsOrderFinalized] [bit] NOT NULL,
[Comments] [nvarchar] (max) NULL,
[InternalComments] [nvarchar] (max) NULL,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Purchasing_PurchaseOrders_LastEditedWhen] DEFAULT (sysdatetime())
)
GO
ALTER TABLE [Purchasing].[PurchaseOrders] ADD CONSTRAINT [PK_Purchasing_PurchaseOrders] PRIMARY KEY CLUSTERED  ([PurchaseOrderID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_PurchaseOrders_ContactPersonID] ON [Purchasing].[PurchaseOrders] ([ContactPersonID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_PurchaseOrders_DeliveryMethodID] ON [Purchasing].[PurchaseOrders] ([DeliveryMethodID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_PurchaseOrders_SupplierID] ON [Purchasing].[PurchaseOrders] ([SupplierID])
GO
ALTER TABLE [Purchasing].[PurchaseOrders] ADD CONSTRAINT [FK_Purchasing_PurchaseOrders_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Purchasing].[PurchaseOrders] ADD CONSTRAINT [FK_Purchasing_PurchaseOrders_ContactPersonID_Application_People] FOREIGN KEY ([ContactPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Purchasing].[PurchaseOrders] ADD CONSTRAINT [FK_Purchasing_PurchaseOrders_DeliveryMethodID_Application_DeliveryMethods] FOREIGN KEY ([DeliveryMethodID]) REFERENCES [Application].[DeliveryMethods] ([DeliveryMethodID])
GO
ALTER TABLE [Purchasing].[PurchaseOrders] ADD CONSTRAINT [FK_Purchasing_PurchaseOrders_SupplierID_Purchasing_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [Purchasing].[Suppliers] ([SupplierID])
GO
EXEC sp_addextendedproperty N'Description', N'Details of supplier purchase orders', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Any comments related this purchase order (comments sent to the supplier)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'COLUMN', N'Comments'
GO
EXEC sp_addextendedproperty N'Description', 'The person who is the primary contact for this purchase order', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'COLUMN', N'ContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'How this purchase order should be delivered', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'COLUMN', N'DeliveryMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Expected delivery date for this purchase order', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'COLUMN', N'ExpectedDeliveryDate'
GO
EXEC sp_addextendedproperty N'Description', 'Any internal comments related this purchase order (comments for internal reference only and not sent to the supplier)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'COLUMN', N'InternalComments'
GO
EXEC sp_addextendedproperty N'Description', 'Is this purchase order now considered finalized?', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'COLUMN', N'IsOrderFinalized'
GO
EXEC sp_addextendedproperty N'Description', 'Date that this purchase order was raised', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'COLUMN', N'OrderDate'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a purchase order within the database', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'COLUMN', N'PurchaseOrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier for this purchase order', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'COLUMN', N'SupplierID'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier reference for our organization (might be our account number at the supplier)', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'COLUMN', N'SupplierReference'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'INDEX', N'FK_Purchasing_PurchaseOrders_ContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'INDEX', N'FK_Purchasing_PurchaseOrders_DeliveryMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'PurchaseOrders', 'INDEX', N'FK_Purchasing_PurchaseOrders_SupplierID'
GO
