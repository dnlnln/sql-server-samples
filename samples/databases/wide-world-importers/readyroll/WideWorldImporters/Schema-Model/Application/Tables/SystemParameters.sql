CREATE TABLE [Application].[SystemParameters]
(
[SystemParameterID] [int] NOT NULL CONSTRAINT [DF_Application_SystemParameters_SystemParameterID] DEFAULT (NEXT VALUE FOR [Sequences].[SystemParameterID]),
[DeliveryAddressLine1] [nvarchar] (60) NOT NULL,
[DeliveryAddressLine2] [nvarchar] (60) NULL,
[DeliveryCityID] [int] NOT NULL,
[DeliveryPostalCode] [nvarchar] (10) NOT NULL,
[DeliveryLocation] [sys].[geography] NOT NULL,
[PostalAddressLine1] [nvarchar] (60) NOT NULL,
[PostalAddressLine2] [nvarchar] (60) NULL,
[PostalCityID] [int] NOT NULL,
[PostalPostalCode] [nvarchar] (10) NOT NULL,
[ApplicationSettings] [nvarchar] (max) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[LastEditedWhen] [datetime2] NOT NULL CONSTRAINT [DF_Application_SystemParameters_LastEditedWhen] DEFAULT (sysdatetime())
)
GO
ALTER TABLE [Application].[SystemParameters] ADD CONSTRAINT [PK_Application_SystemParameters] PRIMARY KEY CLUSTERED  ([SystemParameterID])
GO
CREATE NONCLUSTERED INDEX [FK_Application_SystemParameters_DeliveryCityID] ON [Application].[SystemParameters] ([DeliveryCityID])
GO
CREATE NONCLUSTERED INDEX [FK_Application_SystemParameters_PostalCityID] ON [Application].[SystemParameters] ([PostalCityID])
GO
ALTER TABLE [Application].[SystemParameters] ADD CONSTRAINT [FK_Application_SystemParameters_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
ALTER TABLE [Application].[SystemParameters] ADD CONSTRAINT [FK_Application_SystemParameters_DeliveryCityID_Application_Cities] FOREIGN KEY ([DeliveryCityID]) REFERENCES [Application].[Cities] ([CityID])
GO
ALTER TABLE [Application].[SystemParameters] ADD CONSTRAINT [FK_Application_SystemParameters_PostalCityID_Application_Cities] FOREIGN KEY ([PostalCityID]) REFERENCES [Application].[Cities] ([CityID])
GO
EXEC sp_addextendedproperty N'Description', N'Any configurable parameters for the whole system', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'JSON-structured application settings', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'ApplicationSettings'
GO
EXEC sp_addextendedproperty N'Description', 'First address line for the company', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'DeliveryAddressLine1'
GO
EXEC sp_addextendedproperty N'Description', 'Second address line for the company', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'DeliveryAddressLine2'
GO
EXEC sp_addextendedproperty N'Description', 'ID of the city for this address', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'DeliveryCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Geographic location for the company office', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'DeliveryLocation'
GO
EXEC sp_addextendedproperty N'Description', 'Postal code for the company', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'DeliveryPostalCode'
GO
EXEC sp_addextendedproperty N'Description', 'First postal address line for the company', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'PostalAddressLine1'
GO
EXEC sp_addextendedproperty N'Description', 'Second postaladdress line for the company', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'PostalAddressLine2'
GO
EXEC sp_addextendedproperty N'Description', 'ID of the city for this postaladdress', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'PostalCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Postal code for the company when sending via mail', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'PostalPostalCode'
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for row holding system parameters', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'COLUMN', N'SystemParameterID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'INDEX', N'FK_Application_SystemParameters_DeliveryCityID'
GO
EXEC sp_addextendedproperty N'Description', 'Auto-created to support a foreign key', 'SCHEMA', N'Application', 'TABLE', N'SystemParameters', 'INDEX', N'FK_Application_SystemParameters_PostalCityID'
GO
