-- WWI Construct database from metadata tables
--
-- The output of this script is used to create the schema for the actual sample database
--
-----------------------------------------------------------------------------------------
-- Implementation Note:
--
-- Decided for user simplicity that two schemas will not have a table with the same name.
-- So code now assumes that table names are unique.
--
-- Default is to just output the required script which then needs to be executed.
------------------------------------------------------------------------------------------

USE WWI_Preparation;
GO

-- Configuration
DECLARE @SQLDataFolder nvarchar(max) = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS nvarchar(max));
DECLARE @SQLLogFolder nvarchar(max) = CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS nvarchar(max));

DECLARE @LastEditedByColumnName sysname = N'LastEditedBy';
DECLARE @LastEditedWhenColumnName sysname = N'LastEditedWhen';
DECLARE @LastEditedByFKSchemaName sysname = N'Application';
DECLARE @LastEditedByFKTableName sysname = N'People';
DECLARE @LastEditedByFKColumnName sysname = N'PersonID';
DECLARE @TemporalFromColumnName sysname = N'ValidFrom';
DECLARE @TemporalToColumnName sysname = N'ValidTo';
DECLARE @TemporalTableSuffix sysname = N'Archive';
DECLARE @LocaleID nvarchar(20) = N'1033';

DECLARE @IncludeForeignKeyIndexes bit = 1;
DECLARE @IncludeExtendedProperties bit = 1;

-- Create required tables
DECLARE @SchemaName sysname;
DECLARE @TableName sysname;
DECLARE @IncludeTemporalColumns bit;
DECLARE @IncludeModificationTrackingColumns bit;
DECLARE @ColumnName sysname;
DECLARE @ConstraintName sysname;
DECLARE @IndexName sysname;
DECLARE @IsPrimaryKeyColumn bit;
DECLARE @DataType nvarchar(max);
DECLARE @IsNullable bit;
DECLARE @MaximumLength int;
DECLARE @DecimalPrecision int;
DECLARE @DecimalScale int;
DECLARE @HasDefaultValue bit;
DECLARE @UsesSequenceDefault bit;
DECLARE @DefaultSequenceName sysname;
DECLARE @DefaultValue nvarchar(max);
DECLARE @IsUnique bit;
DECLARE @HasForeignKeyReference bit;
DECLARE @ForeignKeySchema sysname;
DECLARE @ForeignKeyTable sysname;
DECLARE @ForeignKeyColumn sysname;
DECLARE @AutomaticallyIndexForeignKey bit;
DECLARE @ColumnMaskFunction nvarchar(max);
DECLARE @ConstraintDefinition nvarchar(max);
DECLARE @SchemaDescription nvarchar(max);
DECLARE @TableDescription nvarchar(max);
DECLARE @ColumnDescription nvarchar(max);
DECLARE @IndexDescription nvarchar(max);
DECLARE @ConstraintDescription nvarchar(max);
DECLARE @IndexColumns nvarchar(max);
DECLARE @IncludedColumns nvarchar(max);
DECLARE @FilterClause nvarchar(max);

DECLARE @CrLf nchar(2) = NCHAR(13) + NCHAR(10);
DECLARE @GO nchar(6) = N'GO' + @CrLf + @CrLf;
DECLARE @GO_SingleCrLf nchar(4) = N'GO' + @CrLf;
DECLARE @Indent nchar(4) = N'    ';

DECLARE @SQL nvarchar(max) = N'';
DECLARE @FirstColumnOfTable bit = 1;
DECLARE @AnySequencesCreated bit = 0;
DECLARE @ForeignKeyIndexSQL nvarchar(max) = N'';
DECLARE @ExtendedPropertySQL nvarchar(max) = N'';
DECLARE @NormalColumnList nvarchar(max) = N'';
DECLARE @NormalColumnListWithDPrefix nvarchar(max) = N'';
DECLARE @PrimaryKeyColumn nvarchar(max) = N'';

SET @SQL = N'';

