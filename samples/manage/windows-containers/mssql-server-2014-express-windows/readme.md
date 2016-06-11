# mssql-server-2014-express-windows
This Dockerfile helps developers to get started using SQL Server 2014 Express in Windows Server Core Containers. The file downloads and installs SQL Server 2014 Express with the default setup parameters.

Note: This dockerfile is based on Buc Rogers' work that can be found [here] (https://github.com/brogersyh/Dockerfiles-for-windows/tree/master/sqlexpress)

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Run this sample](#run-this-sample)<br/>
[Sample details](#sample-details)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>

<a name=about-this-sample></a>

## About this sample

1. **Applies to:** SQL Server 2014 Express, Windows Server Technical Preview 4 or later
5. **Authors:** Perry Skountrianos [perrysk-msft]

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

You can run the container with the following command. Note the you'll need Windows Server Core TP5 v10.0.14300.1000.
docker run -p 1433:1433 --env sa_password=<YOUR SA PASSWORD> microsoft/mssql-server-2014-express-windows

<a name=run-this-sample></a>

## Run this sample

The image provides one environment variable to set the sa password: </br>
- sa_password: Sets the sa password and enables the sa login

<a name=sample-details></a>

## Sample details

The Dockerfile downloads and installs SQL Server 2014 Express with the following default setup parameters that could be changed (if needed) after the image is installed.
- Collation: SQL_Latin1_General_CP1_CI_AS
- SQL Instance Name: SQLEXPRESS
- Root Directory: C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL
- Language: English (United Stated)

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be a set of best practices on how to build scalable enterprise grade applications. This is beyond the scope of this quick start sample.

<a name=related-links></a>

## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->

For more information, see these articles:
- [Windows Containers] (https://msdn.microsoft.com/en-us/virtualization/windowscontainers/about/about_overview)
- [Windows-based containers: Modern app development with enterprise-grade control] (https://www.youtube.com/watch?v=Ryx3o0rD5lY&feature=youtu.be)
- [Windows Containers: What, Why and How] (https://channel9.msdn.com/Events/Build/2015/2-704)
- [SQL Server in Windows Containers] (https://blogs.msdn.microsoft.com/sqlserverstorageengine/2016/03/21/sql-server-in-windows-containers/#comments)
