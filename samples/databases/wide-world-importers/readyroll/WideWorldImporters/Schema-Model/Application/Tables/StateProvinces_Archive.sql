CREATE TABLE [Application].[StateProvinces_Archive]
(
[StateProvinceID] [int] NOT NULL,
[StateProvinceCode] [nvarchar] (5) NOT NULL,
[StateProvinceName] [nvarchar] (50) NOT NULL,
[CountryID] [int] NOT NULL,
[SalesTerritory] [nvarchar] (50) NOT NULL,
[Border] [sys].[geography] NULL,
[LatestRecordedPopulation] [bigint] NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_StateProvinces_Archive] ON [Application].[StateProvinces_Archive] ([ValidTo], [ValidFrom])
GO
