CREATE TABLE [Application].[TransactionTypes]
(
[TransactionTypeID] [int] NOT NULL CONSTRAINT [DF_Application_TransactionTypes_TransactionTypeID] DEFAULT (NEXT VALUE FOR [Sequences].[TransactionTypeID]),
[TransactionTypeName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Application].[TransactionTypes] ADD CONSTRAINT [PK_Application_TransactionTypes] PRIMARY KEY CLUSTERED  ([TransactionTypeID])
GO
ALTER TABLE [Application].[TransactionTypes] ADD CONSTRAINT [UQ_Application_TransactionTypes_TransactionTypeName] UNIQUE NONCLUSTERED  ([TransactionTypeName])
GO
ALTER TABLE [Application].[TransactionTypes] ADD CONSTRAINT [FK_Application_TransactionTypes_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Types of customer, supplier, or stock transactions (ie: invoice, credit note, etc.)', 'SCHEMA', N'Application', 'TABLE', N'TransactionTypes', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a transaction type within the database', 'SCHEMA', N'Application', 'TABLE', N'TransactionTypes', 'COLUMN', N'TransactionTypeID'
GO
EXEC sp_addextendedproperty N'Description', 'Full name of the transaction type', 'SCHEMA', N'Application', 'TABLE', N'TransactionTypes', 'COLUMN', N'TransactionTypeName'
GO
