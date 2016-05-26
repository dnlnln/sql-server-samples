# Sample for use of Row-Level Security in WideWorldImporters

This script demonstrates the use of Row-Level Security to restrict access to certains rows in the table to certain users. 


### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Running the sample](#run-this-sample)<br/>
[Sample details](#sample-details)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>


<a name=about-this-sample></a>

## About this sample

<!-- Delete the ones that don't apply -->
1. **Applies to:** SQL Server 2016 (or higher), Azure SQL Database
1. **Key features:** Row-Level Security
1. **Workload:** OLTP
1. **Programming Language:** T-SQL
1. **Authors:** Greg Low, Jos de Bruijn
1. **Update history:** 26 May 2016 - initial revision

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

<!-- Examples -->
1. SQL Server 2016 (or higher) or Azure SQL Database. 
 - With SQL Server, make sure SQL authentication is enabled.
2. SQL Server Management Studio
3. The WideWorldImporters database.

<a name=run-this-sample></a>

## Running the sample

1. Open both scripts in different windows or tabs in Management Studio.

2. Follow the instructions in the main script DemonstrateRLS.sql.

## Sample details

The sample adds a new table with sensitive data about suppliers. This sensitive data is always encrypted.

As part of the sample you create an encryption key that is saved locally (where you run SSMS). The client application inserts data into the table. With the sample scripts you will see how the data is encrypted in the table and cannot be viewed, even by a sysadmin, unless you have the encryption key.

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be used for production purposes.

<a name=related-links></a>

## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->
TBD

