-- Restore the database from backup. Substitute the path 'C:\YourFolder' with the target location of the backup.

USE [master]
ALTER DATABASE [WideWorldImportersDW] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [WideWorldImportersDW] 
FROM  DISK = N'C:\YourFolder\WideWorldImportersDW.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5
ALTER DATABASE [WideWorldImportersDW] SET MULTI_USER

GO


