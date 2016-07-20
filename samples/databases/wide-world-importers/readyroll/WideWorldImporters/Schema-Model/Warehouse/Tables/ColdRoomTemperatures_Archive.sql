CREATE TABLE [Warehouse].[ColdRoomTemperatures_Archive]
(
[ColdRoomTemperatureID] [bigint] NOT NULL,
[ColdRoomSensorNumber] [int] NOT NULL,
[RecordedWhen] [datetime2] NOT NULL,
[Temperature] [decimal] (10, 2) NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_ColdRoomTemperatures_Archive] ON [Warehouse].[ColdRoomTemperatures_Archive] ([ValidTo], [ValidFrom])
GO
