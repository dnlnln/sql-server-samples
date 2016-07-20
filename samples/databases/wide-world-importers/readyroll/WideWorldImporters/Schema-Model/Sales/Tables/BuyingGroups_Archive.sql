CREATE TABLE [Sales].[BuyingGroups_Archive]
(
[BuyingGroupID] [int] NOT NULL,
[BuyingGroupName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_BuyingGroups_Archive] ON [Sales].[BuyingGroups_Archive] ([ValidTo], [ValidFrom])
GO
