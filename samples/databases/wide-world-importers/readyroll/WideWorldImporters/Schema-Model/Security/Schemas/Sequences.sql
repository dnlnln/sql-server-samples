CREATE SCHEMA [Sequences]
AUTHORIZATION [dbo]
GO
EXEC sp_addextendedproperty N'Description', N'Holds sequences used by all tables in the application', 'SCHEMA', N'Sequences', NULL, NULL, NULL, NULL
GO
