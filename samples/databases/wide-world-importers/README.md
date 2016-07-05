# WideWorldImporters Sample Database for SQL Server and Azure SQL Database

WideWorldImporters is a sample for SQL Server and Azure SQL Database. It showcases database design, as well as how to best leverage SQL Server features in a database.

WideWorldImporters is a wholesale company. Transactions and real-time analytics are performed in the database WideWorldImporters. The database WideWorldImportersDW is an OLAP database, focused on analytics.

The sample includes the databases that can be explored, as well as sample applications and sample scripts that can be used to explore the use of individual SQL Server features in the sample database.

**Latest release**: [wide-world-importers-release](http://go.microsoft.com/fwlink/?LinkID=800630)

**Documentation**: [Wide World Importers Documentation](http://go.microsoft.com/fwlink/?LinkID=800631)

**Feedback on the sample**: send to [sqlserversamples@microsoft.com](mailto:sqlserversamples@microsoft.com)

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Sample structure](#run-this-sample)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>


<a name=about-this-sample></a>

## About this sample

<!-- Delete the ones that don't apply -->
1. **Applies to:** SQL Server 2016 (or higher), Azure SQL Database
1. **Key features:** Core database features
1. **Workload:** OLTP, OLAP, IoT
1. **Programming Language:** T-SQL, C#
1. **Authors:** Greg Low, Denzil Ribeiro, Jos de Bruijn
1. **Update history:** 25 May 2016 - initial revision

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

<!-- Examples -->
1. SQL Server 2016 (or higher) or an Azure SQL Database.
2. SQL Server Management Studio, preferably June 2016 release or later (version >= 13.0.15000.23).
3. (to build sample apps) Visual Studio 2015.
4. (to run ETL jobs) SQL Server 2016 Integration Services

<a name=run-this-sample></a>

## Sample structure

The latest release of this sample is available here: TBD

The source code for the sample is structured as follows:

__[sample-scripts] (sample-scripts/)__

Sample scripts that illustrate the use of various SQL Server features with the WideWorldImporters sample database.

__[workload-drivers] (workload-drivers/)__

Simple apps that simulate workloads for the WideWorldImporters sample database.

__[wwi-database-scripts] (wwi-database-scripts/)__

T-SQL scripts to create the main WideWorldImporters database.

__[wwi-dw-database-scripts] (wwi-dw-database-scripts/)__

T-SQL scripts to create the analytics database WideWorldImportersDW.

__[wwi-integration-etl] (wwi-integration-etl/)__

SQL Server Integration Services (SSIS) project for the Extract, Transform, and Load (ETL) process that takes data from the transactional database WideWorldImporters and loads it into the WideWorldImportersDW database.


<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be used for production purposes.

<a name=related-links></a>

## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->
For more information, see these articles:
- [SQL Server 2016 product page](https://www.microsoft.com/server-cloud/products/sql-server-2016/)
- [SQL Server 2016 download page](https://www.microsoft.com/evalcenter/evaluate-sql-server-2016)
- [Azure SQL Database product page](https://azure.microsoft.com/services/sql-database/)
- [What's new in SQL Server 2016](https://msdn.microsoft.com/en-us/library/bb500435.aspx)
