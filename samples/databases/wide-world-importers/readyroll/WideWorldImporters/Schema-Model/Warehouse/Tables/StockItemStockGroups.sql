CREATE TABLE [Warehouse].[StockItemStockGroups]
(
[StockItemStockGroupID] [int] NOT NULL CONSTRAINT [DF_Warehouse_StockItemStockGroups_StockItemStockGroupID] DEFAULT (NEXT VALUE FOR [Sequences].[StockItemStockGroupID]),
[StockItemID] [int] NOT NULL,
[StockGroupID] [int] NOT NULL,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Warehouse_StockItemStockGroups_LastEditedWhen] DEFAULT (sysdatetime())
)
GO
ALTER TABLE [Warehouse].[StockItemStockGroups] ADD CONSTRAINT [PK_Warehouse_StockItemStockGroups] PRIMARY KEY CLUSTERED  ([StockItemStockGroupID])
GO
ALTER TABLE [Warehouse].[StockItemStockGroups] ADD CONSTRAINT [UQ_StockItemStockGroups_StockGroupID_Lookup] UNIQUE NONCLUSTERED  ([StockGroupID], [StockItemID])
GO
ALTER TABLE [Warehouse].[StockItemStockGroups] ADD CONSTRAINT [UQ_StockItemStockGroups_StockItemID_Lookup] UNIQUE NONCLUSTERED  ([StockItemID], [StockGroupID])
GO
ALTER TABLE [Warehouse].[StockItemStockGroups] ADD CONSTRAINT [FK_Warehouse_StockItemStockGroups_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Warehouse].[StockItemStockGroups] ADD CONSTRAINT [FK_Warehouse_StockItemStockGroups_StockGroupID_Warehouse_StockGroups] FOREIGN KEY ([StockGroupID]) REFERENCES [Warehouse].[StockGroups] ([StockGroupID])
GO
ALTER TABLE [Warehouse].[StockItemStockGroups] ADD CONSTRAINT [FK_Warehouse_StockItemStockGroups_StockItemID_Warehouse_StockItems] FOREIGN KEY ([StockItemID]) REFERENCES [Warehouse].[StockItems] ([StockItemID])
GO
EXEC sp_addextendedproperty N'Description', N'Which stock items are in which stock groups', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemStockGroups', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'StockGroup assigned to this stock item (FK indexed via unique constraint)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemStockGroups', 'COLUMN', N'StockGroupID'
GO
EXEC sp_addextendedproperty N'Description', 'Stock item assigned to this stock group (FK indexed via unique constraint)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemStockGroups', 'COLUMN', N'StockItemID'
GO
EXEC sp_addextendedproperty N'Description', 'Internal reference for this linking row', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemStockGroups', 'COLUMN', N'StockItemStockGroupID'
GO
EXEC sp_addextendedproperty N'Description', 'Enforces uniqueness and indexes one side of the many to many relationship', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemStockGroups', 'CONSTRAINT', N'UQ_StockItemStockGroups_StockGroupID_Lookup'
GO
EXEC sp_addextendedproperty N'Description', 'Enforces uniqueness and indexes one side of the many to many relationship', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemStockGroups', 'CONSTRAINT', N'UQ_StockItemStockGroups_StockItemID_Lookup'
GO
