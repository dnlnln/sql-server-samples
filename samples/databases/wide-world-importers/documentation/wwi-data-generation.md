# WideWorldImporters Data Generation

The released versions of the WideWorldImporters and WideWorldImportersDW databases contains data starting January 1st 2013, up to the day these databases were generated.

If the sample databases are used at a later date, for demonstration or illustration purposes, it may be beneficial to include more recent sample data in the database.

## Data Generation in WideWorldImporters

To generate sample data up to the current date, follow these steps:

1. If you have not yet done so, install a clean version of the WideWorldImporters database. For installation instructions, [WideWorldImporters Installation and Configuration](wwi-oltp-htap-installation.md).
2. Execute the following statement in the database:

    EXEC WideWorldImporters.DataLoadSimulation.PopulateDataToCurrentDate
        @AverageNumberOfCustomerOrdersPerDay = 60,
        @SaturdayPercentageOfNormalWorkDay = 50,
        @SundayPercentageOfNormalWorkDay = 0,
        @IsSilentMode = 1,
        @AreDatesPrinted = 1;

This statement adds sample sales and purchase data in the database, up to the current date. It outputs the progress of the data generation day-by-day. It will take rougly 10 minutes for every year that needs data. Note that there are some differences in the data generated between runs, since there is a random factor in the data generation.

To increase or decrease the amount of data generated, in terms of orders per day, change the value for the parameter `@AverageNumberOfCustomerOrdersPerDay`. The parameters `@SaturdayPercentageOfNormalWorkDay` and `@SundayPercentageOfNormalWorkDay` are used to determine the order volume for weekend days.

## Importing Data in WideWorldImportersDW

To import sample data up to the current date in the OLAP database WideWorldImportersDW, follow these steps:

1. Execute the data generation logic in the WideWorldImporters OLTP database, using the steps above.
2. If you have not yet done so, install a clean version of the WideWorldImportersDW database. For installation instructions, [WideWorldImporters Installation and Configuration](wwi-olap-installation.md).
3. Reseed the OLAP database by executing the following statement in the database:

    EXECUTE [Application].Configuration_ReseedETL

4. Run the SSIS package **Daily ETL.ispac** to import the data into the OLAP database. For instructions on how to run the ETL job, see [WideWorldImporters ETL Workflow](wwi-etl.md).
