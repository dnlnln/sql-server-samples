# ETL Process for WideWorldImporters

This SSIS project performs ETL from the transactional database WideWorldImporters into the OLAP database WideWorldImportersDW for long-term storage and analytics.

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
1. **Applies to:** SQL Server 2016 (or higher)
1. **Key features:** Core database features
1. **Workload:** ETL
1. **Programming Language:**
1. **Authors:** Greg Low, Jos de Bruijn
1. **Update history:** 25 May 2016 - initial revision

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

<!-- Examples -->
1. SQL Server 2016 (or higher). 
2. SQL Server 2016 Integration Services.
3. Visual Studio 2015.

<a name=run-this-sample></a>

## Running the sample

## Sample details

The ETL package WWI_Integration is used to migrate data from the WideWorldImporters database to the WideWorldImportersDW database as the data changes. The package is run periodically (most commonly daily).
The design of the package uses SSIS to orchestrate bulk T-SQL operations (rather than as separate transformations within SSIS) to ensure high performance.
Dimensions are loaded first, followed by Fact tables. The package can be re-run at any time after a failure.
The workflow is as follows:



It starts with an expression task that works out the appropriate cutoff time. This time is the current time less a few seconds. (This is more robust than requesting data right to the current time). It then truncates any milliseconds from the time. 
The main processing starts by populating the Date dimension table. It ensures that all dates for the current year have been populated in the table.
After this, a series of data flow tasks loads each dimension, then each fact.



<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be used for production purposes.

<a name=related-links></a>

## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->
TBD
For more information, see these articles:
