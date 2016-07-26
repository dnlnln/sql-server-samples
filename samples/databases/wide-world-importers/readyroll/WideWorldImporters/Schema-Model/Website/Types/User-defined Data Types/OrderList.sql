CREATE TYPE [Website].[OrderList] AS TABLE
(
[OrderReference] [int] NOT NULL,
[CustomerID] [int] NULL,
[ContactPersonID] [int] NULL,
[ExpectedDeliveryDate] [date] NULL,
[CustomerPurchaseOrderNumber] [nvarchar] (20) NULL,
[IsUndersupplyBackordered] [bit] NULL,
[Comments] [nvarchar] (max) NULL,
[DeliveryInstructions] [nvarchar] (max) NULL,
PRIMARY KEY CLUSTERED  ([OrderReference])
)
GO
