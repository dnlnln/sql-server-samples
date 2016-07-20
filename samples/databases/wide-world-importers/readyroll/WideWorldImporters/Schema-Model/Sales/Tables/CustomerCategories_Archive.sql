CREATE TABLE [Sales].[CustomerCategories_Archive]
(
[CustomerCategoryID] [int] NOT NULL,
[CustomerCategoryName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_CustomerCategories_Archive] ON [Sales].[CustomerCategories_Archive] ([ValidTo], [ValidFrom])
GO
