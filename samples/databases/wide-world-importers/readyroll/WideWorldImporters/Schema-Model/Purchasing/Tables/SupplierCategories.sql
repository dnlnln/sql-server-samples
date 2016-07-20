CREATE TABLE [Purchasing].[SupplierCategories]
(
[SupplierCategoryID] [int] NOT NULL CONSTRAINT [DF_Purchasing_SupplierCategories_SupplierCategoryID] DEFAULT (NEXT VALUE FOR [Sequences].[SupplierCategoryID]),
[SupplierCategoryName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Purchasing].[SupplierCategories] ADD CONSTRAINT [PK_Purchasing_SupplierCategories] PRIMARY KEY CLUSTERED  ([SupplierCategoryID])
GO
ALTER TABLE [Purchasing].[SupplierCategories] ADD CONSTRAINT [UQ_Purchasing_SupplierCategories_SupplierCategoryName] UNIQUE NONCLUSTERED  ([SupplierCategoryName])
GO
ALTER TABLE [Purchasing].[SupplierCategories] ADD CONSTRAINT [FK_Purchasing_SupplierCategories_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Categories for suppliers (ie novelties, toys, clothing, packaging, etc.)', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierCategories', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a supplier category within the database', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierCategories', 'COLUMN', N'SupplierCategoryID'
GO
EXEC sp_addextendedproperty N'Description', 'Full name of the category that suppliers can be assigned to', 'SCHEMA', N'Purchasing', 'TABLE', N'SupplierCategories', 'COLUMN', N'SupplierCategoryName'
GO
