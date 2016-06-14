-- WideWorldImporters Database Metadata Population
--
-- Creates the WWI_Prep Database
--

USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE name = N'WWI_Preparation')
BEGIN
    ALTER DATABASE WWI_Preparation SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE WWI_Preparation;
END;
GO

CREATE DATABASE WWI_Preparation;
GO

USE WWI_Preparation;
GO

SET NOCOUNT ON;
GO

CREATE SCHEMA Metadata AUTHORIZATION dbo;
GO

CREATE TABLE Metadata.[Schemas]
(
    SchemaID int IDENTITY(1,1)
        CONSTRAINT PK_Metadata_Schemas PRIMARY KEY,
    SchemaName sysname NOT NULL,
    SchemaDescription nvarchar(max) NOT NULL
);

CREATE TABLE Metadata.[Tables]
(
    TableCreationOrder int
        CONSTRAINT PK_Metadata_Tables PRIMARY KEY,
    SchemaName sysname NOT NULL,
    TableName sysname NOT NULL,
	IncludeTemporalColumns bit NOT NULL,
    IncludeModificationTrackingColumns bit NOT NULL,
    TableDescription nvarchar(max) NOT NULL
);

CREATE TABLE Metadata.[Columns]
(
    ColumnID int IDENTITY(1,1)
        CONSTRAINT PK_Metadata_Columns PRIMARY KEY,
    TableName sysname NOT NULL,
    ColumnName sysname NOT NULL,
    IsPrimaryKeyColumn bit NOT NULL,
    DataType nvarchar(max) NOT NULL,
    IsNullable bit NOT NULL,
    MaximumLength int NULL,
    DecimalPrecision int NULL,
    DecimalScale int NULL,
    HasDefaultValue bit NOT NULL,
    UsesSequenceDefault bit NOT NULL,
    DefaultSequenceName sysname NULL,
    DefaultValue nvarchar(max) NULL,
    IsUnique bit NOT NULL,
    HasForeignKeyReference bit NOT NULL,
    ForeignKeySchema sysname NULL,
    ForeignKeyTable sysname NULL,
    ForeignKeyColumn sysname NULL,
    AutomaticallyIndexForeignKey bit NOT NULL,
    ColumnMaskFunction nvarchar(max) NULL,
    ColumnDescription nvarchar(max) NOT NULL
);
GO

CREATE TABLE Metadata.[Constraints]
(
    [ConstraintID] int IDENTITY(1,1)
        CONSTRAINT PK_Metadata_Constraints PRIMARY KEY,
    TableName sysname NOT NULL,
    ConstraintName sysname NOT NULL,
    ConstraintDefinition nvarchar(max) NOT NULL,
    ConstraintDescription nvarchar(max) NOT NULL
);
GO

CREATE TABLE Metadata.[Indexes]
(
    [IndexID] int IDENTITY(1,1)
        CONSTRAINT PK_Metadata_Indexes PRIMARY KEY,
    TableName sysname NOT NULL,
    IndexName sysname NOT NULL,
    IndexColumns nvarchar(max) NOT NULL,
    IncludedColumns nvarchar(max) NULL,
    IsUnique bit NOT NULL,
    FilterClause nvarchar(max) NULL,
    IndexDescription nvarchar(max) NOT NULL
);
GO

-- Schemas
INSERT Metadata.[Schemas]
    (SchemaName, SchemaDescription)
VALUES
    (N'Application', N'Tables common across the application. Used for categorization and lookup lists, system parameters and people (users and contacts)'),
    (N'DataLoadSimulation', N'Tables and procedures used only during simulated data loading operations'),
    (N'Integration', 'Tables and procedures required for integration with the data warehouse'),
    (N'PowerBI', N'Views and stored procedures that provide the only access for the Power BI dashboard system'),
    (N'Purchasing', N'Details of suppliers and of purchasing of stock items'),
    (N'Reports', N'Views and stored procedures that provide the only access for the reporting system'),
    (N'Sales', N'Details of customers, salespeople, and of sales of stock items'),
    (N'Sequences', N'Holds sequences used by all tables in the application'),
    (N'Warehouse', N'Details of stock items, their holdings and transactions'),
    (N'Website', N'Views and stored procedures that provide the only access for the application website');
GO

