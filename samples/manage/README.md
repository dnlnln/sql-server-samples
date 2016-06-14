# Database management samples

Contains samples for managing Microsoft's SQL databases including SQL Server, Azure SQL Database, and Azure SQL Data Warehouse.

## Collect and monitor resource usage data across multiple pools in a subscription  
This Solution Quick Start provides a solution for collecting and monitoring Azure SQL Database resource usage across multiple pools in a subscription. When you have a large number of databases in a subscription, it is cumbersome to monitor each elastic pool separately. To solve this, you can combine SQL database PowerShell cmdlets and T-SQL queries to collect resource usage data from multiple pools and their databases for monitoring and analysis of resource usage.   

[Manage Mulitiple Elastic Pools in SQL Database Using PowerShell and Power BI](https://github.com/Microsoft/sql-server-samples/tree/master/samples/manage/azure-sql-db-elastic-pools) in the GitHub SQL Server samples repository provides a set of powershell scripts and T-SQL queries along with documentation on what it does and how to use it.  

## Get started using Elastic Pools in a SaaS scenario  
This Solution Quick Start provides a solution for a Softwware-as-a-Solution (SaaS) scenario that leverages Elastic Pools to provide a cost-effective, scalable database back-end of a SaaS application. In this solution, you will walk-though the implementation of a web app that lets you visualize the load created on an Elastic Pool by a load generator using a custom dashboard that supplements the Azure Portal.  

[saas-scenario-with-elastic-pools](https://github.com/Microsoft/sql-server-samples/tree/master/samples/manage/azure-sql-db-elastic-pools-custom-dashboard) in the GitHub SQL Server samples repository provides a load generator and monitoring web app along with the documentation on what it does and how to use it.  

## Windows Containers
This includes samples for setting up mssql-server in Windows Containers. Currently it includes the following:
- __[windows-containers] (windows-containers/)__
