CREATE TYPE [Website].[OrderList] AS TABLE
(
[OrderReference] [int] NOT NULL,
[CustomerID] [int] NULL,
[ContactPersonID] [int] NULL,
[ExpectedDeliveryDate] [date] NULL,
[CustomerPurchaseOrderNumber] [nvarchar] (20) COLLATE Latin1_General_100_CI_AS NULL,
[IsUndersupplyBackordered] [bit] NULL,
[Comments] [nvarchar] (max) COLLATE Latin1_General_100_CI_AS NULL,
[DeliveryInstructions] [nvarchar] (max) COLLATE Latin1_General_100_CI_AS NULL,
PRIMARY KEY NONCLUSTERED  ([OrderReference])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