-- Application.Cities Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (180, N'Application', N'Cities', 1, 1, N'Cities that are part of any address (including geographic location)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Cities', N'CityID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'CityID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a city within the database'),
    (N'Cities', N'CityName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Formal name of the city'),
    (N'Cities', N'StateProvinceID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'StateProvinces', N'StateProvinceID', 1, NULL, N'State or province for this city'),
    (N'Cities', N'Location', 0, N'geography', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Geographic location of the city'),
    (N'Cities', N'LatestRecordedPopulation', 0, N'bigint', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Latest available population for the City');
GO

-- Application.Countries Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (40, N'Application', N'Countries', 1, 1, N'Countries that contain the states or provinces (including geographic boundaries)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Countries', N'CountryID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'CountryID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a country within the database'),
    (N'Countries', N'CountryName', 0, N'nvarchar', 0, 60, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Name of the country'),
    (N'Countries', N'FormalName', 0, N'nvarchar', 0, 60, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full formal name of the country as agreed by United Nations'),
    (N'Countries', N'IsoAlpha3Code', 0, N'nvarchar', 1, 3, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'3 letter alphabetic code assigned to the country by ISO'),
    (N'Countries', N'IsoNumericCode', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric code assigned to the country by ISO'),
    (N'Countries', N'CountryType', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Type of country or administrative region'),
    (N'Countries', N'LatestRecordedPopulation', 0, N'bigint', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Latest available population for the country'),
    (N'Countries', N'Continent', 0, N'nvarchar', 0, 30, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name of the continent'),
    (N'Countries', N'Region', 0, N'nvarchar', 0, 30, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name of the region'),
    (N'Countries', N'Subregion', 0, N'nvarchar', 0, 30, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name of the subregion'),
    (N'Countries', N'Border', 0, N'geography', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Geographic border of the country as described by the United Nations');
GO

-- Application.DeliveryMethods Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (50, N'Application', N'DeliveryMethods', 1, 1, N'Ways that stock items can be delivered (ie: truck/van, post, pickup, courier, etc.');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'DeliveryMethods', N'DeliveryMethodID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'DeliveryMethodID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a delivery method within the database'),
    (N'DeliveryMethods', N'DeliveryMethodName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full name of methods that can be used for delivery of customer orders');
GO

-- Application.PaymentMethods Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (60, N'Application', N'PaymentMethods', 1, 1, N'Ways that payments can be made (ie: cash, check, EFT, etc.');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'PaymentMethods', N'PaymentMethodID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'PaymentMethodID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a payment type within the database'),
    (N'PaymentMethods', N'PaymentMethodName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full name of ways that customers can make payments or that suppliers can be paid');
GO

-- Application.People Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (10, N'Application', N'People', 1, 1, N'People known to the application (staff, customer contacts, supplier contacts)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'People', N'PersonID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'PersonID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a person within the database'),
    (N'People', N'FullName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Full name for this person'),
    (N'People', N'PreferredName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name that this person prefers to be called'),
    (N'People', N'SearchName', 0, N'AS CONCAT([PreferredName], N'' '', [FullName]) PERSISTED', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name to build full text search on (computed column)'),
    (N'People', N'IsPermittedToLogon', 0, N'bit', 0, NULL, NULL, NULL, 1, 0, NULL, N'0', 0, 0, NULL, NULL, 0, NULL, N'Is this person permitted to log on?'),
    (N'People', N'LogonName', 0, N'nvarchar', 1, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Person''s system logon name'),
    (N'People', N'IsExternalLogonProvider', 0, N'bit', 0, NULL, NULL, NULL, 1, 0, NULL, N'0', 0, 0, NULL, NULL, 0, NULL, N'Is logon token provided by an external system?'),
    (N'People', N'HashedPassword', 0, N'varbinary(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Hash of password for users without external logon tokens'),
    (N'People', N'IsSystemUser', 0, N'bit', 0, NULL, NULL, NULL, 1, 0, NULL, N'1', 0, 0, NULL, NULL, 0, NULL, N'Is the currently permitted to make online access?'),
    (N'People', N'IsEmployee', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this person an employee?'),
    (N'People', N'IsSalesperson', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this person a staff salesperson?'),
    (N'People', N'UserPreferences', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'User preferences related to the website (holds JSON data)'),
    (N'People', N'PhoneNumber', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Phone number'),
    (N'People', N'FaxNumber', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Fax number  '),
    (N'People', N'EmailAddress', 0, N'nvarchar', 1, 256, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Email address for this person'),
    (N'People', N'Photo', 0, N'varbinary(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Photo of this person'),
    (N'People', N'CustomFields', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Custom fields for employees and salespeople'),
    (N'People', N'OtherLanguages', 0, N'AS JSON_QUERY([CustomFields], N''$.OtherLanguages'')', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Other languages spoken (computed column from custom fields)');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'People', N'IX_Application_People_IsEmployee', N'[IsEmployee]', NULL, 0, NULL, N'Allows quickly locating employees');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'People', N'IX_Application_People_IsSalesperson', N'[IsSalesperson]', NULL, 0, NULL, N'Allows quickly locating salespeople');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'People', N'IX_Application_People_FullName', N'[FullName]', NULL, 0, NULL, N'Improves performance of name-related queries');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'People', N'IX_Application_People_Perf_20160301_05', N'[IsPermittedToLogon],[PersonID]', N'[FullName], [EmailAddress]', 0, NULL, N'Improves performance of order picking and invoicing');
GO

-- Application.StateProvinces Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (170, N'Application', N'StateProvinces', 1, 1, N'States or provinces that contain cities (including geographic location)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'StateProvinces', N'StateProvinceID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'StateProvinceID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a state or province within the database'),
    (N'StateProvinces', N'StateProvinceCode', 0, N'nvarchar', 0, 5, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Common code for this state or province (such as WA - Washington for the USA)'),
    (N'StateProvinces', N'StateProvinceName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Formal name of the state or province'),
    (N'StateProvinces', N'CountryID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Countries', N'CountryID', 1, NULL, N'Country for this StateProvince'),
    (N'StateProvinces', N'SalesTerritory', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Sales territory for this StateProvince'),
    (N'StateProvinces', N'Border', 0, N'geography', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Geographic boundary of the state or province'),
    (N'StateProvinces', N'LatestRecordedPopulation', 0, N'bigint', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Latest available population for the StateProvince');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'StateProvinces', N'IX_Application_StateProvinces_SalesTerritory', N'[SalesTerritory]', NULL, 0, NULL, N'Index used to quickly locate sales territories');
GO

-- Application.SystemParameters Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (190, N'Application', N'SystemParameters', 0, 1, N'Any configurable parameters for the whole system');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'SystemParameters', N'SystemParameterID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'SystemParameterID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for row holding system parameters'),
    (N'SystemParameters', N'DeliveryAddressLine1', 0, N'nvarchar', 0, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'First address line for the company'),
    (N'SystemParameters', N'DeliveryAddressLine2', 0, N'nvarchar', 1, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Second address line for the company'),
    (N'SystemParameters', N'DeliveryCityID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Cities', N'CityID', 1, NULL, N'ID of the city for this address'),
    (N'SystemParameters', N'DeliveryPostalCode', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Postal code for the company'),
    (N'SystemParameters', N'DeliveryLocation', 0, N'geography', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Geographic location for the company office'),
    (N'SystemParameters', N'PostalAddressLine1', 0, N'nvarchar', 0, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'First postal address line for the company'),
    (N'SystemParameters', N'PostalAddressLine2', 0, N'nvarchar', 1, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Second postaladdress line for the company'),
    (N'SystemParameters', N'PostalCityID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Cities', N'CityID', 1, NULL, N'ID of the city for this postaladdress'),
    (N'SystemParameters', N'PostalPostalCode', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Postal code for the company when sending via mail'),
    (N'SystemParameters', N'ApplicationSettings', 0, N'nvarchar(max)', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'JSON-structured application settings');
GO

-- Application.TransactionTypes Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (70, N'Application', N'TransactionTypes', 1, 1, N'Types of customer, supplier, or stock transactions (ie: invoice, credit note, etc.)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'TransactionTypes', N'TransactionTypeID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'TransactionTypeID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a transaction type within the database'),
    (N'TransactionTypes', N'TransactionTypeName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full name of the transaction type');
GO

-- Purchasing.PurchaseOrderLines Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (250, N'Purchasing', N'PurchaseOrderLines', 0, 1, N'Detail lines from supplier purchase orders');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'PurchaseOrderLines', N'PurchaseOrderLineID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'PurchaseOrderLineID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a line on a purchase order within the database'),
    (N'PurchaseOrderLines', N'PurchaseOrderID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'PurchaseOrders', N'PurchaseOrderID', 1, NULL, N'Purchase order that this line is associated with'),
    (N'PurchaseOrderLines', N'StockItemID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'StockItems', N'StockItemID', 1, NULL, N'Stock item for this purchase order line'),
    (N'PurchaseOrderLines', N'OrderedOuters', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of the stock item that is ordered'),
    (N'PurchaseOrderLines', N'Description', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Description of the item to be supplied (Often the stock item name but could be supplier description)'),
    (N'PurchaseOrderLines', N'ReceivedOuters', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total quantity of the stock item that has been received so far'),
    (N'PurchaseOrderLines', N'PackageTypeID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'PackageTypes', N'PackageTypeID', 1, NULL, N'Type of package received'),
    (N'PurchaseOrderLines', N'ExpectedUnitPricePerOuter', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'The unit price that we expect to be charged'),
    (N'PurchaseOrderLines', N'LastReceiptDate', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'The last date on which this stock item was received for this purchase order'),
    (N'PurchaseOrderLines', N'IsOrderLineFinalized', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this purchase order line now considered finalized? (Receipted quantities and weights are often not precise)');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'PurchaseOrderLines', N'IX_Purchasing_PurchaseOrderLines_Perf_20160301_4', N'[IsOrderLineFinalized], [StockItemID]', N'[OrderedOuters], [ReceivedOuters]', 0, NULL, N'Improves performance of order picking and invoicing');
GO

-- Purchasing.PurchaseOrders Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (220, N'Purchasing', N'PurchaseOrders', 0, 1, N'Details of supplier purchase orders');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'PurchaseOrders', N'PurchaseOrderID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'PurchaseOrderID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a purchase order within the database'),
    (N'PurchaseOrders', N'SupplierID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Suppliers', N'SupplierID', 1, NULL, N'Supplier for this purchase order'),
    (N'PurchaseOrders', N'OrderDate', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Date that this purchase order was raised'),
    (N'PurchaseOrders', N'DeliveryMethodID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'DeliveryMethods', N'DeliveryMethodID', 1, NULL, N'How this purchase order should be delivered'),
    (N'PurchaseOrders', N'ContactPersonID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'The person who is the primary contact for this purchase order'),
    (N'PurchaseOrders', N'ExpectedDeliveryDate', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Expected delivery date for this purchase order'),
    (N'PurchaseOrders', N'SupplierReference', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier reference for our organization (might be our account number at the supplier)'),
    (N'PurchaseOrders', N'IsOrderFinalized', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this purchase order now considered finalized?'),
    (N'PurchaseOrders', N'Comments', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Any comments related this purchase order (comments sent to the supplier)'),
    (N'PurchaseOrders', N'InternalComments', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Any internal comments related this purchase order (comments for internal reference only and not sent to the supplier)');
GO

-- Purchasing.SupplierCategories Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (80, N'Purchasing', N'SupplierCategories', 1, 1, N'Categories for suppliers (ie novelties, toys, clothing, packaging, etc.)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'SupplierCategories', N'SupplierCategoryID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'SupplierCategoryID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a supplier category within the database'),
    (N'SupplierCategories', N'SupplierCategoryName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full name of the category that suppliers can be assigned to');
GO

-- Purchasing.Suppliers Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (200, N'Purchasing', N'Suppliers', 1, 1, N'Main entity table for suppliers (organizations)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Suppliers', N'SupplierID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'SupplierID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a supplier within the database'),
    (N'Suppliers', N'SupplierName', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Supplier''s full name (usually a trading name)'),
    (N'Suppliers', N'SupplierCategoryID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'SupplierCategories', N'SupplierCategoryID', 1, NULL, N'Supplier''s category'),
    (N'Suppliers', N'PrimaryContactPersonID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Primary contact'),
    (N'Suppliers', N'AlternateContactPersonID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Alternate contact'),
    (N'Suppliers', N'DeliveryMethodID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'DeliveryMethods', N'DeliveryMethodID', 1, NULL, N'Standard delivery method for stock items received from this supplier'),
    (N'Suppliers', N'DeliveryCityID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Cities', N'CityID', 1, NULL, N'ID of the delivery city for this address'),
    (N'Suppliers', N'PostalCityID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Cities', N'CityID', 1, NULL, N'ID of the mailing city for this address'),
    (N'Suppliers', N'SupplierReference', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier reference for our organization (might be our account number at the supplier)'),
    (N'Suppliers', N'BankAccountName', 0, N'nvarchar', 1, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, N'default()', N'Supplier''s bank account name (ie name on the account)'),
    (N'Suppliers', N'BankAccountBranch', 0, N'nvarchar', 1, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, N'default()', N'Supplier''s bank branch'),
    (N'Suppliers', N'BankAccountCode', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, N'default()', N'Supplier''s bank account code (usually a numeric reference for the bank branch)'),
    (N'Suppliers', N'BankAccountNumber', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, N'default()', N'Supplier''s bank account number'),
    (N'Suppliers', N'BankInternationalCode', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, N'default()', N'Supplier''s bank''s international code (such as a SWIFT code)'),
    (N'Suppliers', N'PaymentDays', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Number of days for payment of an invoice (ie payment terms)'),
    (N'Suppliers', N'InternalComments', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Internal comments (not exposed outside organization)'),
    (N'Suppliers', N'PhoneNumber', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Phone number'),
    (N'Suppliers', N'FaxNumber', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Fax number  '),
    (N'Suppliers', N'WebsiteURL', 0, N'nvarchar', 0, 256, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'URL for the website for this supplier'),
    (N'Suppliers', N'DeliveryAddressLine1', 0, N'nvarchar', 0, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'First delivery address line for the supplier'),
    (N'Suppliers', N'DeliveryAddressLine2', 0, N'nvarchar', 1, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Second delivery address line for the supplier'),
    (N'Suppliers', N'DeliveryPostalCode', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Delivery postal code for the supplier'),
    (N'Suppliers', N'DeliveryLocation', 0, N'geography', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Geographic location for the supplier''s office/warehouse'),
    (N'Suppliers', N'PostalAddressLine1', 0, N'nvarchar', 0, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'First postal address line for the supplier'),
    (N'Suppliers', N'PostalAddressLine2', 0, N'nvarchar', 1, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Second postal address line for the supplier'),
    (N'Suppliers', N'PostalPostalCode', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Postal code for the supplier when sending by mail');
GO

-- Purchasing.SupplierTransactions Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (260, N'Purchasing', N'SupplierTransactions', 0, 1, N'All financial transactions that are supplier-related');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'SupplierTransactions', N'SupplierTransactionID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'TransactionID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used to refer to a supplier transaction within the database'),
    (N'SupplierTransactions', N'SupplierID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Suppliers', N'SupplierID', 1, NULL, N'Supplier for this transaction'),
    (N'SupplierTransactions', N'TransactionTypeID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'TransactionTypes', N'TransactionTypeID', 1, NULL, N'Type of transaction'),
    (N'SupplierTransactions', N'PurchaseOrderID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'PurchaseOrders', N'PurchaseOrderID', 1, NULL, N'ID of an purchase order (for transactions associated with a purchase order)'),
    (N'SupplierTransactions', N'PaymentMethodID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'PaymentMethods', N'PaymentMethodID', 1, NULL, N'ID of a payment method (for transactions involving payments)'),
    (N'SupplierTransactions', N'SupplierInvoiceNumber', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Invoice number for an invoice received from the supplier'),
    (N'SupplierTransactions', N'TransactionDate', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Date for the transaction'),
    (N'SupplierTransactions', N'AmountExcludingTax', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Transaction amount (excluding tax)'),
    (N'SupplierTransactions', N'TaxAmount', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax amount calculated'),
    (N'SupplierTransactions', N'TransactionAmount', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Transaction amount (including tax)'),
    (N'SupplierTransactions', N'OutstandingBalance', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Amount still outstanding for this transaction'),
    (N'SupplierTransactions', N'FinalizationDate', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Date that this transaction was finalized (if it has been)'),
    (N'SupplierTransactions', N'IsFinalized', 0, N'AS CASE WHEN [FinalizationDate] IS NULL THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END PERSISTED', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this transaction finalized (invoices, credits and payments have been matched)');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'SupplierTransactions', N'IX_Purchasing_SupplierTransactions_IsFinalized', N'[IsFinalized]', NULL, 0, NULL, N'Index used to quickly locate unfinalized transactions');
GO

-- Sales.BuyingGroups Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (90, N'Sales', N'BuyingGroups', 1, 1, N'Customer organizations can be part of groups that exert greater buying power');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'BuyingGroups', N'BuyingGroupID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'BuyingGroupID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a buying group within the database'),
    (N'BuyingGroups', N'BuyingGroupName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full name of a buying group that customers can be members of');
GO

-- Sales.CustomerCategories Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (100, N'Sales', N'CustomerCategories', 1, 1, N'Categories for customers (ie restaurants, cafes, supermarkets, etc.)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'CustomerCategories', N'CustomerCategoryID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'CustomerCategoryID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a customer category within the database'),
    (N'CustomerCategories', N'CustomerCategoryName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full name of the category that customers can be assigned to');
GO

-- Sales.Customers Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (210, N'Sales', N'Customers', 1, 1, N'Main entity tables for customers (organizations or individuals)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Customers', N'CustomerID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'CustomerID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a customer within the database'),
    (N'Customers', N'CustomerName', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Customer''s full name (usually a trading name)'),
    (N'Customers', N'BillToCustomerID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customers', N'CustomerID', 0, NULL, N'Customer that this is billed to (usually the same customer but can be another parent company)'),
    (N'Customers', N'CustomerCategoryID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'CustomerCategories', N'CustomerCategoryID', 1, NULL, N'Customer''s category'),
    (N'Customers', N'BuyingGroupID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'BuyingGroups', N'BuyingGroupID', 1, NULL, N'Customer''s buying group (optional)'),
    (N'Customers', N'PrimaryContactPersonID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Primary contact'),
    (N'Customers', N'AlternateContactPersonID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Alternate contact'),
    (N'Customers', N'DeliveryMethodID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'DeliveryMethods', N'DeliveryMethodID', 1, NULL, N'Standard delivery method for stock items sent to this customer'),
    (N'Customers', N'DeliveryCityID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Cities', N'CityID', 1, NULL, N'ID of the delivery city for this address'),
    (N'Customers', N'PostalCityID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Cities', N'CityID', 1, NULL, N'ID of the postal city for this address'),
    (N'Customers', N'CreditLimit', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Credit limit for this customer (NULL if unlimited)'),
    (N'Customers', N'AccountOpenedDate', 0, N'date', 0, NULL, NULL, NULL, 1, 0, NULL, N'SYSDATETIME()', 0, 0, NULL, NULL, 0, NULL, N'Date this customer account was opened'),
    (N'Customers', N'StandardDiscountPercentage', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Standard discount offered to this customer'),
    (N'Customers', N'IsStatementSent', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is a statement sent to this customer? (Or do they just pay on each invoice?)'),
    (N'Customers', N'IsOnCreditHold', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this customer on credit hold? (Prevents further deliveries to this customer)'),
    (N'Customers', N'PaymentDays', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Number of days for payment of an invoice (ie payment terms)'),
    (N'Customers', N'PhoneNumber', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Phone number'),
    (N'Customers', N'FaxNumber', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Fax number  '),
    (N'Customers', N'DeliveryRun', 0, N'nvarchar', 1, 5, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Normal delivery run for this customer'),
    (N'Customers', N'RunPosition', 0, N'nvarchar', 1, 5, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Normal position in the delivery run for this customer'),
    (N'Customers', N'WebsiteURL', 0, N'nvarchar', 0, 256, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'URL for the website for this customer'),
    (N'Customers', N'DeliveryAddressLine1', 0, N'nvarchar', 0, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'First delivery address line for the customer'),
    (N'Customers', N'DeliveryAddressLine2', 0, N'nvarchar', 1, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Second delivery address line for the customer'),
    (N'Customers', N'DeliveryPostalCode', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Delivery postal code for the customer'),
    (N'Customers', N'DeliveryLocation', 0, N'geography', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Geographic location for the customer''s office/warehouse'),
    (N'Customers', N'PostalAddressLine1', 0, N'nvarchar', 0, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'First postal address line for the customer'),
    (N'Customers', N'PostalAddressLine2', 0, N'nvarchar', 1, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Second postal address line for the customer'),
    (N'Customers', N'PostalPostalCode', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Postal code for the customer when sending by mail');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'Customers', N'IX_Sales_Customers_Perf_20160301_06', N'[IsOnCreditHold], [CustomerID], [BillToCustomerID]', N'[PrimaryContactPersonID]', 0, NULL, N'Improves performance of order picking and invoicing');
GO

-- Sales.SpecialDeals Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (300, N'Sales', N'SpecialDeals', 0, 1, N'Special pricing (can include fixed prices, discount $ or discount %)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'SpecialDeals', N'SpecialDealID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'SpecialDealID', NULL, 1, 0, NULL, NULL, 0, NULL, N'ID (sequence based) for a special deal'),
    (N'SpecialDeals', N'StockItemID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'StockItems', N'StockItemID', 1, NULL, N'Stock item that the deal applies to (if NULL, then only discounts are permitted not unit prices)'),
    (N'SpecialDeals', N'CustomerID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customers', N'CustomerID', 1, NULL, N'ID of the customer that the special pricing applies to (if NULL then all customers)'),
    (N'SpecialDeals', N'BuyingGroupID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'BuyingGroups', N'BuyingGroupID', 1, NULL, N'ID of the buying group that the special pricing applies to (optional)'),
    (N'SpecialDeals', N'CustomerCategoryID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'CustomerCategories', N'CustomerCategoryID', 1, NULL, N'ID of the customer category that the special pricing applies to (optional)'),
    (N'SpecialDeals', N'StockGroupID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'StockGroups', N'StockGroupID', 1, NULL, N'ID of the stock group that the special pricing applies to (optional)'),
    (N'SpecialDeals', N'DealDescription', 0, N'nvarchar', 0, 30, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Description of the special deal'),
    (N'SpecialDeals', N'StartDate', 0, N'date', 0, NULL, NULL, NULL, 1, 0, NULL, N'SYSDATETIME()', 0, 0, NULL, NULL, 0, NULL, N'Date that the special pricing starts from'),
    (N'SpecialDeals', N'EndDate', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Date that the special pricing ends on'),
    (N'SpecialDeals', N'DiscountAmount', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Discount per unit to be applied to sale price (optional)'),
    (N'SpecialDeals', N'DiscountPercentage', 0, N'decimal', 1, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Discount percentage per unit to be applied to sale price (optional)'),
    (N'SpecialDeals', N'UnitPrice', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Special price per unit to be applied instead of sale price (optional)');
GO

INSERT Metadata.[Constraints]
    (TableName, ConstraintName, ConstraintDefinition, ConstraintDescription)
VALUES (N'SpecialDeals', N'CK_Sales_SpecialDeals_Exactly_One_NOT_NULL_Pricing_Option_Is_Required',
        N'CHECK ((CASE WHEN DiscountAmount IS NULL THEN 0 ELSE 1 END + CASE WHEN DiscountPercentage IS NULL THEN 0 ELSE 1 END + CASE WHEN UnitPrice IS NULL THEN 0 ELSE 1 END) = 1)',
        N'Ensures that each special price row contains one and only one of DiscountAmount, DiscountPercentage, and UnitPrice');

INSERT Metadata.[Constraints]
    (TableName, ConstraintName, ConstraintDefinition, ConstraintDescription)
VALUES (N'SpecialDeals', N'CK_Sales_SpecialDeals_Unit_Price_Deal_Requires_Special_StockItem',
        N'CHECK (([StockItemID] IS NOT NULL AND [UnitPrice] IS NOT NULL) OR ([UnitPrice] IS NULL))',
        N'Ensures that if a specific price is allocated that it applies to a specific stock item');
GO

-- Sales.CustomerTransactions Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (360, N'Sales', N'CustomerTransactions', 0, 1, N'All financial transactions that are customer-related');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'CustomerTransactions', N'CustomerTransactionID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'TransactionID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used to refer to a customer transaction within the database'),
    (N'CustomerTransactions', N'CustomerID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customers', N'CustomerID', 1, NULL, N'Customer for this transaction'),
    (N'CustomerTransactions', N'TransactionTypeID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'TransactionTypes', N'TransactionTypeID', 1, NULL, N'Type of transaction'),
    (N'CustomerTransactions', N'InvoiceID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Invoices', N'InvoiceID', 1, NULL, N'ID of an invoice (for transactions associated with an invoice)'),
    (N'CustomerTransactions', N'PaymentMethodID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'PaymentMethods', N'PaymentMethodID', 1, NULL, N'ID of a payment method (for transactions involving payments)'),
    (N'CustomerTransactions', N'TransactionDate', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Date for the transaction'),
    (N'CustomerTransactions', N'AmountExcludingTax', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Transaction amount (excluding tax)'),
    (N'CustomerTransactions', N'TaxAmount', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax amount calculated'),
    (N'CustomerTransactions', N'TransactionAmount', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Transaction amount (including tax)'),
    (N'CustomerTransactions', N'OutstandingBalance', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Amount still outstanding for this transaction'),
    (N'CustomerTransactions', N'FinalizationDate', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Date that this transaction was finalized (if it has been)'),
    (N'CustomerTransactions', N'IsFinalized', 0, N'AS CASE WHEN [FinalizationDate] IS NULL THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END PERSISTED', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this transaction finalized (invoices, credits and payments have been matched)');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'CustomerTransactions', N'IX_Sales_CustomerTransactions_IsFinalized', N'[IsFinalized]', NULL, 0, NULL, N'Allows quick location of unfinalized transactions');
GO

-- Sales.InvoiceLines Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (370, N'Sales', N'InvoiceLines', 0, 1, N'Detail lines from customer invoices');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'InvoiceLines', N'InvoiceLineID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'InvoiceLineID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a line on an invoice within the database'),
    (N'InvoiceLines', N'InvoiceID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Invoices', N'InvoiceID', 1, NULL, N'Invoice that this line is associated with'),
    (N'InvoiceLines', N'StockItemID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'StockItems', N'StockItemID', 1, NULL, N'Stock item for this invoice line'),
    (N'InvoiceLines', N'Description', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Description of the item supplied (Usually the stock item name but can be overridden)'),
    (N'InvoiceLines', N'PackageTypeID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'PackageTypes', N'PackageTypeID', 1, NULL, N'Type of package supplied'),
    (N'InvoiceLines', N'Quantity', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity supplied'),
    (N'InvoiceLines', N'UnitPrice', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Unit price charged'),
    (N'InvoiceLines', N'TaxRate', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax rate to be applied'),
    (N'InvoiceLines', N'TaxAmount', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax amount calculated'),
    (N'InvoiceLines', N'LineProfit', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Profit made on this line item at current cost price'),
    (N'InvoiceLines', N'ExtendedPrice', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Extended line price charged');
GO

-- Sales.Invoices Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (310, N'Sales', N'Invoices', 0, 1, N'Details of customer invoices');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Invoices', N'InvoiceID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'InvoiceID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to an invoice within the database'),
    (N'Invoices', N'CustomerID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customers', N'CustomerID', 1, NULL, N'Customer for this invoice'),
    (N'Invoices', N'BillToCustomerID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customers', N'CustomerID', 1, NULL, N'Bill to customer for this invoice (invoices might be billed to a head office)'),
    (N'Invoices', N'OrderID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Orders', N'OrderID', 1, NULL, N'Sales order (if any) for this invoice'),
    (N'Invoices', N'DeliveryMethodID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'DeliveryMethods', N'DeliveryMethodID', 1, NULL, N'How these stock items are beign delivered'),
    (N'Invoices', N'ContactPersonID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Customer contact for this invoice'),
    (N'Invoices', N'AccountsPersonID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Customer accounts contact for this invoice'),
    (N'Invoices', N'SalespersonPersonID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Salesperson for this invoice'),
    (N'Invoices', N'PackedByPersonID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Person who packed this shipment (or checked the packing)'),
    (N'Invoices', N'InvoiceDate', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Date that this invoice was raised'),
    (N'Invoices', N'CustomerPurchaseOrderNumber', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Purchase Order Number received from customer'),
    (N'Invoices', N'IsCreditNote', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this a credit note (rather than an invoice)'),
    (N'Invoices', N'CreditNoteReason', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Reason that this credit note needed to be generated (if applicable)'),
    (N'Invoices', N'Comments', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Any comments related to this invoice (sent to customer)'),
    (N'Invoices', N'DeliveryInstructions', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Any comments related to delivery (sent to customer)'),
    (N'Invoices', N'InternalComments', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Any internal comments related to this invoice (not sent to the customer)'),
    (N'Invoices', N'TotalDryItems', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total number of dry packages (information for the delivery driver)'),
    (N'Invoices', N'TotalChillerItems', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total number of chiller packages (information for the delivery driver)'),
    (N'Invoices', N'DeliveryRun', 0, N'nvarchar', 1, 5, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Delivery run for this shipment'),
    (N'Invoices', N'RunPosition', 0, N'nvarchar', 1, 5, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Position in the delivery run for this shipment'),
    (N'Invoices', N'ReturnedDeliveryData', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'JSON-structured data returned from delivery devices for deliveries made directly by the organization'),
    (N'Invoices', N'ConfirmedDeliveryTime', 0, N'AS TRY_CONVERT(datetime2(7),JSON_VALUE([ReturnedDeliveryData], N''$.DeliveredWhen''), 126)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Confirmed delivery date and time promoted from JSON delivery data'),
    (N'Invoices', N'ConfirmedReceivedBy', 0, N'AS JSON_VALUE([ReturnedDeliveryData], N''$.ReceivedBy'')', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Confirmed receiver promoted from JSON delivery data');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'Invoices', N'IX_Sales_Invoices_ConfirmedDeliveryTime', N'[ConfirmedDeliveryTime]', N'[ConfirmedReceivedBy]', 0, NULL, N'Allows quick retrieval of invoices confirmed to have been delivered in a given time period');
GO

INSERT Metadata.[Constraints]
    (TableName, ConstraintName, ConstraintDefinition, ConstraintDescription)
VALUES (N'Invoices', N'CK_Sales_Invoices_ReturnedDeliveryData_Must_Be_Valid_JSON',
        N'CHECK (ReturnedDeliveryData IS NULL OR ISJSON(ReturnedDeliveryData) <> 0)',
        N'Ensures that if returned delivery data is present that it is valid JSON');

-- Sales.OrderLines Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (320, N'Sales', N'OrderLines', 0, 1, N'Detail lines from customer orders');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'OrderLines', N'OrderLineID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'OrderLineID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a line on an Order within the database'),
    (N'OrderLines', N'OrderID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Orders', N'OrderID', 1, NULL, N'Order that this line is associated with'),
    (N'OrderLines', N'StockItemID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'StockItems', N'StockItemID', 0, NULL, N'Stock item for this order line (FK not indexed as separate index exists)'),
    (N'OrderLines', N'Description', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Description of the item supplied (Usually the stock item name but can be overridden)'),
    (N'OrderLines', N'PackageTypeID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'PackageTypes', N'PackageTypeID', 1, NULL, N'Type of package to be supplied'),
    (N'OrderLines', N'Quantity', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity to be supplied'),
    (N'OrderLines', N'UnitPrice', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Unit price to be charged'),
    (N'OrderLines', N'TaxRate', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax rate to be applied'),
    (N'OrderLines', N'PickedQuantity', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity picked from stock'),
    (N'OrderLines', N'PickingCompletedWhen', 0, N'datetime2', 1, NULL, 7, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'When was picking of this line completed?');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'OrderLines', N'IX_Sales_OrderLines_AllocatedStockItems', N'[StockItemID]', N'[PickedQuantity]', 0, NULL, N'Allows quick summation of stock item quantites already allocated to uninvoiced orders');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'OrderLines', N'IX_Sales_OrderLines_Perf_20160301_01', N'[PickingCompletedWhen], [OrderID], [OrderLineID]', N'[Quantity], [StockItemID]', 0, NULL, N'Improves performance of order picking and invoicing');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'OrderLines', N'IX_Sales_OrderLines_Perf_20160301_02', N'[StockItemID], [PickingCompletedWhen]', N'[OrderID], [PickedQuantity]', 0, NULL, N'Improves performance of order picking and invoicing');
GO

-- Sales.Orders Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (230, N'Sales', N'Orders', 0, 1, N'Detail of customer orders');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Orders', N'OrderID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'OrderID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to an order within the database'),
    (N'Orders', N'CustomerID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customers', N'CustomerID', 1, NULL, N'Customer for this order'),
    (N'Orders', N'SalespersonPersonID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Salesperson for this order'),
    (N'Orders', N'PickedByPersonID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Person who picked this shipment'),
    (N'Orders', N'ContactPersonID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'People', N'PersonID', 1, NULL, N'Customer contact for this order'),
    (N'Orders', N'BackorderOrderID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Orders', N'OrderID', 0, NULL, N'If this order is a backorder, this column holds the original order number'),
    (N'Orders', N'OrderDate', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Date that this order was raised'),
    (N'Orders', N'ExpectedDeliveryDate', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Expected delivery date'),
    (N'Orders', N'CustomerPurchaseOrderNumber', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Purchase Order Number received from customer'),
    (N'Orders', N'IsUndersupplyBackordered', 0, N'bit', 0, NULL, NULL, NULL, 1, 0, NULL, N'1', 0, 0, NULL, NULL, 0, NULL, N'If items cannot be supplied are they backordered?'),
    (N'Orders', N'Comments', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Any comments related to this order (sent to customer)'),
    (N'Orders', N'DeliveryInstructions', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Any comments related to order delivery (sent to customer)'),
    (N'Orders', N'InternalComments', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Any internal comments related to this order (not sent to the customer)'),
    (N'Orders', N'PickingCompletedWhen', 0, N'datetime2', 1, NULL, 7, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'When was picking of the entire order completed?');
GO

-- Warehouse.ColdRoomTemperatures Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (20, N'Warehouse', N'ColdRoomTemperatures', 1, 0, N'Regularly recorded temperatures of cold room chillers');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'ColdRoomTemperatures', N'ColdRoomTemperatureID', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Instantaneous temperature readings for cold rooms (chillers)'),
    (N'ColdRoomTemperatures', N'ColdRoomSensorNumber', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Cold room sensor number'),
    (N'ColdRoomTemperatures', N'RecordedWhen', 0, N'datetime2', 0, NULL, NULL, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Time when this temperature recording was taken'),
    (N'ColdRoomTemperatures', N'Temperature', 0, N'decimal', 0, NULL, 10, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Temperature at the time of recording');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES
    (N'ColdRoomTemperatures', N'IX_Warehouse_ColdRoomTemperatures_ColdRoomSensorNumber', N'[ColdRoomSensorNumber]', NULL, 0, NULL, N'Allows quickly locating sensors');
GO

-- Warehouse.Colors Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (130, N'Warehouse', N'Colors', 1, 1, N'Stock items can (optionally) have colors');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Colors', N'ColorID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'ColorID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a color within the database'),
    (N'Colors', N'ColorName', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full name of a color that can be used to describe stock items');
GO

-- Warehouse.PackageTypes Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (140, N'Warehouse', N'PackageTypes', 1, 1, N'Ways that stock items can be packaged (ie: each, box, carton, pallet, kg, etc.');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'PackageTypes', N'PackageTypeID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'PackageTypeID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a package type within the database'),
    (N'PackageTypes', N'PackageTypeName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full name of package types that stock items can be purchased in or sold in');
GO

-- Warehouse.StockGroups Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (160, N'Warehouse', N'StockGroups', 1, 1, N'Groups for categorizing stock items (ie: novelties, toys, edible novelties, etc.)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'StockGroups', N'StockGroupID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'StockGroupID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a stock group within the database'),
    (N'StockGroups', N'StockGroupName', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full name of groups used to categorize stock items');
GO

-- Warehouse.StockItemHoldings Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (245, N'Warehouse', N'StockItemHoldings', 0, 1, N'Non-temporal attributes for stock items');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'StockItemHoldings', N'StockItemID', 1, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, 1, N'StockItems', N'StockItemID', 0, NULL, N'ID of the stock item that this holding relates to (this table holds non-temporal columns for stock)'),
    (N'StockItemHoldings', N'QuantityOnHand', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity currently on hand (if tracked)'),
    (N'StockItemHoldings', N'BinLocation', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Bin location (ie location of this stock item within the depot)'),
    (N'StockItemHoldings', N'LastStocktakeQuantity', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity at last stocktake (if tracked)'),
    (N'StockItemHoldings', N'LastCostPrice', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Unit cost price the last time this stock item was purchased'),
    (N'StockItemHoldings', N'ReorderLevel', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity below which reordering should take place'),
    (N'StockItemHoldings', N'TargetStockLevel', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Typical quantity ordered');
GO

-- Warehouse.StockItems Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (240, N'Warehouse', N'StockItems', 1, 1, N'Main entity table for stock items');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'StockItems', N'StockItemID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'StockItemID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a stock item within the database'),
    (N'StockItems', N'StockItemName', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Full name of a stock item (but not a full description)'),
    (N'StockItems', N'SupplierID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Suppliers', N'SupplierID', 1, NULL, N'Usual supplier for this stock item'),
    (N'StockItems', N'ColorID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Colors', N'ColorID', 1, NULL, N'Color (optional) for this stock item'),
    (N'StockItems', N'UnitPackageID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'PackageTypes', N'PackageTypeID', 1, NULL, N'Usual package for selling units of this stock item'),
    (N'StockItems', N'OuterPackageID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'PackageTypes', N'PackageTypeID', 1, NULL, N'Usual package for selling outers of this stock item (ie cartons, boxes, etc.)'),
    (N'StockItems', N'Brand', 0, N'nvarchar', 1, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Brand for the stock item (if the item is branded)'),
    (N'StockItems', N'Size', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Size of this item (eg: 100mm)'),
    (N'StockItems', N'LeadTimeDays', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Number of days typically taken from order to receipt of this stock item'),
    (N'StockItems', N'QuantityPerOuter', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of the stock item in an outer package'),
    (N'StockItems', N'IsChillerStock', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Does this stock item need to be in a chiller?'),
    (N'StockItems', N'Barcode', 0, N'nvarchar', 1, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Barcode for this stock item'),
    (N'StockItems', N'TaxRate', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax rate to be applied'),
    (N'StockItems', N'UnitPrice', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Selling price (ex-tax) for one unit of this product'),
    (N'StockItems', N'RecommendedRetailPrice', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Recommended retail price for this stock item'),
    (N'StockItems', N'TypicalWeightPerUnit', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Typical weight for one unit of this product (packaged)'),
    (N'StockItems', N'MarketingComments', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Marketing comments for this stock item (shared outside the organization)'),
    (N'StockItems', N'InternalComments', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Internal comments (not exposed outside organization)'),
    (N'StockItems', N'Photo', 0, N'varbinary(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Photo of the product'),
    (N'StockItems', N'CustomFields', 0, N'nvarchar(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Custom fields added by system users'),
    (N'StockItems', N'Tags', 0, N'AS JSON_QUERY([CustomFields], N''$.Tags'')', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Advertising tags associated with this stock item (JSON array retrieved from CustomFields)'),
    (N'StockItems', N'SearchDetails', 0, N'AS CONCAT([StockItemName], N'' '', [MarketingComments])', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Combination of columns used by full text search');
GO

-- Warehouse.StockItemStockGroups Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (350, N'Warehouse', N'StockItemStockGroups', 0, 1, N'Which stock items are in which stock groups');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'StockItemStockGroups', N'StockItemStockGroupID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'StockItemStockGroupID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Internal reference for this linking row'),
    (N'StockItemStockGroups', N'StockItemID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'StockItems', N'StockItemID', 0, NULL, N'Stock item assigned to this stock group (FK indexed via unique constraint)'),
    (N'StockItemStockGroups', N'StockGroupID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'StockGroups', N'StockGroupID', 0, NULL, N'StockGroup assigned to this stock item (FK indexed via unique constraint)');
GO

INSERT Metadata.[Constraints]
    (TableName, ConstraintName, ConstraintDefinition, ConstraintDescription)
VALUES
    (N'StockItemStockGroups', N'UQ_StockItemStockGroups_StockItemID_Lookup', N'UNIQUE(StockItemID, StockGroupID)', N'Enforces uniqueness and indexes one side of the many to many relationship'),
    (N'StockItemStockGroups', N'UQ_StockItemStockGroups_StockGroupID_Lookup', N'UNIQUE(StockGroupID, StockItemID)', N'Enforces uniqueness and indexes one side of the many to many relationship');
GO

-- Warehouse.StockItemTransactions Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (380, N'Warehouse', N'StockItemTransactions', 0, 1, N'Transactions covering all movements of all stock items');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'StockItemTransactions', N'StockItemTransactionID', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'TransactionID', NULL, 1, 0, NULL, NULL, 0, NULL, N'Numeric ID used to refer to a stock item transaction within the database'),
    (N'StockItemTransactions', N'StockItemID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'StockItems', N'StockItemID', 1, NULL, N'StockItem for this transaction'),
    (N'StockItemTransactions', N'TransactionTypeID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'TransactionTypes', N'TransactionTypeID', 1, NULL, N'Type of transaction'),
    (N'StockItemTransactions', N'CustomerID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customers', N'CustomerID', 1, NULL, N'Customer for this transaction (if applicable)'),
    (N'StockItemTransactions', N'InvoiceID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Invoices', N'InvoiceID', 1, NULL, N'ID of an invoice (for transactions associated with an invoice)'),
    (N'StockItemTransactions', N'SupplierID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Suppliers', N'SupplierID', 1, NULL, N'Supplier for this stock transaction (if applicable)'),
    (N'StockItemTransactions', N'PurchaseOrderID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'PurchaseOrders', N'PurchaseOrderID', 1, NULL, N'ID of an purchase order (for transactions associated with a purchase order)'),
    (N'StockItemTransactions', N'TransactionOccurredWhen', 0, N'datetime2', 0, NULL, 7, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Date and time when the transaction occurred'),
    (N'StockItemTransactions', N'Quantity', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of stock movement (positive is incoming stock, negative is outgoing)');
GO

-- Warehouse.VehicleTemperatures Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (30, N'Warehouse', N'VehicleTemperatures', 0, 0, N'Regularly recorded temperatures of vehicle chillers');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'VehicleTemperatures', N'VehicleTemperatureID', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Instantaneous temperature readings for vehicle freezers and chillers'),
    (N'VehicleTemperatures', N'VehicleRegistration', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Vehicle registration number'),
    (N'VehicleTemperatures', N'ChillerSensorNumber', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Cold room sensor number'),
    (N'VehicleTemperatures', N'RecordedWhen', 0, N'datetime2', 0, NULL, NULL, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Time when this temperature recording was taken'),
    (N'VehicleTemperatures', N'Temperature', 0, N'decimal', 0, NULL, 10, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Temperature at the time of recording'),
    (N'VehicleTemperatures', N'IsCompressed', 0, N'bit', 0, NULL, NULL, NULL, 1, 0, NULL, N'0', 0, 0, NULL, NULL, 0, NULL, N'Is the sensor data compressed for archival storage?'),
    (N'VehicleTemperatures', N'FullSensorData', 0, N'nvarchar', 1, 1000, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Full JSON data received from sensor'),
    (N'VehicleTemperatures', N'CompressedSensorData', 0, N'varbinary(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Compressed JSON data for archival purposes');
GO

-- Create any required utility functions and procedures

CREATE PROCEDURE dbo.ExecuteOrPrint
@String nvarchar(max),
@PrintOnly bit = 1,
@NumberOfCrLfBeforeGO int = 0,
@IncludeGO bit = 0,
@NumberOfCrLfAfterGO int = 0
AS BEGIN
    SET NOCOUNT ON;

    DECLARE @StringToPrint nvarchar(max) = REPLACE(RTRIM(@String), NCHAR(10), N'');
	DECLARE @FullLine nvarchar(max);
	DECLARE @StringToExecute nvarchar(max) = N'';
    DECLARE @NextLineEnd int;
    DECLARE @Counter int;

    WHILE LEN(@StringToPrint) > 0
    BEGIN
        SET @NextLineEnd = CHARINDEX(NCHAR(13), @StringToPrint, 1);
        IF @NextLineEnd <> 0 -- more than one line left
        BEGIN
			SET @FullLine = RTRIM(SUBSTRING(@StringToPrint, 1, @NextLineEnd - 1));
            PRINT @FullLine;

			IF LTRIM(@FullLine) = N'GO' -- line just contains GO
			BEGIN
				SET @StringToExecute = LTRIM(RTRIM(@StringToExecute));
				IF LEN(@StringToExecute) > 0 AND @PrintOnly = 0
				BEGIN
					EXECUTE (@StringToExecute); -- Execute if non-blank
				END;
				SET @StringToExecute = N'';
			END ELSE BEGIN
				SET @StringToExecute += NCHAR(13) + NCHAR(10) + @FullLine;
			END;
            SET @StringToPrint = RTRIM(SUBSTRING(@StringToPrint, @NextLineEnd + 1, LEN(@StringToPrint)));
		END ELSE BEGIN -- on the last line
			SET @FullLine = RTRIM(@StringToPrint);
            PRINT @FullLine;

			IF LTRIM(@FullLine) = N'GO' -- line just contains GO
			BEGIN
				SET @StringToExecute = LTRIM(RTRIM(@StringToExecute));
				IF LEN(@StringToExecute) > 0 AND @PrintOnly = 0
				BEGIN
					EXECUTE (@StringToExecute); -- Execute if non-blank
				END;
				SET @StringToExecute = N'';
			END;

            SET @StringToPrint = N'';
        END;

        SET @Counter = 0;
        WHILE @Counter < @NumberOfCrLfBeforeGO
        BEGIN
            PRINT N' ';
            SET @Counter += 1;
        END;
        IF @IncludeGO <> 0 PRINT N'GO';

        SET @Counter = 0;
        WHILE @Counter < @NumberOfCrLfAfterGO
        BEGIN
            PRINT N' ';
            SET @Counter += 1;
        END;
    END;
END;
GO

USE master;
GO
