USE master;
 
IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = N'$(DatabaseName)')
BEGIN
	CREATE DATABASE [$(DatabaseName)]
	ON PRIMARY
	(
		NAME = WWI_Primary,
		FILENAME = '$(DefaultDataPath)\$(DefaultFilePrefix).mdf',
		SIZE = 1GB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 64MB
	),
	FILEGROUP USERDATA DEFAULT
	(
		NAME = WWI_UserData,
		FILENAME = '$(DefaultDataPath)\$(DefaultFilePrefix)_UserData.ndf',
		SIZE = 2GB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 64MB
	)
	LOG ON
	(
		NAME = WWI_Log,
		FILENAME = '$(DefaultLogPath)\$(DefaultFilePrefix).ldf',
		SIZE = 100MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 64MB
	);
END
GO
