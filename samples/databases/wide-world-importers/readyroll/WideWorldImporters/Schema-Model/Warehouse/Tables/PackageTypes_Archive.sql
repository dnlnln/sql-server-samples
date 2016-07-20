CREATE TABLE [Warehouse].[PackageTypes_Archive]
(
[PackageTypeID] [int] NOT NULL,
[PackageTypeName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_PackageTypes_Archive] ON [Warehouse].[PackageTypes_Archive] ([ValidTo], [ValidFrom])
GO
