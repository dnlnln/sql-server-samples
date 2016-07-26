CREATE TYPE [Website].[OrderLineList] AS TABLE
(
[OrderReference] [int] NULL,
[StockItemID] [int] NULL,
[Description] [nvarchar] (100) NULL,
[Quantity] [int] NULL
)
GO
