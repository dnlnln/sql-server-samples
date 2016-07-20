CREATE TABLE [Application].[Cities]
(
[CityID] [int] NOT NULL CONSTRAINT [DF_Application_Cities_CityID] DEFAULT (NEXT VALUE FOR [Sequences].[CityID]),
[CityName] [nvarchar] (50) NOT NULL,
[StateProvinceID] [int] NOT NULL,
[Location] [sys].[geography] NULL,
[LatestRecordedPopulation] [bigint] NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Application].[Cities] ADD CONSTRAINT [PK_Application_Cities] PRIMARY KEY CLUSTERED  ([CityID])
GO
CREATE NONCLUSTERED INDEX [FK_Application_Cities_StateProvinceID] ON [Application].[Cities] ([StateProvinceID])
GO
ALTER TABLE [Application].[Cities] ADD CONSTRAINT [FK_Application_Cities_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Application].[Cities] ADD CONSTRAINT [FK_Application_Cities_StateProvinceID_Application_StateProvinces] FOREIGN KEY ([StateProvinceID]) REFERENCES [Application].[StateProvinces] ([StateProvinceID])
GO
EXEC sp_addextendedproperty N'Description', N'Cities that are part of any address (including geographic location)', 'SCHEMA', N'Application', 'TABLE', N'Cities', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a city within the database', 'SCHEMA', N'Application', 'TABLE', N'Cities', 'COLUMN', N'CityID'
GO
EXEC sp_addextendedproperty N'Description', 'Formal name of the city', 'SCHEMA', N'Application', 'TABLE', N'Cities', 'COLUMN', N'CityName'
GO
EXEC sp_addextendedproperty N'Description', 'Latest available population for the City', 'SCHEMA', N'Application', 'TABLE', N'Cities', 'COLUMN', N'LatestRecordedPopulation'
GO
EXEC sp_addextendedproperty N'Description', 'Geographic location of the city', 'SCHEMA', N'Application', 'TABLE', N'Cities', 'COLUMN', N'Location'
GO
EXEC sp_addextendedproperty N'Description', 'State or province for this city', 'SCHEMA', N'Application', 'TABLE', N'Cities', 'COLUMN', N'StateProvinceID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Application', 'TABLE', N'Cities', 'INDEX', N'FK_Application_Cities_StateProvinceID'
GO
