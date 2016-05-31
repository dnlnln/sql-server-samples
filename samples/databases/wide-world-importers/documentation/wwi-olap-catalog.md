# WideWorldImportersDW OLAP Database Catalog

The WideWorldImportersDW database is used for data warehousing and analytical processing. The transactional data about sales and purchases is generated in the WideWorldImporters database, and loaded into the WideWorldImportersDW database using a [daily ETL process](wwi-etl.md).

The data in WideWorldImportersDW thus mirrors the data in WideWorldImporters, but the tables are organized differently. While WideWorldImporters has a traditional normalized schema, WideWorldImportersDW uses the [star schema](https://wikipedia.org/wiki/Star_schema) approach for its table design. Besides the fact and dimension tables, the database includes a number of staging tables that are used in the ETL process.

## Schemas

The different types of tables are organized in three schemas.

|Schema|Description|
|-----------------------------|---------------------|
|Dimension|Dimension tables.|
|Fact|Fact tables.|  
|Integration|Staging tables and other objects needed for ETL.|  

## Tables

The dimension and fact tables are listed below. The tables in the Integration schema are used only for the ETL process, and are not listed.

### Dimension tables

WideWorldImportersDW has the following dimension tables. The description includes the relationship with the source tables in the WideWorldImporters database.

|Table|Source tables|
|-----------------------------|---------------------|
|City|`Application.Cities`, `Application.StateProvinces`, `Application.Countries`.|
|Customer|`Sales.Customers`, `Sales.BuyingGroups`, `Sales.CustomerCategories`.|
|Date|New table with information about dates, including financial year (based on November 1st start for financial year).|
|Employee|`Application.People`.|
|StockItem|`Warehouse.StockItems`, `Warehouse.Colors`, `Warehouse.PackageType`.|
|Supplier|`Purchasing.Suppliers`, `Purchasing.SupplierCategories`.|
|PaymentMethod|`Application.PaymentMethods`.|
|TransactionType|`Application.TransactionTypes`.|

### Fact tables

WideWorldImportersDW has the following dimension tables. The description includes the relationship with the source tables in the WideWorldImporters database, as well as the classes of analytics/reporting queries each fact table is typically used with.

|Table|Source tables|Sample Analytics|
|-----------------------------|---------------------|
|Order|`Sales.Orders` and `Sales.OrderLines`|Sales people, picker/packer productivity, and on time to pick orders. In addition, low stock situations leading to back orders.|
|Sale|`Sales.Invoices` and `Sales.InvoiceLines`|Sales dates, delivery dates, profitability over time, profitability by sales person.|
|Purchase|`Purchasing.PurchaseOrderLines`|Expected vs actual lead times|
|Transaction|`Sales.CustomerTransactions` and `Purchasing.SupplierTransactions`|Measuring issue dates vs finalization dates, and amounts.|
|Movement|`Warehouse.StockTransactions`|Movements over time.|
|Stock Holding|`Warehouse.StockItemHoldings`|On-hand stock levels and value|
