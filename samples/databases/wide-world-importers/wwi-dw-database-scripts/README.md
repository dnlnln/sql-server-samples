# Construct WideWorldImporters OLAP Database

The scripts in this folder are used to construct the WideWorldImportersDW database from scratch on SQL Server or Azure SQL Database.

A pre-created version of the database is available for download as part of the latest release of the sample: [wide-world-importers-release](http://go.microsoft.com/fwlink/?LinkID=800630).

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Run this sample](#run-this-sample)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>


<a name=about-this-sample></a>

## About this sample

<!-- Delete the ones that don't apply -->
1. **Applies to:** SQL Server 2016 (or higher), Azure SQL Database [testing and modified instructions are TBD]
1. **Key features:** Core database features
1. **Workload:** OLTP
1. **Programming Language:** T-SQL
1. **Authors:** Greg Low, Denzil Ribeiro, Jos de Bruijn
1. **Update history:** 25 May 2016 - initial revision

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

<!-- Examples -->
1. SQL Server 2016 (or higher) or an Azure SQL Database. 
2. SQL Server Management Studio, preferably June 2016 release or later (version >= 13.0.15000.23)


<a name=run-this-sample></a>

## Run this sample

The below steps reconstruct the WideWorldImportersDW database. To construct the full version of the sample database (for Eval/Developer/Enterprise Edition and Azure SQL DB Premium), simply follow the steps below. To construct the standard edition version (for Standard Edition and Azure SQL DB Basic/Standard), omit step 6.

<!-- Step by step instructions. Here's a few examples -->

1. Execute the script: **1-wwi-dw-metadata-population.sql** -> this script creates the WWI_DW_Preparation database that holds all required metadata to create the OLAP database.

2. Execute the script: **2-wwi-dw-construct-database-from-metadata-tables.sql** -> this script performs code generation to create the script for the OLAP database.

3. Copy the output from the execution of the previous script to a new query window and execute it. (A copy of this has been saved as 3-**wwi-dw-recreate.sql**) (If the database already existed, you will also see warnings related to it being removed and existing transactions rolled back).

4. Execute the script: **4-wwi-dw-configured-required-database-objects.sql** -> this script creates additional objects that are required that are not part of the table and schema metadata. This predominantly involves additional types, views, and stored procedures.

5. Execute the script **5-wwi-dw-load-seed-data.sql**. This script populates the seed data required for the database. It will typically take a few minutes to execute.

6. Execute the script **6-wwi-dw-enable-full-features.sql**. This script enables features not available in standard edition. Skip this step when creating the sample database targeting standard edition.

7. Execute the **WWI_Integration** SSIS package to perform the ETL to populate the database. For details see [wwi-integration-etl] (../wwi-integration-etl/).

8. Execute the script **8-wwi-dw-backup.sql**. This creates a backup of the database. Make sure to adjust the file path of the backup to match your folder structure. (A sample restore script **9-wwi-restore.sql** is also provided).

9. If required, remove the **WWI_DW_Preparation** database.

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be used for production purposes.

<a name=related-links></a>

## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->
TBD
For more information, see these articles:
