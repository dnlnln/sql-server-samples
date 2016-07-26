CREATE TABLE [Sales].[Customers]
(
[CustomerID] [int] NOT NULL CONSTRAINT [DF_Sales_Customers_CustomerID] DEFAULT (NEXT VALUE FOR [Sequences].[CustomerID]),
[CustomerName] [nvarchar] (100) NOT NULL,
[BillToCustomerID] [int] NOT NULL,
[CustomerCategoryID] [int] NOT NULL,
[BuyingGroupID] [int] NULL,
[PrimaryContactPersonID] [int] NOT NULL,
[AlternateContactPersonID] [int] NULL,
[DeliveryMethodID] [int] NOT NULL,
[DeliveryCityID] [int] NOT NULL,
[PostalCityID] [int] NOT NULL,
[CreditLimit] [decimal] (18, 2) NULL,
[AccountOpenedDate] [date] NOT NULL,
[StandardDiscountPercentage] [decimal] (18, 3) NOT NULL,
[IsStatementSent] [bit] NOT NULL,
[IsOnCreditHold] [bit] NOT NULL,
[PaymentDays] [int] NOT NULL,
[PhoneNumber] [nvarchar] (20) NOT NULL,
[FaxNumber] [nvarchar] (20) NOT NULL,
[DeliveryRun] [nvarchar] (5) NULL,
[RunPosition] [nvarchar] (5) NULL,
[WebsiteURL] [nvarchar] (256) NOT NULL,
[DeliveryAddressLine1] [nvarchar] (60) NOT NULL,
[DeliveryAddressLine2] [nvarchar] (60) NULL,
[DeliveryPostalCode] [nvarchar] (10) NOT NULL,
[DeliveryLocation] [sys].[geography] NULL,
[PostalAddressLine1] [nvarchar] (60) NOT NULL,
[PostalAddressLine2] [nvarchar] (60) NULL,
[PostalPostalCode] [nvarchar] (10) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [PK_Sales_Customers] PRIMARY KEY CLUSTERED  ([CustomerID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_AlternateContactPersonID] ON [Sales].[Customers] ([AlternateContactPersonID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_BuyingGroupID] ON [Sales].[Customers] ([BuyingGroupID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_CustomerCategoryID] ON [Sales].[Customers] ([CustomerCategoryID])
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [UQ_Sales_Customers_CustomerName] UNIQUE NONCLUSTERED  ([CustomerName])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_DeliveryCityID] ON [Sales].[Customers] ([DeliveryCityID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_DeliveryMethodID] ON [Sales].[Customers] ([DeliveryMethodID])
GO
CREATE NONCLUSTERED INDEX [IX_Sales_Customers_Perf_20160301_06] ON [Sales].[Customers] ([IsOnCreditHold], [CustomerID], [BillToCustomerID]) INCLUDE ([PrimaryContactPersonID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_PostalCityID] ON [Sales].[Customers] ([PostalCityID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_Customers_PrimaryContactPersonID] ON [Sales].[Customers] ([PrimaryContactPersonID])
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [FK_Sales_Customers_AlternateContactPersonID_Application_People] FOREIGN KEY ([AlternateContactPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [FK_Sales_Customers_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [FK_Sales_Customers_BillToCustomerID_Sales_Customers] FOREIGN KEY ([BillToCustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [FK_Sales_Customers_BuyingGroupID_Sales_BuyingGroups] FOREIGN KEY ([BuyingGroupID]) REFERENCES [Sales].[BuyingGroups] ([BuyingGroupID])
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [FK_Sales_Customers_CustomerCategoryID_Sales_CustomerCategories] FOREIGN KEY ([CustomerCategoryID]) REFERENCES [Sales].[CustomerCategories] ([CustomerCategoryID])
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [FK_Sales_Customers_DeliveryCityID_Application_Cities] FOREIGN KEY ([DeliveryCityID]) REFERENCES [Application].[Cities] ([CityID])
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [FK_Sales_Customers_DeliveryMethodID_Application_DeliveryMethods] FOREIGN KEY ([DeliveryMethodID]) REFERENCES [Application].[DeliveryMethods] ([DeliveryMethodID])
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [FK_Sales_Customers_PostalCityID_Application_Cities] FOREIGN KEY ([PostalCityID]) REFERENCES [Application].[Cities] ([CityID])
GO
ALTER TABLE [Sales].[Customers] ADD CONSTRAINT [FK_Sales_Customers_PrimaryContactPersonID_Application_People] FOREIGN KEY ([PrimaryContactPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Main entity tables for customers (organizations or individuals)', 'SCHEMA', N'Sales', 'TABLE', N'Customers', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Date this customer account was opened', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'AccountOpenedDate'
GO
EXEC sp_addextendedproperty N'Description', 'Alternate contact', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'AlternateContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Customer that this is billed to (usually the same customer but can be another parent company)', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'BillToCustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Customer''s buying group (optional)', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'BuyingGroupID'
GO
EXEC sp_addextendedproperty N'Description', 'Credit limit for this customer (NULL if unlimited)', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'CreditLimit'
GO
EXEC sp_addextendedproperty N'Description', 'Customer''s category', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'CustomerCategoryID'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a customer within the database', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Customer''s full name (usually a trading name)', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'CustomerName'
GO
EXEC sp_addextendedproperty N'Description', 'First delivery address line for the customer', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'DeliveryAddressLine1'
GO
EXEC sp_addextendedproperty N'Description', 'Second delivery address line for the customer', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'DeliveryAddressLine2'
GO
EXEC sp_addextendedproperty N'Description', 'ID of the delivery city for this address', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'DeliveryCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Geographic location for the customer''s office/warehouse', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'DeliveryLocation'
GO
EXEC sp_addextendedproperty N'Description', 'Standard delivery method for stock items sent to this customer', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'DeliveryMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Delivery postal code for the customer', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'DeliveryPostalCode'
GO
EXEC sp_addextendedproperty N'Description', 'Normal delivery run for this customer', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'DeliveryRun'
GO
EXEC sp_addextendedproperty N'Description', 'Fax number  ', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'FaxNumber'
GO
EXEC sp_addextendedproperty N'Description', 'Is this customer on credit hold? (Prevents further deliveries to this customer)', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'IsOnCreditHold'
GO
EXEC sp_addextendedproperty N'Description', 'Is a statement sent to this customer? (Or do they just pay on each invoice?)', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'IsStatementSent'
GO
EXEC sp_addextendedproperty N'Description', 'Number of days for payment of an invoice (ie payment terms)', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'PaymentDays'
GO
EXEC sp_addextendedproperty N'Description', 'Phone number', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'PhoneNumber'
GO
EXEC sp_addextendedproperty N'Description', 'First postal address line for the customer', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'PostalAddressLine1'
GO
EXEC sp_addextendedproperty N'Description', 'Second postal address line for the customer', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'PostalAddressLine2'
GO
EXEC sp_addextendedproperty N'Description', 'ID of the postal city for this address', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'PostalCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Postal code for the customer when sending by mail', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'PostalPostalCode'
GO
EXEC sp_addextendedproperty N'Description', 'Primary contact', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'PrimaryContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Normal position in the delivery run for this customer', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'RunPosition'
GO
EXEC sp_addextendedproperty N'Description', 'Standard discount offered to this customer', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'StandardDiscountPercentage'
GO
EXEC sp_addextendedproperty N'Description', 'URL for the website for this customer', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'COLUMN', N'WebsiteURL'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'INDEX', N'FK_Sales_Customers_AlternateContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'INDEX', N'FK_Sales_Customers_BuyingGroupID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'INDEX', N'FK_Sales_Customers_CustomerCategoryID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'INDEX', N'FK_Sales_Customers_DeliveryCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'INDEX', N'FK_Sales_Customers_DeliveryMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'INDEX', N'FK_Sales_Customers_PostalCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'INDEX', N'FK_Sales_Customers_PrimaryContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Improves performance of order picking and invoicing', 'SCHEMA', N'Sales', 'TABLE', N'Customers', 'INDEX', N'IX_Sales_Customers_Perf_20160301_06'
GO
CREATE FULLTEXT INDEX ON [Sales].[Customers] KEY INDEX [PK_Sales_Customers] ON [FTCatalog]
GO
