CREATE TABLE [Sales].[CustomerCategories]
(
[CustomerCategoryID] [int] NOT NULL CONSTRAINT [DF_Sales_CustomerCategories_CustomerCategoryID] DEFAULT (NEXT VALUE FOR [Sequences].[CustomerCategoryID]),
[CustomerCategoryName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Sales].[CustomerCategories] ADD CONSTRAINT [PK_Sales_CustomerCategories] PRIMARY KEY CLUSTERED  ([CustomerCategoryID])
GO
ALTER TABLE [Sales].[CustomerCategories] ADD CONSTRAINT [UQ_Sales_CustomerCategories_CustomerCategoryName] UNIQUE NONCLUSTERED  ([CustomerCategoryName])
GO
ALTER TABLE [Sales].[CustomerCategories] ADD CONSTRAINT [FK_Sales_CustomerCategories_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Categories for customers (ie restaurants, cafes, supermarkets, etc.)', 'SCHEMA', N'Sales', 'TABLE', N'CustomerCategories', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a customer category within the database', 'SCHEMA', N'Sales', 'TABLE', N'CustomerCategories', 'COLUMN', N'CustomerCategoryID'
GO
EXEC sp_addextendedproperty N'Description', 'Full name of the category that customers can be assigned to', 'SCHEMA', N'Sales', 'TABLE', N'CustomerCategories', 'COLUMN', N'CustomerCategoryName'
GO
