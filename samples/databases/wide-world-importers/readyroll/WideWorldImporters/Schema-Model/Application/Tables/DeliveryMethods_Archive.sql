CREATE TABLE [Application].[DeliveryMethods_Archive]
(
[DeliveryMethodID] [int] NOT NULL,
[DeliveryMethodName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_DeliveryMethods_Archive] ON [Application].[DeliveryMethods_Archive] ([ValidTo], [ValidFrom])
GO
