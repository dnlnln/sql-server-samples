CREATE TABLE [Sales].[SpecialDeals]
(
[SpecialDealID] [int] NOT NULL CONSTRAINT [DF_Sales_SpecialDeals_SpecialDealID] DEFAULT (NEXT VALUE FOR [Sequences].[SpecialDealID]),
[StockItemID] [int] NULL,
[CustomerID] [int] NULL,
[BuyingGroupID] [int] NULL,
[CustomerCategoryID] [int] NULL,
[StockGroupID] [int] NULL,
[DealDescription] [nvarchar] (30) NOT NULL,
[StartDate] [date] NOT NULL,
[EndDate] [date] NOT NULL,
[DiscountAmount] [decimal] (18, 2) NULL,
[DiscountPercentage] [decimal] (18, 3) NULL,
[UnitPrice] [decimal] (18, 2) NULL,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Sales_SpecialDeals_LastEditedWhen] DEFAULT (sysdatetime())
)
GO
ALTER TABLE [Sales].[SpecialDeals] ADD CONSTRAINT [CK_Sales_SpecialDeals_Unit_Price_Deal_Requires_Special_StockItem] CHECK ((([StockItemID] IS NOT NULL AND [UnitPrice] IS NOT NULL) OR [UnitPrice] IS NULL))
GO
ALTER TABLE [Sales].[SpecialDeals] ADD CONSTRAINT [CK_Sales_SpecialDeals_Exactly_One_NOT_NULL_Pricing_Option_Is_Required] CHECK (((case  when [DiscountAmount] IS NULL then (0) else (1) end+case  when [DiscountPercentage] IS NULL then (0) else (1) end)+case  when [UnitPrice] IS NULL then (0) else (1) end=(1)))
GO
ALTER TABLE [Sales].[SpecialDeals] ADD CONSTRAINT [PK_Sales_SpecialDeals] PRIMARY KEY CLUSTERED  ([SpecialDealID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_SpecialDeals_BuyingGroupID] ON [Sales].[SpecialDeals] ([BuyingGroupID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_SpecialDeals_CustomerCategoryID] ON [Sales].[SpecialDeals] ([CustomerCategoryID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_SpecialDeals_CustomerID] ON [Sales].[SpecialDeals] ([CustomerID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_SpecialDeals_StockGroupID] ON [Sales].[SpecialDeals] ([StockGroupID])
GO
CREATE NONCLUSTERED INDEX [FK_Sales_SpecialDeals_StockItemID] ON [Sales].[SpecialDeals] ([StockItemID])
GO
ALTER TABLE [Sales].[SpecialDeals] ADD CONSTRAINT [FK_Sales_SpecialDeals_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Sales].[SpecialDeals] ADD CONSTRAINT [FK_Sales_SpecialDeals_BuyingGroupID_Sales_BuyingGroups] FOREIGN KEY ([BuyingGroupID]) REFERENCES [Sales].[BuyingGroups] ([BuyingGroupID])
GO
ALTER TABLE [Sales].[SpecialDeals] ADD CONSTRAINT [FK_Sales_SpecialDeals_CustomerCategoryID_Sales_CustomerCategories] FOREIGN KEY ([CustomerCategoryID]) REFERENCES [Sales].[CustomerCategories] ([CustomerCategoryID])
GO
ALTER TABLE [Sales].[SpecialDeals] ADD CONSTRAINT [FK_Sales_SpecialDeals_CustomerID_Sales_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
ALTER TABLE [Sales].[SpecialDeals] ADD CONSTRAINT [FK_Sales_SpecialDeals_StockGroupID_Warehouse_StockGroups] FOREIGN KEY ([StockGroupID]) REFERENCES [Warehouse].[StockGroups] ([StockGroupID])
GO
ALTER TABLE [Sales].[SpecialDeals] ADD CONSTRAINT [FK_Sales_SpecialDeals_StockItemID_Warehouse_StockItems] FOREIGN KEY ([StockItemID]) REFERENCES [Warehouse].[StockItems] ([StockItemID])
GO
EXEC sp_addextendedproperty N'Description', N'Special pricing (can include fixed prices, discount $ or discount %)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'ID of the buying group that the special pricing applies to (optional)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'BuyingGroupID'
GO
EXEC sp_addextendedproperty N'Description', 'ID of the customer category that the special pricing applies to (optional)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'CustomerCategoryID'
GO
EXEC sp_addextendedproperty N'Description', 'ID of the customer that the special pricing applies to (if NULL then all customers)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Description of the special deal', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'DealDescription'
GO
EXEC sp_addextendedproperty N'Description', 'Discount per unit to be applied to sale price (optional)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'DiscountAmount'
GO
EXEC sp_addextendedproperty N'Description', 'Discount percentage per unit to be applied to sale price (optional)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'DiscountPercentage'
GO
EXEC sp_addextendedproperty N'Description', 'Date that the special pricing ends on', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'EndDate'
GO
EXEC sp_addextendedproperty N'Description', 'ID (sequence based) for a special deal', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'SpecialDealID'
GO
EXEC sp_addextendedproperty N'Description', 'Date that the special pricing starts from', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'StartDate'
GO
EXEC sp_addextendedproperty N'Description', 'ID of the stock group that the special pricing applies to (optional)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'StockGroupID'
GO
EXEC sp_addextendedproperty N'Description', 'Stock item that the deal applies to (if NULL, then only discounts are permitted not unit prices)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'StockItemID'
GO
EXEC sp_addextendedproperty N'Description', 'Special price per unit to be applied instead of sale price (optional)', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'COLUMN', N'UnitPrice'
GO
EXEC sp_addextendedproperty N'Description', 'Ensures that each special price row contains one and only one of DiscountAmount, DiscountPercentage, and UnitPrice', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'CONSTRAINT', N'CK_Sales_SpecialDeals_Exactly_One_NOT_NULL_Pricing_Option_Is_Required'
GO
EXEC sp_addextendedproperty N'Description', 'Ensures that if a specific price is allocated that it applies to a specific stock item', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'CONSTRAINT', N'CK_Sales_SpecialDeals_Unit_Price_Deal_Requires_Special_StockItem'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'INDEX', N'FK_Sales_SpecialDeals_BuyingGroupID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'INDEX', N'FK_Sales_SpecialDeals_CustomerCategoryID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'INDEX', N'FK_Sales_SpecialDeals_CustomerID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'INDEX', N'FK_Sales_SpecialDeals_StockGroupID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Sales', 'TABLE', N'SpecialDeals', 'INDEX', N'FK_Sales_SpecialDeals_StockItemID'
GO
