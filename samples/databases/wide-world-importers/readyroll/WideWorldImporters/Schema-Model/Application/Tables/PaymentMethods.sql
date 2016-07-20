CREATE TABLE [Application].[PaymentMethods]
(
[PaymentMethodID] [int] NOT NULL CONSTRAINT [DF_Application_PaymentMethods_PaymentMethodID] DEFAULT (NEXT VALUE FOR [Sequences].[PaymentMethodID]),
[PaymentMethodName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Application].[PaymentMethods] ADD CONSTRAINT [PK_Application_PaymentMethods] PRIMARY KEY CLUSTERED  ([PaymentMethodID])
GO
ALTER TABLE [Application].[PaymentMethods] ADD CONSTRAINT [UQ_Application_PaymentMethods_PaymentMethodName] UNIQUE NONCLUSTERED  ([PaymentMethodName])
GO
ALTER TABLE [Application].[PaymentMethods] ADD CONSTRAINT [FK_Application_PaymentMethods_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Ways that payments can be made (ie: cash, check, EFT, etc.', 'SCHEMA', N'Application', 'TABLE', N'PaymentMethods', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a payment type within the database', 'SCHEMA', N'Application', 'TABLE', N'PaymentMethods', 'COLUMN', N'PaymentMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Full name of ways that customers can make payments or that suppliers can be paid', 'SCHEMA', N'Application', 'TABLE', N'PaymentMethods', 'COLUMN', N'PaymentMethodName'
GO
