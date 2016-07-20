-- Restore the database from backup. Substitute the path 'C:\YourFolder' with the target location of the backup.

USE [master]
ALTER DATABASE [WideWorldImporters] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
RESTORE DATABASE [WideWorldImporters] 
FROM DISK = N'C:\YourPath\WideWorldImporters.bak' 
WITH FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5
ALTER DATABASE [WideWorldImporters] SET MULTI_USER
GO


