USE master;
 
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = N'WideWorldImporters')
BEGIN
    ALTER DATABASE WideWorldImporters SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE WideWorldImporters;
END;
GO
 
CREATE DATABASE WideWorldImporters
ON PRIMARY
(
    NAME = WWI_Primary,
    FILENAME = 'D:\Data\WideWorldImporters.mdf',
    SIZE = 1GB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 64MB
),
FILEGROUP USERDATA DEFAULT
(
    NAME = WWI_UserData,
    FILENAME = 'D:\Data\WideWorldImporters_UserData.ndf',
    SIZE = 2GB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 64MB
)
LOG ON
(
    NAME = WWI_Log,
    FILENAME = 'E:\Log\WideWorldImporters.ldf',
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 64MB
);
GO
 
ALTER AUTHORIZATION ON DATABASE::WideWorldImporters to sa;
GO
 
USE WideWorldImporters;
GO
 
ALTER DATABASE CURRENT COLLATE Latin1_General_100_CI_AS;
GO
 
ALTER DATABASE CURRENT SET RECOVERY SIMPLE;
GO
 
ALTER DATABASE CURRENT SET AUTO_UPDATE_STATISTICS_ASYNC ON;
GO
 
ALTER DATABASE CURRENT
SET QUERY_STORE
(
    OPERATION_MODE = READ_WRITE,
    CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),
    DATA_FLUSH_INTERVAL_SECONDS = 3000,
    MAX_STORAGE_SIZE_MB = 500,
    INTERVAL_LENGTH_MINUTES = 15,
    SIZE_BASED_CLEANUP_MODE = AUTO,
    QUERY_CAPTURE_MODE = AUTO,
    MAX_PLANS_PER_QUERY = 1000
);
GO
 
CREATE SCHEMA [Application] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Tables common across the application. Used for categorization and lookup lists, system parameters and people (users and contacts)', @level0type = N'SCHEMA', @level0name = 'Application';
GO
 
CREATE SCHEMA [DataLoadSimulation] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Tables and procedures used only during simulated data loading operations', @level0type = N'SCHEMA', @level0name = 'DataLoadSimulation';
GO
 
CREATE SCHEMA [Integration] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Tables and procedures required for integration with the data warehouse', @level0type = N'SCHEMA', @level0name = 'Integration';
GO
 
CREATE SCHEMA [PowerBI] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Views and stored procedures that provide the only access for the Power BI dashboard system', @level0type = N'SCHEMA', @level0name = 'PowerBI';
GO
 
CREATE SCHEMA [Purchasing] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Details of suppliers and of purchasing of stock items', @level0type = N'SCHEMA', @level0name = 'Purchasing';
GO
 
CREATE SCHEMA [Reports] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Views and stored procedures that provide the only access for the reporting system', @level0type = N'SCHEMA', @level0name = 'Reports';
GO
 
CREATE SCHEMA [Sales] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Details of customers, salespeople, and of sales of stock items', @level0type = N'SCHEMA', @level0name = 'Sales';
GO
 
CREATE SCHEMA [Sequences] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Holds sequences used by all tables in the application', @level0type = N'SCHEMA', @level0name = 'Sequences';
GO
 
CREATE SCHEMA [Warehouse] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Details of stock items, their holdings and transactions', @level0type = N'SCHEMA', @level0name = 'Warehouse';
GO
 
