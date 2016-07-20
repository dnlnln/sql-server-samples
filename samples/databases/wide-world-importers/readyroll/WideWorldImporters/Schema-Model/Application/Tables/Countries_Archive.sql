CREATE TABLE [Application].[Countries_Archive]
(
[CountryID] [int] NOT NULL,
[CountryName] [nvarchar] (60) NOT NULL,
[FormalName] [nvarchar] (60) NOT NULL,
[IsoAlpha3Code] [nvarchar] (3) NULL,
[IsoNumericCode] [int] NULL,
[CountryType] [nvarchar] (20) NULL,
[LatestRecordedPopulation] [bigint] NULL,
[Continent] [nvarchar] (30) NOT NULL,
[Region] [nvarchar] (30) NOT NULL,
[Subregion] [nvarchar] (30) NOT NULL,
[Border] [sys].[geography] NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_Countries_Archive] ON [Application].[Countries_Archive] ([ValidTo], [ValidFrom])
GO
