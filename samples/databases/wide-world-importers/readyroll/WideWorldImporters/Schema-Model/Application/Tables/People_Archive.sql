CREATE TABLE [Application].[People_Archive]
(
[PersonID] [int] NOT NULL,
[FullName] [nvarchar] (50) NOT NULL,
[PreferredName] [nvarchar] (50) NOT NULL,
[SearchName] [nvarchar] (101) NOT NULL,
[IsPermittedToLogon] [bit] NOT NULL,
[LogonName] [nvarchar] (50) NULL,
[IsExternalLogonProvider] [bit] NOT NULL,
[HashedPassword] [varbinary] (max) NULL,
[IsSystemUser] [bit] NOT NULL,
[IsEmployee] [bit] NOT NULL,
[IsSalesperson] [bit] NOT NULL,
[UserPreferences] [nvarchar] (max) NULL,
[PhoneNumber] [nvarchar] (20) NULL,
[FaxNumber] [nvarchar] (20) NULL,
[EmailAddress] [nvarchar] (256) NULL,
[Photo] [varbinary] (max) NULL,
[CustomFields] [nvarchar] (max) NULL,
[OtherLanguages] [nvarchar] (max) NULL,
[LastEditedBy] [int] NOT NULL,
[ValidFrom] [datetime2] NOT NULL,
[ValidTo] [datetime2] NOT NULL
)
GO
CREATE CLUSTERED INDEX [ix_People_Archive] ON [Application].[People_Archive] ([ValidTo], [ValidFrom])
GO
