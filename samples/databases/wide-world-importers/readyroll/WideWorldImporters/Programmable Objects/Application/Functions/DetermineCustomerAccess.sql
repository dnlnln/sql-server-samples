DROP SECURITY POLICY IF EXISTS [Application].FilterCustomersBySalesTerritoryRole;

IF OBJECT_ID('[Application].[DetermineCustomerAccess]') IS NOT NULL
	DROP FUNCTION [Application].[DetermineCustomerAccess];

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [Application].[DetermineCustomerAccess](@CityID int)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN (SELECT 1 AS AccessResult
        WHERE IS_ROLEMEMBER(N'db_owner') <> 0
        OR IS_ROLEMEMBER((SELECT sp.SalesTerritory
                          FROM [Application].Cities AS c
                          INNER JOIN [Application].StateProvinces AS sp
                          ON c.StateProvinceID = sp.StateProvinceID
                          WHERE c.CityID = @CityID) + N' Sales') <> 0
	    OR (ORIGINAL_LOGIN() = N'Website'
		    AND EXISTS (SELECT 1
		                FROM [Application].Cities AS c
				        INNER JOIN [Application].StateProvinces AS sp
				        ON c.StateProvinceID = sp.StateProvinceID
				        WHERE c.CityID = @CityID
				        AND sp.SalesTerritory = SESSION_CONTEXT(N'SalesTerritory'))));
GO

CREATE SECURITY POLICY [Application].FilterCustomersBySalesTerritoryRole
ADD FILTER PREDICATE [Application].DetermineCustomerAccess(DeliveryCityID)
ON Sales.Customers,
ADD BLOCK PREDICATE [Application].DetermineCustomerAccess(DeliveryCityID)
ON Sales.Customers AFTER UPDATE;
GO
