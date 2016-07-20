IF OBJECT_ID('[Application].[Configuration_ConfigureForEnterpriseEdition]') IS NOT NULL
	DROP PROCEDURE [Application].[Configuration_ConfigureForEnterpriseEdition];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Application].[Configuration_ConfigureForEnterpriseEdition]
AS
BEGIN

    EXEC [Application].[Configuration_ApplyColumnstoreIndexing];

    EXEC [Application].[Configuration_ApplyFullTextIndexing];

    EXEC [Application].[Configuration_EnableInMemory];

    EXEC [Application].[Configuration_ApplyPartitioning];

END;
GO
