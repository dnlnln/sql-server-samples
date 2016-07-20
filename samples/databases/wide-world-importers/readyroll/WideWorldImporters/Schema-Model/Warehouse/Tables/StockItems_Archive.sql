CREATE TABLE [Warehouse].[StockItems_Archive]
(
[StockItemID] [int] NOT NULL,
[StockItemName] [nvarchar] (100) NOT NULL,
[SupplierID] [int] NOT NULL,
[ColorID] [int] NULL,
[UnitPackageID] [int] NOT NULL,
[OuterPackageID] [int] NOT NULL,
[Brand] [nvarchar] (50) NULL,
[Size] [nvarchar] (20) NULL,
[LeadTimeDays] [int] NOT NULL,
[QuantityPerOuter] [int] NOT NULL,
[IsChillerStock] [bit] NOT NULL,
[Barcode] [nvarchar] (50) NULL,
[TaxRate] [decimal] (18, 3) NOT NULL,
[UnitPrice] [decimal] (18, 2) NOT NULL,
[RecommendedRetailPrice] [decimal] (18, 2) NULL,
[TypicalWeightPerUnit] [decimal] (18, 3) NOT NULL,
[MarketingComments] [nvarchar] (max) NULL,
[InternalComments] [nvarchar] (max) NULL,
[Photo] [varbinary] (max) NULL,
[CustomFields] [nvarchar] (max) NULL,
[Tags] [nvarchar] (max) NULL,
[SearchDetails] [nvarchar] (max) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_StockItems_Archive] ON [Warehouse].[StockItems_Archive] ([ValidTo], [ValidFrom])
GO