-- when not using Azure DB, add create database statement
IF SERVERPROPERTY('EngineEdition') != 5
    SET @SQL += N'USE master;' + @CrLf + @CrLf
          + N'IF EXISTS(SELECT 1 FROM sys.databases WHERE name = N''WideWorldImporters'')' + @CrLf
          + N'BEGIN' + @CrLf
          + N'    ALTER DATABASE WideWorldImporters SET SINGLE_USER WITH ROLLBACK IMMEDIATE;' + @CrLf
          + N'    DROP DATABASE WideWorldImporters;' + @CrLf
          + N'END;' + @CrLf + @GO
          + N'CREATE DATABASE WideWorldImporters' + @CrLf
          + N'ON PRIMARY' + @CrLf
          + N'( ' + @CrLf
          + N'    NAME = WWI_Primary,' + @CrLf
          + N'    FILENAME = ''' + @SQLDataFolder + N'WideWorldImporters.mdf'',' + @CrLf
          + N'    SIZE = 1GB,' + @CrLf
          + N'    MAXSIZE = UNLIMITED,' + @CrLf
          + N'    FILEGROWTH = 64MB' + @CrLf
          + N'),' + @CrLf
                + N'FILEGROUP USERDATA DEFAULT' + @CrLf
          + N'( ' + @CrLf
          + N'    NAME = WWI_UserData,' + @CrLf
          + N'    FILENAME = ''' + @SQLDataFolder + N'WideWorldImporters_UserData.ndf'',' + @CrLf
          + N'    SIZE = 2GB,' + @CrLf
          + N'    MAXSIZE = UNLIMITED,' + @CrLf
          + N'    FILEGROWTH = 64MB' + @CrLf
          + N')' + @CrLf
          + N'LOG ON' + @CrLf
          + N'(' + @CrLf
          + N'    NAME = WWI_Log,' + @CrLf
          + N'    FILENAME = ''' + @SQLLogFolder + N'WideWorldImporters.ldf'',' + @CrLf
          + N'    SIZE = 100MB,' + @CrLf
          + N'    MAXSIZE = UNLIMITED,' + @CrLf
          + N'    FILEGROWTH = 64MB' + @CrLf
          + N');' + @CrLf + @GO
          + N'ALTER AUTHORIZATION ON DATABASE::WideWorldImporters to sa;' + @CrLf + @GO
          + N'USE WideWorldImporters;' + @CrLf + @GO;

 SET @SQL += N'ALTER DATABASE CURRENT COLLATE Latin1_General_100_CI_AS;' + @CrLf + @GO
  	  + N'ALTER DATABASE CURRENT SET RECOVERY SIMPLE;' + @CrLf + @GO
        + N'ALTER DATABASE CURRENT SET AUTO_UPDATE_STATISTICS_ASYNC ON;' + @CrLf + @GO
        + N'ALTER DATABASE CURRENT' + @CrLf
        + N'SET QUERY_STORE' + @CrLf
        + N'(' + @CrLf
        + @Indent + N'OPERATION_MODE = READ_WRITE,' + @CrLf
        + @Indent + N'CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),' + @CrLf
        + @Indent + N'DATA_FLUSH_INTERVAL_SECONDS = 3000,' + @CrLf
        + @Indent + N'MAX_STORAGE_SIZE_MB = 500,' + @CrLf
        + @Indent + N'INTERVAL_LENGTH_MINUTES = 15,' + @CrLf
        + @Indent + N'SIZE_BASED_CLEANUP_MODE = AUTO,' + @CrLf
        + @Indent + N'QUERY_CAPTURE_MODE = AUTO,' + @CrLf
        + @Indent + N'MAX_PLANS_PER_QUERY = 1000' + @CrLf
        + N');' + @CrLf + @GO

DECLARE SchemaList CURSOR FAST_FORWARD READ_ONLY
FOR
SELECT SchemaName, SchemaDescription
FROM Metadata.[Schemas]
ORDER BY SchemaID;

