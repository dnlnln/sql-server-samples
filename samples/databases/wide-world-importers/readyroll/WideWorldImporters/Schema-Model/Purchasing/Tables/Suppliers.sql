CREATE TABLE [Purchasing].[Suppliers]
(
[SupplierID] [int] NOT NULL CONSTRAINT [DF_Purchasing_Suppliers_SupplierID] DEFAULT (NEXT VALUE FOR [Sequences].[SupplierID]),
[SupplierName] [nvarchar] (100) NOT NULL,
[SupplierCategoryID] [int] NOT NULL,
[PrimaryContactPersonID] [int] NOT NULL,
[AlternateContactPersonID] [int] NOT NULL,
[DeliveryMethodID] [int] NULL,
[DeliveryCityID] [int] NOT NULL,
[PostalCityID] [int] NOT NULL,
[SupplierReference] [nvarchar] (20) NULL,
[BankAccountName] [nvarchar] (50) MASKED WITH (FUNCTION = 'default()') NULL,
[BankAccountBranch] [nvarchar] (50) MASKED WITH (FUNCTION = 'default()') NULL,
[BankAccountCode] [nvarchar] (20) MASKED WITH (FUNCTION = 'default()') NULL,
[BankAccountNumber] [nvarchar] (20) MASKED WITH (FUNCTION = 'default()') NULL,
[BankInternationalCode] [nvarchar] (20) MASKED WITH (FUNCTION = 'default()') NULL,
[PaymentDays] [int] NOT NULL,
[InternalComments] [nvarchar] (max) NULL,
[PhoneNumber] [nvarchar] (20) NOT NULL,
[FaxNumber] [nvarchar] (20) NOT NULL,
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
ALTER TABLE [Purchasing].[Suppliers] ADD CONSTRAINT [PK_Purchasing_Suppliers] PRIMARY KEY CLUSTERED  ([SupplierID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_Suppliers_AlternateContactPersonID] ON [Purchasing].[Suppliers] ([AlternateContactPersonID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_Suppliers_DeliveryCityID] ON [Purchasing].[Suppliers] ([DeliveryCityID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_Suppliers_DeliveryMethodID] ON [Purchasing].[Suppliers] ([DeliveryMethodID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_Suppliers_PostalCityID] ON [Purchasing].[Suppliers] ([PostalCityID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_Suppliers_PrimaryContactPersonID] ON [Purchasing].[Suppliers] ([PrimaryContactPersonID])
GO
CREATE NONCLUSTERED INDEX [FK_Purchasing_Suppliers_SupplierCategoryID] ON [Purchasing].[Suppliers] ([SupplierCategoryID])
GO
ALTER TABLE [Purchasing].[Suppliers] ADD CONSTRAINT [UQ_Purchasing_Suppliers_SupplierName] UNIQUE NONCLUSTERED  ([SupplierName])
GO
ALTER TABLE [Purchasing].[Suppliers] ADD CONSTRAINT [FK_Purchasing_Suppliers_AlternateContactPersonID_Application_People] FOREIGN KEY ([AlternateContactPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Purchasing].[Suppliers] ADD CONSTRAINT [FK_Purchasing_Suppliers_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Purchasing].[Suppliers] ADD CONSTRAINT [FK_Purchasing_Suppliers_DeliveryCityID_Application_Cities] FOREIGN KEY ([DeliveryCityID]) REFERENCES [Application].[Cities] ([CityID])
GO
ALTER TABLE [Purchasing].[Suppliers] ADD CONSTRAINT [FK_Purchasing_Suppliers_DeliveryMethodID_Application_DeliveryMethods] FOREIGN KEY ([DeliveryMethodID]) REFERENCES [Application].[DeliveryMethods] ([DeliveryMethodID])
GO
ALTER TABLE [Purchasing].[Suppliers] ADD CONSTRAINT [FK_Purchasing_Suppliers_PostalCityID_Application_Cities] FOREIGN KEY ([PostalCityID]) REFERENCES [Application].[Cities] ([CityID])
GO
ALTER TABLE [Purchasing].[Suppliers] ADD CONSTRAINT [FK_Purchasing_Suppliers_PrimaryContactPersonID_Application_People] FOREIGN KEY ([PrimaryContactPersonID]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Purchasing].[Suppliers] ADD CONSTRAINT [FK_Purchasing_Suppliers_SupplierCategoryID_Purchasing_SupplierCategories] FOREIGN KEY ([SupplierCategoryID]) REFERENCES [Purchasing].[SupplierCategories] ([SupplierCategoryID])
GO
EXEC sp_addextendedproperty N'Description', N'Main entity table for suppliers (organizations)', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Alternate contact', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'AlternateContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier''s bank branch', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'BankAccountBranch'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier''s bank account code (usually a numeric reference for the bank branch)', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'BankAccountCode'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier''s bank account name (ie name on the account)', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'BankAccountName'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier''s bank account number', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'BankAccountNumber'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier''s bank''s international code (such as a SWIFT code)', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'BankInternationalCode'
GO
EXEC sp_addextendedproperty N'Description', 'First delivery address line for the supplier', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'DeliveryAddressLine1'
GO
EXEC sp_addextendedproperty N'Description', 'Second delivery address line for the supplier', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'DeliveryAddressLine2'
GO
EXEC sp_addextendedproperty N'Description', 'ID of the delivery city for this address', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'DeliveryCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Geographic location for the supplier''s office/warehouse', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'DeliveryLocation'
GO
EXEC sp_addextendedproperty N'Description', 'Standard delivery method for stock items received from this supplier', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'DeliveryMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Delivery postal code for the supplier', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'DeliveryPostalCode'
GO
EXEC sp_addextendedproperty N'Description', 'Fax number  ', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'FaxNumber'
GO
EXEC sp_addextendedproperty N'Description', 'Internal comments (not exposed outside organization)', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'InternalComments'
GO
EXEC sp_addextendedproperty N'Description', 'Number of days for payment of an invoice (ie payment terms)', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'PaymentDays'
GO
EXEC sp_addextendedproperty N'Description', 'Phone number', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'PhoneNumber'
GO
EXEC sp_addextendedproperty N'Description', 'First postal address line for the supplier', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'PostalAddressLine1'
GO
EXEC sp_addextendedproperty N'Description', 'Second postal address line for the supplier', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'PostalAddressLine2'
GO
EXEC sp_addextendedproperty N'Description', 'ID of the mailing city for this address', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'PostalCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Postal code for the supplier when sending by mail', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'PostalPostalCode'
GO
EXEC sp_addextendedproperty N'Description', 'Primary contact', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'PrimaryContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier''s category', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'SupplierCategoryID'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a supplier within the database', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'SupplierID'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier''s full name (usually a trading name)', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'SupplierName'
GO
EXEC sp_addextendedproperty N'Description', 'Supplier reference for our organization (might be our account number at the supplier)', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'SupplierReference'
GO
EXEC sp_addextendedproperty N'Description', 'URL for the website for this supplier', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'COLUMN', N'WebsiteURL'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'INDEX', N'FK_Purchasing_Suppliers_AlternateContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'INDEX', N'FK_Purchasing_Suppliers_DeliveryCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'INDEX', N'FK_Purchasing_Suppliers_DeliveryMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'INDEX', N'FK_Purchasing_Suppliers_PostalCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'INDEX', N'FK_Purchasing_Suppliers_PrimaryContactPersonID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Purchasing', 'TABLE', N'Suppliers', 'INDEX', N'FK_Purchasing_Suppliers_SupplierCategoryID'
GO
CREATE FULLTEXT INDEX ON [Purchasing].[Suppliers] KEY INDEX [PK_Purchasing_Suppliers] ON [FTCatalog]
GO
