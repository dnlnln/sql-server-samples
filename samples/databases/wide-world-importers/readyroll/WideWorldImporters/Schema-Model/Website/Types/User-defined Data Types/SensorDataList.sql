CREATE TYPE [Website].[SensorDataList] AS TABLE
(
[SensorDataListID] [int] NOT NULL IDENTITY(1, 1),
[ColdRoomSensorNumber] [int] NOT NULL,
[RecordedWhen] [datetime2] NOT NULL,
[Temperature] [decimal] (18, 2) NOT NULL,
PRIMARY KEY CLUSTERED  ([SensorDataListID])
)
GO
