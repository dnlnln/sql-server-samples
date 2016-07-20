CREATE TABLE [Application].[DeliveryMethods]
(
[DeliveryMethodID] [int] NOT NULL CONSTRAINT [DF_Application_DeliveryMethods_DeliveryMethodID] DEFAULT (NEXT VALUE FOR [Sequences].[DeliveryMethodID]),
[DeliveryMethodName] [nvarchar] (50) NOT NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
ALTER TABLE [Application].[DeliveryMethods] ADD CONSTRAINT [PK_Application_DeliveryMethods] PRIMARY KEY CLUSTERED  ([DeliveryMethodID])
GO
ALTER TABLE [Application].[DeliveryMethods] ADD CONSTRAINT [UQ_Application_DeliveryMethods_DeliveryMethodName] UNIQUE NONCLUSTERED  ([DeliveryMethodName])
GO
ALTER TABLE [Application].[DeliveryMethods] ADD CONSTRAINT [FK_Application_DeliveryMethods_Application_People] FOREIGN KEY ([LastEditedBy]) REFERENCES [Application].[People] ([PersonID])
GO
EXEC sp_addextendedproperty N'Description', N'Ways that stock items can be delivered (ie: truck/van, post, pickup, courier, etc.', 'SCHEMA', N'Application', 'TABLE', N'DeliveryMethods', NULL, NULL
GO
EXEC sp_addextendedproperty N'Description', 'Numeric ID used for reference to a delivery method within the database', 'SCHEMA', N'Application', 'TABLE', N'DeliveryMethods', 'COLUMN', N'DeliveryMethodID'
GO
EXEC sp_addextendedproperty N'Description', 'Full name of methods that can be used for delivery of customer orders', 'SCHEMA', N'Application', 'TABLE', N'DeliveryMethods', 'COLUMN', N'DeliveryMethodName'
GO
