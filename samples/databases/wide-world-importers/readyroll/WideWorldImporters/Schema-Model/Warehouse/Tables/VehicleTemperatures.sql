CREATE TABLE [Warehouse].[VehicleTemperatures]
(
[VehicleTemperatureID] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleRegistration] [nvarchar] (20) NOT NULL,
[ChillerSensorNumber] [int] NOT NULL,
[RecordedWhen] [datetime2] NOT NULL,
[Temperature] [decimal] (10, 2) NOT NULL,
[IsCompressed] [bit] NOT NULL,
[FullSensorData] [nvarchar] (1000) NULL,
[CompressedSensorData] [varbinary] (max) NULL
)
GO
ALTER TABLE [Warehouse].[VehicleTemperatures] ADD CONSTRAINT [PK_Warehouse_VehicleTemperatures] PRIMARY KEY CLUSTERED  ([VehicleTemperatureID])
GO
EXEC sp_addextendedproperty N'Description', N'Regularly recorded temperatures of vehicle chillers', 'SCHEMA', N'Warehouse', 'TABLE', N'VehicleTemperatures', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Cold room sensor number', 'SCHEMA', N'Warehouse', 'TABLE', N'VehicleTemperatures', 'COLUMN', N'ChillerSensorNumber'
GO
EXEC sp_addextendedproperty N'Description', 'Compressed JSON data for archival purposes', 'SCHEMA', N'Warehouse', 'TABLE', N'VehicleTemperatures', 'COLUMN', N'CompressedSensorData'
GO
EXEC sp_addextendedproperty N'Description', 'Full JSON data received from sensor', 'SCHEMA', N'Warehouse', 'TABLE', N'VehicleTemperatures', 'COLUMN', N'FullSensorData'
GO
EXEC sp_addextendedproperty N'Description', 'Is the sensor data compressed for archival storage?', 'SCHEMA', N'Warehouse', 'TABLE', N'VehicleTemperatures', 'COLUMN', N'IsCompressed'
GO
EXEC sp_addextendedproperty N'Description', 'Time when this temperature recording was taken', 'SCHEMA', N'Warehouse', 'TABLE', N'VehicleTemperatures', 'COLUMN', N'RecordedWhen'
GO
EXEC sp_addextendedproperty N'Description', 'Temperature at the time of recording', 'SCHEMA', N'Warehouse', 'TABLE', N'VehicleTemperatures', 'COLUMN', N'Temperature'
GO
EXEC sp_addextendedproperty N'Description', 'Vehicle registration number', 'SCHEMA', N'Warehouse', 'TABLE', N'VehicleTemperatures', 'COLUMN', N'VehicleRegistration'
GO
EXEC sp_addextendedproperty N'Description', 'Instantaneous temperature readings for vehicle freezers and chillers', 'SCHEMA', N'Warehouse', 'TABLE', N'VehicleTemperatures', 'COLUMN', N'VehicleTemperatureID'
GO
