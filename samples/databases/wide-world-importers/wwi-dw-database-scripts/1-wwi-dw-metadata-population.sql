-- WideWorldImportersDW Database Metadata Population
--
-- Creates the WWI_DW_Preparation Database
-- 

USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE name = N'WWI_DW_Preparation')
BEGIN
    ALTER DATABASE WWI_DW_Preparation SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE WWI_DW_Preparation;
END;
GO

CREATE DATABASE WWI_DW_Preparation;
GO

USE WWI_DW_Preparation;
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
	(N'Application', N'Application configuration code'),
    (N'Dimension', N'Dimensional model dimension tables'),
    (N'Fact', N'Dimensional model fact tables'),
    (N'Integration', N'Objects needed for ETL integration'),
    (N'PowerBI', N'Views and stored procedures that provide the only access for the Power BI dashboard system'),
    (N'Reports', N'Views and stored procedures that provide the only access for the reporting system'),
    (N'Sequences', N'Holds sequences used by all tables in the application'),
    (N'Website', N'Views and stored procedures that provide the only access for the application website');
GO

-- Dimension.City Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (10, N'Dimension', N'City', 0, 0, N'City dimension');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'City', N'City Key', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'CityKey', NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for the city dimension'),
    (N'City', N'WWI City ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a city within the WWI database'),
    (N'City', N'City', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Formal name of the city'),
    (N'City', N'State Province', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'State or province for this city'),
    (N'City', N'Country', 0, N'nvarchar', 0, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Country name'),
    (N'City', N'Continent', 0, N'nvarchar', 0, 30, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Continent that this city is on'),
    (N'City', N'Sales Territory', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Sales territory for this StateProvince'),
    (N'City', N'Region', 0, N'nvarchar', 0, 30, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name of the region'),
    (N'City', N'Subregion', 0, N'nvarchar', 0, 30, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name of the subregion'),
    (N'City', N'Location', 0, N'geography', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Geographic location of the city'),
    (N'City', N'Latest Recorded Population', 0, N'bigint', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Latest available population for the City'),
    (N'City', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'City', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time'),
    (N'City', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'City', N'IX_Dimension_City_WWICityID', N'[WWI City ID], [Valid From], [Valid To]', NULL, 0, NULL, N'Allows quickly locating by WWI ID');
GO

-- Dimension.Customer Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (20, N'Dimension', N'Customer', 0, 0, N'Customer dimension');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Customer', N'Customer Key', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'CustomerKey', NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for the customer dimension'),
    (N'Customer', N'WWI Customer ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a customer within the WWI database'),
    (N'Customer', N'Customer', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer''s full name (usually a trading name)'),
    (N'Customer', N'Bill To Customer', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Bill to customer''s full name'),
    (N'Customer', N'Category', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer''s category'),
    (N'Customer', N'Buying Group', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer''s buying group'),
    (N'Customer', N'Primary Contact', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Primary contact'),
    (N'Customer', N'Postal Code', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Delivery postal code for the customer'),
    (N'Customer', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'Customer', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time'),
    (N'Customer', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Customer', N'IX_Dimension_Customer_WWICustomerID', N'[WWI Customer ID], [Valid From], [Valid To]', NULL, 0, NULL, N'Allows quickly locating by WWI ID');
GO

-- Dimension.Date Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (30, N'Dimension', N'Date', 0, 0, N'Date dimension');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Date', N'Date', 1, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for date dimension (actual date is used for key)'),
    (N'Date', N'Day Number', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Day of the month'),
    (N'Date', N'Day', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Day name'),
    (N'Date', N'Month', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Month name (ie September)'),
    (N'Date', N'Short Month', 0, N'nvarchar', 0, 3, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Short month name (ie Sep)'),
    (N'Date', N'Calendar Month Number', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Calendar month number'),
    (N'Date', N'Calendar Month Label', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Calendar month label (ie CY2015Jun)'),
    (N'Date', N'Calendar Year', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Calendar year (ie 2015)'),
    (N'Date', N'Calendar Year Label', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Calendar year label (ie CY2015)'),
    (N'Date', N'Fiscal Month Number', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Fiscal month number'),
    (N'Date', N'Fiscal Month Label', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Fiscal month label (ie FY2015Feb)'),
    (N'Date', N'Fiscal Year', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Fiscal year (ie 2016)'),
    (N'Date', N'Fiscal Year Label', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Fiscal year label (ie FY2015)'),
    (N'Date', N'ISO Week Number', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'ISO week number (ie 25)');
GO

-- Dimension.Employee Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (40, N'Dimension', N'Employee', 0, 0, N'Employee dimension');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Employee', N'Employee Key', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'EmployeeKey', NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for the employee dimension'),
    (N'Employee', N'WWI Employee ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID (PersonID) in the WWI database'),
    (N'Employee', N'Employee', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Full name for this person'),
    (N'Employee', N'Preferred Name', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name that this person prefers to be called'),
    (N'Employee', N'Is Salesperson', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this person a staff salesperson?'),
    (N'Employee', N'Photo', 0, N'varbinary(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Photo of this person'),
    (N'Employee', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'Employee', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time'),
    (N'Employee', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Employee', N'IX_Dimension_Employee_WWIEmployeeID', N'[WWI Employee ID], [Valid From], [Valid To]', NULL, 0, NULL, N'Allows quickly locating by WWI ID');
GO

-- Dimension.PaymentMethod Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (50, N'Dimension', N'Payment Method', 0, 0, N'PaymentMethod dimension');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Payment Method', N'Payment Method Key', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'PaymentMethodKey', NULL, 0, 0, NULL, NULL, 0, NULL, N'DW key for the payment method dimension'),
    (N'Payment Method', N'WWI Payment Method ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID for the payment method in the WWI database'),
    (N'Payment Method', N'Payment Method', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Payment method name'),
    (N'Payment Method', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'Payment Method', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time'),
    (N'Payment Method', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Payment Method', N'IX_Dimension_Payment_Method_WWIPaymentMethodID', N'[WWI Payment Method ID], [Valid From], [Valid To]', NULL, 0, NULL, N'Allows quickly locating by WWI ID');
GO

-- Dimension.[Stock Item] Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (60, N'Dimension', N'Stock Item', 0, 0, N'StockItem dimension');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Stock Item', N'Stock Item Key', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'StockItemKey', NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for the stock item dimension'),
    (N'Stock Item', N'WWI Stock Item ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a stock item within the WWI database'),
    (N'Stock Item', N'Stock Item', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Full name of a stock item (but not a full description)'),
    (N'Stock Item', N'Color', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Color (optional) for this stock item'),
    (N'Stock Item', N'Selling Package', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Usual package for selling units of this stock item'),
    (N'Stock Item', N'Buying Package', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Usual package for selling outers of this stock item (ie cartons, boxes, etc.)'),
    (N'Stock Item', N'Brand', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Brand for the stock item (if the item is branded)'),
    (N'Stock Item', N'Size', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Size of this item (eg: 100mm)'),
    (N'Stock Item', N'Lead Time Days', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Number of days typically taken from order to receipt of this stock item'),
    (N'Stock Item', N'Quantity Per Outer', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of the stock item in an outer package'),
    (N'Stock Item', N'Is Chiller Stock', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Does this stock item need to be in a chiller?'),
    (N'Stock Item', N'Barcode', 0, N'nvarchar', 1, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Barcode for this stock item'),
    (N'Stock Item', N'Tax Rate', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax rate to be applied'),
    (N'Stock Item', N'Unit Price', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Selling price (ex-tax) for one unit of this product'),
    (N'Stock Item', N'Recommended Retail Price', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Recommended retail price for this stock item'),
    (N'Stock Item', N'Typical Weight Per Unit', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Typical weight for one unit of this product (packaged)'),
    (N'Stock Item', N'Photo', 0, N'varbinary(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Photo of the product'),
    (N'Stock Item', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'Stock Item', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time'),
    (N'Stock Item', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Stock Item', N'IX_Dimension_Stock_Item_WWIStockItemID', N'[WWI Stock Item ID], [Valid From], [Valid To]', NULL, 0, NULL, N'Allows quickly locating by WWI ID');
GO

-- Dimension.Supplier Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (70, N'Dimension', N'Supplier', 0, 0, N'Supplier dimension');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Supplier', N'Supplier Key', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'SupplierKey', NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for the supplier dimension'),
    (N'Supplier', N'WWI Supplier ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a supplier within the WWI database'),
    (N'Supplier', N'Supplier', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier''s full name (usually a trading name)'),
    (N'Supplier', N'Category', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier''s category'),
    (N'Supplier', N'Primary Contact', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Primary contact'),
    (N'Supplier', N'Supplier Reference', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier reference for our organization (might be our account number at the supplier)'),
    (N'Supplier', N'Payment Days', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Number of days for payment of an invoice (ie payment terms)'),
    (N'Supplier', N'Postal Code', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Delivery postal code for the supplier'),
    (N'Supplier', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'Supplier', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time'),
    (N'Supplier', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Supplier', N'IX_Dimension_Supplier_WWISupplierID', N'[WWI Supplier ID], [Valid From], [Valid To]', NULL, 0, NULL, N'Allows quickly locating by WWI ID');
GO

-- Dimension.TransactionType Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (80, N'Dimension', N'Transaction Type', 0, 0, N'TransactionType dimension');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Transaction Type', N'Transaction Type Key', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'TransactionTypeKey', NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for the transaction type dimension'),
    (N'Transaction Type', N'WWI Transaction Type ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a transaction type within the WWI database'),
    (N'Transaction Type', N'Transaction Type', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Full name of the transaction type'),
    (N'Transaction Type', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'Transaction Type', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time'),
    (N'Transaction Type', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Transaction Type', N'IX_Dimension_Transaction_Type_WWITransactionTypeID', N'[WWI Transaction Type ID], [Valid From], [Valid To]', NULL, 0, NULL, N'Allows quickly locating by WWI ID');
GO

-- Fact.Movement Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (210, N'Fact', N'Movement', 0, 0, N'Movement fact table (movements of stock items)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Movement', N'Movement Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Movement fact'),
    (N'Movement', N'Date Key', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Date', N'Date', 1, NULL, N'Transaction date'),
    (N'Movement', N'Stock Item Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Stock Item', N'Stock Item Key', 1, NULL, N'Stock item for this purchase order'),
    (N'Movement', N'Customer Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customer', N'Customer Key', 1, NULL, N'Customer (if applicable)'),
    (N'Movement', N'Supplier Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Supplier', N'Supplier Key', 1, NULL, N'Supplier (if applicable)'),
    (N'Movement', N'Transaction Type Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Transaction Type', N'Transaction Type Key', 1, NULL, N'Type of transaction'),
    (N'Movement', N'WWI Stock Item Transaction ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock item transaction ID in source system'),
    (N'Movement', N'WWI Invoice ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Invoice ID in source system'),
    (N'Movement', N'WWI Purchase Order ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Purchase order ID in source system'),
    (N'Movement', N'Quantity', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of stock movement (positive is incoming stock, negative is outgoing)'),
    (N'Movement', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Movement', N'IX_Integration_Movement_WWI_Stock_Item_Transaction_ID', N'[WWI Stock Item Transaction ID]', NULL, 0, NULL, N'Allows quickly locating by WWI Stock Item Transaction ID');
GO

-- Fact.Order Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (220, N'Fact', N'Order', 0, 0, N'Order fact table (customer orders)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Order', N'Order Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Order fact'),
    (N'Order', N'City Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'City', N'City Key', 1, NULL, N'City for this order'),
    (N'Order', N'Customer Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customer', N'Customer Key', 1, NULL, N'Customer for this order'),
    (N'Order', N'Stock Item Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Stock Item', N'Stock Item Key', 1, NULL, N'Stock item for this order'),
    (N'Order', N'Order Date Key', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Date', N'Date', 1, NULL, N'Order date for this order'),
    (N'Order', N'Picked Date Key', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Date', N'Date', 1, NULL, N'Picked date for this order'),
    (N'Order', N'Salesperson Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Employee', N'Employee Key', 1, NULL, N'Salesperson for this order'),
    (N'Order', N'Picker Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Employee', N'Employee Key', 1, NULL, N'Picker for this order'),
    (N'Order', N'WWI Order ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'OrderID in source system'),
    (N'Order', N'WWI Backorder ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'BackorderID in source system'),
    (N'Order', N'Description', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Description of the item supplied (Usually the stock item name but can be overridden)'),
    (N'Order', N'Package', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Type of package to be supplied'),
    (N'Order', N'Quantity', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity to be supplied'),
    (N'Order', N'Unit Price', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Unit price to be charged'),
    (N'Order', N'Tax Rate', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax rate to be applied'),
    (N'Order', N'Total Excluding Tax', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount excluding tax'),
    (N'Order', N'Tax Amount', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount of tax'),
    (N'Order', N'Total Including Tax', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount including tax'),
    (N'Order', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Order', N'IX_Integration_Order_WWI_Order_ID', N'[WWI Order ID]', NULL, 0, NULL, N'Allows quickly locating by WWI Order ID');
GO

-- Fact.Purchase Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (230, N'Fact', N'Purchase', 0, 0, N'Purchase fact table (stock purchases from suppliers)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Purchase', N'Purchase Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Purchase fact'),
    (N'Purchase', N'Date Key', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Date', N'Date', 1, NULL, N'Purchase order date'),
    (N'Purchase', N'Supplier Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Supplier', N'Supplier Key', 1, NULL, N'Supplier for this purchase order'),
    (N'Purchase', N'Stock Item Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Stock Item', N'Stock Item Key', 1, NULL, N'Stock item for this purchase order'),
    (N'Purchase', N'WWI Purchase Order ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Purchase order ID in source system '),
    (N'Purchase', N'Ordered Outers', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of outers (ordering packages)'),
    (N'Purchase', N'Ordered Quantity', 0, N'int', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of inners (selling packages)'),
    (N'Purchase', N'Received Outers', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Received outers (so far)'),
    (N'Purchase', N'Package', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Package ordered'),
    (N'Purchase', N'Is Order Finalized', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this purchase order now finalized?'),
    (N'Purchase', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

-- Fact.Sale Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (240, N'Fact', N'Sale', 0, 0, N'Sale fact table (invoiced sales to customers)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Sale', N'Sale Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Sale fact'),
    (N'Sale', N'City Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'City', N'City Key', 1, NULL, N'City for this invoice'),
    (N'Sale', N'Customer Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customer', N'Customer Key', 1, NULL, N'Customer for this invoice'),
    (N'Sale', N'Bill To Customer Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customer', N'Customer Key', 1, NULL, N'Bill To Customer for this invoice'),
    (N'Sale', N'Stock Item Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Stock Item', N'Stock Item Key', 1, NULL, N'Stock item for this invoice'),
    (N'Sale', N'Invoice Date Key', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Date', N'Date', 1, NULL, N'Invoice date for this invoice'),
    (N'Sale', N'Delivery Date Key', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Date', N'Date', 1, NULL, N'Date that these items were delivered'),
    (N'Sale', N'Salesperson Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Employee', N'Employee Key', 1, NULL, N'Salesperson for this invoice'),
    (N'Sale', N'WWI Invoice ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'InvoiceID in source system'),
    (N'Sale', N'Description', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Description of the item supplied (Usually the stock item name but can be overridden)'),
    (N'Sale', N'Package', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Type of package supplied'),
    (N'Sale', N'Quantity', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity supplied'),
    (N'Sale', N'Unit Price', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Unit price charged'),
    (N'Sale', N'Tax Rate', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax rate applied'),
    (N'Sale', N'Total Excluding Tax', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount excluding tax'),
    (N'Sale', N'Tax Amount', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount of tax'),
    (N'Sale', N'Profit', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount of profit'),
    (N'Sale', N'Total Including Tax', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount including tax'),
    (N'Sale', N'Total Dry Items', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total number of dry items'),
    (N'Sale', N'Total Chiller Items', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total number of chiller items'),
    (N'Sale', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

-- Fact.[Stock Holding] Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (250, N'Fact', N'Stock Holding', 0, 0, N'Holdings of stock items');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Stock Holding', N'Stock Holding Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Stock Holding fact'),
    (N'Stock Holding', N'Stock Item Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Stock Item', N'Stock Item Key', 1, NULL, N'Stock item being held'),
    (N'Stock Holding', N'Quantity On Hand', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity on hand'),
    (N'Stock Holding', N'Bin Location', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Bin location (where is this stock in the warehouse)'),
    (N'Stock Holding', N'Last Stocktake Quantity', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity present at last stocktake'),
    (N'Stock Holding', N'Last Cost Price', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Unit cost when the stock item was last purchased'),
    (N'Stock Holding', N'Reorder Level', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity below which reordering should take place'),
    (N'Stock Holding', N'Target Stock Level', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Typical stock level held'),
    (N'Stock Holding', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

-- Fact.Transaction Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (260, N'Fact', N'Transaction', 0, 0, N'Transaction fact table (financial transactions involving customers and supppliers)');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Transaction', N'Transaction Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Transaction fact'),
    (N'Transaction', N'Date Key', 0, N'date', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Date', N'Date', 1, NULL, N'Transaction date'),
    (N'Transaction', N'Customer Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customer', N'Customer Key', 1, NULL, N'Customer (if applicable)'),
    (N'Transaction', N'Bill To Customer Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Customer', N'Customer Key', 1, NULL, N'Bill to customer (if applicable)'),
    (N'Transaction', N'Supplier Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Supplier', N'Supplier Key', 1, NULL, N'Supplier (if applicable)'),
    (N'Transaction', N'Transaction Type Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Transaction Type', N'Transaction Type Key', 1, NULL, N'Type of transaction'),
    (N'Transaction', N'Payment Method Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 1, N'Payment Method', N'Payment Method Key', 1, NULL, N'Payment method (if applicable)'),
    (N'Transaction', N'WWI Customer Transaction ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer transaction ID in source system'),
    (N'Transaction', N'WWI Supplier Transaction ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier transaction ID in source system'),
    (N'Transaction', N'WWI Invoice ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Invoice ID in source system'),
    (N'Transaction', N'WWI Purchase Order ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Purchase order ID in source system'),
    (N'Transaction', N'Supplier Invoice Number', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier invoice number (if applicable)'),
    (N'Transaction', N'Total Excluding Tax', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount excluding tax'),
    (N'Transaction', N'Tax Amount', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount of tax'),
    (N'Transaction', N'Total Including Tax', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount including tax'),
    (N'Transaction', N'Outstanding Balance', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Amount still outstanding for this transaction'),
    (N'Transaction', N'Is Finalized', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Has this transaction been finalized?'),
    (N'Transaction', N'Lineage Key', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row');
GO

-- Integration.City_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (510, N'Integration', N'City_Staging', 0, 0, N'City staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'City_Staging', N'City Staging Key', 1, N'int', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Row ID within the staging table'),
    (N'City_Staging', N'WWI City ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a city within the WWI database'),
    (N'City_Staging', N'City', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Formal name of the city'),
    (N'City_Staging', N'State Province', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'State or province for this city'),
    (N'City_Staging', N'Country', 0, N'nvarchar', 0, 60, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Country name'),
    (N'City_Staging', N'Continent', 0, N'nvarchar', 0, 30, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Continent that this city is on'),
    (N'City_Staging', N'Sales Territory', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Sales territory for this StateProvince'),
    (N'City_Staging', N'Region', 0, N'nvarchar', 0, 30, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name of the region'),
    (N'City_Staging', N'Subregion', 0, N'nvarchar', 0, 30, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name of the subregion'),
    (N'City_Staging', N'Location', 0, N'geography', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Geographic location of the city'),
    (N'City_Staging', N'Latest Recorded Population', 0, N'bigint', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Latest available population for the City'),
    (N'City_Staging', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'City_Staging', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'City_Staging', N'IX_Integration_City_Staging_WWI_City_ID', N'[WWI City ID]', NULL, 0, NULL, N'Allows quickly locating by WWI City Key');
GO

-- Integration.Customer_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (520, N'Integration', N'Customer_Staging', 0, 0, N'Customer staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Customer_Staging', N'Customer Staging Key', 1, N'int', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Row ID within the staging table'),
    (N'Customer_Staging', N'WWI Customer ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a customer within the WWI database'),
    (N'Customer_Staging', N'Customer', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer''s full name (usually a trading name)'),
    (N'Customer_Staging', N'Bill To Customer', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Bill to customer''s full name'),
    (N'Customer_Staging', N'Category', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer''s category'),
    (N'Customer_Staging', N'Buying Group', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer''s buying group'),
    (N'Customer_Staging', N'Primary Contact', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Primary contact'),
    (N'Customer_Staging', N'Postal Code', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Delivery postal code for the customer'),
    (N'Customer_Staging', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'Customer_Staging', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Customer_Staging', N'IX_Integration_Customer_Staging_WWI_Customer_ID', N'[WWI Customer ID]', NULL, 0, NULL, N'Allows quickly locating by WWI Customer ID');
GO

-- Integration.Employee_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (530, N'Integration', N'Employee_Staging', 0, 0, N'Employee staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Employee_Staging', N'Employee Staging Key', 1, N'int', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Row ID within the staging table'),
    (N'Employee_Staging', N'WWI Employee ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID (PersonID) in the WWI database'),
    (N'Employee_Staging', N'Employee', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Full name for this person'),
    (N'Employee_Staging', N'Preferred Name', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name that this person prefers to be called'),
    (N'Employee_Staging', N'Is Salesperson', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this person a staff salesperson?'),
    (N'Employee_Staging', N'Photo', 0, N'varbinary(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Photo of this person'),
    (N'Employee_Staging', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'Employee_Staging', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Employee_Staging', N'IX_Integration_Employee_Staging_WWI_Employee_ID', N'[WWI Employee ID]', NULL, 0, NULL, N'Allows quickly locating by WWI Employee ID');
GO

-- Integration.PaymentMethod_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (540, N'Integration', N'PaymentMethod_Staging', 0, 0, N'Payment method staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'PaymentMethod_Staging', N'Payment Method Staging Key', 1, N'int', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Row ID within the staging table'),
    (N'PaymentMethod_Staging', N'WWI Payment Method ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID for the payment method in the WWI database'),
    (N'PaymentMethod_Staging', N'Payment Method', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Payment method name'),
    (N'PaymentMethod_Staging', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'PaymentMethod_Staging', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'PaymentMethod_Staging', N'IX_Integration_PaymentMethod_Staging_WWI_Payment_Method_ID', N'[WWI Payment Method ID]', NULL, 0, NULL, N'Allows quickly locating by WWI Payment Method ID');
GO

-- Integration.StockItem_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (550, N'Integration', N'StockItem_Staging', 0, 0, N'Stock item staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'StockItem_Staging', N'Stock Item Staging Key', 1, N'int', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Row ID within the staging table'),
    (N'StockItem_Staging', N'WWI Stock Item ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a stock item within the WWI database'),
    (N'StockItem_Staging', N'Stock Item', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Full name of a stock item (but not a full description)'),
    (N'StockItem_Staging', N'Color', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Color (optional) for this stock item'),
    (N'StockItem_Staging', N'Selling Package', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Usual package for selling units of this stock item'),
    (N'StockItem_Staging', N'Buying Package', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Usual package for selling outers of this stock item (ie cartons, boxes, etc.)'),
    (N'StockItem_Staging', N'Brand', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Brand for the stock item (if the item is branded)'),
    (N'StockItem_Staging', N'Size', 0, N'nvarchar', 0, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Size of this item (eg: 100mm)'),
    (N'StockItem_Staging', N'Lead Time Days', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Number of days typically taken from order to receipt of this stock item'),
    (N'StockItem_Staging', N'Quantity Per Outer', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of the stock item in an outer package'),
    (N'StockItem_Staging', N'Is Chiller Stock', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Does this stock item need to be in a chiller?'),
    (N'StockItem_Staging', N'Barcode', 0, N'nvarchar', 1, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Barcode for this stock item'),
    (N'StockItem_Staging', N'Tax Rate', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax rate to be applied'),
    (N'StockItem_Staging', N'Unit Price', 0, N'decimal', 0, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Selling price (ex-tax) for one unit of this product'),
    (N'StockItem_Staging', N'Recommended Retail Price', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Recommended retail price for this stock item'),
    (N'StockItem_Staging', N'Typical Weight Per Unit', 0, N'decimal', 0, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Typical weight for one unit of this product (packaged)'),
    (N'StockItem_Staging', N'Photo', 0, N'varbinary(max)', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Photo of the product'),
    (N'StockItem_Staging', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'StockItem_Staging', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'StockItem_Staging', N'IX_Integration_StockItem_Staging_WWI_Stock_Item_ID', N'[WWI Stock Item ID]', NULL, 0, NULL, N'Allows quickly locating by WWI Stock Item ID');
GO

-- Integration.Supplier_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (560, N'Integration', N'Supplier_Staging', 0, 0, N'Supplier staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Supplier_Staging', N'Supplier Staging Key', 1, N'int', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Row ID within the staging table'),
    (N'Supplier_Staging', N'WWI Supplier ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a supplier within the WWI database'),
    (N'Supplier_Staging', N'Supplier', 0, N'nvarchar', 0, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier''s full name (usually a trading name)'),
    (N'Supplier_Staging', N'Category', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier''s category'),
    (N'Supplier_Staging', N'Primary Contact', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Primary contact'),
    (N'Supplier_Staging', N'Supplier Reference', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier reference for our organization (might be our account number at the supplier)'),
    (N'Supplier_Staging', N'Payment Days', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Number of days for payment of an invoice (ie payment terms)'),
    (N'Supplier_Staging', N'Postal Code', 0, N'nvarchar', 0, 10, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Delivery postal code for the supplier'),
    (N'Supplier_Staging', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'Supplier_Staging', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time');
GO

INSERT Metadata.[Indexes]
    (TableName, IndexName, IndexColumns, IncludedColumns, IsUnique, FilterClause, IndexDescription)
VALUES 
    (N'Supplier_Staging', N'IX_Integration_Supplier_Staging_WWI_Supplier_ID', N'[WWI Supplier ID]', NULL, 0, NULL, N'Allows quickly locating by WWI Supplier ID');
GO

-- Integration.TransactionType_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (570, N'Integration', N'TransactionType_Staging', 0, 0, N'Transaction type staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'TransactionType_Staging', N'Transaction Type Staging Key', 1, N'int', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Row ID within the staging table'),
    (N'TransactionType_Staging', N'WWI Transaction Type ID', 0, N'int', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Numeric ID used for reference to a transaction type within the WWI database'),
    (N'TransactionType_Staging', N'Transaction Type', 0, N'nvarchar', 0, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Full name of the transaction type'),
    (N'TransactionType_Staging', N'Valid From', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid from this date and time'),
    (N'TransactionType_Staging', N'Valid To', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Valid until this date and time');
GO

-- Integration.Movement_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (600, N'Integration', N'Movement_Staging', 0, 0, N'Movement staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Movement_Staging', N'Movement Staging Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Movement fact'),
    (N'Movement_Staging', N'Date Key', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Transaction date'),
    (N'Movement_Staging', N'Stock Item Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock item for this purchase order'),
    (N'Movement_Staging', N'Customer Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer (if applicable)'),
    (N'Movement_Staging', N'Supplier Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier (if applicable)'),
    (N'Movement_Staging', N'Transaction Type Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Type of transaction'),
    (N'Movement_Staging', N'WWI Stock Item Transaction ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock item transaction ID in source system'),
    (N'Movement_Staging', N'WWI Invoice ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Invoice ID in source system'),
    (N'Movement_Staging', N'WWI Purchase Order ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Purchase order ID in source system'),
    (N'Movement_Staging', N'Quantity', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of stock movement (positive is incoming stock, negative is outgoing)'),
    (N'Movement_Staging', N'WWI Stock Item ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock Item ID in source system'),
    (N'Movement_Staging', N'WWI Customer ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer ID in source system'),
    (N'Movement_Staging', N'WWI Supplier ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier ID in source system'),
    (N'Movement_Staging', N'WWI Transaction Type ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Transaction Type ID in source system'),
    (N'Movement_Staging', N'Last Modifed When', 0, N'datetime2', 1, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'When this row was last modified');
GO

-- Integration.Order_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (610, N'Integration', N'Order_Staging', 0, 0, N'Order staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Order_Staging', N'Order Staging Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Order fact'),
    (N'Order_Staging', N'City Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'City for this order'),
    (N'Order_Staging', N'Customer Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer for this order'),
    (N'Order_Staging', N'Stock Item Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock item for this order'),
    (N'Order_Staging', N'Order Date Key', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Order date for this order'),
    (N'Order_Staging', N'Picked Date Key', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Picked date for this order'),
    (N'Order_Staging', N'Salesperson Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Salesperson for this order'),
    (N'Order_Staging', N'Picker Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Picker for this order'),
    (N'Order_Staging', N'WWI Order ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'OrderID in source system'),
    (N'Order_Staging', N'WWI Backorder ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'BackorderID in source system'),
    (N'Order_Staging', N'Description', 0, N'nvarchar', 1, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Description of the item supplied (Usually the stock item name but can be overridden)'),
    (N'Order_Staging', N'Package', 0, N'nvarchar', 1, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Type of package to be supplied'),
    (N'Order_Staging', N'Quantity', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity to be supplied'),
    (N'Order_Staging', N'Unit Price', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Unit price to be charged'),
    (N'Order_Staging', N'Tax Rate', 0, N'decimal', 1, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax rate to be applied'),
    (N'Order_Staging', N'Total Excluding Tax', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount excluding tax'),
    (N'Order_Staging', N'Tax Amount', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount of tax'),
    (N'Order_Staging', N'Total Including Tax', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount including tax'),
    (N'Order_Staging', N'Lineage Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Lineage Key for the data load for this row'),
    (N'Order_Staging', N'WWI City ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'City ID in source system'),
    (N'Order_Staging', N'WWI Customer ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer ID in source system'),
    (N'Order_Staging', N'WWI Stock Item ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock Item ID in source system'),
    (N'Order_Staging', N'WWI Salesperson ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Salesperson person ID in source system'),
    (N'Order_Staging', N'WWI Picker ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Picker person ID in source system'),
    (N'Order_Staging', N'Last Modified When', 0, N'datetime2', 1, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'When this row was last modified');
GO

-- Integration.Purchase_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (620, N'Integration', N'Purchase_Staging', 0, 0, N'Purchase staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Purchase_Staging', N'Purchase Staging Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Purchase fact'),
    (N'Purchase_Staging', N'Date Key', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Purchase order date'),
    (N'Purchase_Staging', N'Supplier Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier for this purchase order'),
    (N'Purchase_Staging', N'Stock Item Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock item for this purchase order'),
    (N'Purchase_Staging', N'WWI Purchase Order ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Purchase order ID in source system '),
    (N'Purchase_Staging', N'Ordered Outers', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of outers (ordering packages)'),
    (N'Purchase_Staging', N'Ordered Quantity', 0, N'int', 1, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity of inners (selling packages)'),
    (N'Purchase_Staging', N'Received Outers', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Received outers (so far)'),
    (N'Purchase_Staging', N'Package', 0, N'nvarchar', 1, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Package ordered'),
    (N'Purchase_Staging', N'Is Order Finalized', 0, N'bit', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Is this purchase order now finalized?'),
    (N'Purchase_Staging', N'WWI Supplier ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier ID in source system'),
    (N'Purchase_Staging', N'WWI Stock Item ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock Item ID in source system'),
    (N'Purchase_Staging', N'Last Modified When', 0, N'datetime2', 1, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'When this row was last modified');
GO

-- Integration.Sale_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (630, N'Integration', N'Sale_Staging', 0, 0, N'Sale staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Sale_Staging', N'Sale Staging Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Sale fact'),
    (N'Sale_Staging', N'City Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'City for this invoice'),
    (N'Sale_Staging', N'Customer Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer for this invoice'),
    (N'Sale_Staging', N'Bill To Customer Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Bill To Customer for this invoice'),
    (N'Sale_Staging', N'Stock Item Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock item for this invoice'),
    (N'Sale_Staging', N'Invoice Date Key', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Invoice date for this invoice'),
    (N'Sale_Staging', N'Delivery Date Key', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Date that these items were delivered'),
    (N'Sale_Staging', N'Salesperson Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Salesperson for this invoice'),
    (N'Sale_Staging', N'WWI Invoice ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'InvoiceID in source system'),
    (N'Sale_Staging', N'Description', 0, N'nvarchar', 1, 100, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Description of the item supplied (Usually the stock item name but can be overridden)'),
    (N'Sale_Staging', N'Package', 0, N'nvarchar', 1, 50, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Type of package supplied'),
    (N'Sale_Staging', N'Quantity', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity supplied'),
    (N'Sale_Staging', N'Unit Price', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Unit price charged'),
    (N'Sale_Staging', N'Tax Rate', 0, N'decimal', 1, NULL, 18, 3, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Tax rate applied'),
    (N'Sale_Staging', N'Total Excluding Tax', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount excluding tax'),
    (N'Sale_Staging', N'Tax Amount', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount of tax'),
    (N'Sale_Staging', N'Profit', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount of profit'),
    (N'Sale_Staging', N'Total Including Tax', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount including tax'),
    (N'Sale_Staging', N'Total Dry Items', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total number of dry items'),
    (N'Sale_Staging', N'Total Chiller Items', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total number of chiller items'),
    (N'Sale_Staging', N'WWI City ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'City ID in source system'),
    (N'Sale_Staging', N'WWI Customer ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer ID in source system'),
    (N'Sale_Staging', N'WWI Bill To Customer ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Bill to Customer ID in source system'),
    (N'Sale_Staging', N'WWI Stock Item ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock Item ID in source system'),
    (N'Sale_Staging', N'WWI Salesperson ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Salesperson person ID in source system'),
    (N'Sale_Staging', N'Last Modified When', 0, N'datetime2', 1, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'When this row was last modified');
GO

-- Integration.StockHolding_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (640, N'Integration', N'StockHolding_Staging', 0, 0, N'Stock holding staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'StockHolding_Staging', N'Stock Holding Staging Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Stock Holding fact'),
    (N'StockHolding_Staging', N'Stock Item Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock item being held'),
    (N'StockHolding_Staging', N'Quantity On Hand', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity on hand'),
    (N'StockHolding_Staging', N'Bin Location', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Bin location (where is this stock in the warehouse)'),
    (N'StockHolding_Staging', N'Last Stocktake Quantity', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity present at last stocktake'),
    (N'StockHolding_Staging', N'Last Cost Price', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Unit cost when the stock item was last purchased'),
    (N'StockHolding_Staging', N'Reorder Level', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Quantity below which reordering should take place'),
    (N'StockHolding_Staging', N'Target Stock Level', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Typical stock level held'),
    (N'StockHolding_Staging', N'WWI Stock Item ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Stock Item ID in source system');
GO

-- Integration.Transaction_Staging Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (650, N'Integration', N'Transaction_Staging', 0, 0, N'Transaction staging table');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Transaction_Staging', N'Transaction Staging Key', 1, N'bigint', 0, NULL, NULL, NULL, 1, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'DW key for a row in the Transaction fact'),
    (N'Transaction_Staging', N'Date Key', 0, N'date', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Transaction date'),
    (N'Transaction_Staging', N'Customer Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer (if applicable)'),
    (N'Transaction_Staging', N'Bill To Customer Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Bill to customer (if applicable)'),
    (N'Transaction_Staging', N'Supplier Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier (if applicable)'),
    (N'Transaction_Staging', N'Transaction Type Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Type of transaction'),
    (N'Transaction_Staging', N'Payment Method Key', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Payment method (if applicable)'),
    (N'Transaction_Staging', N'WWI Customer Transaction ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer transaction ID in source system'),
    (N'Transaction_Staging', N'WWI Supplier Transaction ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier transaction ID in source system'),
    (N'Transaction_Staging', N'WWI Invoice ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Invoice ID in source system'),
    (N'Transaction_Staging', N'WWI Purchase Order ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Purchase order ID in source system'),
    (N'Transaction_Staging', N'Supplier Invoice Number', 0, N'nvarchar', 1, 20, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier invoice number (if applicable)'),
    (N'Transaction_Staging', N'Total Excluding Tax', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount excluding tax'),
    (N'Transaction_Staging', N'Tax Amount', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount of tax'),
    (N'Transaction_Staging', N'Total Including Tax', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Total amount including tax'),
    (N'Transaction_Staging', N'Outstanding Balance', 0, N'decimal', 1, NULL, 18, 2, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Amount still outstanding for this transaction'),
    (N'Transaction_Staging', N'Is Finalized', 0, N'bit', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Has this transaction been finalized?'),
    (N'Transaction_Staging', N'WWI Customer ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Customer ID in source system'),
    (N'Transaction_Staging', N'WWI Bill To Customer ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Bill to Customer ID in source system'),
    (N'Transaction_Staging', N'WWI Supplier ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Supplier ID in source system'),
    (N'Transaction_Staging', N'WWI Transaction Type ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Transaction Type ID in source system'),
    (N'Transaction_Staging', N'WWI Payment Method ID', 0, N'int', 1, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Payment method ID in source system'),
    (N'Transaction_Staging', N'Last Modified When', 0, N'datetime2', 1, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'When this row was last modified');
GO

-- Integration.[ETL Cutoff] Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (700, N'Integration', N'ETL Cutoff', 0, 0, N'ETL Cutoff Times');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'ETL Cutoff', N'Table Name', 1, N'sysname', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 1, 0, NULL, NULL, 0, NULL, N'Table name'),
    (N'ETL Cutoff', N'Cutoff Time', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Time up to which data has been loaded');
GO

-- Integration.Lineage Table
INSERT Metadata.[Tables]
    (TableCreationOrder, SchemaName, TableName, IncludeTemporalColumns, IncludeModificationTrackingColumns, TableDescription)
VALUES (710, N'Integration', N'Lineage', 0, 0, N'Details of data load attempts');

INSERT Metadata.[Columns]
    (TableName, ColumnName, IsPrimaryKeyColumn, DataType, IsNullable,
     MaximumLength, DecimalPrecision, DecimalScale, HasDefaultValue, UsesSequenceDefault, DefaultSequenceName,
     DefaultValue, IsUnique, HasForeignKeyReference, ForeignKeyTable, ForeignKeyColumn, AutomaticallyIndexForeignKey,
     ColumnMaskFunction, ColumnDescription)
VALUES
    (N'Lineage', N'Lineage Key', 1, N'int', 0, NULL, NULL, NULL, 1, 1, N'LineageKey', NULL, 0, 0, NULL, NULL, 0, NULL, N'DW key for lineage data'),
    (N'Lineage', N'Data Load Started', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Time when the data load attempt began'),
    (N'Lineage', N'Table Name', 0, N'sysname', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Name of the table for this data load event'),
    (N'Lineage', N'Data Load Completed', 0, N'datetime2', 1, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Time when the data load attempt completed (successfully or not)'),
    (N'Lineage', N'Was Successful', 0, N'bit', 0, NULL, NULL, NULL, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Was the attempt successful?'),
    (N'Lineage', N'Source System Cutoff Time', 0, N'datetime2', 0, NULL, NULL, 7, 0, 0, NULL, NULL, 0, 0, NULL, NULL, 0, NULL, N'Time that rows from the source system were loaded up until');
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
