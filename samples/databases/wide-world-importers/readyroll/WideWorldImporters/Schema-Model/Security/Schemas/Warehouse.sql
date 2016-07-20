CREATE SCHEMA [Warehouse]
AUTHORIZATION [dbo]
GO
EXEC sp_addextendedproperty N'Description', N'Details of stock items, their holdings and transactions', 'SCHEMA', N'Warehouse', NULL, NULL, NULL, NULL
GO
