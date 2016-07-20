CREATE TABLE [Sales].[BuyingGroups]
(
[BuyingGroupID] [int] NOT NULL CONSTRAINT [DF_Sales_BuyingGroups_BuyingGroupID] DEFAULT (NEXT VALUE FOR [Sequences].[BuyingGroupID]),
[BuyingGroupName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Sales].[BuyingGroups] ADD CONSTRAINT [PK_Sales_BuyingGroups] PRIMARY KEY CLUSTERED  ([BuyingGroupID])
GO
ALTER TABLE [Sales].[BuyingGroups] ADD CONSTRAINT [UQ_Sales_BuyingGroups_BuyingGroupName] UNIQUE NONCLUSTERED  ([BuyingGroupName])
GO
ALTER TABLE [Sales].[BuyingGroups] ADD CONSTRAINT [FK_Sales_BuyingGroups_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Customer organizations can be part of groups that exert greater buying power', 'SCHEMA', N'Sales', 'TABLE', N'BuyingGroups', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a buying group within the database', 'SCHEMA', N'Sales', 'TABLE', N'BuyingGroups', 'COLUMN', N'BuyingGroupID'
GO
EXEC sp_addextendedproperty N'Description', 'Full name of a buying group that customers can be members of', 'SCHEMA', N'Sales', 'TABLE', N'BuyingGroups', 'COLUMN', N'BuyingGroupName'
GO
