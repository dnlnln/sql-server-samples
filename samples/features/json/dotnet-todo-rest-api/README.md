# .Net Todo REST API
This sample application shows how to create simple REST API service that performs CRUD operations on a simple Todo table.
ASP.NET Core Web API is used to implement REST Service in the example.
Service uses built-in JSON functionalities that are available in SQL Server 2016 and Azure SQL Database.

## Documentation
More details about this sample are available in CodeProject article: 
http://www.codeproject.com/Articles/1106622/Building-Web-API-REST-services-on-Azure-SQL-Databa

## How to use and run the sample?
1. Download the sample or clone repository,
2. Create database that contains Todo table using the Transact-SQL script placed in /setup/setup.sql or using bacpac file stored in /setup/TodoDb.bacpac,
3. Change connection string in Startup.cs class,
4. Build and run sample app.

## License
These samples and templates are all licensed under the MIT license. See the license.txt file in the root.

## Questions
Email questions to: sqlserversamples@microsoft.com.
