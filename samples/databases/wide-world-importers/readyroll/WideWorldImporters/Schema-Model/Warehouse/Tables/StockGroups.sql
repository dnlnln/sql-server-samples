CREATE TABLE [Warehouse].[StockGroups]
(
[StockGroupID] [int] NOT NULL CONSTRAINT [DF_Warehouse_StockGroups_StockGroupID] DEFAULT (NEXT VALUE FOR [Sequences].[StockGroupID]),
[StockGroupName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Warehouse].[StockGroups] ADD CONSTRAINT [PK_Warehouse_StockGroups] PRIMARY KEY CLUSTERED  ([StockGroupID])
GO
ALTER TABLE [Warehouse].[StockGroups] ADD CONSTRAINT [UQ_Warehouse_StockGroups_StockGroupName] UNIQUE NONCLUSTERED  ([StockGroupName])
GO
ALTER TABLE [Warehouse].[StockGroups] ADD CONSTRAINT [FK_Warehouse_StockGroups_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Groups for categorizing stock items (ie: novelties, toys, edible novelties, etc.)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockGroups', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a stock group within the database', 'SCHEMA', N'Warehouse', 'TABLE', N'StockGroups', 'COLUMN', N'StockGroupID'
GO
EXEC sp_addextendedproperty N'Description', 'Full name of groups used to categorize stock items', 'SCHEMA', N'Warehouse', 'TABLE', N'StockGroups', 'COLUMN', N'StockGroupName'
GO
