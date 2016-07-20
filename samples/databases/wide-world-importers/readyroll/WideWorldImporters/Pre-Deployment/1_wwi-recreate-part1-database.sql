IF NOT EXISTS(SELECT 1 FROM sys.databases WHERE name = N'$(DatabaseName)')
BEGIN
	CREATE DATABASE [$(DatabaseName)] -- Use RR built-in SQLCMD variable instead of hard-coded database name
	ON PRIMARY
	(
		NAME = WWI_Primary,
		FILENAME = '$(DefaultDataPath)\$(DefaultFilePrefix).mdf', -- Use RR built-in SQLCMD variable instead of hard-coded path
		SIZE = 1GB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 64MB
	),
	FILEGROUP USERDATA DEFAULT
	(
		NAME = WWI_UserData,
		FILENAME = '$(DefaultDataPath)\$(DefaultFilePrefix)_UserData.ndf', -- Use RR built-in SQLCMD variable instead of hard-coded path
		SIZE = 2GB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 64MB
	)
	LOG ON
	(
		NAME = WWI_Log,
		FILENAME = '$(DefaultLogPath)\$(DefaultFilePrefix).ldf', -- Use RR built-in SQLCMD variable instead of hard-coded path
		SIZE = 100MB,
		MAXSIZE = UNLIMITED,
		FILEGROWTH = 64MB
	);
END
GO