OPEN SchemaList;
FETCH NEXT FROM SchemaList INTO @SchemaName, @SchemaDescription;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL += N'CREATE SCHEMA ' + QUOTENAME(@SchemaName) + N' AUTHORIZATION dbo;' + @CrLf + @GO_SingleCrLf;
    IF @IncludeExtendedProperties <> 0
    BEGIN
        SET @SQL += N'EXEC sys.sp_addextendedproperty @name = N''Description'', @value = N''' + REPLACE(@SchemaDescription, N'''', N'''''') + N''', '
                  + N'@level0type = N''SCHEMA'', '
                  + N'@level0name = ''' + @SchemaName + N''';' + @CrLf + @GO;
    END;
    FETCH NEXT FROM SchemaList INTO @SchemaName, @SchemaDescription;
END;
CLOSE SchemaList;
DEALLOCATE SchemaList;

SET @SQL += @CrLf;

DECLARE SequenceList CURSOR FAST_FORWARD READ_ONLY
FOR
SELECT DISTINCT DefaultSequenceName, DataType
FROM Metadata.[Columns]
WHERE DefaultSequenceName IS NOT NULL
ORDER BY DefaultSequenceName;

OPEN SequenceList;
FETCH NEXT FROM SequenceList INTO @DefaultSequenceName, @DataType;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL += N'CREATE SEQUENCE ' + QUOTENAME(N'Sequences') + N'.' + QUOTENAME(@DefaultSequenceName) + N' AS ' + LOWER(@DataType)
              + N' START WITH 1;' + @CrLf;
    SET @AnySequencesCreated = 1;
    FETCH NEXT FROM SequenceList INTO @DefaultSequenceName, @DataType;
END;
CLOSE SequenceList;
DEALLOCATE SequenceList;

IF @AnySequencesCreated <> 0
BEGIN
    SET @SQL += @GO;
END;

DECLARE TableList CURSOR FAST_FORWARD READ_ONLY
FOR
SELECT SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription
FROM Metadata.[Tables]
ORDER BY TableCreationOrder;

OPEN TableList;
FETCH NEXT FROM TableList INTO @SchemaName, @TableName, @IncludeTemporalColumns,
                               @IncludeModificationTrackingColumns, @TableDescription;

WHILE @@FETCH_STATUS = 0
BEGIN

	-- Start creating the next table
	SET @SQL += N'CREATE TABLE ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
	          + N'(' + @CrLf;
	SET @FirstColumnOfTable = 1;
	SET @ForeignKeyIndexSQL = N'';
    SET @ExtendedPropertySQL = N'EXEC sys.sp_addextendedproperty @name = N''Description'', @value = N''' + REPLACE(@TableDescription, N'''', N'''''') + N''', '
                             + N'@level0type = N''SCHEMA'', @level0name = ''' + @SchemaName + N''', '
                             + N'@level1type = N''TABLE'',  @level1name = ''' + @TableName + N''';' + @CrLf + @CrLf;

	DECLARE ColumnList CURSOR FAST_FORWARD READ_ONLY
	FOR
	SELECT ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
	       MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
	       DefaultValue, IsUnique, HasForeignKeyReference,
           (SELECT SchemaName FROM Metadata.Tables AS t WHERE t.TableName = ForeignKeyTable) AS ForeignKeySchema, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
	       ColumnDescription
	FROM Metadata.[Columns]
	WHERE TableName = @TableName
	ORDER BY ColumnID;

	OPEN ColumnList;
	FETCH NEXT FROM ColumnList
	    INTO @ColumnName, @IsPrimaryKeyColumn, @DataType, @IsNullable,
	         @MaximumLength, @DecimalPrecision, @DecimalScale, @HasDefaultValue, @UsesSequenceDefault, @DefaultSequenceName,
	         @DefaultValue, @IsUnique, @HasForeignKeyReference, @ForeignKeySchema, @ForeignKeyTable, @ForeignKeyColumn, @AutomaticallyIndexForeignKey,
	         @ColumnDescription;

	WHILE @@FETCH_STATUS = 0
	BEGIN

	    IF @FirstColumnOfTable = 0
	    BEGIN
	        SET @SQL += N',' + @CrLf;
	    END;
	    SET @FirstColumnOfTable = 0;

        IF UPPER(LEFT(@DataType, 2)) = N'AS'
        BEGIN
            SET @SQL += @Indent + QUOTENAME(@ColumnName) + N' ' + @DataType;
        END ELSE BEGIN
	        SET @SQL += @Indent + QUOTENAME(@ColumnName) + N' ' + LOWER(@DataType)
	                  + CASE WHEN @DataType IN (N'varchar', N'nvarchar')
	                         THEN N'(' + CAST(@MaximumLength AS nvarchar(10)) + N')'
	                         WHEN @DataType IN (N'decimal', N'numeric')
	                         THEN N'(' + CAST(@DecimalPrecision AS nvarchar(10)) + N',' + CAST(@DecimalScale AS nvarchar(10)) + N')'
                             WHEN @DataType IN (N'datetime2')
                             THEN N'(7)'
	                         ELSE N''
	                    END;

	        SET @SQL += CASE WHEN @IsNullable = 0 THEN N' NOT' ELSE N'' END
	                  + N' NULL';

	        IF @IsPrimaryKeyColumn <> 0 AND @HasDefaultValue <> 0 AND @DefaultValue IS NULL AND @DefaultSequenceName IS NULL
            BEGIN
                SET @SQL += N' IDENTITY(1,1)';
            END;
        END; -- of if not a calculated column

	    IF @IsPrimaryKeyColumn <> 0
	    BEGIN
	        SET @SQL += @CrLf + @Indent + @Indent + N'CONSTRAINT '
	                  + QUOTENAME(N'PK_' + @SchemaName + N'_' + @TableName) + N' PRIMARY KEY';
	    END;

	    IF @IsPrimaryKeyColumn = 0 AND @IsUnique <> 0
	    BEGIN
	        SET @SQL += @CrLf + @Indent + @Indent + N'CONSTRAINT '
	                  + QUOTENAME(N'UQ_' + @SchemaName + N'_' + @TableName + N'_' + @ColumnName) + N' UNIQUE';
	    END;

	    IF @HasDefaultValue <> 0 AND @DefaultSequenceName IS NOT NULL
	    BEGIN
            SET @SQL += @CrLf + @Indent + @Indent + N'CONSTRAINT '
	                 + QUOTENAME(N'DF_' + @SchemaName + N'_' + @TableName + N'_' + @ColumnName) + @CrLf
	                 + @Indent + @Indent + @Indent + N'DEFAULT('
	                 + CASE WHEN @UsesSequenceDefault <> 0
	                        THEN N'NEXT VALUE FOR ' + QUOTENAME(N'Sequences') + N'.' + QUOTENAME(@DefaultSequenceName)
	                        ELSE @DefaultValue
	                   END
	                 + N')';
	    END;

	    IF @HasForeignKeyReference <> 0
	    BEGIN
	        SET @SQL += @CrLf + @Indent + @Indent + N'CONSTRAINT '
	                  + QUOTENAME(CASE WHEN @IsPrimaryKeyColumn <> 0 THEN N'PK' ELSE N'' END
	                              + N'FK_' + @SchemaName + N'_' + @TableName + N'_' + @ColumnName
	                              + N'_' + @ForeignKeySchema + N'_' + @ForeignKeyTable)
	                  + @CrLf + @Indent + @Indent + @Indent
	                  + N'FOREIGN KEY REFERENCES ' + QUOTENAME(@ForeignKeySchema) + N'.' + QUOTENAME(@ForeignKeyTable)
	                  + N' (' + QUOTENAME(@ForeignKeyColumn) + N')';
	        IF @IncludeForeignKeyIndexes <> 0 AND @IsPrimaryKeyColumn = 0 AND @AutomaticallyIndexForeignKey <> 0
	        BEGIN
	            SET @ForeignKeyIndexSQL += N'CREATE INDEX '
	                                     + QUOTENAME(N'FK_' + @SchemaName + N'_' + @TableName + N'_' + @ColumnName) + @CrLf
	                                     + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName)
	                                     + N' (' + QUOTENAME(@ColumnName) + N');' + @CrLf;
                SET @ExtendedPropertySQL += N'EXEC sys.sp_addextendedproperty @name = N''Description'', @value = ''Auto-created to support a foreign key'','
                                 + N'@level0type = N''SCHEMA'', @level0name = ''' + @SchemaName + N''', '
                                 + N'@level1type = N''TABLE'',  @level1name = ''' + @TableName + N''', '
                                 + N'@level2type = N''INDEX'', @level2name = ''' + N'FK_' + @SchemaName + N'_' + @TableName + N'_' + @ColumnName + N''';' + @CrLf;

	        END;
	    END;

        SET @ExtendedPropertySQL += N'EXEC sys.sp_addextendedproperty @name = N''Description'', @value = ''' + REPLACE(@ColumnDescription, N'''', N'''''')
                                 + N''', @level0type = N''SCHEMA'', @level0name = ''' + @SchemaName + N''', '
                                 + N'@level1type = N''TABLE'',  @level1name = ''' + @TableName + N''', '
                                 + N'@level2type = N''COLUMN'', @level2name = ''' + @ColumnName + N''';' + @CrLf;

	    FETCH NEXT FROM ColumnList
	        INTO @ColumnName, @IsPrimaryKeyColumn, @DataType, @IsNullable,
	             @MaximumLength, @DecimalPrecision, @DecimalScale, @HasDefaultValue, @UsesSequenceDefault, @DefaultSequenceName,
	             @DefaultValue, @IsUnique, @HasForeignKeyReference, @ForeignKeySchema, @ForeignKeyTable, @ForeignKeyColumn, @AutomaticallyIndexForeignKey,
	             @ColumnDescription;
	END;

	CLOSE ColumnList;
	DEALLOCATE ColumnList;

    IF @IncludeModificationTrackingColumns <> 0
    BEGIN
		IF @FirstColumnOfTable = 0
	    BEGIN
	        SET @SQL += N',' + @CrLf;
	    END;
	    SET @FirstColumnOfTable = 0;

        SET @SQL += @Indent + QUOTENAME(@LastEditedByColumnName) + N' int NOT NULL' + @CrLf
	              + @Indent + @Indent + N'CONSTRAINT '
	              + QUOTENAME(N'FK_' + @SchemaName + N'_' + @TableName
	                          + N'_' + @LastEditedByFKSchemaName + N'_' + @LastEditedByFKTableName) + @CrLf
	              + @Indent + @Indent + @Indent
	              + N'FOREIGN KEY REFERENCES ' + QUOTENAME(@LastEditedByFKSchemaName) + N'.' + QUOTENAME(@LastEditedByFKTableName)
	              + N' (' + QUOTENAME(@LastEditedByFKColumnName) + N')'
                  + CASE WHEN @IncludeTemporalColumns <> 0 THEN N''
                         ELSE N',' + @CrLf + @Indent + QUOTENAME(@LastEditedWhenColumnName) + N' datetime2(7) NOT NULL' + @CrLf
                              + @Indent + @Indent + N'CONSTRAINT '
	                          + QUOTENAME(N'DF_' + @SchemaName + N'_' + @TableName + N'_' + @LastEditedWhenColumnName) + @CrLf
	                          + @Indent + @Indent + @Indent + N'DEFAULT(SYSDATETIME())'
                    END;
    END;

	IF @IncludeTemporalColumns <> 0
	BEGIN
		IF @FirstColumnOfTable = 0
	    BEGIN
	        SET @SQL += N',' + @CrLf;
	    END;
	    SET @FirstColumnOfTable = 0;

	    SET @SQL += @Indent + QUOTENAME(@TemporalFromColumnName) + N' datetime2(7) GENERATED ALWAYS AS ROW START,' + @CrLf
		          + @Indent + QUOTENAME(@TemporalToColumnName) + N' datetime2(7) GENERATED ALWAYS AS ROW END,' + @CrLf
				  + @Indent + N'PERIOD FOR SYSTEM_TIME (' + QUOTENAME(@TemporalFromColumnName)
				  + N',' + QUOTENAME(@TemporalToColumnName) + N')';

	END; -- of if temporal included

	-- Finish creating the table
	SET @SQL += @CrLf + N')';

    IF @IncludeTemporalColumns <> 0
    BEGIN
	    SET @SQL += @CrLf + N'WITH ' + @CrLf + N'(' + @CrLf
                  + @Indent + N'SYSTEM_VERSIONING = ON (HISTORY_TABLE = '
				  + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + N')' + @CrLf
                  + N');' + @CrLf
                  + N'ALTER INDEX ix_' + @TableName + N'_' + @TemporalTableSuffix + N' ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + N' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE)';
    END;

	SET @SQL += N';' + @CrLf + @GO;

    IF @IncludeForeignKeyIndexes <> 0
    BEGIN
        IF @ForeignKeyIndexSQL <> N''
        BEGIN
            SET @SQL += @ForeignKeyIndexSQL + @GO;
        END;
    END;

	DECLARE ConstraintList CURSOR FAST_FORWARD READ_ONLY
	FOR
	SELECT ConstraintName, ConstraintDefinition, ConstraintDescription
	FROM Metadata.[Constraints]
	WHERE TableName = @TableName
	ORDER BY [ConstraintID];

	OPEN ConstraintList;
	FETCH NEXT FROM ConstraintList INTO @ConstraintName, @ConstraintDefinition, @ConstraintDescription;
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SET @SQL += N'ALTER TABLE ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
	              + @Indent + N'ADD CONSTRAINT ' + QUOTENAME(@ConstraintName) + @CrLf
	              + @Indent + @Indent + N' ' + @ConstraintDefinition + N';' + @CrLf + @GO;
        IF @IncludeExtendedProperties <> 0
        BEGIN
            SET @SQL += N'EXEC sys.sp_addextendedproperty @name = N''Description'', @value = ''' + REPLACE(@ConstraintDescription, N'''', N'''''')
                      + N''', @level0type = N''SCHEMA'', @level0name = ''' + @SchemaName + N''', '
                      + N'@level1type = N''TABLE'',  @level1name = ''' + @TableName + N''', '
                      + N'@level2type = N''CONSTRAINT'', @level2name = ''' + @ConstraintName + N''';' + @CrLf + @GO;
        END;
	    FETCH NEXT FROM ConstraintList INTO @ConstraintName, @ConstraintDefinition, @ConstraintDescription;
	END;
	CLOSE ConstraintList;
	DEALLOCATE ConstraintList;

	DECLARE IndexList CURSOR FAST_FORWARD READ_ONLY
	FOR
	SELECT IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription
	FROM Metadata.[Indexes]
	WHERE TableName = @TableName
	ORDER BY [IndexID];

	OPEN IndexList;
	FETCH NEXT FROM IndexList INTO @IndexName, @IndexColumns, @IncludedColumns, @IsUnique, @FilterClause, @IndexDescription;
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    SET @SQL += N'CREATE ' + CASE WHEN @IsUnique <> 0 THEN N'UNIQUE ' ELSE N'' END + N'INDEX ' + QUOTENAME(@IndexName) + @CrLf
	              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N'(' + @IndexColumns + N')'
	    IF @IncludedColumns IS NOT NULL
	    BEGIN
	        SET @SQL += @CrLf + N'INCLUDE (' + @IncludedColumns + N')'
	    END;
        IF @FilterClause IS NOT NULL
        BEGIN
            SET @SQL += @CrLf + N'WHERE ' + @FilterClause;
        END;
	    SET @SQL += N';' + @CrLf + @GO;
        IF @IncludeExtendedProperties <> 0
        BEGIN
            SET @SQL += N'EXEC sys.sp_addextendedproperty @name = N''Description'', @value = ''' + REPLACE(@IndexDescription, N'''', N'''''')
                      + N''', @level0type = N''SCHEMA'', @level0name = ''' + @SchemaName + N''', '
                      + N'@level1type = N''TABLE'',  @level1name = ''' + @TableName + N''', '
                      + N'@level2type = N''INDEX'', @level2name = ''' + @IndexName + N''';' + @CrLf + @CrLf;
        END;
	    FETCH NEXT FROM IndexList INTO @IndexName, @IndexColumns, @IncludedColumns, @IsUnique, @FilterClause, @IndexDescription;
	END;
	CLOSE IndexList;
	DEALLOCATE IndexList;

    DECLARE MaskedColumnList CURSOR FAST_FORWARD READ_ONLY
	FOR
	SELECT ColumnName, ColumnMaskFunction
	FROM Metadata.[Columns]
	WHERE TableName = @TableName
    AND ColumnMaskFunction IS NOT NULL
	ORDER BY ColumnID;

	OPEN MaskedColumnList;
	FETCH NEXT FROM MaskedColumnList
	    INTO @ColumnName, @ColumnMaskFunction;

	WHILE @@FETCH_STATUS = 0
	BEGIN
        SET @SQL += N'ALTER TABLE ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
                  + @Indent + N'ALTER COLUMN ' + QUOTENAME(@ColumnName) + N' ADD MASKED WITH (FUNCTION = ''' + @ColumnMaskFunction + N''');' + @CrLf + @GO;
    	FETCH NEXT FROM MaskedColumnList
	        INTO @ColumnName, @ColumnMaskFunction;
    END;

	CLOSE MaskedColumnList;
    DEALLOCATE MaskedColumnList;

    IF @IncludeExtendedProperties <> 0
    BEGIN
        SET @SQL += @ExtendedPropertySQL + @GO;
    END;

	FETCH NEXT FROM TableList INTO @SchemaName, @TableName, @IncludeTemporalColumns,
                                   @IncludeModificationTrackingColumns, @TableDescription;
END; -- of for each table

CLOSE TableList;
DEALLOCATE TableList;

IF @AnySequencesCreated <> 0
BEGIN
    SET @SQL += N'CREATE PROCEDURE Sequences.ReseedSequenceBeyondTableValues' + @CrLf
              + N'@SequenceName sysname, ' + @CrLf
              + N'@SchemaName sysname, ' + @CrLf
              + N'@TableName sysname, ' + @CrLf
              + N'@ColumnName sysname ' + @CrLf
              + N'AS BEGIN' + @CrLf
              + @Indent + N'-- Ensures that the next sequence value is above the maximum value of the supplied table column' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'DECLARE @SQL nvarchar(max);' + @CrLf
              + @Indent + N'DECLARE @CurrentTableMaximumValue bigint;' + @CrLf
              + @Indent + N'DECLARE @NewSequenceValue bigint;' + @CrLf
              + @Indent + N'DECLARE @CurrentSequenceMaximumValue bigint' + @CrLf
              + @Indent + @Indent + N'= (SELECT CAST(current_value AS bigint) FROM sys.sequences' + @CrLf
              + @Indent + @Indent + N'                                        WHERE name = @SequenceName' + @CrLf
              + @Indent + @Indent + N'                                        AND SCHEMA_NAME(schema_id) = N''Sequences'');' + @CrLf
              + @Indent + N'CREATE TABLE #CurrentValue' + @CrLf
              + @Indent + N'(' + @CrLf
              + @Indent + @Indent + N'CurrentValue bigint' + @CrLf
              + @Indent + N')' + @CrLf + @CrLf
              + @Indent + N'SET @SQL = N''INSERT #CurrentValue (CurrentValue) '
                        + N'SELECT COALESCE(MAX('' + QUOTENAME(@ColumnName) + N''), 0) '
                        + N'FROM '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@TableName) + N'';'';' + @CrLf
              + @Indent + N'EXECUTE (@SQL);' + @CrLf
              + @Indent + N'SET @CurrentTableMaximumValue = (SELECT CurrentValue FROM #CurrentValue);' + @CrLf
              + @Indent + N'DROP TABLE #CurrentValue;' + @CrLf + @CrLf
              + @Indent + N'IF @CurrentTableMaximumValue >= @CurrentSequenceMaximumValue' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'SET @NewSequenceValue = @CurrentTableMaximumValue + 1;' + @CrLf
              + @Indent + @Indent + N'SET @SQL = N''ALTER SEQUENCE Sequences.'' + QUOTENAME(@SequenceName) + N'' RESTART WITH '' + CAST(@NewSequenceValue AS nvarchar(20)) + N'';'';' + @CrLf
              + @Indent + @Indent + N'EXECUTE (@SQL);' + @CrLf
              + @Indent + N'END;' + @CrLf
              + N'END;' + @CrLf + @GO;

    DECLARE SequenceList CURSOR FAST_FORWARD READ_ONLY
    FOR
    SELECT t.SchemaName, t.TableName, c.ColumnName, c.DefaultSequenceName
    FROM Metadata.[Columns] AS c
    INNER JOIN Metadata.[Tables] AS t
    ON c.TableName = t.TableName
    WHERE c.DefaultSequenceName IS NOT NULL
    ORDER BY c.DefaultSequenceName;

    SET @SQL += N'CREATE PROCEDURE Sequences.ReseedAllSequences' + @CrLf
              + N'AS BEGIN' + @CrLf
              + @Indent + N'-- Ensures that the next sequence values are above the maximum value of the related table columns' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf;

    OPEN SequenceList;
    FETCH NEXT FROM SequenceList INTO @SchemaName, @TableName, @ColumnName, @DefaultSequenceName;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL += @Indent + N'EXEC Sequences.ReseedSequenceBeyondTableValues '
                  + N'@SequenceName = ''' + @DefaultSequenceName + N''', '
                  + N'@SchemaName = ''' + @SchemaName + N''', '
                  + N'@TableName = ''' + @TableName + N''', '
                  + N'@ColumnName = ''' + @ColumnName + N''';' + @CrLf;
        FETCH NEXT FROM SequenceList INTO @SchemaName, @TableName, @ColumnName, @DefaultSequenceName;
    END;
    CLOSE SequenceList;
    DEALLOCATE SequenceList;

    SET @SQL += N'END;' + @CrLf + @GO;
END; -- of setting appropriate next values for sequences

-- Create the procedure for disabling temporal before simulated data load

SET @SQL += N'CREATE PROCEDURE DataLoadSimulation.DeactivateTemporalTablesBeforeDataLoad' + @CrLf
          + N'AS BEGIN' + @CrLf
          + @Indent + N'-- Disables the temporal nature of the temporal tables before a simulated data load' + @CrLf
          + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf;

SET @SQL += @Indent + N'IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = N''Configuration_RemoveRowLevelSecurity'')' + @CrLf
          + @Indent + N'BEGIN' + @CrLf
          + @Indent + @Indent + N'EXEC [Application].Configuration_RemoveRowLevelSecurity;' + @CrLf
          + @Indent + N'END;' + @CrLf + @CrLf;

SET @SQL += @Indent + N'DECLARE @SQL nvarchar(max) = N'''';' + @CrLf
          + @Indent + N'DECLARE @CrLf nvarchar(2) = NCHAR(13) + NCHAR(10);' + @CrLf
          + @Indent + N'DECLARE @Indent nvarchar(4) = N''    '';' + @CrLf
          + @Indent + N'DECLARE @SchemaName sysname;' + @CrLf
          + @Indent + N'DECLARE @TableName sysname;' + @CrLf
          + @Indent + N'DECLARE @NormalColumnList nvarchar(max);' + @CrLf
          + @Indent + N'DECLARE @NormalColumnListWithDPrefix nvarchar(max);' + @CrLf
          + @Indent + N'DECLARE @PrimaryKeyColumn sysname;' + @CrLf
          + @Indent + N'DECLARE @TemporalFromColumnName sysname = N''' + @TemporalFromColumnName + N''';' + @CrLf
          + @Indent + N'DECLARE @TemporalToColumnName sysname = N''' + @TemporalToColumnName + N''';' + @CrLf
          + @Indent + N'DECLARE @TemporalTableSuffix nvarchar(max) = N''' + @TemporalTableSuffix + N''';' + @CrLf
          + @Indent + N'DECLARE @LastEditedByColumnName sysname;' + @CrLf + @CrLf;

DECLARE TableList CURSOR FAST_FORWARD READ_ONLY
FOR
SELECT SchemaName, TableName, IncludeModificationTrackingColumns
FROM Metadata.[Tables] AS t
WHERE IncludeTemporalColumns <> 0
ORDER BY SchemaName, TableName;

OPEN TableList;
FETCH NEXT FROM TableList INTO @SchemaName, @TableName, @IncludeModificationTrackingColumns;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL += @Indent + N'ALTER TABLE ' + QUOTENAME(@SchemaName) + N'.'
                  + QUOTENAME(@TableName) + N' SET (SYSTEM_VERSIONING = OFF);' + @CrLf
              + @Indent + N'ALTER TABLE ' + QUOTENAME(@SchemaName) + N'.'
                  + QUOTENAME(@TableName) + N' DROP PERIOD FOR SYSTEM_TIME;' + @CrLf + @CrLf;
    FETCH NEXT FROM TableList INTO @SchemaName, @TableName, @IncludeModificationTrackingColumns;
END;

CLOSE TableList;

OPEN TableList;
FETCH NEXT FROM TableList INTO @SchemaName, @TableName, @IncludeModificationTrackingColumns;

WHILE @@FETCH_STATUS = 0
BEGIN

    DECLARE ColumnList CURSOR FAST_FORWARD READ_ONLY
    FOR
    SELECT c.ColumnName, c.IsPrimaryKeyColumn
    FROM Metadata.[Columns] AS c
    WHERE c.TableName = @TableName
    ORDER BY c.ColumnID;

    SET @NormalColumnList = N'';
    SET @NormalColumnListWithDPrefix = N'';

    OPEN ColumnList;
    FETCH NEXT FROM ColumnList INTO @ColumnName, @IsPrimaryKeyColumn;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @IsPrimaryKeyColumn <> 0 SET @PrimaryKeyColumn = @ColumnName;
        SET @NormalColumnList += N' ' + QUOTENAME(@ColumnName) + N',';
        SET @NormalColumnListWithDPrefix += N' d.' + QUOTENAME(@ColumnName) + N',';
        FETCH NEXT FROM ColumnList INTO @ColumnName, @IsPrimaryKeyColumn;
    END;

    CLOSE ColumnList;
    DEALLOCATE ColumnList;

    SET @SQL += @Indent + N'SET @SQL = N'''';' + @CrLf
              + @Indent + N'SET @SchemaName = N''' + @SchemaName + N''';' + @CrLf
              + @Indent + N'SET @TableName = N''' + @TableName + N''';' + @CrLf
              + @Indent + N'SET @PrimaryKeyColumn = N''' + @PrimaryKeyColumn + N''';' + @CrLf
              + @Indent + N'SET @LastEditedByColumnName = N''' + CASE WHEN @IncludeModificationTrackingColumns <> 0
                                                                      THEN @LastEditedByColumnName
                                                                      ELSE N''
                                                                 END + N''';' + @CrLf
              + @Indent + N'SET @NormalColumnList = N''' + @NormalColumnList + N''';' + @CrLf
              + @Indent + N'SET @NormalColumnListWithDPrefix = N''' + @NormalColumnListWithDPrefix + N''';' + @CrLf + @CrLf;

    SET @SQL += @Indent + N'SET @SQL = N''DROP TRIGGER IF EXISTS '' + QUOTENAME(@SchemaName)'
              + N' + N''.[TR_'' + @SchemaName + N''_'' + @TableName + N''_DataLoad_Modify];''' + @CrLf
              + @Indent + N'EXECUTE (@SQL);' + @CrLf + @CrLf
              + @Indent + N'SET @SQL = N''CREATE TRIGGER '' + QUOTENAME(@SchemaName) + N''.[TR_'' + @SchemaName + N''_'' + @TableName + N''_DataLoad_Modify]'' + @CrLf
              + N''ON '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@TableName) + @CrLf
              + N''AFTER INSERT, UPDATE'' + @CrLf
              + N''AS'' + @CrLf
              + N''BEGIN'' + @CrLf
              + @Indent + N''SET NOCOUNT ON;'' + @CrLf + @CrLf
              + @Indent + N''IF NOT UPDATE('' + QUOTENAME(@TemporalFromColumnName) + N'')'' + @CrLf
              + @Indent + N''BEGIN'' + @CrLf
              + @Indent + @Indent + N''THROW 51000, '''''' + QUOTENAME(@TemporalFromColumnName)
                                  + N'' must be updated when simulating data loads'''', 1;'' + @CrLf
              + @Indent + @Indent + N''ROLLBACK TRAN;'' + @CrLf
              + @Indent + N''END;'' + @Crlf + @CrLf
              + @Indent + N''INSERT '' + QUOTENAME(@SchemaName) + N''.'' + QUOTENAME(@TableName + N''_'' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N''('' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'''') <> N'''' THEN QUOTENAME(@LastEditedByColumnName) + N'', '' ELSE N'''' END
                                  + QUOTENAME(@TemporalFromColumnName) + N'','' + QUOTENAME(@TemporalToColumnName) + N'')'' + @CrLf
              + @Indent + N''SELECT'' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'''') <> N'''' THEN N''d.'' + QUOTENAME(@LastEditedByColumnName) + N'', '' ELSE N'''' END
                                  + N'' d.'' + QUOTENAME(@TemporalFromColumnName) + N'', i.'' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N''FROM inserted AS i'' + @CrLf
              + @Indent + N''INNER JOIN deleted AS d'' + @CrLf
              + @Indent + N''ON i.'' + QUOTENAME(@PrimaryKeyColumn) + N'' = d.'' + QUOTENAME(@PrimaryKeyColumn) + N'';'' + @CrLf
              + N''END;'';' + @CrLf
              + @Indent + N'IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + N'    EXECUTE (@SQL);' + @CrLf
              + @Indent + N'END;' + @CrLf + @CrLf;
    FETCH NEXT FROM TableList INTO @SchemaName, @TableName, @IncludeModificationTrackingColumns;
END;

CLOSE TableList;

DEALLOCATE TableList;

SET @SQL += N'END;' + @CrLf + @GO;

-- Create the procedure for re-enabling temporal after simulated data load

SET @SQL += N'CREATE PROCEDURE DataLoadSimulation.ReactivateTemporalTablesAfterDataLoad' + @CrLf
          + N'AS BEGIN' + @CrLf
          + @Indent + N'-- Re-enables the temporal nature of the temporal tables after a simulated data load' + @CrLf
          + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf;

SET @SQL += @Indent + N'IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = N''Configuration_ApplyRowLevelSecurity'')' + @CrLf
          + @Indent + N'BEGIN' + @CrLf
          + @Indent + @Indent + N'EXEC [Application].Configuration_ApplyRowLevelSecurity;' + @CrLf
          + @Indent + N'END;' + @CrLf + @CrLf;

DECLARE TableList CURSOR FAST_FORWARD READ_ONLY
FOR
SELECT SchemaName, TableName
FROM Metadata.[Tables]
WHERE IncludeTemporalColumns <> 0
ORDER BY SchemaName, TableName;

OPEN TableList;
FETCH NEXT FROM TableList INTO @SchemaName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL += @Indent + N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName)
                  + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];' + @CrLf
              + @Indent + N'ALTER TABLE ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName)
                  + N' ADD PERIOD FOR SYSTEM_TIME(' + QUOTENAME(@TemporalFromColumnName) + N', '
                  + QUOTENAME(@TemporalToColumnName) + N');' + @CrLf
              + @Indent + N'ALTER TABLE ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName)
                  + N' SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = ' + QUOTENAME(@SchemaName)
                  + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix)
                  + N', DATA_CONSISTENCY_CHECK = ON));' + @CrLf + @CrLf;
    FETCH NEXT FROM TableList INTO @SchemaName, @TableName;
END;

CLOSE TableList;
DEALLOCATE TableList;

SET @SQL += N'END;' + @CrLf + @GO;

SET @SQL += N'USE tempdb;' + @CrLf + @GO;

EXEC dbo.ExecuteOrPrint @SQL, 1, 0, 0, 0;

USE tempdb;
GO
