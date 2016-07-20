CREATE TABLE [Warehouse].[StockGroups_Archive]
(
[StockGroupID] [int] NOT NULL,
[StockGroupName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_StockGroups_Archive] ON [Warehouse].[StockGroups_Archive] ([ValidTo], [ValidFrom])
GO
