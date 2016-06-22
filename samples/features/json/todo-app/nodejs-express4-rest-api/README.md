# NodeJS Express4 REST API that uses SQL/JSON functionalities 

This project contains an example implementation of NodeJS REST API with CRUD operations on a simple Todo table. You can learn how to build REST API on the existing database schema using NodeJS, Express4, and new JSON functionalities that are available in SQL Server 2016 (or higher) and Azure SQL Database.

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
- **Programming Language:** JavaScript (NodeJS)
- **Authors:** Jovan Popovic

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

1. SQL Server 2016 (or higher) or an Azure SQL Database
2. Visual Studio 2015 (or higher) with the NodeJS

**Azure prerequisites:**

1. Permission to create an Azure SQL Database

<a name=run-this-sample></a>

## Run this sample

1. Navigate to the folder where you have downloaded sample and run **npm install** in command window, or run setup.bat if you are on Windows operating system. This command will install necessary npm packages defined in project.json.

2. From SQL Server Management Studio or SQL Server Data Tools connect to your SQL Server 2016 or Azure SQL database and execute setup.sql script that will create and populate Todo table in the database.

3. From Visual Studio, open the **TodoApp.xproj** file from the root directory,

4. Locate db.js file in the project, change database connection info in createConnection() method to reference your database. the following tokens should be replaced:
 1. SERVERNAME - name of the database server.
 2. DATABASE - Name of database where Todo table is stored.
 3. USERNAME - SQL Server login that can access table data and execute stored procedures.
 4. PASSWORD - Password associated to SQL Server login.

```
    var config = {
        server  : "SERVER.database.windows.net",
        userName: "USER",
        password: "PASSWORD",
        // If you're on Azure, you will need this:
        options: { encrypt: true, database: 'DATABASE' }
    };
```

5. Build project using Ctrl+Shift+B, right-click on project + Build, or Build/Build Solution from menu.

6. Run sample app using F5 or Ctrl+F5. /todo Url will be opened with a list of all Todo items as a JSON array,
 1. Open /api/Todo/1 Url to get details about a single Todo item with id 1,
 2. Send POST, PUT, or DELETE Http requests to update content of Todo table.

<a name=sample-details></a>

## Sample details

This sample application shows how to create simple REST API service that performs CRUD operations on a simple Todo table.
NodeJS REST API is used to implement REST Service in the example.
1. app.js file that contains startup code.
2. db.js file that contains functions that wrap Tedious library
3. todo.js file that contains action that will be called on GET, POST, PUT, and DELETE Http requests.

Service uses Tedious library for data access and built-in JSON functionalities that are available in SQL Server 2016 and Azure SQL Database.

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended demonstrate some general guidance and architectural patterns for web development.
It contains minimal code required to create REST API.
You can easily modify this code to fit the architecture of your application.

<a name=related-links></a>

## Related Links

For more information, see this [MSDN documentation](https://msdn.microsoft.com/en-us/library/dn921897.aspx).

## Code of Conduct
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## License
These samples and templates are all licensed under the MIT license. See the license.txt file in the root.

## Questions
Email questions to: [sqlserversamples@microsoft.com](mailto: sqlserversamples@microsoft.com).