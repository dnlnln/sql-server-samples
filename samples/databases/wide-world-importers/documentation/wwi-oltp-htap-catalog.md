# WideWorldImporters Database Catalog

The WideWorldImporters database contains all the transaction information and daily data for sales and purchases, as well as sensor data for vehicles and cold rooms.

## Schemas

WideWorldImporters uses schemas for different purposes, such as storing data, defining how users can access the data, and providing objects for data warehouse development and integration.

### Data schemas

These schemas contain the data. A number of tables are needed by all other schemas and are located in the Application schema.

|Schema|Description|
|-----------------------------|---------------------|
|Application|Application-wide users, contacts, and parameters. This also contains reference tables with data that is used by multiple schemas|
|Purchasing|Stock item purchases from suppliers and details about suppliers.|  
|Sales|Stock item sales to retail customers, and details about customers and sales people. |  
|Warehouse|Stock item inventory and transactions.|  

### Secure-access schemas

These schemas are used for external applications that are not allowed to access the data tables directly. They contain views and stored procedures used by external applications.

|Schema|Description|
|-----------------------------|---------------------|
|Website|All access to the database from the company website is through this schema.|
|Reports|All access to the database from Reporting Services reports is through this schema.|
|PowerBI|All access to the database from the Power BI dashboards via the Enterprise Gateway is through this schema.|

Note that the Reports and PowerBI schemas are not used in the initial release of the sample database. However, all Reporting Services and Power BI samples built on top of this database are encouraged to use these schemas.

### Development schemas

Special-purpose schemas

|Schema|Description|
|-----------------------------|---------------------|
|Integration|Objects and procedures required for data warehouse integration (i.e. migrating the data to the WideWorldImportersDW database).|
|Sequences|Holds sequences used by all tables in the application.|

## Tables

All tables in the database are in the data schemas.

### Application Schema

Details of parameters and people (users and contacts), along with common reference tables (common to multiple other schemas).

|Table|Description|
|-----------------------------|---------------------|
|SystemParameters|Contains system-wide configurable parameters.|
|People|Contains user names, contact information, for all who use the application, and for the people that the Wide World Importers deals with at customer organizations. This includes staff, customers, suppliers, and any other contacts. For people who have been granted permission to use the system or website, the information includes login details.|
|Cities|There are many addresses stored in the system, for people, customer organization delivery addresses, pickup addresses at suppliers, etc. Whenever an address is stored, there is a reference to a city in this table. There is also a spatial location for each city.|
|StateProvinces|Cities are part of states or provinces. This table has details of those, including spatial data describing the boundaries each state or province.|
|Countries|States or Provinces are part of countries. This table has details of those, including spatial data describing the boundaries of each country.|
|DeliveryMethods|Choices for delivering stock items (e.g., truck/van, post, pickup, courier, etc.)|
|PaymentMethods|Choices for making payments (e.g., cash, check, EFT, etc.)|
|TransactionTypes|Types of customer, supplier, or stock transactions (e.g., invoice, credit note, etc.)|

### Purchasing Schema

Details of suppliers and of stock item purchases.

|Table|Description|
|-----------------------------|---------------------|
|Suppliers|Main entity table for suppliers (organizations)|
|SupplierCategories|Categories for suppliers (e.g., novelties, toys, clothing, packaging, etc.)|
|SupplierTransactions|All financial transactions that are supplier-related (invoices, payments)|
|PurchaseOrders|Details of supplier purchase orders|
|PurchaseOrderLines|Detail lines from supplier purchase orders|

 
### Sales Schema

Details of customers, salespeople, and of stock item sales.

|Table|Description|
|-----------------------------|---------------------|
|Customers|Main entity tables for customers (organizations or individuals)|
|CustomerCategories|Categories for customers (ie novelty stores, supermarkets, etc.)|
|BuyingGroups|Customer organizations can be part of groups that exert greater buying power|
|CustomerTransactions|All financial transactions that are customer-related (invoices, payments)|
|SpecialDeals|Special pricing. This can include fixed prices, discount in dollars or discount percent.|
|Orders|Detail of customer orders|
|OrderLines|Detail lines from customer orders|
|Invoices|Details of customer invoices|
|InvoiceLines|Detail lines from customer invoices|

### Warehouse Schema

Details of stock items, their holdings and transactions.

|Table|Description|
|-----------------------------|---------------------|
|StockItems|Main entity table for stock items|
|StockItemHoldings|Non-temporal columns for stock items. These arefrequently updated columns.|
|StockGroups|Groups for categorizing stock items (e.g., novelties, toys, edible novelties, etc.)|
|StockItemStockGroups|Which stock items are in which stock groups (many to many)|
|Colors|Stock items can (optionally) have colors|
|PackageTypes|Ways that stock items can be packaged (e.g., box, carton, pallet, kg, etc.|
|StockItemTransactions|Transactions covering all movements of all stock items (receipt, sale, write-off)|
|VehicleTemperatures|Regularly recorded temperatures of vehicle chillers|
|ColdRoomTemperatures|Regularly recorded temperatures of cold room chillers|


## Design considerations

Database design is subjective and there is no right or wrong way to design a database. The schemas and tables in this database show ideas for how you can design your own database.

### Schema design

WideWorldImporters uses a small number of schemas so that it is easy to understand the database system and demonstrate database principles.  

Wherever possible, the database collocates tables that are commonly queried together into the same schema to minimize join complexity.

The database schema has been code-generated based on a series of metadata tables in another database WWI_Preparation. This gives WideWorldImporters a very high degree of design consistency, naming consistency, and completeness. For details on how the schema has been generated see the source code: [wide-world-importers/wwi-database-scripts](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/wide-world-importers/wwi-database-scripts)

### Table design

- All tables have single column primary keys for join simplicity.
- All schemas, tables, columns, indexes, and check constraints have a Description extended property that can be used to identify the purpose of the object or column. Memory-optimized tables are an exception to this since they don’t currently support extended properties.
- All foreign keys are automatically indexed unless there is another non-clustered index that has the same left-hand component.
- Auto-numbering in tables is based on sequences. These sequences are easier to work with across linked servers and similar environments than IDENTITY columns. Memory-optimized tables use IDENTITY columns since they don’t support in SQL Server 2016.
- A single sequence (TransactionID) is used for these tables: CustomerTransactions, SupplierTransactions, and StockItemTransactions. This demonstrates how a set of tables can have a single sequence.
- Some columns have appropriate default values.

### Security schemas

For security, WideWorldImporters does not allow external applications to access data schemas directly. To isolate access, WideWorldImporters uses security-access schemas that do not hold data, but contain views and stored procedures. External applications use the security schemas to retrieve the data that they are allowed to view.  This way, users can only run the views and stored procedures in the secure-access schemas

For example, this sample includes Power BI dashboards. An external application accesses these Power BI dashboards from the Power BI gateway as a user that has read-only permission on the PowerBI schema.  For read-only permission, the user only needs SELECT and EXECUTE permission on the PowerBI schema. A database administrator at WWI assigns these permissions as needed.
