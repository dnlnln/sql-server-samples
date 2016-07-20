CREATE SCHEMA [Application]
AUTHORIZATION [dbo]
GO
EXEC sp_addextendedproperty N'Description', N'Tables common across the application. Used for categorization and lookup lists, system parameters and people (users and contacts)', 'SCHEMA', N'Application', NULL, NULL, NULL, NULL
GO
