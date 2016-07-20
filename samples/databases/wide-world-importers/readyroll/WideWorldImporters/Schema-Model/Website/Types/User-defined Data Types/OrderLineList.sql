CREATE TYPE [Website].[OrderLineList] AS TABLE
(
[OrderReference] [int] NULL,
[StockItemID] [int] NULL,
[Description] [nvarchar] (100) COLLATE Latin1_General_100_CI_AS NULL,
[Quantity] [int] NULL,
INDEX [IX_Website_OrderLineList] NONCLUSTERED ([OrderReference])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
