CREATE SCHEMA [Integration]
AUTHORIZATION [dbo]
GO
EXEC sp_addextendedproperty N'Description', N'Tables and procedures required for integration with the data warehouse', 'SCHEMA', N'Integration', NULL, NULL, NULL, NULL
GO
