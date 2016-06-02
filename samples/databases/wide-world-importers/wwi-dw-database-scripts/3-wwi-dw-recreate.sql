USE master;
 
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = N'WideWorldImportersDW')
BEGIN
    ALTER DATABASE WideWorldImportersDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE WideWorldImportersDW;
END;
GO
 
CREATE DATABASE WideWorldImportersDW
ON PRIMARY
(
    NAME = WWI_Primary,
    FILENAME = 'D:\Data\WideWorldImportersDW.mdf',
    SIZE = 2GB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 64MB
),
FILEGROUP USERDATA DEFAULT
(
    NAME = WWI_UserData,
    FILENAME = 'D:\Data\WideWorldImportersDW_UserData.ndf',
    SIZE = 2GB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 64MB
)
LOG ON
(
    NAME = WWI_Log,
    FILENAME = 'E:\Log\WideWorldImportersDW.ldf',
    SIZE = 100MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 64MB
)
COLLATE Latin1_General_100_CI_AS;
GO
 
ALTER DATABASE WideWorldImportersDW SET RECOVERY SIMPLE;
GO
 
ALTER DATABASE WideWorldImporters SET AUTO_UPDATE_STATISTICS_ASYNC ON;
GO
 
ALTER AUTHORIZATION ON DATABASE::WideWorldImportersDW to sa;
GO
 
ALTER DATABASE WideWorldImportersDW
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
 
USE WideWorldImportersDW;
GO
 
CREATE SCHEMA [Application] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Application configuration code', @level0type = N'SCHEMA', @level0name = 'Application';
GO
 
CREATE SCHEMA [Dimension] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Dimensional model dimension tables', @level0type = N'SCHEMA', @level0name = 'Dimension';
GO
 
CREATE SCHEMA [Fact] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Dimensional model fact tables', @level0type = N'SCHEMA', @level0name = 'Fact';
GO
 
CREATE SCHEMA [Integration] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Objects needed for ETL integration', @level0type = N'SCHEMA', @level0name = 'Integration';
GO
 
CREATE SCHEMA [PowerBI] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Views and stored procedures that provide the only access for the Power BI dashboard system', @level0type = N'SCHEMA', @level0name = 'PowerBI';
GO
 
CREATE SCHEMA [Reports] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Views and stored procedures that provide the only access for the reporting system', @level0type = N'SCHEMA', @level0name = 'Reports';
GO
 
CREATE SCHEMA [Sequences] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Holds sequences used by all tables in the application', @level0type = N'SCHEMA', @level0name = 'Sequences';
GO
 
CREATE SCHEMA [Website] AUTHORIZATION dbo;
GO
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Views and stored procedures that provide the only access for the application website', @level0type = N'SCHEMA', @level0name = 'Website';
GO
 
 
CREATE SEQUENCE [Sequences].[CityKey] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[CustomerKey] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[EmployeeKey] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[LineageKey] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[PaymentMethodKey] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[StockItemKey] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[SupplierKey] AS int START WITH 1;
CREATE SEQUENCE [Sequences].[TransactionTypeKey] AS int START WITH 1;
GO
 
CREATE TABLE [Dimension].[City]
(
    [City Key] int NOT NULL
        CONSTRAINT [PK_Dimension_City] PRIMARY KEY
        CONSTRAINT [DF_Dimension_City_City_Key]
            DEFAULT(NEXT VALUE FOR [Sequences].[CityKey]),
    [WWI City ID] int NOT NULL,
    [City] nvarchar(50) NOT NULL,
    [State Province] nvarchar(50) NOT NULL,
    [Country] nvarchar(60) NOT NULL,
    [Continent] nvarchar(30) NOT NULL,
    [Sales Territory] nvarchar(50) NOT NULL,
    [Region] nvarchar(30) NOT NULL,
    [Subregion] nvarchar(30) NOT NULL,
    [Location] geography NULL,
    [Latest Recorded Population] bigint NOT NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [IX_Dimension_City_WWICityID]
ON [Dimension].[City]([WWI City ID], [Valid From], [Valid To]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI ID', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'INDEX', @level2name = 'IX_Dimension_City_WWICityID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'City dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for the city dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'City Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a city within the WWI database', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'WWI City ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Formal name of the city', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'City';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'State or province for this city', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'State Province';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Country name', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'Country';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Continent that this city is on', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'Continent';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Sales territory for this StateProvince', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'Sales Territory';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name of the region', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'Region';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name of the subregion', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'Subregion';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Geographic location of the city', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'Location';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Latest available population for the City', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'Latest Recorded Population';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'Valid To';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'City', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Dimension].[Customer]
(
    [Customer Key] int NOT NULL
        CONSTRAINT [PK_Dimension_Customer] PRIMARY KEY
        CONSTRAINT [DF_Dimension_Customer_Customer_Key]
            DEFAULT(NEXT VALUE FOR [Sequences].[CustomerKey]),
    [WWI Customer ID] int NOT NULL,
    [Customer] nvarchar(100) NOT NULL,
    [Bill To Customer] nvarchar(100) NOT NULL,
    [Category] nvarchar(50) NOT NULL,
    [Buying Group] nvarchar(50) NOT NULL,
    [Primary Contact] nvarchar(50) NOT NULL,
    [Postal Code] nvarchar(10) NOT NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [IX_Dimension_Customer_WWICustomerID]
ON [Dimension].[Customer]([WWI Customer ID], [Valid From], [Valid To]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI ID', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'INDEX', @level2name = 'IX_Dimension_Customer_WWICustomerID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Customer dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for the customer dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a customer within the WWI database', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'WWI Customer ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer''s full name (usually a trading name)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'Customer';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bill to customer''s full name', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'Bill To Customer';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer''s category', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'Category';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer''s buying group', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'Buying Group';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Primary contact', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'Primary Contact';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Delivery postal code for the customer', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'Postal Code';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'Valid To';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Customer', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Dimension].[Date]
(
    [Date] date NOT NULL
        CONSTRAINT [PK_Dimension_Date] PRIMARY KEY,
    [Day Number] int NOT NULL,
    [Day] nvarchar(10) NOT NULL,
    [Month] nvarchar(10) NOT NULL,
    [Short Month] nvarchar(3) NOT NULL,
    [Calendar Month Number] int NOT NULL,
    [Calendar Month Label] nvarchar(20) NOT NULL,
    [Calendar Year] int NOT NULL,
    [Calendar Year Label] nvarchar(10) NOT NULL,
    [Fiscal Month Number] int NOT NULL,
    [Fiscal Month Label] nvarchar(20) NOT NULL,
    [Fiscal Year] int NOT NULL,
    [Fiscal Year Label] nvarchar(10) NOT NULL,
    [ISO Week Number] int NOT NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Date dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for date dimension (actual date is used for key)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Date';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Day of the month', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Day Number';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Day name', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Day';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Month name (ie September)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Month';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Short month name (ie Sep)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Short Month';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Calendar month number', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Calendar Month Number';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Calendar month label (ie CY2015Jun)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Calendar Month Label';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Calendar year (ie 2015)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Calendar Year';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Calendar year label (ie CY2015)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Calendar Year Label';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Fiscal month number', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Fiscal Month Number';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Fiscal month label (ie FY2015Feb)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Fiscal Month Label';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Fiscal year (ie 2016)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Fiscal Year';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Fiscal year label (ie FY2015)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'Fiscal Year Label';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'ISO week number (ie 25)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Date', @level2type = N'COLUMN', @level2name = 'ISO Week Number';
GO
 
CREATE TABLE [Dimension].[Employee]
(
    [Employee Key] int NOT NULL
        CONSTRAINT [PK_Dimension_Employee] PRIMARY KEY
        CONSTRAINT [DF_Dimension_Employee_Employee_Key]
            DEFAULT(NEXT VALUE FOR [Sequences].[EmployeeKey]),
    [WWI Employee ID] int NOT NULL,
    [Employee] nvarchar(50) NOT NULL,
    [Preferred Name] nvarchar(50) NOT NULL,
    [Is Salesperson] bit NOT NULL,
    [Photo] varbinary(max) NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [IX_Dimension_Employee_WWIEmployeeID]
ON [Dimension].[Employee]([WWI Employee ID], [Valid From], [Valid To]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI ID', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee', @level2type = N'INDEX', @level2name = 'IX_Dimension_Employee_WWIEmployeeID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Employee dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for the employee dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee', @level2type = N'COLUMN', @level2name = 'Employee Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID (PersonID) in the WWI database', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee', @level2type = N'COLUMN', @level2name = 'WWI Employee ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name for this person', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee', @level2type = N'COLUMN', @level2name = 'Employee';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name that this person prefers to be called', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee', @level2type = N'COLUMN', @level2name = 'Preferred Name';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this person a staff salesperson?', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee', @level2type = N'COLUMN', @level2name = 'Is Salesperson';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Photo of this person', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee', @level2type = N'COLUMN', @level2name = 'Photo';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee', @level2type = N'COLUMN', @level2name = 'Valid To';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Employee', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Dimension].[Payment Method]
(
    [Payment Method Key] int NOT NULL
        CONSTRAINT [PK_Dimension_Payment_Method] PRIMARY KEY
        CONSTRAINT [DF_Dimension_Payment_Method_Payment_Method_Key]
            DEFAULT(NEXT VALUE FOR [Sequences].[PaymentMethodKey]),
    [WWI Payment Method ID] int NOT NULL,
    [Payment Method] nvarchar(50) NOT NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [IX_Dimension_Payment_Method_WWIPaymentMethodID]
ON [Dimension].[Payment Method]([WWI Payment Method ID], [Valid From], [Valid To]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI ID', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Payment Method', @level2type = N'INDEX', @level2name = 'IX_Dimension_Payment_Method_WWIPaymentMethodID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'PaymentMethod dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Payment Method';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for the payment method dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Payment Method', @level2type = N'COLUMN', @level2name = 'Payment Method Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID for the payment method in the WWI database', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Payment Method', @level2type = N'COLUMN', @level2name = 'WWI Payment Method ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Payment method name', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Payment Method', @level2type = N'COLUMN', @level2name = 'Payment Method';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Payment Method', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Payment Method', @level2type = N'COLUMN', @level2name = 'Valid To';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Payment Method', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Dimension].[Stock Item]
(
    [Stock Item Key] int NOT NULL
        CONSTRAINT [PK_Dimension_Stock_Item] PRIMARY KEY
        CONSTRAINT [DF_Dimension_Stock_Item_Stock_Item_Key]
            DEFAULT(NEXT VALUE FOR [Sequences].[StockItemKey]),
    [WWI Stock Item ID] int NOT NULL,
    [Stock Item] nvarchar(100) NOT NULL,
    [Color] nvarchar(20) NOT NULL,
    [Selling Package] nvarchar(50) NOT NULL,
    [Buying Package] nvarchar(50) NOT NULL,
    [Brand] nvarchar(50) NOT NULL,
    [Size] nvarchar(20) NOT NULL,
    [Lead Time Days] int NOT NULL,
    [Quantity Per Outer] int NOT NULL,
    [Is Chiller Stock] bit NOT NULL,
    [Barcode] nvarchar(50) NULL,
    [Tax Rate] decimal(18,3) NOT NULL,
    [Unit Price] decimal(18,2) NOT NULL,
    [Recommended Retail Price] decimal(18,2) NULL,
    [Typical Weight Per Unit] decimal(18,3) NOT NULL,
    [Photo] varbinary(max) NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [IX_Dimension_Stock_Item_WWIStockItemID]
ON [Dimension].[Stock Item]([WWI Stock Item ID], [Valid From], [Valid To]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI ID', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'INDEX', @level2name = 'IX_Dimension_Stock_Item_WWIStockItemID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'StockItem dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for the stock item dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a stock item within the WWI database', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'WWI Stock Item ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of a stock item (but not a full description)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Stock Item';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Color (optional) for this stock item', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Color';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Usual package for selling units of this stock item', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Selling Package';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Usual package for selling outers of this stock item (ie cartons, boxes, etc.)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Buying Package';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Brand for the stock item (if the item is branded)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Brand';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Size of this item (eg: 100mm)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Size';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Number of days typically taken from order to receipt of this stock item', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Lead Time Days';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of the stock item in an outer package', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Quantity Per Outer';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Does this stock item need to be in a chiller?', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Is Chiller Stock';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Barcode for this stock item', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Barcode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax rate to be applied', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Tax Rate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Selling price (ex-tax) for one unit of this product', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Unit Price';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Recommended retail price for this stock item', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Recommended Retail Price';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Typical weight for one unit of this product (packaged)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Typical Weight Per Unit';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Photo of the product', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Photo';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Valid To';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Stock Item', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Dimension].[Supplier]
(
    [Supplier Key] int NOT NULL
        CONSTRAINT [PK_Dimension_Supplier] PRIMARY KEY
        CONSTRAINT [DF_Dimension_Supplier_Supplier_Key]
            DEFAULT(NEXT VALUE FOR [Sequences].[SupplierKey]),
    [WWI Supplier ID] int NOT NULL,
    [Supplier] nvarchar(100) NOT NULL,
    [Category] nvarchar(50) NOT NULL,
    [Primary Contact] nvarchar(50) NOT NULL,
    [Supplier Reference] nvarchar(20) NULL,
    [Payment Days] int NOT NULL,
    [Postal Code] nvarchar(10) NOT NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [IX_Dimension_Supplier_WWISupplierID]
ON [Dimension].[Supplier]([WWI Supplier ID], [Valid From], [Valid To]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI ID', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'INDEX', @level2name = 'IX_Dimension_Supplier_WWISupplierID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Supplier dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for the supplier dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'Supplier Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a supplier within the WWI database', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'WWI Supplier ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s full name (usually a trading name)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'Supplier';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s category', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'Category';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Primary contact', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'Primary Contact';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier reference for our organization (might be our account number at the supplier)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'Supplier Reference';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Number of days for payment of an invoice (ie payment terms)', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'Payment Days';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Delivery postal code for the supplier', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'Postal Code';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'Valid To';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Supplier', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Dimension].[Transaction Type]
(
    [Transaction Type Key] int NOT NULL
        CONSTRAINT [PK_Dimension_Transaction_Type] PRIMARY KEY
        CONSTRAINT [DF_Dimension_Transaction_Type_Transaction_Type_Key]
            DEFAULT(NEXT VALUE FOR [Sequences].[TransactionTypeKey]),
    [WWI Transaction Type ID] int NOT NULL,
    [Transaction Type] nvarchar(50) NOT NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [IX_Dimension_Transaction_Type_WWITransactionTypeID]
ON [Dimension].[Transaction Type]([WWI Transaction Type ID], [Valid From], [Valid To]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI ID', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Transaction Type', @level2type = N'INDEX', @level2name = 'IX_Dimension_Transaction_Type_WWITransactionTypeID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'TransactionType dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Transaction Type';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for the transaction type dimension', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Transaction Type', @level2type = N'COLUMN', @level2name = 'Transaction Type Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a transaction type within the WWI database', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Transaction Type', @level2type = N'COLUMN', @level2name = 'WWI Transaction Type ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of the transaction type', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Transaction Type', @level2type = N'COLUMN', @level2name = 'Transaction Type';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Transaction Type', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Transaction Type', @level2type = N'COLUMN', @level2name = 'Valid To';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Dimension', @level1type = N'TABLE',  @level1name = 'Transaction Type', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Fact].[Movement]
(
    [Movement Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Fact_Movement] PRIMARY KEY,
    [Date Key] date NOT NULL
        CONSTRAINT [FK_Fact_Movement_Date_Key_Dimension_Date]
            FOREIGN KEY REFERENCES [Dimension].[Date] ([Date]),
    [Stock Item Key] int NOT NULL
        CONSTRAINT [FK_Fact_Movement_Stock_Item_Key_Dimension_Stock Item]
            FOREIGN KEY REFERENCES [Dimension].[Stock Item] ([Stock Item Key]),
    [Customer Key] int NULL
        CONSTRAINT [FK_Fact_Movement_Customer_Key_Dimension_Customer]
            FOREIGN KEY REFERENCES [Dimension].[Customer] ([Customer Key]),
    [Supplier Key] int NULL
        CONSTRAINT [FK_Fact_Movement_Supplier_Key_Dimension_Supplier]
            FOREIGN KEY REFERENCES [Dimension].[Supplier] ([Supplier Key]),
    [Transaction Type Key] int NOT NULL
        CONSTRAINT [FK_Fact_Movement_Transaction_Type_Key_Dimension_Transaction Type]
            FOREIGN KEY REFERENCES [Dimension].[Transaction Type] ([Transaction Type Key]),
    [WWI Stock Item Transaction ID] int NOT NULL,
    [WWI Invoice ID] int NULL,
    [WWI Purchase Order ID] int NULL,
    [Quantity] int NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [FK_Fact_Movement_Date_Key]
ON [Fact].[Movement] ([Date Key]);
CREATE INDEX [FK_Fact_Movement_Stock_Item_Key]
ON [Fact].[Movement] ([Stock Item Key]);
CREATE INDEX [FK_Fact_Movement_Customer_Key]
ON [Fact].[Movement] ([Customer Key]);
CREATE INDEX [FK_Fact_Movement_Supplier_Key]
ON [Fact].[Movement] ([Supplier Key]);
CREATE INDEX [FK_Fact_Movement_Transaction_Type_Key]
ON [Fact].[Movement] ([Transaction Type Key]);
GO
 
CREATE INDEX [IX_Integration_Movement_WWI_Stock_Item_Transaction_ID]
ON [Fact].[Movement]([WWI Stock Item Transaction ID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI Stock Item Transaction ID', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'INDEX', @level2name = 'IX_Integration_Movement_WWI_Stock_Item_Transaction_ID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Movement fact table (movements of stock items)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Movement fact', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'Movement Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'INDEX', @level2name = 'FK_Fact_Movement_Date_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Transaction date', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'INDEX', @level2name = 'FK_Fact_Movement_Stock_Item_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this purchase order', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'INDEX', @level2name = 'FK_Fact_Movement_Customer_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer (if applicable)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'INDEX', @level2name = 'FK_Fact_Movement_Supplier_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier (if applicable)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'Supplier Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'INDEX', @level2name = 'FK_Fact_Movement_Transaction_Type_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of transaction', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'Transaction Type Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item transaction ID in source system', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'WWI Stock Item Transaction ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Invoice ID in source system', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'WWI Invoice ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase order ID in source system', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'WWI Purchase Order ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of stock movement (positive is incoming stock, negative is outgoing)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Movement', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Fact].[Order]
(
    [Order Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Fact_Order] PRIMARY KEY,
    [City Key] int NOT NULL
        CONSTRAINT [FK_Fact_Order_City_Key_Dimension_City]
            FOREIGN KEY REFERENCES [Dimension].[City] ([City Key]),
    [Customer Key] int NOT NULL
        CONSTRAINT [FK_Fact_Order_Customer_Key_Dimension_Customer]
            FOREIGN KEY REFERENCES [Dimension].[Customer] ([Customer Key]),
    [Stock Item Key] int NOT NULL
        CONSTRAINT [FK_Fact_Order_Stock_Item_Key_Dimension_Stock Item]
            FOREIGN KEY REFERENCES [Dimension].[Stock Item] ([Stock Item Key]),
    [Order Date Key] date NOT NULL
        CONSTRAINT [FK_Fact_Order_Order_Date_Key_Dimension_Date]
            FOREIGN KEY REFERENCES [Dimension].[Date] ([Date]),
    [Picked Date Key] date NULL
        CONSTRAINT [FK_Fact_Order_Picked_Date_Key_Dimension_Date]
            FOREIGN KEY REFERENCES [Dimension].[Date] ([Date]),
    [Salesperson Key] int NOT NULL
        CONSTRAINT [FK_Fact_Order_Salesperson_Key_Dimension_Employee]
            FOREIGN KEY REFERENCES [Dimension].[Employee] ([Employee Key]),
    [Picker Key] int NULL
        CONSTRAINT [FK_Fact_Order_Picker_Key_Dimension_Employee]
            FOREIGN KEY REFERENCES [Dimension].[Employee] ([Employee Key]),
    [WWI Order ID] int NOT NULL,
    [WWI Backorder ID] int NULL,
    [Description] nvarchar(100) NOT NULL,
    [Package] nvarchar(50) NOT NULL,
    [Quantity] int NOT NULL,
    [Unit Price] decimal(18,2) NOT NULL,
    [Tax Rate] decimal(18,3) NOT NULL,
    [Total Excluding Tax] decimal(18,2) NOT NULL,
    [Tax Amount] decimal(18,2) NOT NULL,
    [Total Including Tax] decimal(18,2) NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [FK_Fact_Order_City_Key]
ON [Fact].[Order] ([City Key]);
CREATE INDEX [FK_Fact_Order_Customer_Key]
ON [Fact].[Order] ([Customer Key]);
CREATE INDEX [FK_Fact_Order_Stock_Item_Key]
ON [Fact].[Order] ([Stock Item Key]);
CREATE INDEX [FK_Fact_Order_Order_Date_Key]
ON [Fact].[Order] ([Order Date Key]);
CREATE INDEX [FK_Fact_Order_Picked_Date_Key]
ON [Fact].[Order] ([Picked Date Key]);
CREATE INDEX [FK_Fact_Order_Salesperson_Key]
ON [Fact].[Order] ([Salesperson Key]);
CREATE INDEX [FK_Fact_Order_Picker_Key]
ON [Fact].[Order] ([Picker Key]);
GO
 
CREATE INDEX [IX_Integration_Order_WWI_Order_ID]
ON [Fact].[Order]([WWI Order ID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI Order ID', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'INDEX', @level2name = 'IX_Integration_Order_WWI_Order_ID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Order fact table (customer orders)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Order fact', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Order Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'INDEX', @level2name = 'FK_Fact_Order_City_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'City for this order', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'City Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'INDEX', @level2name = 'FK_Fact_Order_Customer_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer for this order', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'INDEX', @level2name = 'FK_Fact_Order_Stock_Item_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this order', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'INDEX', @level2name = 'FK_Fact_Order_Order_Date_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Order date for this order', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Order Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'INDEX', @level2name = 'FK_Fact_Order_Picked_Date_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Picked date for this order', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Picked Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'INDEX', @level2name = 'FK_Fact_Order_Salesperson_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Salesperson for this order', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Salesperson Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'INDEX', @level2name = 'FK_Fact_Order_Picker_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Picker for this order', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Picker Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'OrderID in source system', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'WWI Order ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'BackorderID in source system', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'WWI Backorder ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Description of the item supplied (Usually the stock item name but can be overridden)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Description';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of package to be supplied', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Package';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity to be supplied', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Unit price to be charged', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Unit Price';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax rate to be applied', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Tax Rate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount excluding tax', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Total Excluding Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount of tax', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Tax Amount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount including tax', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Total Including Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Order', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Fact].[Purchase]
(
    [Purchase Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Fact_Purchase] PRIMARY KEY,
    [Date Key] date NOT NULL
        CONSTRAINT [FK_Fact_Purchase_Date_Key_Dimension_Date]
            FOREIGN KEY REFERENCES [Dimension].[Date] ([Date]),
    [Supplier Key] int NOT NULL
        CONSTRAINT [FK_Fact_Purchase_Supplier_Key_Dimension_Supplier]
            FOREIGN KEY REFERENCES [Dimension].[Supplier] ([Supplier Key]),
    [Stock Item Key] int NOT NULL
        CONSTRAINT [FK_Fact_Purchase_Stock_Item_Key_Dimension_Stock Item]
            FOREIGN KEY REFERENCES [Dimension].[Stock Item] ([Stock Item Key]),
    [WWI Purchase Order ID] int NULL,
    [Ordered Outers] int NOT NULL,
    [Ordered Quantity] int NOT NULL,
    [Received Outers] int NOT NULL,
    [Package] nvarchar(50) NOT NULL,
    [Is Order Finalized] bit NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [FK_Fact_Purchase_Date_Key]
ON [Fact].[Purchase] ([Date Key]);
CREATE INDEX [FK_Fact_Purchase_Supplier_Key]
ON [Fact].[Purchase] ([Supplier Key]);
CREATE INDEX [FK_Fact_Purchase_Stock_Item_Key]
ON [Fact].[Purchase] ([Stock Item Key]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Purchase fact table (stock purchases from suppliers)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Purchase fact', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'Purchase Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'INDEX', @level2name = 'FK_Fact_Purchase_Date_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase order date', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'INDEX', @level2name = 'FK_Fact_Purchase_Supplier_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier for this purchase order', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'Supplier Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'INDEX', @level2name = 'FK_Fact_Purchase_Stock_Item_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this purchase order', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase order ID in source system ', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'WWI Purchase Order ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of outers (ordering packages)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'Ordered Outers';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of inners (selling packages)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'Ordered Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Received outers (so far)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'Received Outers';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Package ordered', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'Package';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this purchase order now finalized?', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'Is Order Finalized';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Purchase', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Fact].[Sale]
(
    [Sale Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Fact_Sale] PRIMARY KEY,
    [City Key] int NOT NULL
        CONSTRAINT [FK_Fact_Sale_City_Key_Dimension_City]
            FOREIGN KEY REFERENCES [Dimension].[City] ([City Key]),
    [Customer Key] int NOT NULL
        CONSTRAINT [FK_Fact_Sale_Customer_Key_Dimension_Customer]
            FOREIGN KEY REFERENCES [Dimension].[Customer] ([Customer Key]),
    [Bill To Customer Key] int NOT NULL
        CONSTRAINT [FK_Fact_Sale_Bill_To_Customer_Key_Dimension_Customer]
            FOREIGN KEY REFERENCES [Dimension].[Customer] ([Customer Key]),
    [Stock Item Key] int NOT NULL
        CONSTRAINT [FK_Fact_Sale_Stock_Item_Key_Dimension_Stock Item]
            FOREIGN KEY REFERENCES [Dimension].[Stock Item] ([Stock Item Key]),
    [Invoice Date Key] date NOT NULL
        CONSTRAINT [FK_Fact_Sale_Invoice_Date_Key_Dimension_Date]
            FOREIGN KEY REFERENCES [Dimension].[Date] ([Date]),
    [Delivery Date Key] date NULL
        CONSTRAINT [FK_Fact_Sale_Delivery_Date_Key_Dimension_Date]
            FOREIGN KEY REFERENCES [Dimension].[Date] ([Date]),
    [Salesperson Key] int NOT NULL
        CONSTRAINT [FK_Fact_Sale_Salesperson_Key_Dimension_Employee]
            FOREIGN KEY REFERENCES [Dimension].[Employee] ([Employee Key]),
    [WWI Invoice ID] int NOT NULL,
    [Description] nvarchar(100) NOT NULL,
    [Package] nvarchar(50) NOT NULL,
    [Quantity] int NOT NULL,
    [Unit Price] decimal(18,2) NOT NULL,
    [Tax Rate] decimal(18,3) NOT NULL,
    [Total Excluding Tax] decimal(18,2) NOT NULL,
    [Tax Amount] decimal(18,2) NOT NULL,
    [Profit] decimal(18,2) NOT NULL,
    [Total Including Tax] decimal(18,2) NOT NULL,
    [Total Dry Items] int NOT NULL,
    [Total Chiller Items] int NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [FK_Fact_Sale_City_Key]
ON [Fact].[Sale] ([City Key]);
CREATE INDEX [FK_Fact_Sale_Customer_Key]
ON [Fact].[Sale] ([Customer Key]);
CREATE INDEX [FK_Fact_Sale_Bill_To_Customer_Key]
ON [Fact].[Sale] ([Bill To Customer Key]);
CREATE INDEX [FK_Fact_Sale_Stock_Item_Key]
ON [Fact].[Sale] ([Stock Item Key]);
CREATE INDEX [FK_Fact_Sale_Invoice_Date_Key]
ON [Fact].[Sale] ([Invoice Date Key]);
CREATE INDEX [FK_Fact_Sale_Delivery_Date_Key]
ON [Fact].[Sale] ([Delivery Date Key]);
CREATE INDEX [FK_Fact_Sale_Salesperson_Key]
ON [Fact].[Sale] ([Salesperson Key]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Sale fact table (invoiced sales to customers)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Sale fact', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Sale Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'INDEX', @level2name = 'FK_Fact_Sale_City_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'City for this invoice', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'City Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'INDEX', @level2name = 'FK_Fact_Sale_Customer_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer for this invoice', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'INDEX', @level2name = 'FK_Fact_Sale_Bill_To_Customer_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bill To Customer for this invoice', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Bill To Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'INDEX', @level2name = 'FK_Fact_Sale_Stock_Item_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this invoice', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'INDEX', @level2name = 'FK_Fact_Sale_Invoice_Date_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Invoice date for this invoice', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Invoice Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'INDEX', @level2name = 'FK_Fact_Sale_Delivery_Date_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date that these items were delivered', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Delivery Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'INDEX', @level2name = 'FK_Fact_Sale_Salesperson_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Salesperson for this invoice', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Salesperson Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'InvoiceID in source system', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'WWI Invoice ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Description of the item supplied (Usually the stock item name but can be overridden)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Description';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of package supplied', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Package';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity supplied', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Unit price charged', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Unit Price';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax rate applied', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Tax Rate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount excluding tax', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Total Excluding Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount of tax', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Tax Amount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount of profit', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Profit';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount including tax', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Total Including Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total number of dry items', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Total Dry Items';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total number of chiller items', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Total Chiller Items';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Sale', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Fact].[Stock Holding]
(
    [Stock Holding Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Fact_Stock_Holding] PRIMARY KEY,
    [Stock Item Key] int NOT NULL
        CONSTRAINT [FK_Fact_Stock_Holding_Stock_Item_Key_Dimension_Stock Item]
            FOREIGN KEY REFERENCES [Dimension].[Stock Item] ([Stock Item Key]),
    [Quantity On Hand] int NOT NULL,
    [Bin Location] nvarchar(20) NOT NULL,
    [Last Stocktake Quantity] int NOT NULL,
    [Last Cost Price] decimal(18,2) NOT NULL,
    [Reorder Level] int NOT NULL,
    [Target Stock Level] int NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [FK_Fact_Stock_Holding_Stock_Item_Key]
ON [Fact].[Stock Holding] ([Stock Item Key]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Holdings of stock items', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Stock Holding fact', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding', @level2type = N'COLUMN', @level2name = 'Stock Holding Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding', @level2type = N'INDEX', @level2name = 'FK_Fact_Stock_Holding_Stock_Item_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item being held', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity on hand', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding', @level2type = N'COLUMN', @level2name = 'Quantity On Hand';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bin location (where is this stock in the warehouse)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding', @level2type = N'COLUMN', @level2name = 'Bin Location';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity present at last stocktake', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding', @level2type = N'COLUMN', @level2name = 'Last Stocktake Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Unit cost when the stock item was last purchased', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding', @level2type = N'COLUMN', @level2name = 'Last Cost Price';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity below which reordering should take place', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding', @level2type = N'COLUMN', @level2name = 'Reorder Level';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Typical stock level held', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding', @level2type = N'COLUMN', @level2name = 'Target Stock Level';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Stock Holding', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Fact].[Transaction]
(
    [Transaction Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Fact_Transaction] PRIMARY KEY,
    [Date Key] date NOT NULL
        CONSTRAINT [FK_Fact_Transaction_Date_Key_Dimension_Date]
            FOREIGN KEY REFERENCES [Dimension].[Date] ([Date]),
    [Customer Key] int NULL
        CONSTRAINT [FK_Fact_Transaction_Customer_Key_Dimension_Customer]
            FOREIGN KEY REFERENCES [Dimension].[Customer] ([Customer Key]),
    [Bill To Customer Key] int NULL
        CONSTRAINT [FK_Fact_Transaction_Bill_To_Customer_Key_Dimension_Customer]
            FOREIGN KEY REFERENCES [Dimension].[Customer] ([Customer Key]),
    [Supplier Key] int NULL
        CONSTRAINT [FK_Fact_Transaction_Supplier_Key_Dimension_Supplier]
            FOREIGN KEY REFERENCES [Dimension].[Supplier] ([Supplier Key]),
    [Transaction Type Key] int NOT NULL
        CONSTRAINT [FK_Fact_Transaction_Transaction_Type_Key_Dimension_Transaction Type]
            FOREIGN KEY REFERENCES [Dimension].[Transaction Type] ([Transaction Type Key]),
    [Payment Method Key] int NULL
        CONSTRAINT [FK_Fact_Transaction_Payment_Method_Key_Dimension_Payment Method]
            FOREIGN KEY REFERENCES [Dimension].[Payment Method] ([Payment Method Key]),
    [WWI Customer Transaction ID] int NULL,
    [WWI Supplier Transaction ID] int NULL,
    [WWI Invoice ID] int NULL,
    [WWI Purchase Order ID] int NULL,
    [Supplier Invoice Number] nvarchar(20) NULL,
    [Total Excluding Tax] decimal(18,2) NOT NULL,
    [Tax Amount] decimal(18,2) NOT NULL,
    [Total Including Tax] decimal(18,2) NOT NULL,
    [Outstanding Balance] decimal(18,2) NOT NULL,
    [Is Finalized] bit NOT NULL,
    [Lineage Key] int NOT NULL
);
GO
 
CREATE INDEX [FK_Fact_Transaction_Date_Key]
ON [Fact].[Transaction] ([Date Key]);
CREATE INDEX [FK_Fact_Transaction_Customer_Key]
ON [Fact].[Transaction] ([Customer Key]);
CREATE INDEX [FK_Fact_Transaction_Bill_To_Customer_Key]
ON [Fact].[Transaction] ([Bill To Customer Key]);
CREATE INDEX [FK_Fact_Transaction_Supplier_Key]
ON [Fact].[Transaction] ([Supplier Key]);
CREATE INDEX [FK_Fact_Transaction_Transaction_Type_Key]
ON [Fact].[Transaction] ([Transaction Type Key]);
CREATE INDEX [FK_Fact_Transaction_Payment_Method_Key]
ON [Fact].[Transaction] ([Payment Method Key]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Transaction fact table (financial transactions involving customers and supppliers)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Transaction fact', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Transaction Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'INDEX', @level2name = 'FK_Fact_Transaction_Date_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Transaction date', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'INDEX', @level2name = 'FK_Fact_Transaction_Customer_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer (if applicable)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'INDEX', @level2name = 'FK_Fact_Transaction_Bill_To_Customer_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bill to customer (if applicable)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Bill To Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'INDEX', @level2name = 'FK_Fact_Transaction_Supplier_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier (if applicable)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Supplier Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'INDEX', @level2name = 'FK_Fact_Transaction_Transaction_Type_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of transaction', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Transaction Type Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Auto-created to support a foreign key',@level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'INDEX', @level2name = 'FK_Fact_Transaction_Payment_Method_Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Payment method (if applicable)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Payment Method Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer transaction ID in source system', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'WWI Customer Transaction ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier transaction ID in source system', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'WWI Supplier Transaction ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Invoice ID in source system', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'WWI Invoice ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase order ID in source system', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'WWI Purchase Order ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier invoice number (if applicable)', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Supplier Invoice Number';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount excluding tax', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Total Excluding Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount of tax', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Tax Amount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount including tax', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Total Including Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Amount still outstanding for this transaction', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Outstanding Balance';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Has this transaction been finalized?', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Is Finalized';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Fact', @level1type = N'TABLE',  @level1name = 'Transaction', @level2type = N'COLUMN', @level2name = 'Lineage Key';
GO
 
CREATE TABLE [Integration].[City_Staging]
(
    [City Staging Key] int NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_City_Staging] PRIMARY KEY,
    [WWI City ID] int NOT NULL,
    [City] nvarchar(50) NOT NULL,
    [State Province] nvarchar(50) NOT NULL,
    [Country] nvarchar(60) NOT NULL,
    [Continent] nvarchar(30) NOT NULL,
    [Sales Territory] nvarchar(50) NOT NULL,
    [Region] nvarchar(30) NOT NULL,
    [Subregion] nvarchar(30) NOT NULL,
    [Location] geography NULL,
    [Latest Recorded Population] bigint NOT NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL
);
GO
 
CREATE INDEX [IX_Integration_City_Staging_WWI_City_ID]
ON [Integration].[City_Staging]([WWI City ID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI City Key', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'INDEX', @level2name = 'IX_Integration_City_Staging_WWI_City_ID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'City staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Row ID within the staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'City Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a city within the WWI database', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'WWI City ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Formal name of the city', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'City';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'State or province for this city', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'State Province';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Country name', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'Country';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Continent that this city is on', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'Continent';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Sales territory for this StateProvince', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'Sales Territory';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name of the region', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'Region';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name of the subregion', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'Subregion';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Geographic location of the city', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'Location';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Latest available population for the City', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'Latest Recorded Population';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'City_Staging', @level2type = N'COLUMN', @level2name = 'Valid To';
GO
 
CREATE TABLE [Integration].[Customer_Staging]
(
    [Customer Staging Key] int NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_Customer_Staging] PRIMARY KEY,
    [WWI Customer ID] int NOT NULL,
    [Customer] nvarchar(100) NOT NULL,
    [Bill To Customer] nvarchar(100) NOT NULL,
    [Category] nvarchar(50) NOT NULL,
    [Buying Group] nvarchar(50) NOT NULL,
    [Primary Contact] nvarchar(50) NOT NULL,
    [Postal Code] nvarchar(10) NOT NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL
);
GO
 
CREATE INDEX [IX_Integration_Customer_Staging_WWI_Customer_ID]
ON [Integration].[Customer_Staging]([WWI Customer ID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI Customer ID', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'INDEX', @level2name = 'IX_Integration_Customer_Staging_WWI_Customer_ID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Customer staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Row ID within the staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'COLUMN', @level2name = 'Customer Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a customer within the WWI database', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'COLUMN', @level2name = 'WWI Customer ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer''s full name (usually a trading name)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'COLUMN', @level2name = 'Customer';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bill to customer''s full name', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'COLUMN', @level2name = 'Bill To Customer';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer''s category', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'COLUMN', @level2name = 'Category';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer''s buying group', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'COLUMN', @level2name = 'Buying Group';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Primary contact', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'COLUMN', @level2name = 'Primary Contact';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Delivery postal code for the customer', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'COLUMN', @level2name = 'Postal Code';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Customer_Staging', @level2type = N'COLUMN', @level2name = 'Valid To';
GO
 
CREATE TABLE [Integration].[Employee_Staging]
(
    [Employee Staging Key] int NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_Employee_Staging] PRIMARY KEY,
    [WWI Employee ID] int NOT NULL,
    [Employee] nvarchar(50) NOT NULL,
    [Preferred Name] nvarchar(50) NOT NULL,
    [Is Salesperson] bit NOT NULL,
    [Photo] varbinary(max) NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL
);
GO
 
CREATE INDEX [IX_Integration_Employee_Staging_WWI_Employee_ID]
ON [Integration].[Employee_Staging]([WWI Employee ID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI Employee ID', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Employee_Staging', @level2type = N'INDEX', @level2name = 'IX_Integration_Employee_Staging_WWI_Employee_ID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Employee staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Employee_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Row ID within the staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Employee_Staging', @level2type = N'COLUMN', @level2name = 'Employee Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID (PersonID) in the WWI database', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Employee_Staging', @level2type = N'COLUMN', @level2name = 'WWI Employee ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name for this person', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Employee_Staging', @level2type = N'COLUMN', @level2name = 'Employee';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name that this person prefers to be called', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Employee_Staging', @level2type = N'COLUMN', @level2name = 'Preferred Name';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this person a staff salesperson?', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Employee_Staging', @level2type = N'COLUMN', @level2name = 'Is Salesperson';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Photo of this person', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Employee_Staging', @level2type = N'COLUMN', @level2name = 'Photo';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Employee_Staging', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Employee_Staging', @level2type = N'COLUMN', @level2name = 'Valid To';
GO
 
CREATE TABLE [Integration].[PaymentMethod_Staging]
(
    [Payment Method Staging Key] int NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_PaymentMethod_Staging] PRIMARY KEY,
    [WWI Payment Method ID] int NOT NULL,
    [Payment Method] nvarchar(50) NOT NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL
);
GO
 
CREATE INDEX [IX_Integration_PaymentMethod_Staging_WWI_Payment_Method_ID]
ON [Integration].[PaymentMethod_Staging]([WWI Payment Method ID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI Payment Method ID', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'PaymentMethod_Staging', @level2type = N'INDEX', @level2name = 'IX_Integration_PaymentMethod_Staging_WWI_Payment_Method_ID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Payment method staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'PaymentMethod_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Row ID within the staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'PaymentMethod_Staging', @level2type = N'COLUMN', @level2name = 'Payment Method Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID for the payment method in the WWI database', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'PaymentMethod_Staging', @level2type = N'COLUMN', @level2name = 'WWI Payment Method ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Payment method name', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'PaymentMethod_Staging', @level2type = N'COLUMN', @level2name = 'Payment Method';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'PaymentMethod_Staging', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'PaymentMethod_Staging', @level2type = N'COLUMN', @level2name = 'Valid To';
GO
 
CREATE TABLE [Integration].[StockItem_Staging]
(
    [Stock Item Staging Key] int NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_StockItem_Staging] PRIMARY KEY,
    [WWI Stock Item ID] int NOT NULL,
    [Stock Item] nvarchar(100) NOT NULL,
    [Color] nvarchar(20) NOT NULL,
    [Selling Package] nvarchar(50) NOT NULL,
    [Buying Package] nvarchar(50) NOT NULL,
    [Brand] nvarchar(50) NOT NULL,
    [Size] nvarchar(20) NOT NULL,
    [Lead Time Days] int NOT NULL,
    [Quantity Per Outer] int NOT NULL,
    [Is Chiller Stock] bit NOT NULL,
    [Barcode] nvarchar(50) NULL,
    [Tax Rate] decimal(18,3) NOT NULL,
    [Unit Price] decimal(18,2) NOT NULL,
    [Recommended Retail Price] decimal(18,2) NULL,
    [Typical Weight Per Unit] decimal(18,3) NOT NULL,
    [Photo] varbinary(max) NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL
);
GO
 
CREATE INDEX [IX_Integration_StockItem_Staging_WWI_Stock_Item_ID]
ON [Integration].[StockItem_Staging]([WWI Stock Item ID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI Stock Item ID', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'INDEX', @level2name = 'IX_Integration_StockItem_Staging_WWI_Stock_Item_ID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Stock item staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Row ID within the staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Stock Item Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a stock item within the WWI database', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'WWI Stock Item ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of a stock item (but not a full description)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Stock Item';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Color (optional) for this stock item', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Color';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Usual package for selling units of this stock item', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Selling Package';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Usual package for selling outers of this stock item (ie cartons, boxes, etc.)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Buying Package';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Brand for the stock item (if the item is branded)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Brand';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Size of this item (eg: 100mm)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Size';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Number of days typically taken from order to receipt of this stock item', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Lead Time Days';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of the stock item in an outer package', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Quantity Per Outer';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Does this stock item need to be in a chiller?', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Is Chiller Stock';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Barcode for this stock item', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Barcode';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax rate to be applied', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Tax Rate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Selling price (ex-tax) for one unit of this product', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Unit Price';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Recommended retail price for this stock item', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Recommended Retail Price';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Typical weight for one unit of this product (packaged)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Typical Weight Per Unit';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Photo of the product', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Photo';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockItem_Staging', @level2type = N'COLUMN', @level2name = 'Valid To';
GO
 
CREATE TABLE [Integration].[Supplier_Staging]
(
    [Supplier Staging Key] int NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_Supplier_Staging] PRIMARY KEY,
    [WWI Supplier ID] int NOT NULL,
    [Supplier] nvarchar(100) NOT NULL,
    [Category] nvarchar(50) NOT NULL,
    [Primary Contact] nvarchar(50) NOT NULL,
    [Supplier Reference] nvarchar(20) NULL,
    [Payment Days] int NOT NULL,
    [Postal Code] nvarchar(10) NOT NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL
);
GO
 
CREATE INDEX [IX_Integration_Supplier_Staging_WWI_Supplier_ID]
ON [Integration].[Supplier_Staging]([WWI Supplier ID]);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Allows quickly locating by WWI Supplier ID', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'INDEX', @level2name = 'IX_Integration_Supplier_Staging_WWI_Supplier_ID';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Supplier staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Row ID within the staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'COLUMN', @level2name = 'Supplier Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a supplier within the WWI database', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'COLUMN', @level2name = 'WWI Supplier ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s full name (usually a trading name)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'COLUMN', @level2name = 'Supplier';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier''s category', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'COLUMN', @level2name = 'Category';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Primary contact', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'COLUMN', @level2name = 'Primary Contact';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier reference for our organization (might be our account number at the supplier)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'COLUMN', @level2name = 'Supplier Reference';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Number of days for payment of an invoice (ie payment terms)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'COLUMN', @level2name = 'Payment Days';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Delivery postal code for the supplier', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'COLUMN', @level2name = 'Postal Code';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Supplier_Staging', @level2type = N'COLUMN', @level2name = 'Valid To';
GO
 
CREATE TABLE [Integration].[TransactionType_Staging]
(
    [Transaction Type Staging Key] int NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_TransactionType_Staging] PRIMARY KEY,
    [WWI Transaction Type ID] int NOT NULL,
    [Transaction Type] nvarchar(50) NOT NULL,
    [Valid From] datetime2(7) NOT NULL,
    [Valid To] datetime2(7) NOT NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Transaction type staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'TransactionType_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Row ID within the staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'TransactionType_Staging', @level2type = N'COLUMN', @level2name = 'Transaction Type Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Numeric ID used for reference to a transaction type within the WWI database', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'TransactionType_Staging', @level2type = N'COLUMN', @level2name = 'WWI Transaction Type ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Full name of the transaction type', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'TransactionType_Staging', @level2type = N'COLUMN', @level2name = 'Transaction Type';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid from this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'TransactionType_Staging', @level2type = N'COLUMN', @level2name = 'Valid From';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Valid until this date and time', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'TransactionType_Staging', @level2type = N'COLUMN', @level2name = 'Valid To';
GO
 
CREATE TABLE [Integration].[Movement_Staging]
(
    [Movement Staging Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_Movement_Staging] PRIMARY KEY,
    [Date Key] date NULL,
    [Stock Item Key] int NULL,
    [Customer Key] int NULL,
    [Supplier Key] int NULL,
    [Transaction Type Key] int NULL,
    [WWI Stock Item Transaction ID] int NULL,
    [WWI Invoice ID] int NULL,
    [WWI Purchase Order ID] int NULL,
    [Quantity] int NULL,
    [WWI Stock Item ID] int NULL,
    [WWI Customer ID] int NULL,
    [WWI Supplier ID] int NULL,
    [WWI Transaction Type ID] int NULL,
    [Last Modifed When] datetime2(7) NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Movement staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Movement fact', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'Movement Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Transaction date', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this purchase order', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer (if applicable)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier (if applicable)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'Supplier Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of transaction', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'Transaction Type Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item transaction ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'WWI Stock Item Transaction ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Invoice ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'WWI Invoice ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase order ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'WWI Purchase Order ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of stock movement (positive is incoming stock, negative is outgoing)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock Item ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'WWI Stock Item ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'WWI Customer ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'WWI Supplier ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Transaction Type ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'WWI Transaction Type ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'When this row was last modified', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Movement_Staging', @level2type = N'COLUMN', @level2name = 'Last Modifed When';
GO
 
CREATE TABLE [Integration].[Order_Staging]
(
    [Order Staging Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_Order_Staging] PRIMARY KEY,
    [City Key] int NULL,
    [Customer Key] int NULL,
    [Stock Item Key] int NULL,
    [Order Date Key] date NULL,
    [Picked Date Key] date NULL,
    [Salesperson Key] int NULL,
    [Picker Key] int NULL,
    [WWI Order ID] int NULL,
    [WWI Backorder ID] int NULL,
    [Description] nvarchar(100) NULL,
    [Package] nvarchar(50) NULL,
    [Quantity] int NULL,
    [Unit Price] decimal(18,2) NULL,
    [Tax Rate] decimal(18,3) NULL,
    [Total Excluding Tax] decimal(18,2) NULL,
    [Tax Amount] decimal(18,2) NULL,
    [Total Including Tax] decimal(18,2) NULL,
    [Lineage Key] int NULL,
    [WWI City ID] int NULL,
    [WWI Customer ID] int NULL,
    [WWI Stock Item ID] int NULL,
    [WWI Salesperson ID] int NULL,
    [WWI Picker ID] int NULL,
    [Last Modified When] datetime2(7) NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Order staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Order fact', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Order Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'City for this order', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'City Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer for this order', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this order', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Order date for this order', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Order Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Picked date for this order', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Picked Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Salesperson for this order', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Salesperson Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Picker for this order', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Picker Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'OrderID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'WWI Order ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'BackorderID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'WWI Backorder ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Description of the item supplied (Usually the stock item name but can be overridden)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Description';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of package to be supplied', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Package';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity to be supplied', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Unit price to be charged', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Unit Price';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax rate to be applied', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Tax Rate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount excluding tax', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Total Excluding Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount of tax', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Tax Amount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount including tax', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Total Including Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Lineage Key for the data load for this row', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Lineage Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'City ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'WWI City ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'WWI Customer ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock Item ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'WWI Stock Item ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Salesperson person ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'WWI Salesperson ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Picker person ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'WWI Picker ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'When this row was last modified', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Order_Staging', @level2type = N'COLUMN', @level2name = 'Last Modified When';
GO
 
CREATE TABLE [Integration].[Purchase_Staging]
(
    [Purchase Staging Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_Purchase_Staging] PRIMARY KEY,
    [Date Key] date NULL,
    [Supplier Key] int NULL,
    [Stock Item Key] int NULL,
    [WWI Purchase Order ID] int NULL,
    [Ordered Outers] int NULL,
    [Ordered Quantity] int NULL,
    [Received Outers] int NULL,
    [Package] nvarchar(50) NULL,
    [Is Order Finalized] bit NULL,
    [WWI Supplier ID] int NULL,
    [WWI Stock Item ID] int NULL,
    [Last Modified When] datetime2(7) NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Purchase staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Purchase fact', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'Purchase Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase order date', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier for this purchase order', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'Supplier Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this purchase order', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase order ID in source system ', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'WWI Purchase Order ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of outers (ordering packages)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'Ordered Outers';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity of inners (selling packages)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'Ordered Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Received outers (so far)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'Received Outers';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Package ordered', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'Package';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Is this purchase order now finalized?', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'Is Order Finalized';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'WWI Supplier ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock Item ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'WWI Stock Item ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'When this row was last modified', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Purchase_Staging', @level2type = N'COLUMN', @level2name = 'Last Modified When';
GO
 
CREATE TABLE [Integration].[Sale_Staging]
(
    [Sale Staging Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_Sale_Staging] PRIMARY KEY,
    [City Key] int NULL,
    [Customer Key] int NULL,
    [Bill To Customer Key] int NULL,
    [Stock Item Key] int NULL,
    [Invoice Date Key] date NULL,
    [Delivery Date Key] date NULL,
    [Salesperson Key] int NULL,
    [WWI Invoice ID] int NULL,
    [Description] nvarchar(100) NULL,
    [Package] nvarchar(50) NULL,
    [Quantity] int NULL,
    [Unit Price] decimal(18,2) NULL,
    [Tax Rate] decimal(18,3) NULL,
    [Total Excluding Tax] decimal(18,2) NULL,
    [Tax Amount] decimal(18,2) NULL,
    [Profit] decimal(18,2) NULL,
    [Total Including Tax] decimal(18,2) NULL,
    [Total Dry Items] int NULL,
    [Total Chiller Items] int NULL,
    [WWI City ID] int NULL,
    [WWI Customer ID] int NULL,
    [WWI Bill To Customer ID] int NULL,
    [WWI Stock Item ID] int NULL,
    [WWI Salesperson ID] int NULL,
    [Last Modified When] datetime2(7) NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Sale staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Sale fact', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Sale Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'City for this invoice', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'City Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer for this invoice', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bill To Customer for this invoice', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Bill To Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item for this invoice', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Invoice date for this invoice', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Invoice Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Date that these items were delivered', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Delivery Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Salesperson for this invoice', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Salesperson Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'InvoiceID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'WWI Invoice ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Description of the item supplied (Usually the stock item name but can be overridden)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Description';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of package supplied', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Package';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity supplied', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Unit price charged', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Unit Price';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Tax rate applied', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Tax Rate';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount excluding tax', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Total Excluding Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount of tax', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Tax Amount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount of profit', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Profit';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount including tax', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Total Including Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total number of dry items', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Total Dry Items';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total number of chiller items', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Total Chiller Items';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'City ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'WWI City ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'WWI Customer ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bill to Customer ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'WWI Bill To Customer ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock Item ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'WWI Stock Item ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Salesperson person ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'WWI Salesperson ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'When this row was last modified', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Sale_Staging', @level2type = N'COLUMN', @level2name = 'Last Modified When';
GO
 
CREATE TABLE [Integration].[StockHolding_Staging]
(
    [Stock Holding Staging Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_StockHolding_Staging] PRIMARY KEY,
    [Stock Item Key] int NULL,
    [Quantity On Hand] int NULL,
    [Bin Location] nvarchar(20) NULL,
    [Last Stocktake Quantity] int NULL,
    [Last Cost Price] decimal(18,2) NULL,
    [Reorder Level] int NULL,
    [Target Stock Level] int NULL,
    [WWI Stock Item ID] int NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Stock holding staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockHolding_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Stock Holding fact', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockHolding_Staging', @level2type = N'COLUMN', @level2name = 'Stock Holding Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock item being held', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockHolding_Staging', @level2type = N'COLUMN', @level2name = 'Stock Item Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity on hand', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockHolding_Staging', @level2type = N'COLUMN', @level2name = 'Quantity On Hand';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bin location (where is this stock in the warehouse)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockHolding_Staging', @level2type = N'COLUMN', @level2name = 'Bin Location';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity present at last stocktake', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockHolding_Staging', @level2type = N'COLUMN', @level2name = 'Last Stocktake Quantity';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Unit cost when the stock item was last purchased', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockHolding_Staging', @level2type = N'COLUMN', @level2name = 'Last Cost Price';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Quantity below which reordering should take place', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockHolding_Staging', @level2type = N'COLUMN', @level2name = 'Reorder Level';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Typical stock level held', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockHolding_Staging', @level2type = N'COLUMN', @level2name = 'Target Stock Level';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Stock Item ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'StockHolding_Staging', @level2type = N'COLUMN', @level2name = 'WWI Stock Item ID';
GO
 
CREATE TABLE [Integration].[Transaction_Staging]
(
    [Transaction Staging Key] bigint NOT NULL IDENTITY(1,1)
        CONSTRAINT [PK_Integration_Transaction_Staging] PRIMARY KEY,
    [Date Key] date NULL,
    [Customer Key] int NULL,
    [Bill To Customer Key] int NULL,
    [Supplier Key] int NULL,
    [Transaction Type Key] int NULL,
    [Payment Method Key] int NULL,
    [WWI Customer Transaction ID] int NULL,
    [WWI Supplier Transaction ID] int NULL,
    [WWI Invoice ID] int NULL,
    [WWI Purchase Order ID] int NULL,
    [Supplier Invoice Number] nvarchar(20) NULL,
    [Total Excluding Tax] decimal(18,2) NULL,
    [Tax Amount] decimal(18,2) NULL,
    [Total Including Tax] decimal(18,2) NULL,
    [Outstanding Balance] decimal(18,2) NULL,
    [Is Finalized] bit NULL,
    [WWI Customer ID] int NULL,
    [WWI Bill To Customer ID] int NULL,
    [WWI Supplier ID] int NULL,
    [WWI Transaction Type ID] int NULL,
    [WWI Payment Method ID] int NULL,
    [Last Modified When] datetime2(7) NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Transaction staging table', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for a row in the Transaction fact', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Transaction Staging Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Transaction date', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Date Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer (if applicable)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bill to customer (if applicable)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Bill To Customer Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier (if applicable)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Supplier Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Type of transaction', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Transaction Type Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Payment method (if applicable)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Payment Method Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer transaction ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'WWI Customer Transaction ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier transaction ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'WWI Supplier Transaction ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Invoice ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'WWI Invoice ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Purchase order ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'WWI Purchase Order ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier invoice number (if applicable)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Supplier Invoice Number';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount excluding tax', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Total Excluding Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount of tax', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Tax Amount';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Total amount including tax', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Total Including Tax';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Amount still outstanding for this transaction', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Outstanding Balance';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Has this transaction been finalized?', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Is Finalized';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Customer ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'WWI Customer ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Bill to Customer ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'WWI Bill To Customer ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Supplier ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'WWI Supplier ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Transaction Type ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'WWI Transaction Type ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Payment method ID in source system', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'WWI Payment Method ID';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'When this row was last modified', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Transaction_Staging', @level2type = N'COLUMN', @level2name = 'Last Modified When';
GO
 
CREATE TABLE [Integration].[ETL Cutoff]
(
    [Table Name] sysname NOT NULL
        CONSTRAINT [PK_Integration_ETL_Cutoff] PRIMARY KEY,
    [Cutoff Time] datetime2(7) NOT NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'ETL Cutoff Times', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'ETL Cutoff';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Table name', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'ETL Cutoff', @level2type = N'COLUMN', @level2name = 'Table Name';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Time up to which data has been loaded', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'ETL Cutoff', @level2type = N'COLUMN', @level2name = 'Cutoff Time';
GO
 
CREATE TABLE [Integration].[Lineage]
(
    [Lineage Key] int NOT NULL
        CONSTRAINT [PK_Integration_Lineage] PRIMARY KEY
        CONSTRAINT [DF_Integration_Lineage_Lineage_Key]
            DEFAULT(NEXT VALUE FOR [Sequences].[LineageKey]),
    [Data Load Started] datetime2(7) NOT NULL,
    [Table Name] sysname NOT NULL,
    [Data Load Completed] datetime2(7) NULL,
    [Was Successful] bit NOT NULL,
    [Source System Cutoff Time] datetime2(7) NOT NULL
);
GO
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = N'Details of data load attempts', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Lineage';
 
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'DW key for lineage data', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Lineage', @level2type = N'COLUMN', @level2name = 'Lineage Key';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Time when the data load attempt began', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Lineage', @level2type = N'COLUMN', @level2name = 'Data Load Started';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Name of the table for this data load event', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Lineage', @level2type = N'COLUMN', @level2name = 'Table Name';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Time when the data load attempt completed (successfully or not)', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Lineage', @level2type = N'COLUMN', @level2name = 'Data Load Completed';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Was the attempt successful?', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Lineage', @level2type = N'COLUMN', @level2name = 'Was Successful';
EXEC sys.sp_addextendedproperty @name = N'Description', @value = 'Time that rows from the source system were loaded up until', @level0type = N'SCHEMA', @level0name = 'Integration', @level1type = N'TABLE',  @level1name = 'Lineage', @level2type = N'COLUMN', @level2name = 'Source System Cutoff Time';
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
 
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'CityKey', @SchemaName = 'Dimension', @TableName = 'City', @ColumnName = 'City Key';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'CustomerKey', @SchemaName = 'Dimension', @TableName = 'Customer', @ColumnName = 'Customer Key';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'EmployeeKey', @SchemaName = 'Dimension', @TableName = 'Employee', @ColumnName = 'Employee Key';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'LineageKey', @SchemaName = 'Integration', @TableName = 'Lineage', @ColumnName = 'Lineage Key';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'PaymentMethodKey', @SchemaName = 'Dimension', @TableName = 'Payment Method', @ColumnName = 'Payment Method Key';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'StockItemKey', @SchemaName = 'Dimension', @TableName = 'Stock Item', @ColumnName = 'Stock Item Key';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'SupplierKey', @SchemaName = 'Dimension', @TableName = 'Supplier', @ColumnName = 'Supplier Key';
    EXEC Sequences.ReseedSequenceBeyondTableValues @SequenceName = 'TransactionTypeKey', @SchemaName = 'Dimension', @TableName = 'Transaction Type', @ColumnName = 'Transaction Type Key';
END;
GO
 
USE tempdb;
GO
 
