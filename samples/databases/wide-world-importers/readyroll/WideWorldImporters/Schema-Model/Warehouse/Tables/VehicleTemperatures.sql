CREATE TABLE [Warehouse].[VehicleTemperatures]
(
[VehicleTemperatureID] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleRegistration] [nvarchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[ChillerSensorNumber] [int] NOT NULL,
[RecordedWhen] [datetime2] NOT NULL,
[Temperature] [decimal] (10, 2) NOT NULL,
[FullSensorData] [nvarchar] (1000) COLLATE Latin1_General_CI_AS NULL,
[IsCompressed] [bit] NOT NULL,
[CompressedSensorData] [varbinary] (max) NULL,
CONSTRAINT [PK_Warehouse_VehicleTemperatures] PRIMARY KEY NONCLUSTERED  ([VehicleTemperatureID])
)
WITH
(
MEMORY_OPTIMIZED = ON
)
GO
