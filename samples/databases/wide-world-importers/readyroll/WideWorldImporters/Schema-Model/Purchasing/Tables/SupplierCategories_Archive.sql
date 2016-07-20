CREATE TABLE [Purchasing].[SupplierCategories_Archive]
(
[SupplierCategoryID] [int] NOT NULL,
[SupplierCategoryName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_SupplierCategories_Archive] ON [Purchasing].[SupplierCategories_Archive] ([ValidTo], [ValidFrom])
GO
