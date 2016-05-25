CREATE TABLE [dbo].[MeterMeasurementHistory] (
    [MeterID]          INT            NOT NULL,
    [MeasurementInkWh] DECIMAL (9, 4) NOT NULL,
    [PostalCode]       NVARCHAR (10)  NOT NULL,
    [MeasurementDate]  DATETIME2 (7)  NOT NULL,
    [SysStartTime]     DATETIME2 (7)  NOT NULL,
    [SysEndTime]       DATETIME2 (7)  NOT NULL
);


GO
CREATE CLUSTERED COLUMNSTORE INDEX [ix_MeterMeasurementHistory]
    ON [dbo].[MeterMeasurementHistory];