CREATE SCHEMA [Website] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Views and stored procedures that provide the only access for the application website', @level0type = N'SCHEMA', @level0name = 'Website';
GO
 
 
CREATE SEQUENCE [Sequences].[BuyingGroupID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[CityID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[ColorID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[CountryID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[CustomerCategoryID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[CustomerID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[DeliveryMethodID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[InvoiceID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[InvoiceLineID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[OrderID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[OrderLineID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[PackageTypeID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[PaymentMethodID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[PersonID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[PurchaseOrderID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[PurchaseOrderLineID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[SpecialDealID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[StateProvinceID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[StockGroupID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[StockItemID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[StockItemStockGroupID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[SupplierCategoryID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[SupplierID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[SystemParameterID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[TransactionID] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[TransactionTypeID] AS int START WITH 1;
GO
 
CREATE TABLE [Application].[People]
(
    [PersonID] int NOT NULL
        CONSTRAINT [PK_Application_People] PRIMARY KEY
        CONSTRAINT [DF_Application_People_PersonID]
            DEFAULT(NEXT VALUE FOR [Sequences].[PersonID]),
    [FullName] nvarchar(50) NOT NULL,
    [PreferredName] nvarchar(50) NOT NULL,
    [SearchName] AS CONCAT([PreferredName], N' ', [FullName]) PERSISTED,
    [IsPermittedToLogon] bit NOT NULL,
    [LogonName] nvarchar(50) NULL,
    [IsExternalLogonProvider] bit NOT NULL,
    [HashedPassword] varbinary(max) NULL,
    [IsSystemUser] bit NOT NULL,
    [IsEmployee] bit NOT NULL,
    [IsSalesperson] bit NOT NULL,
    [UserPreferences] nvarchar(max) NULL,
    [PhoneNumber] nvarchar(20) NULL,
    [FaxNumber] nvarchar(20) NULL,
    [EmailAddress] nvarchar(256) NULL,
    [Photo] varbinary(max) NULL,
    [CustomFields] nvarchar(max) NULL,
    [OtherLanguages] AS JSON_QUERY([CustomFields], N'$.OtherLanguages'),
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Application_People_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[People_Archive])
);
ALTER INDEX ix_People_Archive ON [Application].[People_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
CREATE INDEX [IX_Application_People_IsEmployee]
ON [Application].[People]([IsEmployee]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating employees', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'INDEX', @level2name = 'IX_Application_People_IsEmployee';
 
CREATE INDEX [IX_Application_People_IsSalesperson]
ON [Application].[People]([IsSalesperson]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating salespeople', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'INDEX', @level2name = 'IX_Application_People_IsSalesperson';
 
CREATE INDEX [IX_Application_People_FullName]
ON [Application].[People]([FullName]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Improves performance of name-related queries', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'INDEX', @level2name = 'IX_Application_People_FullName';
 
CREATE INDEX [IX_Application_People_Perf_20160301_05]
ON [Application].[People]([IsPermittedToLogon],[PersonID])
INCLUDE ([FullName], [EmailAddress]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Improves performance of order picking and invoicing', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'INDEX', @level2name = 'IX_Application_People_Perf_20160301_05';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'People known to the application (staff, customer contacts, supplier contacts)', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a person within the database', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'PersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name for this person', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'FullName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name that this person prefers to be called', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'PreferredName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name to build full text search on (computed column)', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'SearchName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this person permitted to log on?', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'IsPermittedToLogon';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Person''s system logon name', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'LogonName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is logon token provided by an external system?', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'IsExternalLogonProvider';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Hash of password for users without external logon tokens', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'HashedPassword';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is the currently permitted to make online access?', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'IsSystemUser';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this person an employee?', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'IsEmployee';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this person a staff salesperson?', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'IsSalesperson';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'User preferences related to the website (holds JSON data)', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'UserPreferences';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Phone number', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'PhoneNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Fax number  ', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'FaxNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Email address for this person', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'EmailAddress';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Photo of this person', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'Photo';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Custom fields for employees and salespeople', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'CustomFields';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Other languages spoken (computed column from custom fields)', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'People', @level2type = N'COLUMN', @level2name = 'OtherLanguages';
GO
 
CREATE TABLE [Warehouse].[ColdRoomTemperatures]
(
    [ColdRoomTemperatureID] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Warehouse_ColdRoomTemperatures] PRIMARY KEY,
    [ColdRoomSensorNumber] int NOT NULL,
    [RecordedWhen] datetime2(7) NOT NULL,
    [Temperature] decimal(10,2) NOT NULL,
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Warehouse].[ColdRoomTemperatures_Archive])
);
ALTER INDEX ix_ColdRoomTemperatures_Archive ON [Warehouse].[ColdRoomTemperatures_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
CREATE INDEX [IX_Warehouse_ColdRoomTemperatures_ColdRoomSensorNumber]
ON [Warehouse].[ColdRoomTemperatures]([ColdRoomSensorNumber]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating sensors', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'ColdRoomTemperatures', @level2type = N'INDEX', @level2name = 'IX_Warehouse_ColdRoomTemperatures_ColdRoomSensorNumber';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Regularly recorded temperatures of cold room chillers', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'ColdRoomTemperatures';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Instantaneous temperature readings for cold rooms (chillers)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'ColdRoomTemperatures', @level2type = N'COLUMN', @level2name = 'ColdRoomTemperatureID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Cold room sensor number', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'ColdRoomTemperatures', @level2type = N'COLUMN', @level2name = 'ColdRoomSensorNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Time when this temperature recording was taken', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'ColdRoomTemperatures', @level2type = N'COLUMN', @level2name = 'RecordedWhen';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Temperature at the time of recording', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'ColdRoomTemperatures', @level2type = N'COLUMN', @level2name = 'Temperature';
GO
 
CREATE TABLE [Warehouse].[VehicleTemperatures]
(
    [VehicleTemperatureID] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Warehouse_VehicleTemperatures] PRIMARY KEY,
    [VehicleRegistration] nvarchar(20) NOT NULL,
    [ChillerSensorNumber] int NOT NULL,
    [RecordedWhen] datetime2(7) NOT NULL,
    [Temperature] decimal(10,2) NOT NULL,
    [IsCompressed] bit NOT NULL,
    [FullSensorData] nvarchar(1000) NULL,
    [CompressedSensorData] varbinary(max) NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Regularly recorded temperatures of vehicle chillers', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'VehicleTemperatures';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Instantaneous temperature readings for vehicle freezers and chillers', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'VehicleTemperatures', @level2type = N'COLUMN', @level2name = 'VehicleTemperatureID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Vehicle registration number', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'VehicleTemperatures', @level2type = N'COLUMN', @level2name = 'VehicleRegistration';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Cold room sensor number', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'VehicleTemperatures', @level2type = N'COLUMN', @level2name = 'ChillerSensorNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Time when this temperature recording was taken', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'VehicleTemperatures', @level2type = N'COLUMN', @level2name = 'RecordedWhen';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Temperature at the time of recording', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'VehicleTemperatures', @level2type = N'COLUMN', @level2name = 'Temperature';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is the sensor data compressed for archival storage?', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'VehicleTemperatures', @level2type = N'COLUMN', @level2name = 'IsCompressed';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full JSON data received from sensor', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'VehicleTemperatures', @level2type = N'COLUMN', @level2name = 'FullSensorData';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Compressed JSON data for archival purposes', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'VehicleTemperatures', @level2type = N'COLUMN', @level2name = 'CompressedSensorData';
GO
 
CREATE TABLE [Application].[Countries]
(
    [CountryID] int NOT NULL
        CONSTRAINT [PK_Application_Countries] PRIMARY KEY
        CONSTRAINT [DF_Application_Countries_CountryID]
            DEFAULT(NEXT VALUE FOR [Sequences].[CountryID]),
    [CountryName] nvarchar(60) NOT NULL
        CONSTRAINT [UQ_Application_Countries_CountryName] UNIQUE,
    [FormalName] nvarchar(60) NOT NULL
        CONSTRAINT [UQ_Application_Countries_FormalName] UNIQUE,
    [IsoAlpha3Code] nvarchar(3) NULL,
    [IsoNumericCode] int NULL,
    [CountryType] nvarchar(20) NULL,
    [LatestRecordedPopulation] bigint NULL,
    [Continent] nvarchar(30) NOT NULL,
    [Region] nvarchar(30) NOT NULL,
    [Subregion] nvarchar(30) NOT NULL,
    [Border] geography NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Application_Countries_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[Countries_Archive])
);
ALTER INDEX ix_Countries_Archive ON [Application].[Countries_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Countries that contain the states or provinces (including geographic boundaries)', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a country within the database', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'CountryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name of the country', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'CountryName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full formal name of the country as agreed by United Nations', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'FormalName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = '3 letter alphabetic code assigned to the country by ISO', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'IsoAlpha3Code';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric code assigned to the country by ISO', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'IsoNumericCode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of country or administrative region', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'CountryType';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Latest available population for the country', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'LatestRecordedPopulation';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name of the continent', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'Continent';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name of the region', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'Region';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name of the subregion', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'Subregion';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Geographic border of the country as described by the United Nations', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Countries', @level2type = N'COLUMN', @level2name = 'Border';
GO
 
CREATE TABLE [Application].[DeliveryMethods]
(
    [DeliveryMethodID] int NOT NULL
        CONSTRAINT [PK_Application_DeliveryMethods] PRIMARY KEY
        CONSTRAINT [DF_Application_DeliveryMethods_DeliveryMethodID]
            DEFAULT(NEXT VALUE FOR [Sequences].[DeliveryMethodID]),
    [DeliveryMethodName] nvarchar(50) NOT NULL
        CONSTRAINT [UQ_Application_DeliveryMethods_DeliveryMethodName] UNIQUE,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Application_DeliveryMethods_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[DeliveryMethods_Archive])
);
ALTER INDEX ix_DeliveryMethods_Archive ON [Application].[DeliveryMethods_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Ways that stock items can be delivered (ie: truck/van, post, pickup, courier, etc.', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'DeliveryMethods';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a delivery method within the database', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'DeliveryMethods', @level2type = N'COLUMN', @level2name = 'DeliveryMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of methods that can be used for delivery of customer orders', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'DeliveryMethods', @level2type = N'COLUMN', @level2name = 'DeliveryMethodName';
GO
 
CREATE TABLE [Application].[PaymentMethods]
(
    [PaymentMethodID] int NOT NULL
        CONSTRAINT [PK_Application_PaymentMethods] PRIMARY KEY
        CONSTRAINT [DF_Application_PaymentMethods_PaymentMethodID]
            DEFAULT(NEXT VALUE FOR [Sequences].[PaymentMethodID]),
    [PaymentMethodName] nvarchar(50) NOT NULL
        CONSTRAINT [UQ_Application_PaymentMethods_PaymentMethodName] UNIQUE,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Application_PaymentMethods_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[PaymentMethods_Archive])
);
ALTER INDEX ix_PaymentMethods_Archive ON [Application].[PaymentMethods_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Ways that payments can be made (ie: cash, check, EFT, etc.', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'PaymentMethods';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a payment type within the database', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'PaymentMethods', @level2type = N'COLUMN', @level2name = 'PaymentMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of ways that customers can make payments or that suppliers can be paid', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'PaymentMethods', @level2type = N'COLUMN', @level2name = 'PaymentMethodName';
GO
 
CREATE TABLE [Application].[TransactionTypes]
(
    [TransactionTypeID] int NOT NULL
        CONSTRAINT [PK_Application_TransactionTypes] PRIMARY KEY
        CONSTRAINT [DF_Application_TransactionTypes_TransactionTypeID]
            DEFAULT(NEXT VALUE FOR [Sequences].[TransactionTypeID]),
    [TransactionTypeName] nvarchar(50) NOT NULL
        CONSTRAINT [UQ_Application_TransactionTypes_TransactionTypeName] UNIQUE,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Application_TransactionTypes_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[TransactionTypes_Archive])
);
ALTER INDEX ix_TransactionTypes_Archive ON [Application].[TransactionTypes_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Types of customer, supplier, or stock transactions (ie: invoice, credit note, etc.)', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'TransactionTypes';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a transaction type within the database', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'TransactionTypes', @level2type = N'COLUMN', @level2name = 'TransactionTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of the transaction type', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'TransactionTypes', @level2type = N'COLUMN', @level2name = 'TransactionTypeName';
GO
 
CREATE TABLE [Purchasing].[SupplierCategories]
(
    [SupplierCategoryID] int NOT NULL
        CONSTRAINT [PK_Purchasing_SupplierCategories] PRIMARY KEY
        CONSTRAINT [DF_Purchasing_SupplierCategories_SupplierCategoryID]
            DEFAULT(NEXT VALUE FOR [Sequences].[SupplierCategoryID]),
    [SupplierCategoryName] nvarchar(50) NOT NULL
        CONSTRAINT [UQ_Purchasing_SupplierCategories_SupplierCategoryName] UNIQUE,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Purchasing_SupplierCategories_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Purchasing].[SupplierCategories_Archive])
);
ALTER INDEX ix_SupplierCategories_Archive ON [Purchasing].[SupplierCategories_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Categories for suppliers (ie novelties, toys, clothing, packaging, etc.)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierCategories';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a supplier category within the database', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierCategories', @level2type = N'COLUMN', @level2name = 'SupplierCategoryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of the category that suppliers can be assigned to', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierCategories', @level2type = N'COLUMN', @level2name = 'SupplierCategoryName';
GO
 
CREATE TABLE [Sales].[BuyingGroups]
(
    [BuyingGroupID] int NOT NULL
        CONSTRAINT [PK_Sales_BuyingGroups] PRIMARY KEY
        CONSTRAINT [DF_Sales_BuyingGroups_BuyingGroupID]
            DEFAULT(NEXT VALUE FOR [Sequences].[BuyingGroupID]),
    [BuyingGroupName] nvarchar(50) NOT NULL
        CONSTRAINT [UQ_Sales_BuyingGroups_BuyingGroupName] UNIQUE,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Sales_BuyingGroups_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Sales].[BuyingGroups_Archive])
);
ALTER INDEX ix_BuyingGroups_Archive ON [Sales].[BuyingGroups_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Customer organizations can be part of groups that exert greater buying power', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'BuyingGroups';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a buying group within the database', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'BuyingGroups', @level2type = N'COLUMN', @level2name = 'BuyingGroupID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of a buying group that customers can be members of', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'BuyingGroups', @level2type = N'COLUMN', @level2name = 'BuyingGroupName';
GO
 
CREATE TABLE [Sales].[CustomerCategories]
(
    [CustomerCategoryID] int NOT NULL
        CONSTRAINT [PK_Sales_CustomerCategories] PRIMARY KEY
        CONSTRAINT [DF_Sales_CustomerCategories_CustomerCategoryID]
            DEFAULT(NEXT VALUE FOR [Sequences].[CustomerCategoryID]),
    [CustomerCategoryName] nvarchar(50) NOT NULL
        CONSTRAINT [UQ_Sales_CustomerCategories_CustomerCategoryName] UNIQUE,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Sales_CustomerCategories_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Sales].[CustomerCategories_Archive])
);
ALTER INDEX ix_CustomerCategories_Archive ON [Sales].[CustomerCategories_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Categories for customers (ie restaurants, cafes, supermarkets, etc.)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerCategories';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a customer category within the database', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerCategories', @level2type = N'COLUMN', @level2name = 'CustomerCategoryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of the category that customers can be assigned to', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerCategories', @level2type = N'COLUMN', @level2name = 'CustomerCategoryName';
GO
 
CREATE TABLE [Warehouse].[Colors]
(
    [ColorID] int NOT NULL
        CONSTRAINT [PK_Warehouse_Colors] PRIMARY KEY
        CONSTRAINT [DF_Warehouse_Colors_ColorID]
            DEFAULT(NEXT VALUE FOR [Sequences].[ColorID]),
    [ColorName] nvarchar(20) NOT NULL
        CONSTRAINT [UQ_Warehouse_Colors_ColorName] UNIQUE,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Warehouse_Colors_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Warehouse].[Colors_Archive])
);
ALTER INDEX ix_Colors_Archive ON [Warehouse].[Colors_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Stock items can (optionally) have colors', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'Colors';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a color within the database', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'Colors', @level2type = N'COLUMN', @level2name = 'ColorID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of a color that can be used to describe stock items', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'Colors', @level2type = N'COLUMN', @level2name = 'ColorName';
GO
 
CREATE TABLE [Warehouse].[PackageTypes]
(
    [PackageTypeID] int NOT NULL
        CONSTRAINT [PK_Warehouse_PackageTypes] PRIMARY KEY
        CONSTRAINT [DF_Warehouse_PackageTypes_PackageTypeID]
            DEFAULT(NEXT VALUE FOR [Sequences].[PackageTypeID]),
    [PackageTypeName] nvarchar(50) NOT NULL
        CONSTRAINT [UQ_Warehouse_PackageTypes_PackageTypeName] UNIQUE,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Warehouse_PackageTypes_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Warehouse].[PackageTypes_Archive])
);
ALTER INDEX ix_PackageTypes_Archive ON [Warehouse].[PackageTypes_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Ways that stock items can be packaged (ie: each, box, carton, pallet, kg, etc.', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'PackageTypes';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a package type within the database', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'PackageTypes', @level2type = N'COLUMN', @level2name = 'PackageTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of package types that stock items can be purchased in or sold in', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'PackageTypes', @level2type = N'COLUMN', @level2name = 'PackageTypeName';
GO
 
CREATE TABLE [Warehouse].[StockGroups]
(
    [StockGroupID] int NOT NULL
        CONSTRAINT [PK_Warehouse_StockGroups] PRIMARY KEY
        CONSTRAINT [DF_Warehouse_StockGroups_StockGroupID]
            DEFAULT(NEXT VALUE FOR [Sequences].[StockGroupID]),
    [StockGroupName] nvarchar(50) NOT NULL
        CONSTRAINT [UQ_Warehouse_StockGroups_StockGroupName] UNIQUE,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockGroups_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Warehouse].[StockGroups_Archive])
);
ALTER INDEX ix_StockGroups_Archive ON [Warehouse].[StockGroups_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Groups for categorizing stock items (ie: novelties, toys, edible novelties, etc.)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockGroups';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a stock group within the database', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockGroups', @level2type = N'COLUMN', @level2name = 'StockGroupID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of groups used to categorize stock items', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockGroups', @level2type = N'COLUMN', @level2name = 'StockGroupName';
GO
 
CREATE TABLE [Application].[StateProvinces]
(
    [StateProvinceID] int NOT NULL
        CONSTRAINT [PK_Application_StateProvinces] PRIMARY KEY
        CONSTRAINT [DF_Application_StateProvinces_StateProvinceID]
            DEFAULT(NEXT VALUE FOR [Sequences].[StateProvinceID]),
    [StateProvinceCode] nvarchar(5) NOT NULL,
    [StateProvinceName] nvarchar(50) NOT NULL
        CONSTRAINT [UQ_Application_StateProvinces_StateProvinceName] UNIQUE,
    [CountryID] int NOT NULL
        CONSTRAINT [FK_Application_StateProvinces_CountryID_Application_Countries]
            FOREIGN KEY REFERENCES [Application].[Countries] ([CountryID]),
    [SalesTerritory] nvarchar(50) NOT NULL,
    [Border] geography NULL,
    [LatestRecordedPopulation] bigint NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Application_StateProvinces_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[StateProvinces_Archive])
);
ALTER INDEX ix_StateProvinces_Archive ON [Application].[StateProvinces_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
CREATE INDEX [FK_Application_StateProvinces_CountryID]
ON [Application].[StateProvinces] ([CountryID]);
GO
 
CREATE INDEX [IX_Application_StateProvinces_SalesTerritory]
ON [Application].[StateProvinces]([SalesTerritory]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Index used to quickly locate sales territories', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'StateProvinces', @level2type = N'INDEX', @level2name = 'IX_Application_StateProvinces_SalesTerritory';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'States or provinces that contain cities (including geographic location)', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'StateProvinces';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a state or province within the database', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'StateProvinces', @level2type = N'COLUMN', @level2name = 'StateProvinceID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Common code for this state or province (such as WA - Washington for the USA)', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'StateProvinces', @level2type = N'COLUMN', @level2name = 'StateProvinceCode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Formal name of the state or province', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'StateProvinces', @level2type = N'COLUMN', @level2name = 'StateProvinceName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'StateProvinces', @level2type = N'INDEX', @level2name = 'FK_Application_StateProvinces_CountryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Country for this StateProvince', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'StateProvinces', @level2type = N'COLUMN', @level2name = 'CountryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Sales territory for this StateProvince', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'StateProvinces', @level2type = N'COLUMN', @level2name = 'SalesTerritory';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Geographic boundary of the state or province', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'StateProvinces', @level2type = N'COLUMN', @level2name = 'Border';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Latest available population for the StateProvince', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'StateProvinces', @level2type = N'COLUMN', @level2name = 'LatestRecordedPopulation';
GO
 
CREATE TABLE [Application].[Cities]
(
    [CityID] int NOT NULL
        CONSTRAINT [PK_Application_Cities] PRIMARY KEY
        CONSTRAINT [DF_Application_Cities_CityID]
            DEFAULT(NEXT VALUE FOR [Sequences].[CityID]),
    [CityName] nvarchar(50) NOT NULL,
    [StateProvinceID] int NOT NULL
        CONSTRAINT [FK_Application_Cities_StateProvinceID_Application_StateProvinces]
            FOREIGN KEY REFERENCES [Application].[StateProvinces] ([StateProvinceID]),
    [Location] geography NULL,
    [LatestRecordedPopulation] bigint NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Application_Cities_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[Cities_Archive])
);
ALTER INDEX ix_Cities_Archive ON [Application].[Cities_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
CREATE INDEX [FK_Application_Cities_StateProvinceID]
ON [Application].[Cities] ([StateProvinceID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Cities that are part of any address (including geographic location)', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Cities';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a city within the database', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Cities', @level2type = N'COLUMN', @level2name = 'CityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Formal name of the city', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Cities', @level2type = N'COLUMN', @level2name = 'CityName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Cities', @level2type = N'INDEX', @level2name = 'FK_Application_Cities_StateProvinceID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'State or province for this city', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Cities', @level2type = N'COLUMN', @level2name = 'StateProvinceID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Geographic location of the city', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Cities', @level2type = N'COLUMN', @level2name = 'Location';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Latest available population for the City', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'Cities', @level2type = N'COLUMN', @level2name = 'LatestRecordedPopulation';
GO
 
CREATE TABLE [Application].[SystemParameters]
(
    [SystemParameterID] int NOT NULL
        CONSTRAINT [PK_Application_SystemParameters] PRIMARY KEY
        CONSTRAINT [DF_Application_SystemParameters_SystemParameterID]
            DEFAULT(NEXT VALUE FOR [Sequences].[SystemParameterID]),
    [DeliveryAddressLine1] nvarchar(60) NOT NULL,
    [DeliveryAddressLine2] nvarchar(60) NULL,
    [DeliveryCityID] int NOT NULL
        CONSTRAINT [FK_Application_SystemParameters_DeliveryCityID_Application_Cities]
            FOREIGN KEY REFERENCES [Application].[Cities] ([CityID]),
    [DeliveryPostalCode] nvarchar(10) NOT NULL,
    [DeliveryLocation] geography NOT NULL,
    [PostalAddressLine1] nvarchar(60) NOT NULL,
    [PostalAddressLine2] nvarchar(60) NULL,
    [PostalCityID] int NOT NULL
        CONSTRAINT [FK_Application_SystemParameters_PostalCityID_Application_Cities]
            FOREIGN KEY REFERENCES [Application].[Cities] ([CityID]),
    [PostalPostalCode] nvarchar(10) NOT NULL,
    [ApplicationSettings] nvarchar(max) NOT NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Application_SystemParameters_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Application_SystemParameters_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Application_SystemParameters_DeliveryCityID]
ON [Application].[SystemParameters] ([DeliveryCityID]);
CREATE INDEX [FK_Application_SystemParameters_PostalCityID]
ON [Application].[SystemParameters] ([PostalCityID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Any configurable parameters for the whole system', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for row holding system parameters', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'SystemParameterID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'First address line for the company', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'DeliveryAddressLine1';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Second address line for the company', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'DeliveryAddressLine2';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'INDEX', @level2name = 'FK_Application_SystemParameters_DeliveryCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the city for this address', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'DeliveryCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Postal code for the company', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'DeliveryPostalCode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Geographic location for the company office', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'DeliveryLocation';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'First postal address line for the company', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'PostalAddressLine1';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Second postaladdress line for the company', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'PostalAddressLine2';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'INDEX', @level2name = 'FK_Application_SystemParameters_PostalCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the city for this postaladdress', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'PostalCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Postal code for the company when sending via mail', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'PostalPostalCode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'JSON-structured application settings', @level0type = N'SCHEMA', @level0name = 'Application', @level1type = N'TABLE',  @level1name = 'SystemParameters', @level2type = N'COLUMN', @level2name = 'ApplicationSettings';
GO
 
CREATE TABLE [Purchasing].[Suppliers]
(
    [SupplierID] int NOT NULL
        CONSTRAINT [PK_Purchasing_Suppliers] PRIMARY KEY
        CONSTRAINT [DF_Purchasing_Suppliers_SupplierID]
            DEFAULT(NEXT VALUE FOR [Sequences].[SupplierID]),
    [SupplierName] nvarchar(100) NOT NULL
        CONSTRAINT [UQ_Purchasing_Suppliers_SupplierName] UNIQUE,
    [SupplierCategoryID] int NOT NULL
        CONSTRAINT [FK_Purchasing_Suppliers_SupplierCategoryID_Purchasing_SupplierCategories]
            FOREIGN KEY REFERENCES [Purchasing].[SupplierCategories] ([SupplierCategoryID]),
    [PrimaryContactPersonID] int NOT NULL
        CONSTRAINT [FK_Purchasing_Suppliers_PrimaryContactPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [AlternateContactPersonID] int NOT NULL
        CONSTRAINT [FK_Purchasing_Suppliers_AlternateContactPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [DeliveryMethodID] int NULL
        CONSTRAINT [FK_Purchasing_Suppliers_DeliveryMethodID_Application_DeliveryMethods]
            FOREIGN KEY REFERENCES [Application].[DeliveryMethods] ([DeliveryMethodID]),
    [DeliveryCityID] int NOT NULL
        CONSTRAINT [FK_Purchasing_Suppliers_DeliveryCityID_Application_Cities]
            FOREIGN KEY REFERENCES [Application].[Cities] ([CityID]),
    [PostalCityID] int NOT NULL
        CONSTRAINT [FK_Purchasing_Suppliers_PostalCityID_Application_Cities]
            FOREIGN KEY REFERENCES [Application].[Cities] ([CityID]),
    [SupplierReference] nvarchar(20) NULL,
    [BankAccountName] nvarchar(50) NULL,
    [BankAccountBranch] nvarchar(50) NULL,
    [BankAccountCode] nvarchar(20) NULL,
    [BankAccountNumber] nvarchar(20) NULL,
    [BankInternationalCode] nvarchar(20) NULL,
    [PaymentDays] int NOT NULL,
    [InternalComments] nvarchar(max) NULL,
    [PhoneNumber] nvarchar(20) NOT NULL,
    [FaxNumber] nvarchar(20) NOT NULL,
    [WebsiteURL] nvarchar(256) NOT NULL,
    [DeliveryAddressLine1] nvarchar(60) NOT NULL,
    [DeliveryAddressLine2] nvarchar(60) NULL,
    [DeliveryPostalCode] nvarchar(10) NOT NULL,
    [DeliveryLocation] geography NULL,
    [PostalAddressLine1] nvarchar(60) NOT NULL,
    [PostalAddressLine2] nvarchar(60) NULL,
    [PostalPostalCode] nvarchar(10) NOT NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Purchasing_Suppliers_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Purchasing].[Suppliers_Archive])
);
ALTER INDEX ix_Suppliers_Archive ON [Purchasing].[Suppliers_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
CREATE INDEX [FK_Purchasing_Suppliers_SupplierCategoryID]
ON [Purchasing].[Suppliers] ([SupplierCategoryID]);
CREATE INDEX [FK_Purchasing_Suppliers_PrimaryContactPersonID]
ON [Purchasing].[Suppliers] ([PrimaryContactPersonID]);
CREATE INDEX [FK_Purchasing_Suppliers_AlternateContactPersonID]
ON [Purchasing].[Suppliers] ([AlternateContactPersonID]);
CREATE INDEX [FK_Purchasing_Suppliers_DeliveryMethodID]
ON [Purchasing].[Suppliers] ([DeliveryMethodID]);
CREATE INDEX [FK_Purchasing_Suppliers_DeliveryCityID]
ON [Purchasing].[Suppliers] ([DeliveryCityID]);
CREATE INDEX [FK_Purchasing_Suppliers_PostalCityID]
ON [Purchasing].[Suppliers] ([PostalCityID]);
GO
 
ALTER TABLE [Purchasing].[Suppliers]
    ALTER COLUMN [BankAccountName] ADD MASKED WITH (FUNCTION = 'default()');
GO
 
ALTER TABLE [Purchasing].[Suppliers]
    ALTER COLUMN [BankAccountBranch] ADD MASKED WITH (FUNCTION = 'default()');
GO
 
ALTER TABLE [Purchasing].[Suppliers]
    ALTER COLUMN [BankAccountCode] ADD MASKED WITH (FUNCTION = 'default()');
GO
 
ALTER TABLE [Purchasing].[Suppliers]
    ALTER COLUMN [BankAccountNumber] ADD MASKED WITH (FUNCTION = 'default()');
GO
 
ALTER TABLE [Purchasing].[Suppliers]
    ALTER COLUMN [BankInternationalCode] ADD MASKED WITH (FUNCTION = 'default()');
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Main entity table for suppliers (organizations)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a supplier within the database', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'SupplierID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s full name (usually a trading name)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'SupplierName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'INDEX', @level2name = 'FK_Purchasing_Suppliers_SupplierCategoryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s category', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'SupplierCategoryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'INDEX', @level2name = 'FK_Purchasing_Suppliers_PrimaryContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Primary contact', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'PrimaryContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'INDEX', @level2name = 'FK_Purchasing_Suppliers_AlternateContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Alternate contact', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'AlternateContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'INDEX', @level2name = 'FK_Purchasing_Suppliers_DeliveryMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Standard delivery method for stock items received from this supplier', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'DeliveryMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'INDEX', @level2name = 'FK_Purchasing_Suppliers_DeliveryCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the delivery city for this address', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'DeliveryCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'INDEX', @level2name = 'FK_Purchasing_Suppliers_PostalCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the mailing city for this address', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'PostalCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier reference for our organization (might be our account number at the supplier)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'SupplierReference';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s bank account name (ie name on the account)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'BankAccountName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s bank branch', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'BankAccountBranch';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s bank account code (usually a numeric reference for the bank branch)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'BankAccountCode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s bank account number', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'BankAccountNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s bank''s international code (such as a SWIFT code)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'BankInternationalCode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Number of days for payment of an invoice (ie payment terms)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'PaymentDays';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Internal comments (not exposed outside organization)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'InternalComments';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Phone number', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'PhoneNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Fax number  ', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'FaxNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'URL for the website for this supplier', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'WebsiteURL';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'First delivery address line for the supplier', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'DeliveryAddressLine1';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Second delivery address line for the supplier', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'DeliveryAddressLine2';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Delivery postal code for the supplier', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'DeliveryPostalCode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Geographic location for the supplier''s office/warehouse', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'DeliveryLocation';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'First postal address line for the supplier', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'PostalAddressLine1';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Second postal address line for the supplier', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'PostalAddressLine2';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Postal code for the supplier when sending by mail', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'Suppliers', @level2type = N'COLUMN', @level2name = 'PostalPostalCode';
GO
 
CREATE TABLE [Sales].[Customers]
(
    [CustomerID] int NOT NULL
        CONSTRAINT [PK_Sales_Customers] PRIMARY KEY
        CONSTRAINT [DF_Sales_Customers_CustomerID]
            DEFAULT(NEXT VALUE FOR [Sequences].[CustomerID]),
    [CustomerName] nvarchar(100) NOT NULL
        CONSTRAINT [UQ_Sales_Customers_CustomerName] UNIQUE,
    [BillToCustomerID] int NOT NULL
        CONSTRAINT [FK_Sales_Customers_BillToCustomerID_Sales_Customers]
            FOREIGN KEY REFERENCES [Sales].[Customers] ([CustomerID]),
    [CustomerCategoryID] int NOT NULL
        CONSTRAINT [FK_Sales_Customers_CustomerCategoryID_Sales_CustomerCategories]
            FOREIGN KEY REFERENCES [Sales].[CustomerCategories] ([CustomerCategoryID]),
    [BuyingGroupID] int NULL
        CONSTRAINT [FK_Sales_Customers_BuyingGroupID_Sales_BuyingGroups]
            FOREIGN KEY REFERENCES [Sales].[BuyingGroups] ([BuyingGroupID]),
    [PrimaryContactPersonID] int NOT NULL
        CONSTRAINT [FK_Sales_Customers_PrimaryContactPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [AlternateContactPersonID] int NULL
        CONSTRAINT [FK_Sales_Customers_AlternateContactPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [DeliveryMethodID] int NOT NULL
        CONSTRAINT [FK_Sales_Customers_DeliveryMethodID_Application_DeliveryMethods]
            FOREIGN KEY REFERENCES [Application].[DeliveryMethods] ([DeliveryMethodID]),
    [DeliveryCityID] int NOT NULL
        CONSTRAINT [FK_Sales_Customers_DeliveryCityID_Application_Cities]
            FOREIGN KEY REFERENCES [Application].[Cities] ([CityID]),
    [PostalCityID] int NOT NULL
        CONSTRAINT [FK_Sales_Customers_PostalCityID_Application_Cities]
            FOREIGN KEY REFERENCES [Application].[Cities] ([CityID]),
    [CreditLimit] decimal(18,2) NULL,
    [AccountOpenedDate] date NOT NULL,
    [StandardDiscountPercentage] decimal(18,3) NOT NULL,
    [IsStatementSent] bit NOT NULL,
    [IsOnCreditHold] bit NOT NULL,
    [PaymentDays] int NOT NULL,
    [PhoneNumber] nvarchar(20) NOT NULL,
    [FaxNumber] nvarchar(20) NOT NULL,
    [DeliveryRun] nvarchar(5) NULL,
    [RunPosition] nvarchar(5) NULL,
    [WebsiteURL] nvarchar(256) NOT NULL,
    [DeliveryAddressLine1] nvarchar(60) NOT NULL,
    [DeliveryAddressLine2] nvarchar(60) NULL,
    [DeliveryPostalCode] nvarchar(10) NOT NULL,
    [DeliveryLocation] geography NULL,
    [PostalAddressLine1] nvarchar(60) NOT NULL,
    [PostalAddressLine2] nvarchar(60) NULL,
    [PostalPostalCode] nvarchar(10) NOT NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Sales_Customers_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Sales].[Customers_Archive])
);
ALTER INDEX ix_Customers_Archive ON [Sales].[Customers_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
CREATE INDEX [FK_Sales_Customers_CustomerCategoryID]
ON [Sales].[Customers] ([CustomerCategoryID]);
CREATE INDEX [FK_Sales_Customers_BuyingGroupID]
ON [Sales].[Customers] ([BuyingGroupID]);
CREATE INDEX [FK_Sales_Customers_PrimaryContactPersonID]
ON [Sales].[Customers] ([PrimaryContactPersonID]);
CREATE INDEX [FK_Sales_Customers_AlternateContactPersonID]
ON [Sales].[Customers] ([AlternateContactPersonID]);
CREATE INDEX [FK_Sales_Customers_DeliveryMethodID]
ON [Sales].[Customers] ([DeliveryMethodID]);
CREATE INDEX [FK_Sales_Customers_DeliveryCityID]
ON [Sales].[Customers] ([DeliveryCityID]);
CREATE INDEX [FK_Sales_Customers_PostalCityID]
ON [Sales].[Customers] ([PostalCityID]);
GO
 
CREATE INDEX [IX_Sales_Customers_Perf_20160301_06]
ON [Sales].[Customers]([IsOnCreditHold], [CustomerID], [BillToCustomerID])
INCLUDE ([PrimaryContactPersonID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Improves performance of order picking and invoicing', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'INDEX', @level2name = 'IX_Sales_Customers_Perf_20160301_06';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Main entity tables for customers (organizations or individuals)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a customer within the database', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer''s full name (usually a trading name)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'CustomerName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer that this is billed to (usually the same customer but can be another parent company)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'BillToCustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'INDEX', @level2name = 'FK_Sales_Customers_CustomerCategoryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer''s category', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'CustomerCategoryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'INDEX', @level2name = 'FK_Sales_Customers_BuyingGroupID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer''s buying group (optional)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'BuyingGroupID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'INDEX', @level2name = 'FK_Sales_Customers_PrimaryContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Primary contact', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'PrimaryContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'INDEX', @level2name = 'FK_Sales_Customers_AlternateContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Alternate contact', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'AlternateContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'INDEX', @level2name = 'FK_Sales_Customers_DeliveryMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Standard delivery method for stock items sent to this customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'DeliveryMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'INDEX', @level2name = 'FK_Sales_Customers_DeliveryCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the delivery city for this address', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'DeliveryCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'INDEX', @level2name = 'FK_Sales_Customers_PostalCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the postal city for this address', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'PostalCityID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Credit limit for this customer (NULL if unlimited)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'CreditLimit';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date this customer account was opened', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'AccountOpenedDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Standard discount offered to this customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'StandardDiscountPercentage';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is a statement sent to this customer? (Or do they just pay on each invoice?)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'IsStatementSent';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this customer on credit hold? (Prevents further deliveries to this customer)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'IsOnCreditHold';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Number of days for payment of an invoice (ie payment terms)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'PaymentDays';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Phone number', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'PhoneNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Fax number  ', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'FaxNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Normal delivery run for this customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'DeliveryRun';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Normal position in the delivery run for this customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'RunPosition';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'URL for the website for this customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'WebsiteURL';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'First delivery address line for the customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'DeliveryAddressLine1';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Second delivery address line for the customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'DeliveryAddressLine2';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Delivery postal code for the customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'DeliveryPostalCode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Geographic location for the customer''s office/warehouse', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'DeliveryLocation';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'First postal address line for the customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'PostalAddressLine1';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Second postal address line for the customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'PostalAddressLine2';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Postal code for the customer when sending by mail', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Customers', @level2type = N'COLUMN', @level2name = 'PostalPostalCode';
GO
 
CREATE TABLE [Purchasing].[PurchaseOrders]
(
    [PurchaseOrderID] int NOT NULL
        CONSTRAINT [PK_Purchasing_PurchaseOrders] PRIMARY KEY
        CONSTRAINT [DF_Purchasing_PurchaseOrders_PurchaseOrderID]
            DEFAULT(NEXT VALUE FOR [Sequences].[PurchaseOrderID]),
    [SupplierID] int NOT NULL
        CONSTRAINT [FK_Purchasing_PurchaseOrders_SupplierID_Purchasing_Suppliers]
            FOREIGN KEY REFERENCES [Purchasing].[Suppliers] ([SupplierID]),
    [OrderDate] date NOT NULL,
    [DeliveryMethodID] int NOT NULL
        CONSTRAINT [FK_Purchasing_PurchaseOrders_DeliveryMethodID_Application_DeliveryMethods]
            FOREIGN KEY REFERENCES [Application].[DeliveryMethods] ([DeliveryMethodID]),
    [ContactPersonID] int NOT NULL
        CONSTRAINT [FK_Purchasing_PurchaseOrders_ContactPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ExpectedDeliveryDate] date NULL,
    [SupplierReference] nvarchar(20) NULL,
    [IsOrderFinalized] bit NOT NULL,
    [Comments] nvarchar(max) NULL,
    [InternalComments] nvarchar(max) NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Purchasing_PurchaseOrders_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Purchasing_PurchaseOrders_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Purchasing_PurchaseOrders_SupplierID]
ON [Purchasing].[PurchaseOrders] ([SupplierID]);
CREATE INDEX [FK_Purchasing_PurchaseOrders_DeliveryMethodID]
ON [Purchasing].[PurchaseOrders] ([DeliveryMethodID]);
CREATE INDEX [FK_Purchasing_PurchaseOrders_ContactPersonID]
ON [Purchasing].[PurchaseOrders] ([ContactPersonID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Details of supplier purchase orders', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a purchase order within the database', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'COLUMN', @level2name = 'PurchaseOrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'INDEX', @level2name = 'FK_Purchasing_PurchaseOrders_SupplierID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier for this purchase order', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'COLUMN', @level2name = 'SupplierID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date that this purchase order was raised', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'COLUMN', @level2name = 'OrderDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'INDEX', @level2name = 'FK_Purchasing_PurchaseOrders_DeliveryMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'How this purchase order should be delivered', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'COLUMN', @level2name = 'DeliveryMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'INDEX', @level2name = 'FK_Purchasing_PurchaseOrders_ContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'The person who is the primary contact for this purchase order', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'COLUMN', @level2name = 'ContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Expected delivery date for this purchase order', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'COLUMN', @level2name = 'ExpectedDeliveryDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier reference for our organization (might be our account number at the supplier)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'COLUMN', @level2name = 'SupplierReference';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this purchase order now considered finalized?', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'COLUMN', @level2name = 'IsOrderFinalized';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Any comments related this purchase order (comments sent to the supplier)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'COLUMN', @level2name = 'Comments';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Any internal comments related this purchase order (comments for internal reference only and not sent to the supplier)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrders', @level2type = N'COLUMN', @level2name = 'InternalComments';
GO
 
CREATE TABLE [Sales].[Orders]
(
    [OrderID] int NOT NULL
        CONSTRAINT [PK_Sales_Orders] PRIMARY KEY
        CONSTRAINT [DF_Sales_Orders_OrderID]
            DEFAULT(NEXT VALUE FOR [Sequences].[OrderID]),
    [CustomerID] int NOT NULL
        CONSTRAINT [FK_Sales_Orders_CustomerID_Sales_Customers]
            FOREIGN KEY REFERENCES [Sales].[Customers] ([CustomerID]),
    [SalespersonPersonID] int NOT NULL
        CONSTRAINT [FK_Sales_Orders_SalespersonPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [PickedByPersonID] int NULL
        CONSTRAINT [FK_Sales_Orders_PickedByPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ContactPersonID] int NOT NULL
        CONSTRAINT [FK_Sales_Orders_ContactPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [BackorderOrderID] int NULL
        CONSTRAINT [FK_Sales_Orders_BackorderOrderID_Sales_Orders]
            FOREIGN KEY REFERENCES [Sales].[Orders] ([OrderID]),
    [OrderDate] date NOT NULL,
    [ExpectedDeliveryDate] date NOT NULL,
    [CustomerPurchaseOrderNumber] nvarchar(20) NULL,
    [IsUndersupplyBackordered] bit NOT NULL,
    [Comments] nvarchar(max) NULL,
    [DeliveryInstructions] nvarchar(max) NULL,
    [InternalComments] nvarchar(max) NULL,
    [PickingCompletedWhen] datetime2(7) NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Sales_Orders_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Sales_Orders_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Sales_Orders_CustomerID]
ON [Sales].[Orders] ([CustomerID]);
CREATE INDEX [FK_Sales_Orders_SalespersonPersonID]
ON [Sales].[Orders] ([SalespersonPersonID]);
CREATE INDEX [FK_Sales_Orders_PickedByPersonID]
ON [Sales].[Orders] ([PickedByPersonID]);
CREATE INDEX [FK_Sales_Orders_ContactPersonID]
ON [Sales].[Orders] ([ContactPersonID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Detail of customer orders', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to an order within the database', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'OrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'INDEX', @level2name = 'FK_Sales_Orders_CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer for this order', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'INDEX', @level2name = 'FK_Sales_Orders_SalespersonPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Salesperson for this order', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'SalespersonPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'INDEX', @level2name = 'FK_Sales_Orders_PickedByPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Person who picked this shipment', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'PickedByPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'INDEX', @level2name = 'FK_Sales_Orders_ContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer contact for this order', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'ContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'If this order is a backorder, this column holds the original order number', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'BackorderOrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date that this order was raised', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'OrderDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Expected delivery date', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'ExpectedDeliveryDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase Order Number received from customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'CustomerPurchaseOrderNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'If items cannot be supplied are they backordered?', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'IsUndersupplyBackordered';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Any comments related to this order (sent to customer)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'Comments';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Any comments related to order delivery (sent to customer)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'DeliveryInstructions';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Any internal comments related to this order (not sent to the customer)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'InternalComments';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'When was picking of the entire order completed?', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Orders', @level2type = N'COLUMN', @level2name = 'PickingCompletedWhen';
GO
 
CREATE TABLE [Warehouse].[StockItems]
(
    [StockItemID] int NOT NULL
        CONSTRAINT [PK_Warehouse_StockItems] PRIMARY KEY
        CONSTRAINT [DF_Warehouse_StockItems_StockItemID]
            DEFAULT(NEXT VALUE FOR [Sequences].[StockItemID]),
    [StockItemName] nvarchar(100) NOT NULL
        CONSTRAINT [UQ_Warehouse_StockItems_StockItemName] UNIQUE,
    [SupplierID] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItems_SupplierID_Purchasing_Suppliers]
            FOREIGN KEY REFERENCES [Purchasing].[Suppliers] ([SupplierID]),
    [ColorID] int NULL
        CONSTRAINT [FK_Warehouse_StockItems_ColorID_Warehouse_Colors]
            FOREIGN KEY REFERENCES [Warehouse].[Colors] ([ColorID]),
    [UnitPackageID] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItems_UnitPackageID_Warehouse_PackageTypes]
            FOREIGN KEY REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID]),
    [OuterPackageID] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItems_OuterPackageID_Warehouse_PackageTypes]
            FOREIGN KEY REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID]),
    [Brand] nvarchar(50) NULL,
    [Size] nvarchar(20) NULL,
    [LeadTimeDays] int NOT NULL,
    [QuantityPerOuter] int NOT NULL,
    [IsChillerStock] bit NOT NULL,
    [Barcode] nvarchar(50) NULL,
    [TaxRate] decimal(18,3) NOT NULL,
    [UnitPrice] decimal(18,2) NOT NULL,
    [RecommendedRetailPrice] decimal(18,2) NULL,
    [TypicalWeightPerUnit] decimal(18,3) NOT NULL,
    [MarketingComments] nvarchar(max) NULL,
    [InternalComments] nvarchar(max) NULL,
    [Photo] varbinary(max) NULL,
    [CustomFields] nvarchar(max) NULL,
    [Tags] AS JSON_QUERY([CustomFields], N'$.Tags'),
    [SearchDetails] AS CONCAT([StockItemName], N' ', [MarketingComments]),
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItems_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [ValidFrom] datetime2(7) GENERATED ALWAYS AS ROW START,
    [ValidTo] datetime2(7) GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME ([ValidFrom],[ValidTo])
)
WITH
(
    SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Warehouse].[StockItems_Archive])
);
ALTER INDEX ix_StockItems_Archive ON [Warehouse].[StockItems_Archive] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = NONE);
GO
 
CREATE INDEX [FK_Warehouse_StockItems_SupplierID]
ON [Warehouse].[StockItems] ([SupplierID]);
CREATE INDEX [FK_Warehouse_StockItems_ColorID]
ON [Warehouse].[StockItems] ([ColorID]);
CREATE INDEX [FK_Warehouse_StockItems_UnitPackageID]
ON [Warehouse].[StockItems] ([UnitPackageID]);
CREATE INDEX [FK_Warehouse_StockItems_OuterPackageID]
ON [Warehouse].[StockItems] ([OuterPackageID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Main entity table for stock items', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a stock item within the database', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of a stock item (but not a full description)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'StockItemName';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'INDEX', @level2name = 'FK_Warehouse_StockItems_SupplierID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Usual supplier for this stock item', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'SupplierID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'INDEX', @level2name = 'FK_Warehouse_StockItems_ColorID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Color (optional) for this stock item', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'ColorID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'INDEX', @level2name = 'FK_Warehouse_StockItems_UnitPackageID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Usual package for selling units of this stock item', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'UnitPackageID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'INDEX', @level2name = 'FK_Warehouse_StockItems_OuterPackageID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Usual package for selling outers of this stock item (ie cartons, boxes, etc.)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'OuterPackageID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Brand for the stock item (if the item is branded)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'Brand';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Size of this item (eg: 100mm)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'Size';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Number of days typically taken from order to receipt of this stock item', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'LeadTimeDays';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of the stock item in an outer package', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'QuantityPerOuter';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Does this stock item need to be in a chiller?', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'IsChillerStock';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Barcode for this stock item', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'Barcode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax rate to be applied', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'TaxRate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Selling price (ex-tax) for one unit of this product', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'UnitPrice';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Recommended retail price for this stock item', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'RecommendedRetailPrice';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Typical weight for one unit of this product (packaged)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'TypicalWeightPerUnit';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Marketing comments for this stock item (shared outside the organization)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'MarketingComments';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Internal comments (not exposed outside organization)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'InternalComments';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Photo of the product', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'Photo';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Custom fields added by system users', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'CustomFields';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Advertising tags associated with this stock item (JSON array retrieved from CustomFields)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'Tags';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Combination of columns used by full text search', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItems', @level2type = N'COLUMN', @level2name = 'SearchDetails';
GO
 
CREATE TABLE [Warehouse].[StockItemHoldings]
(
    [StockItemID] int NOT NULL
        CONSTRAINT [PK_Warehouse_StockItemHoldings] PRIMARY KEY
        CONSTRAINT [PKFK_Warehouse_StockItemHoldings_StockItemID_Warehouse_StockItems]
            FOREIGN KEY REFERENCES [Warehouse].[StockItems] ([StockItemID]),
    [QuantityOnHand] int NOT NULL,
    [BinLocation] nvarchar(20) NOT NULL,
    [LastStocktakeQuantity] int NOT NULL,
    [LastCostPrice] decimal(18,2) NOT NULL,
    [ReorderLevel] int NOT NULL,
    [TargetStockLevel] int NOT NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItemHoldings_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Warehouse_StockItemHoldings_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Non-temporal attributes for stock items', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemHoldings';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the stock item that this holding relates to (this table holds non-temporal columns for stock)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemHoldings', @level2type = N'COLUMN', @level2name = 'StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity currently on hand (if tracked)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemHoldings', @level2type = N'COLUMN', @level2name = 'QuantityOnHand';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bin location (ie location of this stock item within the depot)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemHoldings', @level2type = N'COLUMN', @level2name = 'BinLocation';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity at last stocktake (if tracked)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemHoldings', @level2type = N'COLUMN', @level2name = 'LastStocktakeQuantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Unit cost price the last time this stock item was purchased', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemHoldings', @level2type = N'COLUMN', @level2name = 'LastCostPrice';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity below which reordering should take place', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemHoldings', @level2type = N'COLUMN', @level2name = 'ReorderLevel';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Typical quantity ordered', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemHoldings', @level2type = N'COLUMN', @level2name = 'TargetStockLevel';
GO
 
CREATE TABLE [Purchasing].[PurchaseOrderLines]
(
    [PurchaseOrderLineID] int NOT NULL
        CONSTRAINT [PK_Purchasing_PurchaseOrderLines] PRIMARY KEY
        CONSTRAINT [DF_Purchasing_PurchaseOrderLines_PurchaseOrderLineID]
            DEFAULT(NEXT VALUE FOR [Sequences].[PurchaseOrderLineID]),
    [PurchaseOrderID] int NOT NULL
        CONSTRAINT [FK_Purchasing_PurchaseOrderLines_PurchaseOrderID_Purchasing_PurchaseOrders]
            FOREIGN KEY REFERENCES [Purchasing].[PurchaseOrders] ([PurchaseOrderID]),
    [StockItemID] int NOT NULL
        CONSTRAINT [FK_Purchasing_PurchaseOrderLines_StockItemID_Warehouse_StockItems]
            FOREIGN KEY REFERENCES [Warehouse].[StockItems] ([StockItemID]),
    [OrderedOuters] int NOT NULL,
    [Description] nvarchar(100) NOT NULL,
    [ReceivedOuters] int NOT NULL,
    [PackageTypeID] int NOT NULL
        CONSTRAINT [FK_Purchasing_PurchaseOrderLines_PackageTypeID_Warehouse_PackageTypes]
            FOREIGN KEY REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID]),
    [ExpectedUnitPricePerOuter] decimal(18,2) NULL,
    [LastReceiptDate] date NULL,
    [IsOrderLineFinalized] bit NOT NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Purchasing_PurchaseOrderLines_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Purchasing_PurchaseOrderLines_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Purchasing_PurchaseOrderLines_PurchaseOrderID]
ON [Purchasing].[PurchaseOrderLines] ([PurchaseOrderID]);
CREATE INDEX [FK_Purchasing_PurchaseOrderLines_StockItemID]
ON [Purchasing].[PurchaseOrderLines] ([StockItemID]);
CREATE INDEX [FK_Purchasing_PurchaseOrderLines_PackageTypeID]
ON [Purchasing].[PurchaseOrderLines] ([PackageTypeID]);
GO
 
CREATE INDEX [IX_Purchasing_PurchaseOrderLines_Perf_20160301_4]
ON [Purchasing].[PurchaseOrderLines]([IsOrderLineFinalized], [StockItemID])
INCLUDE ([OrderedOuters], [ReceivedOuters]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Improves performance of order picking and invoicing', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'INDEX', @level2name = 'IX_Purchasing_PurchaseOrderLines_Perf_20160301_4';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Detail lines from supplier purchase orders', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a line on a purchase order within the database', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'COLUMN', @level2name = 'PurchaseOrderLineID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'INDEX', @level2name = 'FK_Purchasing_PurchaseOrderLines_PurchaseOrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase order that this line is associated with', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'COLUMN', @level2name = 'PurchaseOrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'INDEX', @level2name = 'FK_Purchasing_PurchaseOrderLines_StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this purchase order line', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'COLUMN', @level2name = 'StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of the stock item that is ordered', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'COLUMN', @level2name = 'OrderedOuters';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Description of the item to be supplied (Often the stock item name but could be supplier description)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'COLUMN', @level2name = 'Description';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total quantity of the stock item that has been received so far', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'COLUMN', @level2name = 'ReceivedOuters';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'INDEX', @level2name = 'FK_Purchasing_PurchaseOrderLines_PackageTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of package received', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'COLUMN', @level2name = 'PackageTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'The unit price that we expect to be charged', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'COLUMN', @level2name = 'ExpectedUnitPricePerOuter';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'The last date on which this stock item was received for this purchase order', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'COLUMN', @level2name = 'LastReceiptDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this purchase order line now considered finalized? (Receipted quantities and weights are often not precise)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'PurchaseOrderLines', @level2type = N'COLUMN', @level2name = 'IsOrderLineFinalized';
GO
 
CREATE TABLE [Purchasing].[SupplierTransactions]
(
    [SupplierTransactionID] int NOT NULL
        CONSTRAINT [PK_Purchasing_SupplierTransactions] PRIMARY KEY
        CONSTRAINT [DF_Purchasing_SupplierTransactions_SupplierTransactionID]
            DEFAULT(NEXT VALUE FOR [Sequences].[TransactionID]),
    [SupplierID] int NOT NULL
        CONSTRAINT [FK_Purchasing_SupplierTransactions_SupplierID_Purchasing_Suppliers]
            FOREIGN KEY REFERENCES [Purchasing].[Suppliers] ([SupplierID]),
    [TransactionTypeID] int NOT NULL
        CONSTRAINT [FK_Purchasing_SupplierTransactions_TransactionTypeID_Application_TransactionTypes]
            FOREIGN KEY REFERENCES [Application].[TransactionTypes] ([TransactionTypeID]),
    [PurchaseOrderID] int NULL
        CONSTRAINT [FK_Purchasing_SupplierTransactions_PurchaseOrderID_Purchasing_PurchaseOrders]
            FOREIGN KEY REFERENCES [Purchasing].[PurchaseOrders] ([PurchaseOrderID]),
    [PaymentMethodID] int NULL
        CONSTRAINT [FK_Purchasing_SupplierTransactions_PaymentMethodID_Application_PaymentMethods]
            FOREIGN KEY REFERENCES [Application].[PaymentMethods] ([PaymentMethodID]),
    [SupplierInvoiceNumber] nvarchar(20) NULL,
    [TransactionDate] date NOT NULL,
    [AmountExcludingTax] decimal(18,2) NOT NULL,
    [TaxAmount] decimal(18,2) NOT NULL,
    [TransactionAmount] decimal(18,2) NOT NULL,
    [OutstandingBalance] decimal(18,2) NOT NULL,
    [FinalizationDate] date NULL,
    [IsFinalized] AS CASE WHEN [FinalizationDate] IS NULL THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END PERSISTED,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Purchasing_SupplierTransactions_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Purchasing_SupplierTransactions_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Purchasing_SupplierTransactions_SupplierID]
ON [Purchasing].[SupplierTransactions] ([SupplierID]);
CREATE INDEX [FK_Purchasing_SupplierTransactions_TransactionTypeID]
ON [Purchasing].[SupplierTransactions] ([TransactionTypeID]);
CREATE INDEX [FK_Purchasing_SupplierTransactions_PurchaseOrderID]
ON [Purchasing].[SupplierTransactions] ([PurchaseOrderID]);
CREATE INDEX [FK_Purchasing_SupplierTransactions_PaymentMethodID]
ON [Purchasing].[SupplierTransactions] ([PaymentMethodID]);
GO
 
CREATE INDEX [IX_Purchasing_SupplierTransactions_IsFinalized]
ON [Purchasing].[SupplierTransactions]([IsFinalized]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Index used to quickly locate unfinalized transactions', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'INDEX', @level2name = 'IX_Purchasing_SupplierTransactions_IsFinalized';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'All financial transactions that are supplier-related', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used to refer to a supplier transaction within the database', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'SupplierTransactionID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'INDEX', @level2name = 'FK_Purchasing_SupplierTransactions_SupplierID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier for this transaction', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'SupplierID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'INDEX', @level2name = 'FK_Purchasing_SupplierTransactions_TransactionTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of transaction', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'TransactionTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'INDEX', @level2name = 'FK_Purchasing_SupplierTransactions_PurchaseOrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of an purchase order (for transactions associated with a purchase order)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'PurchaseOrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'INDEX', @level2name = 'FK_Purchasing_SupplierTransactions_PaymentMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of a payment method (for transactions involving payments)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'PaymentMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Invoice number for an invoice received from the supplier', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'SupplierInvoiceNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date for the transaction', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'TransactionDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Transaction amount (excluding tax)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'AmountExcludingTax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax amount calculated', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'TaxAmount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Transaction amount (including tax)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'TransactionAmount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Amount still outstanding for this transaction', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'OutstandingBalance';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date that this transaction was finalized (if it has been)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'FinalizationDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this transaction finalized (invoices, credits and payments have been matched)', @level0type = N'SCHEMA', @level0name = 'Purchasing', @level1type = N'TABLE',  @level1name = 'SupplierTransactions', @level2type = N'COLUMN', @level2name = 'IsFinalized';
GO
 
CREATE TABLE [Sales].[SpecialDeals]
(
    [SpecialDealID] int NOT NULL
        CONSTRAINT [PK_Sales_SpecialDeals] PRIMARY KEY
        CONSTRAINT [DF_Sales_SpecialDeals_SpecialDealID]
            DEFAULT(NEXT VALUE FOR [Sequences].[SpecialDealID]),
    [StockItemID] int NULL
        CONSTRAINT [FK_Sales_SpecialDeals_StockItemID_Warehouse_StockItems]
            FOREIGN KEY REFERENCES [Warehouse].[StockItems] ([StockItemID]),
    [CustomerID] int NULL
        CONSTRAINT [FK_Sales_SpecialDeals_CustomerID_Sales_Customers]
            FOREIGN KEY REFERENCES [Sales].[Customers] ([CustomerID]),
    [BuyingGroupID] int NULL
        CONSTRAINT [FK_Sales_SpecialDeals_BuyingGroupID_Sales_BuyingGroups]
            FOREIGN KEY REFERENCES [Sales].[BuyingGroups] ([BuyingGroupID]),
    [CustomerCategoryID] int NULL
        CONSTRAINT [FK_Sales_SpecialDeals_CustomerCategoryID_Sales_CustomerCategories]
            FOREIGN KEY REFERENCES [Sales].[CustomerCategories] ([CustomerCategoryID]),
    [StockGroupID] int NULL
        CONSTRAINT [FK_Sales_SpecialDeals_StockGroupID_Warehouse_StockGroups]
            FOREIGN KEY REFERENCES [Warehouse].[StockGroups] ([StockGroupID]),
    [DealDescription] nvarchar(30) NOT NULL,
    [StartDate] date NOT NULL,
    [EndDate] date NOT NULL,
    [DiscountAmount] decimal(18,2) NULL,
    [DiscountPercentage] decimal(18,3) NULL,
    [UnitPrice] decimal(18,2) NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Sales_SpecialDeals_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Sales_SpecialDeals_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Sales_SpecialDeals_StockItemID]
ON [Sales].[SpecialDeals] ([StockItemID]);
CREATE INDEX [FK_Sales_SpecialDeals_CustomerID]
ON [Sales].[SpecialDeals] ([CustomerID]);
CREATE INDEX [FK_Sales_SpecialDeals_BuyingGroupID]
ON [Sales].[SpecialDeals] ([BuyingGroupID]);
CREATE INDEX [FK_Sales_SpecialDeals_CustomerCategoryID]
ON [Sales].[SpecialDeals] ([CustomerCategoryID]);
CREATE INDEX [FK_Sales_SpecialDeals_StockGroupID]
ON [Sales].[SpecialDeals] ([StockGroupID]);
GO
 
ALTER TABLE [Sales].[SpecialDeals]
    ADD CONSTRAINT [CK_Sales_SpecialDeals_Exactly_One_NOT_NULL_Pricing_Option_Is_Required]
         CHECK ((CASE WHEN DiscountAmount IS NULL THEN 0 ELSE 1 END + CASE WHEN DiscountPercentage IS NULL THEN 0 ELSE 1 END + CASE WHEN UnitPrice IS NULL THEN 0 ELSE 1 END) = 1);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Ensures that each special price row contains one and only one of DiscountAmount, DiscountPercentage, and UnitPrice', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'CONSTRAINT', @level2name = 'CK_Sales_SpecialDeals_Exactly_One_NOT_NULL_Pricing_Option_Is_Required';
GO
 
ALTER TABLE [Sales].[SpecialDeals]
    ADD CONSTRAINT [CK_Sales_SpecialDeals_Unit_Price_Deal_Requires_Special_StockItem]
         CHECK (([StockItemID] IS NOT NULL AND [UnitPrice] IS NOT NULL) OR ([UnitPrice] IS NULL));
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Ensures that if a specific price is allocated that it applies to a specific stock item', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'CONSTRAINT', @level2name = 'CK_Sales_SpecialDeals_Unit_Price_Deal_Requires_Special_StockItem';
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Special pricing (can include fixed prices, discount $ or discount %)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID (sequence based) for a special deal', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'SpecialDealID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'INDEX', @level2name = 'FK_Sales_SpecialDeals_StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item that the deal applies to (if NULL, then only discounts are permitted not unit prices)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'INDEX', @level2name = 'FK_Sales_SpecialDeals_CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the customer that the special pricing applies to (if NULL then all customers)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'INDEX', @level2name = 'FK_Sales_SpecialDeals_BuyingGroupID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the buying group that the special pricing applies to (optional)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'BuyingGroupID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'INDEX', @level2name = 'FK_Sales_SpecialDeals_CustomerCategoryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the customer category that the special pricing applies to (optional)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'CustomerCategoryID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'INDEX', @level2name = 'FK_Sales_SpecialDeals_StockGroupID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of the stock group that the special pricing applies to (optional)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'StockGroupID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Description of the special deal', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'DealDescription';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date that the special pricing starts from', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'StartDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date that the special pricing ends on', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'EndDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Discount per unit to be applied to sale price (optional)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'DiscountAmount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Discount percentage per unit to be applied to sale price (optional)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'DiscountPercentage';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Special price per unit to be applied instead of sale price (optional)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'SpecialDeals', @level2type = N'COLUMN', @level2name = 'UnitPrice';
GO
 
CREATE TABLE [Sales].[Invoices]
(
    [InvoiceID] int NOT NULL
        CONSTRAINT [PK_Sales_Invoices] PRIMARY KEY
        CONSTRAINT [DF_Sales_Invoices_InvoiceID]
            DEFAULT(NEXT VALUE FOR [Sequences].[InvoiceID]),
    [CustomerID] int NOT NULL
        CONSTRAINT [FK_Sales_Invoices_CustomerID_Sales_Customers]
            FOREIGN KEY REFERENCES [Sales].[Customers] ([CustomerID]),
    [BillToCustomerID] int NOT NULL
        CONSTRAINT [FK_Sales_Invoices_BillToCustomerID_Sales_Customers]
            FOREIGN KEY REFERENCES [Sales].[Customers] ([CustomerID]),
    [OrderID] int NULL
        CONSTRAINT [FK_Sales_Invoices_OrderID_Sales_Orders]
            FOREIGN KEY REFERENCES [Sales].[Orders] ([OrderID]),
    [DeliveryMethodID] int NOT NULL
        CONSTRAINT [FK_Sales_Invoices_DeliveryMethodID_Application_DeliveryMethods]
            FOREIGN KEY REFERENCES [Application].[DeliveryMethods] ([DeliveryMethodID]),
    [ContactPersonID] int NOT NULL
        CONSTRAINT [FK_Sales_Invoices_ContactPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [AccountsPersonID] int NOT NULL
        CONSTRAINT [FK_Sales_Invoices_AccountsPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [SalespersonPersonID] int NOT NULL
        CONSTRAINT [FK_Sales_Invoices_SalespersonPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [PackedByPersonID] int NOT NULL
        CONSTRAINT [FK_Sales_Invoices_PackedByPersonID_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [InvoiceDate] date NOT NULL,
    [CustomerPurchaseOrderNumber] nvarchar(20) NULL,
    [IsCreditNote] bit NOT NULL,
    [CreditNoteReason] nvarchar(max) NULL,
    [Comments] nvarchar(max) NULL,
    [DeliveryInstructions] nvarchar(max) NULL,
    [InternalComments] nvarchar(max) NULL,
    [TotalDryItems] int NOT NULL,
    [TotalChillerItems] int NOT NULL,
    [DeliveryRun] nvarchar(5) NULL,
    [RunPosition] nvarchar(5) NULL,
    [ReturnedDeliveryData] nvarchar(max) NULL,
    [ConfirmedDeliveryTime] AS TRY_CONVERT(datetime2(7),JSON_VALUE([ReturnedDeliveryData], N'$.DeliveredWhen'), 126),
    [ConfirmedReceivedBy] AS JSON_VALUE([ReturnedDeliveryData], N'$.ReceivedBy'),
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Sales_Invoices_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Sales_Invoices_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Sales_Invoices_CustomerID]
ON [Sales].[Invoices] ([CustomerID]);
CREATE INDEX [FK_Sales_Invoices_BillToCustomerID]
ON [Sales].[Invoices] ([BillToCustomerID]);
CREATE INDEX [FK_Sales_Invoices_OrderID]
ON [Sales].[Invoices] ([OrderID]);
CREATE INDEX [FK_Sales_Invoices_DeliveryMethodID]
ON [Sales].[Invoices] ([DeliveryMethodID]);
CREATE INDEX [FK_Sales_Invoices_ContactPersonID]
ON [Sales].[Invoices] ([ContactPersonID]);
CREATE INDEX [FK_Sales_Invoices_AccountsPersonID]
ON [Sales].[Invoices] ([AccountsPersonID]);
CREATE INDEX [FK_Sales_Invoices_SalespersonPersonID]
ON [Sales].[Invoices] ([SalespersonPersonID]);
CREATE INDEX [FK_Sales_Invoices_PackedByPersonID]
ON [Sales].[Invoices] ([PackedByPersonID]);
GO
 
ALTER TABLE [Sales].[Invoices]
    ADD CONSTRAINT [CK_Sales_Invoices_ReturnedDeliveryData_Must_Be_Valid_JSON]
         CHECK (ReturnedDeliveryData IS NULL OR ISJSON(ReturnedDeliveryData) <> 0);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Ensures that if returned delivery data is present that it is valid JSON', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'CONSTRAINT', @level2name = 'CK_Sales_Invoices_ReturnedDeliveryData_Must_Be_Valid_JSON';
GO
 
CREATE INDEX [IX_Sales_Invoices_ConfirmedDeliveryTime]
ON [Sales].[Invoices]([ConfirmedDeliveryTime])
INCLUDE ([ConfirmedReceivedBy]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quick retrieval of invoices confirmed to have been delivered in a given time period', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'INDEX', @level2name = 'IX_Sales_Invoices_ConfirmedDeliveryTime';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Details of customer invoices', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to an invoice within the database', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'InvoiceID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'INDEX', @level2name = 'FK_Sales_Invoices_CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer for this invoice', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'INDEX', @level2name = 'FK_Sales_Invoices_BillToCustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bill to customer for this invoice (invoices might be billed to a head office)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'BillToCustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'INDEX', @level2name = 'FK_Sales_Invoices_OrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Sales order (if any) for this invoice', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'OrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'INDEX', @level2name = 'FK_Sales_Invoices_DeliveryMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'How these stock items are beign delivered', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'DeliveryMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'INDEX', @level2name = 'FK_Sales_Invoices_ContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer contact for this invoice', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'ContactPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'INDEX', @level2name = 'FK_Sales_Invoices_AccountsPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer accounts contact for this invoice', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'AccountsPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'INDEX', @level2name = 'FK_Sales_Invoices_SalespersonPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Salesperson for this invoice', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'SalespersonPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'INDEX', @level2name = 'FK_Sales_Invoices_PackedByPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Person who packed this shipment (or checked the packing)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'PackedByPersonID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date that this invoice was raised', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'InvoiceDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase Order Number received from customer', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'CustomerPurchaseOrderNumber';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this a credit note (rather than an invoice)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'IsCreditNote';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Reason that this credit note needed to be generated (if applicable)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'CreditNoteReason';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Any comments related to this invoice (sent to customer)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'Comments';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Any comments related to delivery (sent to customer)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'DeliveryInstructions';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Any internal comments related to this invoice (not sent to the customer)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'InternalComments';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total number of dry packages (information for the delivery driver)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'TotalDryItems';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total number of chiller packages (information for the delivery driver)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'TotalChillerItems';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Delivery run for this shipment', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'DeliveryRun';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Position in the delivery run for this shipment', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'RunPosition';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'JSON-structured data returned from delivery devices for deliveries made directly by the organization', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'ReturnedDeliveryData';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Confirmed delivery date and time promoted from JSON delivery data', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'ConfirmedDeliveryTime';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Confirmed receiver promoted from JSON delivery data', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'Invoices', @level2type = N'COLUMN', @level2name = 'ConfirmedReceivedBy';
GO
 
CREATE TABLE [Sales].[OrderLines]
(
    [OrderLineID] int NOT NULL
        CONSTRAINT [PK_Sales_OrderLines] PRIMARY KEY
        CONSTRAINT [DF_Sales_OrderLines_OrderLineID]
            DEFAULT(NEXT VALUE FOR [Sequences].[OrderLineID]),
    [OrderID] int NOT NULL
        CONSTRAINT [FK_Sales_OrderLines_OrderID_Sales_Orders]
            FOREIGN KEY REFERENCES [Sales].[Orders] ([OrderID]),
    [StockItemID] int NOT NULL
        CONSTRAINT [FK_Sales_OrderLines_StockItemID_Warehouse_StockItems]
            FOREIGN KEY REFERENCES [Warehouse].[StockItems] ([StockItemID]),
    [Description] nvarchar(100) NOT NULL,
    [PackageTypeID] int NOT NULL
        CONSTRAINT [FK_Sales_OrderLines_PackageTypeID_Warehouse_PackageTypes]
            FOREIGN KEY REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID]),
    [Quantity] int NOT NULL,
    [UnitPrice] decimal(18,2) NULL,
    [TaxRate] decimal(18,3) NOT NULL,
    [PickedQuantity] int NOT NULL,
    [PickingCompletedWhen] datetime2(7) NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Sales_OrderLines_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Sales_OrderLines_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Sales_OrderLines_OrderID]
ON [Sales].[OrderLines] ([OrderID]);
CREATE INDEX [FK_Sales_OrderLines_PackageTypeID]
ON [Sales].[OrderLines] ([PackageTypeID]);
GO
 
CREATE INDEX [IX_Sales_OrderLines_AllocatedStockItems]
ON [Sales].[OrderLines]([StockItemID])
INCLUDE ([PickedQuantity]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quick summation of stock item quantites already allocated to uninvoiced orders', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'INDEX', @level2name = 'IX_Sales_OrderLines_AllocatedStockItems';
 
CREATE INDEX [IX_Sales_OrderLines_Perf_20160301_01]
ON [Sales].[OrderLines]([PickingCompletedWhen], [OrderID], [OrderLineID])
INCLUDE ([Quantity], [StockItemID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Improves performance of order picking and invoicing', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'INDEX', @level2name = 'IX_Sales_OrderLines_Perf_20160301_01';
 
CREATE INDEX [IX_Sales_OrderLines_Perf_20160301_02]
ON [Sales].[OrderLines]([StockItemID], [PickingCompletedWhen])
INCLUDE ([OrderID], [PickedQuantity]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Improves performance of order picking and invoicing', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'INDEX', @level2name = 'IX_Sales_OrderLines_Perf_20160301_02';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Detail lines from customer orders', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a line on an Order within the database', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'COLUMN', @level2name = 'OrderLineID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'INDEX', @level2name = 'FK_Sales_OrderLines_OrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Order that this line is associated with', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'COLUMN', @level2name = 'OrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this order line (FK not indexed as separate index exists)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'COLUMN', @level2name = 'StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Description of the item supplied (Usually the stock item name but can be overridden)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'COLUMN', @level2name = 'Description';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'INDEX', @level2name = 'FK_Sales_OrderLines_PackageTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of package to be supplied', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'COLUMN', @level2name = 'PackageTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity to be supplied', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'COLUMN', @level2name = 'Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Unit price to be charged', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'COLUMN', @level2name = 'UnitPrice';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax rate to be applied', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'COLUMN', @level2name = 'TaxRate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity picked from stock', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'COLUMN', @level2name = 'PickedQuantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'When was picking of this line completed?', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'OrderLines', @level2type = N'COLUMN', @level2name = 'PickingCompletedWhen';
GO
 
CREATE TABLE [Warehouse].[StockItemStockGroups]
(
    [StockItemStockGroupID] int NOT NULL
        CONSTRAINT [PK_Warehouse_StockItemStockGroups] PRIMARY KEY
        CONSTRAINT [DF_Warehouse_StockItemStockGroups_StockItemStockGroupID]
            DEFAULT(NEXT VALUE FOR [Sequences].[StockItemStockGroupID]),
    [StockItemID] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItemStockGroups_StockItemID_Warehouse_StockItems]
            FOREIGN KEY REFERENCES [Warehouse].[StockItems] ([StockItemID]),
    [StockGroupID] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItemStockGroups_StockGroupID_Warehouse_StockGroups]
            FOREIGN KEY REFERENCES [Warehouse].[StockGroups] ([StockGroupID]),
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItemStockGroups_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Warehouse_StockItemStockGroups_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
ALTER TABLE [Warehouse].[StockItemStockGroups]
    ADD CONSTRAINT [UQ_StockItemStockGroups_StockItemID_Lookup]
         UNIQUE(StockItemID, StockGroupID);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Enforces uniqueness and indexes one side of the many to many relationship', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemStockGroups', @level2type = N'CONSTRAINT', @level2name = 'UQ_StockItemStockGroups_StockItemID_Lookup';
GO
 
ALTER TABLE [Warehouse].[StockItemStockGroups]
    ADD CONSTRAINT [UQ_StockItemStockGroups_StockGroupID_Lookup]
         UNIQUE(StockGroupID, StockItemID);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Enforces uniqueness and indexes one side of the many to many relationship', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemStockGroups', @level2type = N'CONSTRAINT', @level2name = 'UQ_StockItemStockGroups_StockGroupID_Lookup';
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Which stock items are in which stock groups', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemStockGroups';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Internal reference for this linking row', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemStockGroups', @level2type = N'COLUMN', @level2name = 'StockItemStockGroupID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item assigned to this stock group (FK indexed via unique constraint)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemStockGroups', @level2type = N'COLUMN', @level2name = 'StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'StockGroup assigned to this stock item (FK indexed via unique constraint)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemStockGroups', @level2type = N'COLUMN', @level2name = 'StockGroupID';
GO
 
CREATE TABLE [Sales].[CustomerTransactions]
(
    [CustomerTransactionID] int NOT NULL
        CONSTRAINT [PK_Sales_CustomerTransactions] PRIMARY KEY
        CONSTRAINT [DF_Sales_CustomerTransactions_CustomerTransactionID]
            DEFAULT(NEXT VALUE FOR [Sequences].[TransactionID]),
    [CustomerID] int NOT NULL
        CONSTRAINT [FK_Sales_CustomerTransactions_CustomerID_Sales_Customers]
            FOREIGN KEY REFERENCES [Sales].[Customers] ([CustomerID]),
    [TransactionTypeID] int NOT NULL
        CONSTRAINT [FK_Sales_CustomerTransactions_TransactionTypeID_Application_TransactionTypes]
            FOREIGN KEY REFERENCES [Application].[TransactionTypes] ([TransactionTypeID]),
    [InvoiceID] int NULL
        CONSTRAINT [FK_Sales_CustomerTransactions_InvoiceID_Sales_Invoices]
            FOREIGN KEY REFERENCES [Sales].[Invoices] ([InvoiceID]),
    [PaymentMethodID] int NULL
        CONSTRAINT [FK_Sales_CustomerTransactions_PaymentMethodID_Application_PaymentMethods]
            FOREIGN KEY REFERENCES [Application].[PaymentMethods] ([PaymentMethodID]),
    [TransactionDate] date NOT NULL,
    [AmountExcludingTax] decimal(18,2) NOT NULL,
    [TaxAmount] decimal(18,2) NOT NULL,
    [TransactionAmount] decimal(18,2) NOT NULL,
    [OutstandingBalance] decimal(18,2) NOT NULL,
    [FinalizationDate] date NULL,
    [IsFinalized] AS CASE WHEN [FinalizationDate] IS NULL THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END PERSISTED,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Sales_CustomerTransactions_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Sales_CustomerTransactions_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Sales_CustomerTransactions_CustomerID]
ON [Sales].[CustomerTransactions] ([CustomerID]);
CREATE INDEX [FK_Sales_CustomerTransactions_TransactionTypeID]
ON [Sales].[CustomerTransactions] ([TransactionTypeID]);
CREATE INDEX [FK_Sales_CustomerTransactions_InvoiceID]
ON [Sales].[CustomerTransactions] ([InvoiceID]);
CREATE INDEX [FK_Sales_CustomerTransactions_PaymentMethodID]
ON [Sales].[CustomerTransactions] ([PaymentMethodID]);
GO
 
CREATE INDEX [IX_Sales_CustomerTransactions_IsFinalized]
ON [Sales].[CustomerTransactions]([IsFinalized]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quick location of unfinalized transactions', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'INDEX', @level2name = 'IX_Sales_CustomerTransactions_IsFinalized';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'All financial transactions that are customer-related', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used to refer to a customer transaction within the database', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'CustomerTransactionID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'INDEX', @level2name = 'FK_Sales_CustomerTransactions_CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer for this transaction', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'INDEX', @level2name = 'FK_Sales_CustomerTransactions_TransactionTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of transaction', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'TransactionTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'INDEX', @level2name = 'FK_Sales_CustomerTransactions_InvoiceID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of an invoice (for transactions associated with an invoice)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'InvoiceID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'INDEX', @level2name = 'FK_Sales_CustomerTransactions_PaymentMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of a payment method (for transactions involving payments)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'PaymentMethodID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date for the transaction', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'TransactionDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Transaction amount (excluding tax)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'AmountExcludingTax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax amount calculated', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'TaxAmount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Transaction amount (including tax)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'TransactionAmount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Amount still outstanding for this transaction', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'OutstandingBalance';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date that this transaction was finalized (if it has been)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'FinalizationDate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this transaction finalized (invoices, credits and payments have been matched)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'CustomerTransactions', @level2type = N'COLUMN', @level2name = 'IsFinalized';
GO
 
CREATE TABLE [Sales].[InvoiceLines]
(
    [InvoiceLineID] int NOT NULL
        CONSTRAINT [PK_Sales_InvoiceLines] PRIMARY KEY
        CONSTRAINT [DF_Sales_InvoiceLines_InvoiceLineID]
            DEFAULT(NEXT VALUE FOR [Sequences].[InvoiceLineID]),
    [InvoiceID] int NOT NULL
        CONSTRAINT [FK_Sales_InvoiceLines_InvoiceID_Sales_Invoices]
            FOREIGN KEY REFERENCES [Sales].[Invoices] ([InvoiceID]),
    [StockItemID] int NOT NULL
        CONSTRAINT [FK_Sales_InvoiceLines_StockItemID_Warehouse_StockItems]
            FOREIGN KEY REFERENCES [Warehouse].[StockItems] ([StockItemID]),
    [Description] nvarchar(100) NOT NULL,
    [PackageTypeID] int NOT NULL
        CONSTRAINT [FK_Sales_InvoiceLines_PackageTypeID_Warehouse_PackageTypes]
            FOREIGN KEY REFERENCES [Warehouse].[PackageTypes] ([PackageTypeID]),
    [Quantity] int NOT NULL,
    [UnitPrice] decimal(18,2) NULL,
    [TaxRate] decimal(18,3) NOT NULL,
    [TaxAmount] decimal(18,2) NOT NULL,
    [LineProfit] decimal(18,2) NOT NULL,
    [ExtendedPrice] decimal(18,2) NOT NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Sales_InvoiceLines_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Sales_InvoiceLines_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Sales_InvoiceLines_InvoiceID]
ON [Sales].[InvoiceLines] ([InvoiceID]);
CREATE INDEX [FK_Sales_InvoiceLines_StockItemID]
ON [Sales].[InvoiceLines] ([StockItemID]);
CREATE INDEX [FK_Sales_InvoiceLines_PackageTypeID]
ON [Sales].[InvoiceLines] ([PackageTypeID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Detail lines from customer invoices', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a line on an invoice within the database', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'InvoiceLineID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'INDEX', @level2name = 'FK_Sales_InvoiceLines_InvoiceID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Invoice that this line is associated with', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'InvoiceID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'INDEX', @level2name = 'FK_Sales_InvoiceLines_StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this invoice line', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Description of the item supplied (Usually the stock item name but can be overridden)', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'Description';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'INDEX', @level2name = 'FK_Sales_InvoiceLines_PackageTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of package supplied', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'PackageTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity supplied', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Unit price charged', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'UnitPrice';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax rate to be applied', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'TaxRate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax amount calculated', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'TaxAmount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Profit made on this line item at current cost price', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'LineProfit';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Extended line price charged', @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'TABLE',  @level1name = 'InvoiceLines', @level2type = N'COLUMN', @level2name = 'ExtendedPrice';
GO
 
CREATE TABLE [Warehouse].[StockItemTransactions]
(
    [StockItemTransactionID] int NOT NULL
        CONSTRAINT [PK_Warehouse_StockItemTransactions] PRIMARY KEY
        CONSTRAINT [DF_Warehouse_StockItemTransactions_StockItemTransactionID]
            DEFAULT(NEXT VALUE FOR [Sequences].[TransactionID]),
    [StockItemID] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItemTransactions_StockItemID_Warehouse_StockItems]
            FOREIGN KEY REFERENCES [Warehouse].[StockItems] ([StockItemID]),
    [TransactionTypeID] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItemTransactions_TransactionTypeID_Application_TransactionTypes]
            FOREIGN KEY REFERENCES [Application].[TransactionTypes] ([TransactionTypeID]),
    [CustomerID] int NULL
        CONSTRAINT [FK_Warehouse_StockItemTransactions_CustomerID_Sales_Customers]
            FOREIGN KEY REFERENCES [Sales].[Customers] ([CustomerID]),
    [InvoiceID] int NULL
        CONSTRAINT [FK_Warehouse_StockItemTransactions_InvoiceID_Sales_Invoices]
            FOREIGN KEY REFERENCES [Sales].[Invoices] ([InvoiceID]),
    [SupplierID] int NULL
        CONSTRAINT [FK_Warehouse_StockItemTransactions_SupplierID_Purchasing_Suppliers]
            FOREIGN KEY REFERENCES [Purchasing].[Suppliers] ([SupplierID]),
    [PurchaseOrderID] int NULL
        CONSTRAINT [FK_Warehouse_StockItemTransactions_PurchaseOrderID_Purchasing_PurchaseOrders]
            FOREIGN KEY REFERENCES [Purchasing].[PurchaseOrders] ([PurchaseOrderID]),
    [TransactionOccurredWhen] datetime2(7) NOT NULL,
    [Quantity] decimal(18,3) NOT NULL,
    [LastEditedBy] int NOT NULL
        CONSTRAINT [FK_Warehouse_StockItemTransactions_Application_People]
            FOREIGN KEY REFERENCES [Application].[People] ([PersonID]),
    [LastEditedWhen] datetime2(7) NOT NULL
        CONSTRAINT [DF_Warehouse_StockItemTransactions_LastEditedWhen]
            DEFAULT(SYSDATETIME())
);
GO
 
CREATE INDEX [FK_Warehouse_StockItemTransactions_StockItemID]
ON [Warehouse].[StockItemTransactions] ([StockItemID]);
CREATE INDEX [FK_Warehouse_StockItemTransactions_TransactionTypeID]
ON [Warehouse].[StockItemTransactions] ([TransactionTypeID]);
CREATE INDEX [FK_Warehouse_StockItemTransactions_CustomerID]
ON [Warehouse].[StockItemTransactions] ([CustomerID]);
CREATE INDEX [FK_Warehouse_StockItemTransactions_InvoiceID]
ON [Warehouse].[StockItemTransactions] ([InvoiceID]);
CREATE INDEX [FK_Warehouse_StockItemTransactions_SupplierID]
ON [Warehouse].[StockItemTransactions] ([SupplierID]);
CREATE INDEX [FK_Warehouse_StockItemTransactions_PurchaseOrderID]
ON [Warehouse].[StockItemTransactions] ([PurchaseOrderID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Transactions covering all movements of all stock items', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used to refer to a stock item transaction within the database', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'COLUMN', @level2name = 'StockItemTransactionID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'INDEX', @level2name = 'FK_Warehouse_StockItemTransactions_StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'StockItem for this transaction', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'COLUMN', @level2name = 'StockItemID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'INDEX', @level2name = 'FK_Warehouse_StockItemTransactions_TransactionTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of transaction', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'COLUMN', @level2name = 'TransactionTypeID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'INDEX', @level2name = 'FK_Warehouse_StockItemTransactions_CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer for this transaction (if applicable)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'COLUMN', @level2name = 'CustomerID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'INDEX', @level2name = 'FK_Warehouse_StockItemTransactions_InvoiceID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of an invoice (for transactions associated with an invoice)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'COLUMN', @level2name = 'InvoiceID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'INDEX', @level2name = 'FK_Warehouse_StockItemTransactions_SupplierID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier for this stock transaction (if applicable)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'COLUMN', @level2name = 'SupplierID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'INDEX', @level2name = 'FK_Warehouse_StockItemTransactions_PurchaseOrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ID of an purchase order (for transactions associated with a purchase order)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'COLUMN', @level2name = 'PurchaseOrderID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date and time when the transaction occurred', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'COLUMN', @level2name = 'TransactionOccurredWhen';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of stock movement (positive is incoming stock, negative is outgoing)', @level0type = N'SCHEMA', @level0name = 'Warehouse', @level1type = N'TABLE',  @level1name = 'StockItemTransactions', @level2type = N'COLUMN', @level2name = 'Quantity';
GO
 
CREATE PROCEDURE Sequences.ReseedSequenceBeyondTableValues
@SequenceName sysname,
@SchemaName sysname,
@TableName sysname,
@ColumnName sysname
AS BEGIN
    -- Ensures that the next sequence value is above the maximum value of the supplied table column
    SET NOCOUNT ON;
 
    DECLARE @SQL nvarchar(max);
    DECLARE @CurrentTableMaximumValue bigint;
    DECLARE @NewSequenceValue bigint;
    DECLARE @CurrentSequenceMaximumValue bigint
        = (SELECT CAST(current_value AS bigint) FROM sys.sequences
                                                WHERE name = @SequenceName
                                                AND SCHEMA_NAME(schema_id) = N'Sequences');
    CREATE TABLE #CurrentValue
    (
        CurrentValue bigint
    )
 
    SET @SQL = N'INSERT #CurrentValue (CurrentValue) SELECT COALESCE(MAX(' + QUOTENAME(@ColumnName) + N'), 0) FROM ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + N';';
    EXECUTE (@SQL);
    SET @CurrentTableMaximumValue = (SELECT CurrentValue FROM #CurrentValue);
    DROP TABLE #CurrentValue;
 
    IF @CurrentTableMaximumValue >= @CurrentSequenceMaximumValue
    BEGIN
        SET @NewSequenceValue = @CurrentTableMaximumValue + 1;
        SET @SQL = N'ALTER SEQUENCE Sequences.' + QUOTENAME(@SequenceName) + N' RESTART WITH ' + CAST(@NewSequenceValue AS nvarchar(20)) + N';';
        EXECUTE (@SQL);
    END;
END;
GO
 
CREATE PROCEDURE Sequences.ReseedAllSequences
AS BEGIN
    -- Ensures that the next sequence values are above the maximum value of the related table columns
    SET NOCOUNT ON;
 
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'BuyingGroupID', @SchemaName = 'Sales', @TableName = 'BuyingGroups', @ColumnName = 'BuyingGroupID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'CityID', @SchemaName = 'Application', @TableName = 'Cities', @ColumnName = 'CityID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'ColorID', @SchemaName = 'Warehouse', @TableName = 'Colors', @ColumnName = 'ColorID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'CountryID', @SchemaName = 'Application', @TableName = 'Countries', @ColumnName = 'CountryID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'CustomerCategoryID', @SchemaName = 'Sales', @TableName = 'CustomerCategories', @ColumnName = 'CustomerCategoryID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'CustomerID', @SchemaName = 'Sales', @TableName = 'Customers', @ColumnName = 'CustomerID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'DeliveryMethodID', @SchemaName = 'Application', @TableName = 'DeliveryMethods', @ColumnName = 'DeliveryMethodID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'InvoiceID', @SchemaName = 'Sales', @TableName = 'Invoices', @ColumnName = 'InvoiceID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'InvoiceLineID', @SchemaName = 'Sales', @TableName = 'InvoiceLines', @ColumnName = 'InvoiceLineID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'OrderID', @SchemaName = 'Sales', @TableName = 'Orders', @ColumnName = 'OrderID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'OrderLineID', @SchemaName = 'Sales', @TableName = 'OrderLines', @ColumnName = 'OrderLineID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'PackageTypeID', @SchemaName = 'Warehouse', @TableName = 'PackageTypes', @ColumnName = 'PackageTypeID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'PaymentMethodID', @SchemaName = 'Application', @TableName = 'PaymentMethods', @ColumnName = 'PaymentMethodID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'PersonID', @SchemaName = 'Application', @TableName = 'People', @ColumnName = 'PersonID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'PurchaseOrderID', @SchemaName = 'Purchasing', @TableName = 'PurchaseOrders', @ColumnName = 'PurchaseOrderID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'PurchaseOrderLineID', @SchemaName = 'Purchasing', @TableName = 'PurchaseOrderLines', @ColumnName = 'PurchaseOrderLineID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'SpecialDealID', @SchemaName = 'Sales', @TableName = 'SpecialDeals', @ColumnName = 'SpecialDealID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'StateProvinceID', @SchemaName = 'Application', @TableName = 'StateProvinces', @ColumnName = 'StateProvinceID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'StockGroupID', @SchemaName = 'Warehouse', @TableName = 'StockGroups', @ColumnName = 'StockGroupID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'StockItemID', @SchemaName = 'Warehouse', @TableName = 'StockItems', @ColumnName = 'StockItemID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'StockItemStockGroupID', @SchemaName = 'Warehouse', @TableName = 'StockItemStockGroups', @ColumnName = 'StockItemStockGroupID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'SupplierCategoryID', @SchemaName = 'Purchasing', @TableName = 'SupplierCategories', @ColumnName = 'SupplierCategoryID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'SupplierID', @SchemaName = 'Purchasing', @TableName = 'Suppliers', @ColumnName = 'SupplierID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'SystemParameterID', @SchemaName = 'Application', @TableName = 'SystemParameters', @ColumnName = 'SystemParameterID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'TransactionID', @SchemaName = 'Purchasing', @TableName = 'SupplierTransactions', @ColumnName = 'SupplierTransactionID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'TransactionID', @SchemaName = 'Sales', @TableName = 'CustomerTransactions', @ColumnName = 'CustomerTransactionID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'TransactionID', @SchemaName = 'Warehouse', @TableName = 'StockItemTransactions', @ColumnName = 'StockItemTransactionID';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'TransactionTypeID', @SchemaName = 'Application', @TableName = 'TransactionTypes', @ColumnName = 'TransactionTypeID';
END;
GO
 
CREATE PROCEDURE DataLoadSimulation.DeactivateTemporalTablesBeforeDataLoad
AS BEGIN
    -- Disables the temporal nature of the temporal tables before a simulated data load
    SET NOCOUNT ON;
 
    IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = N'Configuration_RemoveRowLevelSecurity')
    BEGIN
        EXEC [Application].Configuration_RemoveRowLevelSecurity;
    END;
 
    DECLARE @SQL nvarchar(max) = N'';
    DECLARE @CrLf nvarchar(2) = NCHAR(13) + NCHAR(10);
    DECLARE @Indent nvarchar(4) = N'    ';
    DECLARE @SchemaName sysname;
    DECLARE @TableName sysname;
    DECLARE @NormalColumnList nvarchar(max);
    DECLARE @NormalColumnListWithDPrefix nvarchar(max);
    DECLARE @PrimaryKeyColumn sysname;
    DECLARE @TemporalFromColumnName sysname = N'ValidFrom';
    DECLARE @TemporalToColumnName sysname = N'ValidTo';
    DECLARE @TemporalTableSuffix nvarchar(max) = N'Archive';
    DECLARE @LastEditedByColumnName sysname;
 
    ALTER TABLE [Application].[Cities] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Application].[Cities] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Application].[Countries] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Application].[Countries] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Application].[DeliveryMethods] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Application].[DeliveryMethods] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Application].[PaymentMethods] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Application].[PaymentMethods] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Application].[People] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Application].[People] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Application].[StateProvinces] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Application].[StateProvinces] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Application].[TransactionTypes] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Application].[TransactionTypes] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Purchasing].[SupplierCategories] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Purchasing].[SupplierCategories] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Purchasing].[Suppliers] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Purchasing].[Suppliers] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Sales].[BuyingGroups] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Sales].[BuyingGroups] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Sales].[CustomerCategories] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Sales].[CustomerCategories] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Sales].[Customers] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Sales].[Customers] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Warehouse].[ColdRoomTemperatures] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Warehouse].[ColdRoomTemperatures] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Warehouse].[Colors] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Warehouse].[Colors] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Warehouse].[PackageTypes] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Warehouse].[PackageTypes] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Warehouse].[StockGroups] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Warehouse].[StockGroups] DROP PERIOD FOR SYSTEM_TIME;
 
    ALTER TABLE [Warehouse].[StockItems] SET (SYSTEM_VERSIONING = OFF);
    ALTER TABLE [Warehouse].[StockItems] DROP PERIOD FOR SYSTEM_TIME;
 
    SET @SQL = N'';
    SET @SchemaName = N'Application';
    SET @TableName = N'Cities';
    SET @PrimaryKeyColumn = N'CityID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [CityID], [CityName], [StateProvinceID], [Location], [LatestRecordedPopulation],';
    SET @NormalColumnListWithDPrefix = N' d.[CityID], d.[CityName], d.[StateProvinceID], d.[Location], d.[LatestRecordedPopulation],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Application';
    SET @TableName = N'Countries';
    SET @PrimaryKeyColumn = N'CountryID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [CountryID], [CountryName], [FormalName], [IsoAlpha3Code], [IsoNumericCode], [CountryType], [LatestRecordedPopulation], [Continent], [Region], [Subregion], [Border],';
    SET @NormalColumnListWithDPrefix = N' d.[CountryID], d.[CountryName], d.[FormalName], d.[IsoAlpha3Code], d.[IsoNumericCode], d.[CountryType], d.[LatestRecordedPopulation], d.[Continent], d.[Region], d.[Subregion], d.[Border],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Application';
    SET @TableName = N'DeliveryMethods';
    SET @PrimaryKeyColumn = N'DeliveryMethodID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [DeliveryMethodID], [DeliveryMethodName],';
    SET @NormalColumnListWithDPrefix = N' d.[DeliveryMethodID], d.[DeliveryMethodName],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Application';
    SET @TableName = N'PaymentMethods';
    SET @PrimaryKeyColumn = N'PaymentMethodID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [PaymentMethodID], [PaymentMethodName],';
    SET @NormalColumnListWithDPrefix = N' d.[PaymentMethodID], d.[PaymentMethodName],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Application';
    SET @TableName = N'People';
    SET @PrimaryKeyColumn = N'PersonID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [PersonID], [FullName], [PreferredName], [SearchName], [IsPermittedToLogon], [LogonName], [IsExternalLogonProvider], [HashedPassword], [IsSystemUser], [IsEmployee], [IsSalesperson], [UserPreferences], [PhoneNumber], [FaxNumber], [EmailAddress], [Photo], [CustomFields], [OtherLanguages],';
    SET @NormalColumnListWithDPrefix = N' d.[PersonID], d.[FullName], d.[PreferredName], d.[SearchName], d.[IsPermittedToLogon], d.[LogonName], d.[IsExternalLogonProvider], d.[HashedPassword], d.[IsSystemUser], d.[IsEmployee], d.[IsSalesperson], d.[UserPreferences], d.[PhoneNumber], d.[FaxNumber], d.[EmailAddress], d.[Photo], d.[CustomFields], d.[OtherLanguages],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Application';
    SET @TableName = N'StateProvinces';
    SET @PrimaryKeyColumn = N'StateProvinceID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [StateProvinceID], [StateProvinceCode], [StateProvinceName], [CountryID], [SalesTerritory], [Border], [LatestRecordedPopulation],';
    SET @NormalColumnListWithDPrefix = N' d.[StateProvinceID], d.[StateProvinceCode], d.[StateProvinceName], d.[CountryID], d.[SalesTerritory], d.[Border], d.[LatestRecordedPopulation],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Application';
    SET @TableName = N'TransactionTypes';
    SET @PrimaryKeyColumn = N'TransactionTypeID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [TransactionTypeID], [TransactionTypeName],';
    SET @NormalColumnListWithDPrefix = N' d.[TransactionTypeID], d.[TransactionTypeName],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Purchasing';
    SET @TableName = N'SupplierCategories';
    SET @PrimaryKeyColumn = N'SupplierCategoryID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [SupplierCategoryID], [SupplierCategoryName],';
    SET @NormalColumnListWithDPrefix = N' d.[SupplierCategoryID], d.[SupplierCategoryName],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Purchasing';
    SET @TableName = N'Suppliers';
    SET @PrimaryKeyColumn = N'SupplierID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [SupplierID], [SupplierName], [SupplierCategoryID], [PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID], [SupplierReference], [BankAccountName], [BankAccountBranch], [BankAccountCode], [BankAccountNumber], [BankInternationalCode], [PaymentDays], [InternalComments], [PhoneNumber], [FaxNumber], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode],';
    SET @NormalColumnListWithDPrefix = N' d.[SupplierID], d.[SupplierName], d.[SupplierCategoryID], d.[PrimaryContactPersonID], d.[AlternateContactPersonID], d.[DeliveryMethodID], d.[DeliveryCityID], d.[PostalCityID], d.[SupplierReference], d.[BankAccountName], d.[BankAccountBranch], d.[BankAccountCode], d.[BankAccountNumber], d.[BankInternationalCode], d.[PaymentDays], d.[InternalComments], d.[PhoneNumber], d.[FaxNumber], d.[WebsiteURL], d.[DeliveryAddressLine1], d.[DeliveryAddressLine2], d.[DeliveryPostalCode], d.[DeliveryLocation], d.[PostalAddressLine1], d.[PostalAddressLine2], d.[PostalPostalCode],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Sales';
    SET @TableName = N'BuyingGroups';
    SET @PrimaryKeyColumn = N'BuyingGroupID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [BuyingGroupID], [BuyingGroupName],';
    SET @NormalColumnListWithDPrefix = N' d.[BuyingGroupID], d.[BuyingGroupName],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Sales';
    SET @TableName = N'CustomerCategories';
    SET @PrimaryKeyColumn = N'CustomerCategoryID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [CustomerCategoryID], [CustomerCategoryName],';
    SET @NormalColumnListWithDPrefix = N' d.[CustomerCategoryID], d.[CustomerCategoryName],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Sales';
    SET @TableName = N'Customers';
    SET @PrimaryKeyColumn = N'CustomerID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID], [PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage], [IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber], [DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode],';
    SET @NormalColumnListWithDPrefix = N' d.[CustomerID], d.[CustomerName], d.[BillToCustomerID], d.[CustomerCategoryID], d.[BuyingGroupID], d.[PrimaryContactPersonID], d.[AlternateContactPersonID], d.[DeliveryMethodID], d.[DeliveryCityID], d.[PostalCityID], d.[CreditLimit], d.[AccountOpenedDate], d.[StandardDiscountPercentage], d.[IsStatementSent], d.[IsOnCreditHold], d.[PaymentDays], d.[PhoneNumber], d.[FaxNumber], d.[DeliveryRun], d.[RunPosition], d.[WebsiteURL], d.[DeliveryAddressLine1], d.[DeliveryAddressLine2], d.[DeliveryPostalCode], d.[DeliveryLocation], d.[PostalAddressLine1], d.[PostalAddressLine2], d.[PostalPostalCode],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Warehouse';
    SET @TableName = N'ColdRoomTemperatures';
    SET @PrimaryKeyColumn = N'ColdRoomTemperatureID';
    SET @LastEditedByColumnName = N'';
    SET @NormalColumnList = N' [ColdRoomTemperatureID], [ColdRoomSensorNumber], [RecordedWhen], [Temperature],';
    SET @NormalColumnListWithDPrefix = N' d.[ColdRoomTemperatureID], d.[ColdRoomSensorNumber], d.[RecordedWhen], d.[Temperature],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Warehouse';
    SET @TableName = N'Colors';
    SET @PrimaryKeyColumn = N'ColorID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [ColorID], [ColorName],';
    SET @NormalColumnListWithDPrefix = N' d.[ColorID], d.[ColorName],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Warehouse';
    SET @TableName = N'PackageTypes';
    SET @PrimaryKeyColumn = N'PackageTypeID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [PackageTypeID], [PackageTypeName],';
    SET @NormalColumnListWithDPrefix = N' d.[PackageTypeID], d.[PackageTypeName],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Warehouse';
    SET @TableName = N'StockGroups';
    SET @PrimaryKeyColumn = N'StockGroupID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [StockGroupID], [StockGroupName],';
    SET @NormalColumnListWithDPrefix = N' d.[StockGroupID], d.[StockGroupName],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
    SET @SQL = N'';
    SET @SchemaName = N'Warehouse';
    SET @TableName = N'StockItems';
    SET @PrimaryKeyColumn = N'StockItemID';
    SET @LastEditedByColumnName = N'LastEditedBy';
    SET @NormalColumnList = N' [StockItemID], [StockItemName], [SupplierID], [ColorID], [UnitPackageID], [OuterPackageID], [Brand], [Size], [LeadTimeDays], [QuantityPerOuter], [IsChillerStock], [Barcode], [TaxRate], [UnitPrice], [RecommendedRetailPrice], [TypicalWeightPerUnit], [MarketingComments], [InternalComments], [Photo], [CustomFields], [Tags], [SearchDetails],';
    SET @NormalColumnListWithDPrefix = N' d.[StockItemID], d.[StockItemName], d.[SupplierID], d.[ColorID], d.[UnitPackageID], d.[OuterPackageID], d.[Brand], d.[Size], d.[LeadTimeDays], d.[QuantityPerOuter], d.[IsChillerStock], d.[Barcode], d.[TaxRate], d.[UnitPrice], d.[RecommendedRetailPrice], d.[TypicalWeightPerUnit], d.[MarketingComments], d.[InternalComments], d.[Photo], d.[CustomFields], d.[Tags], d.[SearchDetails],';
 
    SET @SQL = N'DROP TRIGGER IF EXISTS ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify];'
    EXECUTE (@SQL);
 
    SET @SQL = N'CREATE TRIGGER ' + QUOTENAME(@SchemaName) + N'.[TR_' + @SchemaName + N'_' + @TableName + N'_DataLoad_Modify]' + @CrLf
              + N'ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName) + @CrLf
              + N'AFTER INSERT, UPDATE' + @CrLf
              + N'AS' + @CrLf
              + N'BEGIN' + @CrLf
              + @Indent + N'SET NOCOUNT ON;' + @CrLf + @CrLf
              + @Indent + N'IF NOT UPDATE(' + QUOTENAME(@TemporalFromColumnName) + N')' + @CrLf
              + @Indent + N'BEGIN' + @CrLf
              + @Indent + @Indent + N'THROW 51000, ''' + QUOTENAME(@TemporalFromColumnName)
                                  + N' must be updated when simulating data loads'', 1;' + @CrLf
              + @Indent + @Indent + N'ROLLBACK TRAN;' + @CrLf
              + @Indent + N'END;' + @Crlf + @CrLf
              + @Indent + N'INSERT ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName + N'_' + @TemporalTableSuffix) + @CrLf
              + @Indent + @Indent + N'(' + @NormalColumnList + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + QUOTENAME(@TemporalFromColumnName) + N',' + QUOTENAME(@TemporalToColumnName) + N')' + @CrLf
              + @Indent + N'SELECT' + @NormalColumnListWithDPrefix + CASE WHEN COALESCE(@LastEditedByColumnName, N'') <> N'' THEN N'd.' + QUOTENAME(@LastEditedByColumnName) + N', ' ELSE N'' END
                                  + N' d.' + QUOTENAME(@TemporalFromColumnName) + N', i.' + QUOTENAME(@TemporalFromColumnName) + @CrLf
              + @Indent + N'FROM inserted AS i' + @CrLf
              + @Indent + N'INNER JOIN deleted AS d' + @CrLf
              + @Indent + N'ON i.' + QUOTENAME(@PrimaryKeyColumn) + N' = d.' + QUOTENAME(@PrimaryKeyColumn) + N';' + @CrLf
              + N'END;';
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @TableName AND is_memory_optimized <> 0)
    BEGIN
        EXECUTE (@SQL);
    END;
 
END;
GO
 
CREATE PROCEDURE DataLoadSimulation.ReactivateTemporalTablesAfterDataLoad
AS BEGIN
    -- Re-enables the temporal nature of the temporal tables after a simulated data load
    SET NOCOUNT ON;
 
    IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = N'Configuration_ApplyRowLevelSecurity')
    BEGIN
        EXEC [Application].Configuration_ApplyRowLevelSecurity;
    END;
 
    DROP TRIGGER IF EXISTS [Application].[TR_Application_Cities_DataLoad_Modify];
    ALTER TABLE [Application].[Cities] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Application].[Cities] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[Cities_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Application].[TR_Application_Countries_DataLoad_Modify];
    ALTER TABLE [Application].[Countries] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Application].[Countries] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[Countries_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Application].[TR_Application_DeliveryMethods_DataLoad_Modify];
    ALTER TABLE [Application].[DeliveryMethods] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Application].[DeliveryMethods] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[DeliveryMethods_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Application].[TR_Application_PaymentMethods_DataLoad_Modify];
    ALTER TABLE [Application].[PaymentMethods] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Application].[PaymentMethods] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[PaymentMethods_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Application].[TR_Application_People_DataLoad_Modify];
    ALTER TABLE [Application].[People] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Application].[People] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[People_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Application].[TR_Application_StateProvinces_DataLoad_Modify];
    ALTER TABLE [Application].[StateProvinces] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Application].[StateProvinces] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[StateProvinces_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Application].[TR_Application_TransactionTypes_DataLoad_Modify];
    ALTER TABLE [Application].[TransactionTypes] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Application].[TransactionTypes] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Application].[TransactionTypes_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Purchasing].[TR_Purchasing_SupplierCategories_DataLoad_Modify];
    ALTER TABLE [Purchasing].[SupplierCategories] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Purchasing].[SupplierCategories] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Purchasing].[SupplierCategories_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Purchasing].[TR_Purchasing_Suppliers_DataLoad_Modify];
    ALTER TABLE [Purchasing].[Suppliers] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Purchasing].[Suppliers] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Purchasing].[Suppliers_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Sales].[TR_Sales_BuyingGroups_DataLoad_Modify];
    ALTER TABLE [Sales].[BuyingGroups] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Sales].[BuyingGroups] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Sales].[BuyingGroups_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Sales].[TR_Sales_CustomerCategories_DataLoad_Modify];
    ALTER TABLE [Sales].[CustomerCategories] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Sales].[CustomerCategories] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Sales].[CustomerCategories_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Sales].[TR_Sales_Customers_DataLoad_Modify];
    ALTER TABLE [Sales].[Customers] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Sales].[Customers] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Sales].[Customers_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Warehouse].[TR_Warehouse_ColdRoomTemperatures_DataLoad_Modify];
    ALTER TABLE [Warehouse].[ColdRoomTemperatures] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Warehouse].[ColdRoomTemperatures] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Warehouse].[ColdRoomTemperatures_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Warehouse].[TR_Warehouse_Colors_DataLoad_Modify];
    ALTER TABLE [Warehouse].[Colors] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Warehouse].[Colors] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Warehouse].[Colors_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Warehouse].[TR_Warehouse_PackageTypes_DataLoad_Modify];
    ALTER TABLE [Warehouse].[PackageTypes] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Warehouse].[PackageTypes] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Warehouse].[PackageTypes_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Warehouse].[TR_Warehouse_StockGroups_DataLoad_Modify];
    ALTER TABLE [Warehouse].[StockGroups] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Warehouse].[StockGroups] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Warehouse].[StockGroups_Archive], DATA_CONSISTENCY_CHECK = ON));
 
    DROP TRIGGER IF EXISTS [Warehouse].[TR_Warehouse_StockItems_DataLoad_Modify];
    ALTER TABLE [Warehouse].[StockItems] ADD PERIOD FOR SYSTEM_TIME([ValidFrom], [ValidTo]);
    ALTER TABLE [Warehouse].[StockItems] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Warehouse].[StockItems_Archive], DATA_CONSISTENCY_CHECK = ON));
 
END;
GO
 
USE tempdb;
GO
 
