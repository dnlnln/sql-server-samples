# Workload Driver for Vehicle Location Insertion in WideWorldImporters

This application simulates an insertion workload for vehicle location in the WideWorldImporters sample database.

The main purpose is to compare the performance of data insertion into traditional disk-based tables compared with memory-optimized tables. For a more comprehensive sample demonstrating the performance of In-Memory OLTP see the [in-memory/ticket-reservations](/samples/features/in-memory/ticket-reservations) sample.

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
1. **Key features:** Core database features
1. **Workload:** OLTP
1. **Programming Language:** C#
1. **Authors:** Greg Low, Jos de Bruijn
1. **Update history:** 25 May 2016 - initial revision

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

<!-- Examples -->
1. SQL Server 2016 (or higher) or Azure SQL Database. 
2. Visual Studio 2015.
3. The WideWorldImporters database.

<a name=run-this-sample></a>

## Running the sample

1. Open the solution file MultithreadedInMemoryTableInsert.sln in Visual Studio.

2. Build the solution.

3. Run the app.

## Sample details

The driver simulates an insert workload for vehicle location obtained from sensors in the vehicles of Wide World Importers. You can use it to constrast the performance of disk-based with memory-optimized tables on your system.

TBD: more guidelines on perf 


<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be used for production purposes.

<a name=related-links></a>

## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->
TBD

