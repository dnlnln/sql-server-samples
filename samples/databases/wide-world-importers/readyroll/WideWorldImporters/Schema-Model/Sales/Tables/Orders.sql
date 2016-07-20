CREATE TABLE [Sales].[Orders]
(
[OrderID] [int] NOT NULL CONSTRAINT [DF_Sales_Orders_OrderID] DEFAULT (NEXT VALUE FOR [Sequences].[OrderID]),
[CustomerID] [int] NOT NULL,
[SalespersonPersonID] [int] NOT NULL,
[PickedByPersonID] [int] NULL,
[ContactPersonID] [int] NOT NULL,
[BackorderOrderID] [int] NULL,
[OrderDate] [date] NOT NULL,
[ExpectedDeliveryDate] [date] NOT NULL,
[CustomerPurchaseOrderNumber] [nvarchar] (20) NULL,
[IsUndersupplyBackordered] [bit] NOT NULL,
[Comments] [nvarchar] (max) NULL,
[DeliveryInstructions] [nvarchar] (max) NULL,
[InternalComments] [nvarchar] (max) NULL,
[PickingCompletedWhen] [datetime2] NULL,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Sales_Orders_LastEditedWhen] DEFAULT (sysdatetime())
)
GO
ALTER TABLE [Sales].[Orders] ADD CONSTRAINT [PK_Sales_Orders] PRIMARY KEY CLUSTERED  ([OrderID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Orders_ContactPersonID] ON [Sales].[Orders] ([ContactPersonID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Orders_CustomerID] ON [Sales].[Orders] ([CustomerID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Orders_PickedByPersonID] ON [Sales].[Orders] ([PickedByPersonID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Orders_SalespersonPersonID] ON [Sales].[Orders] ([SalespersonPersonID])
GO
ALTER TABLE [Sales].[Orders] ADD CONSTRAINT [FK_Sales_Orders_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[Orders] ADD CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders] FOREIGN KEY ([BackorderOrderID]) REFERENCES [Sales].[Orders] ([OrderID])
GO
ALTER TABLE [Sales].[Orders] ADD CONSTRAINT [FK_Sales_Orders_ContactPersonID_Application_People] FOREIGN KEY ([ContactPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[Orders] ADD CONSTRAINT [FK_Sales_Orders_CustomerID_Sales_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
ALTER TABLE [Sales].[Orders] ADD CONSTRAINT [FK_Sales_Orders_PickedByPersonID_Application_People] FOREIGN KEY ([PickedByPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[Orders] ADD CONSTRAINT [FK_Sales_Orders_SalespersonPersonID_Application_People] FOREIGN KEY ([SalespersonPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Detail of customer orders', 'SCHEMA', N'Sales', 'TABLE', N'Orders', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'If this order is a backorder, this column holds the original order number', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'BackorderOrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Any comments related to this order (sent to customer)', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'Comments'
GO
EXEC sp_addextendedproperty N'Description', 'Customer contact for this order', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'ContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Customer for this order', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Purchase Order Number received from customer', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'CustomerPurchaseOrderNumber'
GO
EXEC sp_addextendedproperty N'Description', 'Any comments related to order delivery (sent to customer)', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'DeliveryInstructions'
GO
EXEC sp_addextendedproperty N'Description', 'Expected delivery date', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'ExpectedDeliveryDate'
GO
EXEC sp_addextendedproperty N'Description', 'Any internal comments related to this order (not sent to the customer)', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'InternalComments'
GO
EXEC sp_addextendedproperty N'Description', 'If items cannot be supplied are they backordered?', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'IsUndersupplyBackordered'
GO
EXEC sp_addextendedproperty N'Description', 'Date that this order was raised', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'OrderDate'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to an order within the database', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'OrderID'
GO
EXEC sp_addextendedproperty N'Description', 'Person who picked this shipment', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'PickedByPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'When was picking of the entire order completed?', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'PickingCompletedWhen'
GO
EXEC sp_addextendedproperty N'Description', 'Salesperson for this order', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'COLUMN', N'SalespersonPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'INDEX', N'FK_Sales_Orders_ContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'INDEX', N'FK_Sales_Orders_CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'INDEX', N'FK_Sales_Orders_PickedByPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Orders', 'INDEX', N'FK_Sales_Orders_SalespersonPersonID'
GO
