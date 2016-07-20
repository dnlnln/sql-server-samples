CREATE TABLE [Warehouse].[StockItemHoldings]
(
[StockItemID] [int] NOT NULL,
[QuantityOnHand] [int] NOT NULL,
[BinLocation] [nvarchar] (20) NOT NULL,
[LastStocktakeQuantity] [int] NOT NULL,
[LastCostPrice] [decimal] (18, 2) NOT NULL,
[ReorderLevel] [int] NOT NULL,
[TargetStockLevel] [int] NOT NULL,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Warehouse_StockItemHoldings_LastEditedWhen] DEFAULT (sysdatetime())
)
GO
ALTER TABLE [Warehouse].[StockItemHoldings] ADD CONSTRAINT [PK_Warehouse_StockItemHoldings] PRIMARY KEY CLUSTERED  ([StockItemID])
GO
ALTER TABLE [Warehouse].[StockItemHoldings] ADD CONSTRAINT [FK_Warehouse_StockItemHoldings_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Warehouse].[StockItemHoldings] ADD CONSTRAINT [PKFK_Warehouse_StockItemHoldings_StockItemID_Warehouse_StockItems] FOREIGN KEY ([StockItemID]) REFERENCES [Warehouse].[StockItems] ([StockItemID])
GO
EXEC sp_addextendedproperty N'Description', N'Non-temporal attributes for stock items', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemHoldings', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Bin location (ie location of this stock item within the depot)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemHoldings', 'COLUMN', N'BinLocation'
GO
EXEC sp_addextendedproperty N'Description', 'Unit cost price the last time this stock item was purchased', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemHoldings', 'COLUMN', N'LastCostPrice'
GO
EXEC sp_addextendedproperty N'Description', 'Quantity at last stocktake (if tracked)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemHoldings', 'COLUMN', N'LastStocktakeQuantity'
GO
EXEC sp_addextendedproperty N'Description', 'Quantity currently on hand (if tracked)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemHoldings', 'COLUMN', N'QuantityOnHand'
GO
EXEC sp_addextendedproperty N'Description', 'Quantity below which reordering should take place', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemHoldings', 'COLUMN', N'ReorderLevel'
GO
EXEC sp_addextendedproperty N'Description', 'ID of the stock item that this holding relates to (this table holds non-temporal columns for stock)', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemHoldings', 'COLUMN', N'StockItemID'
GO
EXEC sp_addextendedproperty N'Description', 'Typical quantity ordered', 'SCHEMA', N'Warehouse', 'TABLE', N'StockItemHoldings', 'COLUMN', N'TargetStockLevel'
GO
