CREATE TYPE [dbo].[udtMeterMeasurement] AS TABLE (
    [RowID]            INT            NOT NULL,
    [MeterID]          INT            NOT NULL,
    [MeasurementInkWh] DECIMAL (9, 4) NOT NULL,
    [PostalCode]       NVARCHAR (10)  NOT NULL,
    [MeasurementDate]  DATETIME2 (7)  NOT NULL,
    INDEX [IX_RowID] NONCLUSTERED HASH ([RowID]) WITH (BUCKET_COUNT = 1024))
    WITH (MEMORY_OPTIMIZED = ON);

