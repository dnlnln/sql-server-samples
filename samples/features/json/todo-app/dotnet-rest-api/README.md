# ASP.NET Core REST Web API that uses SQL/JSON functionalites 

This project contains an example implementation of ASP.NET Core REST API with CRUD operations on a simple Todo table. You can learn how to build REST API on the existing database schema using new JSON functionalities that are available in SQL Server 2016 (or higher) and Azure SQL Database.

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Run this sample](#run-this-sample)<br/>
[Sample details](#sample-details)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>

<a name=about-this-sample></a>

## About this sample

- **Applies to:** SQL Server 2016 (or higher), Azure SQL Database
- **Key features:** JSON Functions in SQL Server 2016/Azure SQL Database - FOR JSON and OPENJSON
- **Programming Language:** C#
- **Authors:** Jovan Popovic

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

1. SQL Server 2016 (or higher) or an Azure SQL Database
2. Visual Studio 2015 (or higher) with the ASP.NET Core RC2 (or higher)

**Azure prerequisites:**

1. Permission to create an Azure SQL Database

<a name=run-this-sample></a>

## Run this sample

1. From SQL Server Management Studio or Sql Server Data Tools connect to your SQL Server 2016 or Azure SQL database and execute setup.sql script that will create and populate Todo table in the database.

2. From Visual Studio, open the **TodoApp.xproj** file from the root directory,

3. Locate Startup.cs file in the project, change connection string in ConfigureServices method to reference your database, and build solution using Ctrl+Shift+B, right-click on project + Build, or Build/Build Solution from menu.

4. Run sample app using F5 or Ctrl+F5,
4.1. Open /api/Todo Url to get all Todo items as a JSON array,
4.2. Open /api/Todo/1 Url to get details about a single Todo item with id 1,
4.3. Send POST, PUT, PATCH, or DELETE Http requests to update content of Todo table.

<a name=sample-details></a>

## Sample details

This sample application shows how to create simple REST API service that performs CRUD operations on a simple Todo table.
ASP.NET Core Web API is used to implement REST Service in the example.
Service uses built-in JSON functionalities that are available in SQL Server 2016 and Azure SQL Database.

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended demonstrate some general guidances and arhitectural patterns for web development. It contains minimal code required to create REST API, and it does not use some patterns such as Repository. Sample uses built-in ASP.NET Core Dependency Injection mechanism; however, this is not prerequisite.
You can easily modify this code to fit the architecture of your application.

<a name=related-links></a>

## Related Links

For more information, see this [article](http://www.codeproject.com/Articles/1106622/Building-Web-API-REST-services-on-Azure-SQL-Databa).

## License
These samples and templates are all licensed under the MIT license. See the license.txt file in the root.

## Questions
Email questions to: sqlserversamples@microsoft.com.