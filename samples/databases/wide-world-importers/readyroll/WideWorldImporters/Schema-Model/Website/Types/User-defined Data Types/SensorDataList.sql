CREATE TYPE [Website].[SensorDataList] AS TABLE
(
[SensorDataListID] [int] NOT NULL IDENTITY(1, 1),
[ColdRoomSensorNumber] [int] NULL,
[RecordedWhen] [datetime2] NULL,
[Temperature] [decimal] (18, 2) NULL,
PRIMARY KEY NONCLUSTERED  ([SensorDataListID])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
