CREATE TABLE [Application].[StateProvinces]
(
[StateProvinceID] [int] NOT NULL CONSTRAINT [DF_Application_StateProvinces_StateProvinceID] DEFAULT (NEXT VALUE FOR [Sequences].[StateProvinceID]),
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
ALTER TABLE [Application].[StateProvinces] ADD CONSTRAINT [PK_Application_StateProvinces] PRIMARY KEY CLUSTERED  ([StateProvinceID])
GO
CREATE NONCLUSTERED INDEX [FK_Application_StateProvinces_CountryID] ON [Application].[StateProvinces] ([CountryID])
GO
CREATE NONCLUSTERED INDEX [IX_Application_StateProvinces_SalesTerritory] ON [Application].[StateProvinces] ([SalesTerritory])
GO
ALTER TABLE [Application].[StateProvinces] ADD CONSTRAINT [UQ_Application_StateProvinces_StateProvinceName] UNIQUE NONCLUSTERED  ([StateProvinceName])
GO
ALTER TABLE [Application].[StateProvinces] ADD CONSTRAINT [FK_Application_StateProvinces_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Application].[StateProvinces] ADD CONSTRAINT [FK_Application_StateProvinces_CountryID_Application_Countries] FOREIGN KEY ([CountryID]) REFERENCES [Application].[Countries] ([CountryID])
GO
EXEC sp_addextendedproperty N'Description', N'States or provinces that contain cities (including geographic location)', 'SCHEMA', N'Application', 'TABLE', N'StateProvinces', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Geographic boundary of the state or province', 'SCHEMA', N'Application', 'TABLE', N'StateProvinces', 'COLUMN', N'Border'
GO
EXEC sp_addextendedproperty N'Description', 'Country for this StateProvince', 'SCHEMA', N'Application', 'TABLE', N'StateProvinces', 'COLUMN', N'CountryID'
GO
EXEC sp_addextendedproperty N'Description', 'Latest available population for the StateProvince', 'SCHEMA', N'Application', 'TABLE', N'StateProvinces', 'COLUMN', N'LatestRecordedPopulation'
GO
EXEC sp_addextendedproperty N'Description', 'Sales territory for this StateProvince', 'SCHEMA', N'Application', 'TABLE', N'StateProvinces', 'COLUMN', N'SalesTerritory'
GO
EXEC sp_addextendedproperty N'Description', 'Common code for this state or province (such as WA - Washington for the USA)', 'SCHEMA', N'Application', 'TABLE', N'StateProvinces', 'COLUMN', N'StateProvinceCode'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a state or province within the database', 'SCHEMA', N'Application', 'TABLE', N'StateProvinces', 'COLUMN', N'StateProvinceID'
GO
EXEC sp_addextendedproperty N'Description', 'Formal name of the state or province', 'SCHEMA', N'Application', 'TABLE', N'StateProvinces', 'COLUMN', N'StateProvinceName'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Application', 'TABLE', N'StateProvinces', 'INDEX', N'FK_Application_StateProvinces_CountryID'
GO
EXEC sp_addextendedproperty N'Description', 'Index used to quickly locate sales territories', 'SCHEMA', N'Application', 'TABLE', N'StateProvinces', 'INDEX', N'IX_Application_StateProvinces_SalesTerritory'
GO
