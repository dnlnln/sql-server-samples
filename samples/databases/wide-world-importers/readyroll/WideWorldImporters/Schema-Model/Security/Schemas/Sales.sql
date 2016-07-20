CREATE SCHEMA [Sales]
AUTHORIZATION [dbo]
GO
EXEC sp_addextendedproperty N'Description', N'Details of customers, salespeople, and of sales of stock items', 'SCHEMA', N'Sales', NULL, NULL, NULL, NULL
GO
