CREATE TABLE [dbo].[MeterMeasurement] (
    [MeterID]          INT                                         NOT NULL,
    [MeasurementInkWh] DECIMAL (9, 4)                              NOT NULL,
    [PostalCode]       NVARCHAR (10)                               NOT NULL,
    [MeasurementDate]  DATETIME2 (7)                               NOT NULL,
    [SysStartTime]     DATETIME2 (7) GENERATED ALWAYS AS ROW START NOT NULL,
    [SysEndTime]       DATETIME2 (7) GENERATED ALWAYS AS ROW END   NOT NULL,
    PRIMARY KEY NONCLUSTERED ([MeterID] ASC),
    PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
)
WITH (MEMORY_OPTIMIZED = ON, SYSTEM_VERSIONING = ON (HISTORY_TABLE=[dbo].[MeterMeasurementHistory], DATA_CONSISTENCY_CHECK=ON));

