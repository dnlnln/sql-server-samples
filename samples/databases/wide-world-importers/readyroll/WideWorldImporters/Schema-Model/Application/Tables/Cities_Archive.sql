CREATE TABLE [Application].[Cities_Archive]
(
[CityID] [int] NOT NULL,
[CityName] [nvarchar] (50) NOT NULL,
[StateProvinceID] [int] NOT NULL,
[Location] [sys].[geography] NULL,
[LatestRecordedPopulation] [bigint] NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_Cities_Archive] ON [Application].[Cities_Archive] ([ValidTo], [ValidFrom])
GO
