CREATE TABLE [Warehouse].[PackageTypes]
(
[PackageTypeID] [int] NOT NULL CONSTRAINT [DF_Warehouse_PackageTypes_PackageTypeID] DEFAULT (NEXT VALUE FOR [Sequences].[PackageTypeID]),
[PackageTypeName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Warehouse].[PackageTypes] ADD CONSTRAINT [PK_Warehouse_PackageTypes] PRIMARY KEY CLUSTERED  ([PackageTypeID])
GO
ALTER TABLE [Warehouse].[PackageTypes] ADD CONSTRAINT [UQ_Warehouse_PackageTypes_PackageTypeName] UNIQUE NONCLUSTERED  ([PackageTypeName])
GO
ALTER TABLE [Warehouse].[PackageTypes] ADD CONSTRAINT [FK_Warehouse_PackageTypes_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Ways that stock items can be packaged (ie: each, box, carton, pallet, kg, etc.', 'SCHEMA', N'Warehouse', 'TABLE', N'PackageTypes', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a package type within the database', 'SCHEMA', N'Warehouse', 'TABLE', N'PackageTypes', 'COLUMN', N'PackageTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Full name of package types that stock items can be purchased in or sold in', 'SCHEMA', N'Warehouse', 'TABLE', N'PackageTypes', 'COLUMN', N'PackageTypeName'
GO
