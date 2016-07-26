CREATE TABLE [Warehouse].[ColdRoomTemperatures]
(
[ColdRoomTemperatureID] [bigint] NOT NULL IDENTITY(1, 1),
[ColdRoomSensorNumber] [int] NOT NULL,
[RecordedWhen] [datetime2] NOT NULL,
[Temperature] [decimal] (10, 2) NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Warehouse].[ColdRoomTemperatures] ADD CONSTRAINT [PK_Warehouse_ColdRoomTemperatures] PRIMARY KEY CLUSTERED  ([ColdRoomTemperatureID])
GO
CREATE NONCLUSTERED INDEX [IX_Warehouse_ColdRoomTemperatures_ColdRoomSensorNumber] ON [Warehouse].[ColdRoomTemperatures] ([ColdRoomSensorNumber])
GO
EXEC sp_addextendedproperty N'Description', N'Regularly recorded temperatures of cold room chillers', 'SCHEMA', N'Warehouse', 'TABLE', N'ColdRoomTemperatures', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Cold room sensor number', 'SCHEMA', N'Warehouse', 'TABLE', N'ColdRoomTemperatures', 'COLUMN', N'ColdRoomSensorNumber'
GO
EXEC sp_addextendedproperty N'Description', 'Instantaneous temperature readings for cold rooms (chillers)', 'SCHEMA', N'Warehouse', 'TABLE', N'ColdRoomTemperatures', 'COLUMN', N'ColdRoomTemperatureID'
GO
EXEC sp_addextendedproperty N'Description', 'Time when this temperature recording was taken', 'SCHEMA', N'Warehouse', 'TABLE', N'ColdRoomTemperatures', 'COLUMN', N'RecordedWhen'
GO
EXEC sp_addextendedproperty N'Description', 'Temperature at the time of recording', 'SCHEMA', N'Warehouse', 'TABLE', N'ColdRoomTemperatures', 'COLUMN', N'Temperature'
GO
EXEC sp_addextendedproperty N'Description', 'Allows quickly locating sensors', 'SCHEMA', N'Warehouse', 'TABLE', N'ColdRoomTemperatures', 'INDEX', N'IX_Warehouse_ColdRoomTemperatures_ColdRoomSensorNumber'
GO
