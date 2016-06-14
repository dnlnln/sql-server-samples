# Construct WideWorldImporters OLTP Database

The scripts in this folder are used to construct the WideWorldImporters database from scratch on SQL Server or Azure SQL Database. It is possible to vary the data size (see step 6 in the instructions below).

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
2. SQL Server Management Studio, 2016 June release or later (version >= 13.0.15000.23)


<a name=run-this-sample></a>

## Run this sample

The below steps reconstruct the WideWorldImporters database. To construct the full version of the sample database (for Eval/Developer/Enterprise Edition and Azure SQL DB Premium), simply follow the steps below. To construct the standard edition version (for Standard Edition and Azure SQL DB Basic/Standard), omit step 7.

Note that each time the databases are reconstructed from empty, they will contain different data as a degree of randomization is used throughout the code. Once the database has been publicly shipped, it would be desirable for it to remain stable (at least with older data up to 31 Mar 2016) so that repeatable demos and courseware could be constructed using it.

<!-- Step by step instructions. Here's a few examples -->

1. Execute the script: **1-wwi-metadata-population.sql** -> this script creates the WWI_Preparation database that holds all required metadata to create the OLTP database.

2. Execute the script: **2-wwi-construct-database-from-metadata-tables.sql** -> this script performs code generation to create the script for the OLTP database.

3. Copy the output from the execution of the previous script to a new query window and execute it. (A copy of this has been saved as **3-wwi-recreate.sql**) (Note that two warnings will be generated about dependencies and this is normal. If the database already existed, you will also see warnings related to it being removed and existing transactions rolled back). 

4. Execute the script: **4-wwi-configure-required-database-objects.sql** -> this script creates additional objects that are required that are not part of the table and schema metadata. This predominantly involves additional types, views, and stored procedures. (You will see output about created roles and another about a dependency).

5. Execute the script **5-wwi-load-seed-data.sql**. This script populates the seed data required for the database. It will typically take a few minutes to execute.

6. Execute the script **6-wwi-data-simulation.sql**. This script runs data simulation to populate the transaction tables. It can take 20-30 minutes to execute.
<br/><br/>The statements in this script remove the temporal nature of the tables, and implements a series of triggers. They then emulate typical activities that would occur during each day. Finally, they remove the triggers and re-establishes the temporal tables. You can see the progress of the simulation in the Messages tab in SSMS as the query executes. (AreDatesPrinted controls whether dates are printed to the messages window as data is generated. IsSilentMode controls whether detailed output is printed. IsSilentMode = 1 produces just date output if AreDatesPrinted = 1.).
Note that a different outcome is produced each time it is run as it uses many random values.
StartDate and EndDate cover the period for generation. Other code populates the 2012 period when expanding the columnstore tables so do not populate back into 2012 or earlier with this procedure. The EndDate must also be at or before the current date as temporal tables do not allow future dates.
You can configure the amount of data produced by modifying the number of orders per day. The default is 60 orders and produces a reasonable OLTP database size of around 93MB compressed. You are also able to configure how busy Saturday and Sunday are compared to normal Monday to Friday working days, as a percentage. The suggested values are 50% for Saturday and 0% for Sunday.

7. Execute the script **7-wwi-enable-full-features.sql**. This script enables features not available in standard edition. Skip this step when creating the sample database targeting standard edition.

8. Execute the script **8-wwi-backup.sql**. This creates a backup of the database. Make sure to adjust the file path of the backup to match your folder structure. (A sample restore script **9-wwi-restore.sql** is also provided).

9. If required, remove the **WWI_Preparation** database.

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be used for production purposes.

<a name=related-links></a>

## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->
TBD
For more information, see these articles:
