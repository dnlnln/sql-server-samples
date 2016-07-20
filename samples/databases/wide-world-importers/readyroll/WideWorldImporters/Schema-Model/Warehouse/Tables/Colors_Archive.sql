CREATE TABLE [Warehouse].[Colors_Archive]
(
[ColorID] [int] NOT NULL,
[ColorName] [nvarchar] (20) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_Colors_Archive] ON [Warehouse].[Colors_Archive] ([ValidTo], [ValidFrom])
GO
