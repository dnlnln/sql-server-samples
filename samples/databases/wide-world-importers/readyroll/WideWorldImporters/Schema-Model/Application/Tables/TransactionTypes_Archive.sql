CREATE TABLE [Application].[TransactionTypes_Archive]
(
[TransactionTypeID] [int] NOT NULL,
[TransactionTypeName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_TransactionTypes_Archive] ON [Application].[TransactionTypes_Archive] ([ValidTo], [ValidFrom])
GO
