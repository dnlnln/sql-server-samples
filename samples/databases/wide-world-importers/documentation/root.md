# Wide World Importers Sample for SQL Server and Azure SQL Database

Wide World Importers is a comprehensive database sample that both illustrates database design, and illustrates how SQL Server features can be leveraged in an application.

Note that the sample is meant to be representative of a typical database. It does not include every feature of SQL Server. The design of the database follows one common set of standards, but there are many ways one might build a database.

The source code for the sample can be found on the SQL Server Samples GitHub repository:
[wide-world-importers](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/wide-world-importers).

The latest released version of the sample:
[wide-world-importers-v0.1](https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v0.1)

The documentation for the sample is organized as follows:

## Overview

__[Wide World Importers Overview](wwi-overview.md)__

Overview of the sample company Wide World Importers, and the workflows addressed by the sample.

## Main OLTP Database WideWorldImporters

__[WideWorldImporters Installation and Configuration](wwi-oltp-htap-installation.md)__

Instructions for the installation and configuration of the core database WideWorldImporters that is used for transaction processing (OLTP - OnLine Transaction Processing) and operational analytics (HTAP - Hybrid Transactional/Analytical Processing).

__[WideWorldImporters Database Catalog](wwi-oltp-htap-catalog.md)__

Description of the schemas and tables used in the WideWorldImporters database.

__[WideWorldImporters Use of SQL Server Features and Capabilities](wwi-oltp-htap-sql-features.md)__   

Describes how WideWorldImporters leverages core SQL Server features.

__[WideWorldImporters Sample Queries](wwi-oltp-htap-sample-queries.md)__

Sample queries for the WideWorldImporters database.

## Data Warehousing and Analytics Database WideWorldImportersDW

__[WideWorldImportersDW Installation and Configuration](wwi-olap-installation.md)__

Instructions for the installation and configuration of the OLAP database WideWorldImportersDW.

__[WideWorldImportersDW OLAP Database Catalog](wwi-olap-catalog.md)__

Description of the schemas and tables used in the WideWorldImportersDW database, which is the sample database for data warehousing and analytics processing (OLAP).

__[WideWorldImporters ETL Workflow](wwi-etl.md)__

Workflow for the ETL (Extract, Transform, Load) process that migrates data from the transactional database WideWorldImporters to the data warehouse WideWorldImportersDW.

__[WideWorldImportersDW Use of SQL Server Features and Capabilities](wwi-olap-sql-features.md)__

Describes how the WideWorldImportersDW leverages SQL Server features for analytics processing.

__[WideWorldImportersDW OLAP Sample Queries](wwi-olap-sample-queries.md)__

Sample analytics queries leveraging the WideWorldImportersDW database.

## Data generation

__[WideWorldImporters Data Generation](wwi-data-generation.md)__

Describes how additional data can be generated in the sample database, for example inserting sales and purchase data up to the current date.
