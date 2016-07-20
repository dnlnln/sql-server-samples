CREATE TABLE [Warehouse].[Colors]
(
[ColorID] [int] NOT NULL CONSTRAINT [DF_Warehouse_Colors_ColorID] DEFAULT (NEXT VALUE FOR [Sequences].[ColorID]),
[ColorName] [nvarchar] (20) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Warehouse].[Colors] ADD CONSTRAINT [PK_Warehouse_Colors] PRIMARY KEY CLUSTERED  ([ColorID])
GO
ALTER TABLE [Warehouse].[Colors] ADD CONSTRAINT [UQ_Warehouse_Colors_ColorName] UNIQUE NONCLUSTERED  ([ColorName])
GO
ALTER TABLE [Warehouse].[Colors] ADD CONSTRAINT [FK_Warehouse_Colors_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Stock items can (optionally) have colors', 'SCHEMA', N'Warehouse', 'TABLE', N'Colors', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a color within the database', 'SCHEMA', N'Warehouse', 'TABLE', N'Colors', 'COLUMN', N'ColorID'
GO
EXEC sp_addextendedproperty N'Description', 'Full name of a color that can be used to describe stock items', 'SCHEMA', N'Warehouse', 'TABLE', N'Colors', 'COLUMN', N'ColorName'
GO
