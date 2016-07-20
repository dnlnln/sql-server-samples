CREATE TABLE [Application].[PaymentMethods_Archive]
(
[PaymentMethodID] [int] NOT NULL,
[PaymentMethodName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_PaymentMethods_Archive] ON [Application].[PaymentMethods_Archive] ([ValidTo], [ValidFrom])
GO
