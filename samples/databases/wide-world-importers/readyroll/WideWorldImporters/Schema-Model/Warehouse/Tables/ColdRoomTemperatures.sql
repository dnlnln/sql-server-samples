CREATE TABLE [Warehouse].[ColdRoomTemperatures]
(
[ColdRoomTemperatureID] [bigint] NOT NULL IDENTITY(1, 1),
[ColdRoomSensorNumber] [int] NOT NULL,
[RecordedWhen] [datetime2] NOT NULL,
[Temperature] [decimal] (10, 2) NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL,
CONSTRAINT [PK_Warehouse_ColdRoomTemperatures] PRIMARY KEY NONCLUSTERED  ([ColdRoomTemperatureID]),
INDEX [IX_Warehouse_ColdRoomTemperatures_ColdRoomSensorNumber] NONCLUSTERED ([ColdRoomSensorNumber])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
