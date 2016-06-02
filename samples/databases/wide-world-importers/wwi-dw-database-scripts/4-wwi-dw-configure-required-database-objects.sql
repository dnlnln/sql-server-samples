-- WWI_DW - Create database objects

USE WideWorldImportersDW;
GO

DROP FUNCTION IF EXISTS Integration.GenerateDateDimensionColumns;
GO

CREATE FUNCTION Integration.GenerateDateDimensionColumns(@Date date)
RETURNS TABLE
AS
RETURN SELECT @Date AS [Date],
              DAY(@Date) AS [Day Number],
              CAST(DATENAME(day, @Date) AS nvarchar(10)) AS [Day],
              CAST(DATENAME(month, @Date) AS nvarchar(10)) AS [Month],
              CAST(SUBSTRING(DATENAME(month, @Date), 1, 3) AS nvarchar(3)) AS [Short Month],
              MONTH(@Date) AS [Calendar Month Number],
              CAST(N'CY' + CAST(YEAR(@Date) AS nvarchar(4)) + N'-' + SUBSTRING(DATENAME(month, @Date), 1, 3) AS nvarchar(10)) AS [Calendar Month Label],
              YEAR(@Date) AS [Calendar Year],
              CAST(N'CY' + CAST(YEAR(@Date) AS nvarchar(4)) AS nvarchar(10)) AS [Calendar Year Label],
              CASE WHEN MONTH(@Date) IN (11, 12)
                   THEN MONTH(@Date) - 10
                   ELSE MONTH(@Date) + 2
              END AS [Fiscal Month Number],
              CAST(N'FY' + CAST(CASE WHEN MONTH(@Date) IN (11, 12)
                                     THEN YEAR(@Date) + 1
                                     ELSE YEAR(@Date)
                                END AS nvarchar(4)) + N'-' + SUBSTRING(DATENAME(month, @Date), 1, 3) AS nvarchar(20)) AS [Fiscal Month Label],
              CASE WHEN MONTH(@Date) IN (11, 12)
                   THEN YEAR(@Date) + 1
                   ELSE YEAR(@Date)
              END AS [Fiscal Year],
              CAST(N'FY' + CAST(CASE WHEN MONTH(@Date) IN (11, 12)
                                     THEN YEAR(@Date) + 1
                                     ELSE YEAR(@Date)
                                END AS nvarchar(4)) AS nvarchar(10)) AS [Fiscal Year Label],
              DATEPART(ISO_WEEK, @Date) AS [ISO Week Number];
GO

DROP PROCEDURE IF EXISTS Integration.PopulateDateDimensionForYear;
GO

CREATE PROCEDURE Integration.PopulateDateDimensionForYear
@YearNumber int
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @DateCounter date = DATEFROMPARTS(@YearNumber, 1, 1);

    BEGIN TRY;

        BEGIN TRAN;

        WHILE YEAR(@DateCounter) = @YearNumber
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Dimension.[Date] WHERE [Date] = @DateCounter)
            BEGIN
                INSERT Dimension.[Date]
                    ([Date], [Day Number], [Day], [Month], [Short Month],
                     [Calendar Month Number], [Calendar Month Label], [Calendar Year], [Calendar Year Label],
                     [Fiscal Month Number], [Fiscal Month Label], [Fiscal Year], [Fiscal Year Label],
                     [ISO Week Number])
                SELECT [Date], [Day Number], [Day], [Month], [Short Month],
                       [Calendar Month Number], [Calendar Month Label], [Calendar Year], [Calendar Year Label],
                       [Fiscal Month Number], [Fiscal Month Label], [Fiscal Year], [Fiscal Year Label],
                       [ISO Week Number]
                FROM Integration.GenerateDateDimensionColumns(@DateCounter);
            END;
            SET @DateCounter = DATEADD(day, 1, @DateCounter);
        END;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        PRINT N'Unable to populate dates for the year';
        THROW;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.GetLastETLCutoffTime;
GO

CREATE PROCEDURE Integration.GetLastETLCutoffTime
@TableName sysname
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SELECT [Cutoff Time] AS CutoffTime
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = @TableName;

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT N'Invalid ETL table name';
        THROW 51000, N'Invalid ETL table name', 1;
        RETURN -1;
    END;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.GetLineageKey;
GO

CREATE PROCEDURE Integration.GetLineageKey
@TableName sysname,
@NewCutoffTime datetime2(7)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @DataLoadStartedWhen datetime2(7) = SYSDATETIME();

    INSERT Integration.Lineage
        ([Data Load Started], [Table Name], [Data Load Completed],
         [Was Successful], [Source System Cutoff Time])
    VALUES
        (@DataLoadStartedWhen, @TableName, NULL,
         0, @NewCutoffTime);

    SELECT TOP(1) [Lineage Key] AS LineageKey
    FROM Integration.Lineage
    WHERE [Table Name] = @TableName
    AND [Data Load Started] = @DataLoadStartedWhen
    ORDER BY LineageKey DESC;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedCityData;
GO

CREATE PROCEDURE Integration.MigrateStagedCityData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'City'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    WITH RowsToCloseOff
    AS
    (
        SELECT c.[WWI City ID], MIN(c.[Valid From]) AS [Valid From]
        FROM Integration.City_Staging AS c
        GROUP BY c.[WWI City ID]
    )
    UPDATE c
        SET c.[Valid To] = rtco.[Valid From]
    FROM Dimension.City AS c
    INNER JOIN RowsToCloseOff AS rtco
    ON c.[WWI City ID] = rtco.[WWI City ID]
    WHERE c.[Valid To] = @EndOfTime;

    INSERT Dimension.City
        ([WWI City ID], City, [State Province], Country, Continent,
         [Sales Territory], Region, Subregion, [Location],
         [Latest Recorded Population], [Valid From], [Valid To],
         [Lineage Key])
    SELECT [WWI City ID], City, [State Province], Country, Continent,
           [Sales Territory], Region, Subregion, [Location],
           [Latest Recorded Population], [Valid From], [Valid To],
           @LineageKey
    FROM Integration.City_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'City';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedCustomerData;
GO

CREATE PROCEDURE Integration.MigrateStagedCustomerData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Customer'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    WITH RowsToCloseOff
    AS
    (
        SELECT c.[WWI Customer ID], MIN(c.[Valid From]) AS [Valid From]
        FROM Integration.Customer_Staging AS c
        GROUP BY c.[WWI Customer ID]
    )
    UPDATE c
        SET c.[Valid To] = rtco.[Valid From]
    FROM Dimension.Customer AS c
    INNER JOIN RowsToCloseOff AS rtco
    ON c.[WWI Customer ID] = rtco.[WWI Customer ID]
    WHERE c.[Valid To] = @EndOfTime;

    INSERT Dimension.Customer
        ([WWI Customer ID], Customer, [Bill To Customer], Category,
         [Buying Group], [Primary Contact], [Postal Code], [Valid From], [Valid To],
         [Lineage Key])
    SELECT [WWI Customer ID], Customer, [Bill To Customer], Category,
           [Buying Group], [Primary Contact], [Postal Code], [Valid From], [Valid To],
           @LineageKey
    FROM Integration.Customer_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Customer';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedEmployeeData;
GO

CREATE PROCEDURE Integration.MigrateStagedEmployeeData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Employee'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    WITH RowsToCloseOff
    AS
    (
        SELECT e.[WWI Employee ID], MIN(e.[Valid From]) AS [Valid From]
        FROM Integration.Employee_Staging AS e
        GROUP BY e.[WWI Employee ID]
    )
    UPDATE e
        SET e.[Valid To] = rtco.[Valid From]
    FROM Dimension.Employee AS e
    INNER JOIN RowsToCloseOff AS rtco
    ON e.[WWI Employee ID] = rtco.[WWI Employee ID]
    WHERE e.[Valid To] = @EndOfTime;

    INSERT Dimension.Employee
        ([WWI Employee ID], Employee, [Preferred Name], [Is Salesperson], Photo, [Valid From], [Valid To], [Lineage Key])
    SELECT [WWI Employee ID], Employee, [Preferred Name], [Is Salesperson], Photo, [Valid From], [Valid To],
           @LineageKey
    FROM Integration.Employee_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Employee';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedPaymentMethodData;
GO

CREATE PROCEDURE Integration.MigrateStagedPaymentMethodData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Payment Method'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    WITH RowsToCloseOff
    AS
    (
        SELECT pm.[WWI Payment Method ID], MIN(pm.[Valid From]) AS [Valid From]
        FROM Integration.PaymentMethod_Staging AS pm
        GROUP BY pm.[WWI Payment Method ID]
    )
    UPDATE pm
        SET pm.[Valid To] = rtco.[Valid From]
    FROM Dimension.[Payment Method] AS pm
    INNER JOIN RowsToCloseOff AS rtco
    ON pm.[WWI Payment Method ID] = rtco.[WWI Payment Method ID]
    WHERE pm.[Valid To] = @EndOfTime;

    INSERT Dimension.[Payment Method]
        ([WWI Payment Method ID], [Payment Method], [Valid From], [Valid To], [Lineage Key])
    SELECT [WWI Payment Method ID], [Payment Method], [Valid From], [Valid To],
           @LineageKey
    FROM Integration.PaymentMethod_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Payment Method';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedStockItemData;
GO

CREATE PROCEDURE Integration.MigrateStagedStockItemData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Stock Item'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    WITH RowsToCloseOff
    AS
    (
        SELECT s.[WWI Stock Item ID], MIN(s.[Valid From]) AS [Valid From]
        FROM Integration.StockItem_Staging AS s
        GROUP BY s.[WWI Stock Item ID]
    )
    UPDATE s
        SET s.[Valid To] = rtco.[Valid From]
    FROM Dimension.[Stock Item] AS s
    INNER JOIN RowsToCloseOff AS rtco
    ON s.[WWI Stock Item ID] = rtco.[WWI Stock Item ID]
    WHERE s.[Valid To] = @EndOfTime;

    INSERT Dimension.[Stock Item]
        ([WWI Stock Item ID], [Stock Item], Color, [Selling Package], [Buying Package],
         Brand, Size, [Lead Time Days], [Quantity Per Outer], [Is Chiller Stock],
         Barcode, [Tax Rate], [Unit Price], [Recommended Retail Price], [Typical Weight Per Unit],
         Photo, [Valid From], [Valid To], [Lineage Key])
    SELECT [WWI Stock Item ID], [Stock Item], Color, [Selling Package], [Buying Package],
           Brand, Size, [Lead Time Days], [Quantity Per Outer], [Is Chiller Stock],
           Barcode, [Tax Rate], [Unit Price], [Recommended Retail Price], [Typical Weight Per Unit],
           Photo, [Valid From], [Valid To],
           @LineageKey
    FROM Integration.StockItem_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Stock Item';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedSupplierData;
GO

CREATE PROCEDURE Integration.MigrateStagedSupplierData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Supplier'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    WITH RowsToCloseOff
    AS
    (
        SELECT s.[WWI Supplier ID], MIN(s.[Valid From]) AS [Valid From]
        FROM Integration.Supplier_Staging AS s
        GROUP BY s.[WWI Supplier ID]
    )
    UPDATE s
        SET s.[Valid To] = rtco.[Valid From]
    FROM Dimension.[Supplier] AS s
    INNER JOIN RowsToCloseOff AS rtco
    ON s.[WWI Supplier ID] = rtco.[WWI Supplier ID]
    WHERE s.[Valid To] = @EndOfTime;

    INSERT Dimension.[Supplier]
        ([WWI Supplier ID], Supplier, Category, [Primary Contact], [Supplier Reference],
         [Payment Days], [Postal Code], [Valid From], [Valid To], [Lineage Key])
    SELECT [WWI Supplier ID], Supplier, Category, [Primary Contact], [Supplier Reference],
           [Payment Days], [Postal Code], [Valid From], [Valid To],
           @LineageKey
    FROM Integration.Supplier_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Supplier';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedTransactionTypeData;
GO

CREATE PROCEDURE Integration.MigrateStagedTransactionTypeData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Transaction Type'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    WITH RowsToCloseOff
    AS
    (
        SELECT pm.[WWI Transaction Type ID], MIN(pm.[Valid From]) AS [Valid From]
        FROM Integration.TransactionType_Staging AS pm
        GROUP BY pm.[WWI Transaction Type ID]
    )
    UPDATE pm
        SET pm.[Valid To] = rtco.[Valid From]
    FROM Dimension.[Transaction Type] AS pm
    INNER JOIN RowsToCloseOff AS rtco
    ON pm.[WWI Transaction Type ID] = rtco.[WWI Transaction Type ID]
    WHERE pm.[Valid To] = @EndOfTime;

    INSERT Dimension.[Transaction Type]
        ([WWI Transaction Type ID], [Transaction Type], [Valid From], [Valid To], [Lineage Key])
    SELECT [WWI Transaction Type ID], [Transaction Type], [Valid From], [Valid To],
           @LineageKey
    FROM Integration.TransactionType_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Transaction Type';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedMovementData;
GO

CREATE PROCEDURE Integration.MigrateStagedMovementData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Movement'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    -- Find the dimension keys required

    UPDATE m
        SET m.[Stock Item Key] = COALESCE((SELECT TOP(1) si.[Stock Item Key]
                                           FROM Dimension.[Stock Item] AS si
                                           WHERE si.[WWI Stock Item ID] = m.[WWI Stock Item ID]
                                           AND m.[Last Modifed When] > si.[Valid From]
                                           AND m.[Last Modifed When] <= si.[Valid To]), 0),
            m.[Customer Key] = COALESCE((SELECT TOP(1) c.[Customer Key]
                                         FROM Dimension.Customer AS c
                                         WHERE c.[WWI Customer ID] = m.[WWI Customer ID]
                                         AND m.[Last Modifed When] > c.[Valid From]
                                         AND m.[Last Modifed When] <= c.[Valid To]), 0),
            m.[Supplier Key] = COALESCE((SELECT TOP(1) s.[Supplier Key]
                                         FROM Dimension.Supplier AS s
                                         WHERE s.[WWI Supplier ID] = m.[WWI Supplier ID]
                                         AND m.[Last Modifed When] > s.[Valid From]
                                         AND m.[Last Modifed When] <= s.[Valid To]), 0),
            m.[Transaction Type Key] = COALESCE((SELECT TOP(1) tt.[Transaction Type Key]
                                                 FROM Dimension.[Transaction Type] AS tt
                                                 WHERE tt.[WWI Transaction Type ID] = m.[WWI Transaction Type ID]
                                                 AND m.[Last Modifed When] > tt.[Valid From]
                                                 AND m.[Last Modifed When] <= tt.[Valid To]), 0)
    FROM Integration.Movement_Staging AS m;

    -- Merge the data into the fact table

    MERGE Fact.Movement AS m
    USING Integration.Movement_Staging AS ms
    ON m.[WWI Stock Item Transaction ID] = ms.[WWI Stock Item Transaction ID]
    WHEN MATCHED THEN
        UPDATE SET m.[Date Key] = ms.[Date Key],
                   m.[Stock Item Key] = ms.[Stock Item Key],
                   m.[Customer Key] = ms.[Customer Key],
                   m.[Supplier Key] = ms.[Supplier Key],
                   m.[Transaction Type Key] = ms.[Transaction Type Key],
                   m.[WWI Invoice ID] = ms.[WWI Invoice ID],
                   m.[WWI Purchase Order ID] = ms.[WWI Purchase Order ID],
                   m.Quantity = ms.Quantity,
                   m.[Lineage Key] = @LineageKey
    WHEN NOT MATCHED THEN
        INSERT ([Date Key], [Stock Item Key], [Customer Key], [Supplier Key], [Transaction Type Key],
                [WWI Stock Item Transaction ID], [WWI Invoice ID], [WWI Purchase Order ID], Quantity, [Lineage Key])
        VALUES (ms.[Date Key], ms.[Stock Item Key], ms.[Customer Key], ms.[Supplier Key], ms.[Transaction Type Key],
                ms.[WWI Stock Item Transaction ID], ms.[WWI Invoice ID], ms.[WWI Purchase Order ID], ms.Quantity, @LineageKey);

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Movement';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedOrderData;
GO

CREATE PROCEDURE Integration.MigrateStagedOrderData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Order'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    -- Find the dimension keys required

    UPDATE o
        SET o.[City Key] = COALESCE((SELECT TOP(1) c.[City Key]
                                     FROM Dimension.City AS c
                                     WHERE c.[WWI City ID] = o.[WWI City ID]
                                     AND o.[Last Modified When] > c.[Valid From]
                                     AND o.[Last Modified When] <= c.[Valid To]), 0),
            o.[Customer Key] = COALESCE((SELECT TOP(1) c.[Customer Key]
                                         FROM Dimension.Customer AS c
                                         WHERE c.[WWI Customer ID] = o.[WWI Customer ID]
                                         AND o.[Last Modified When] > c.[Valid From]
                                         AND o.[Last Modified When] <= c.[Valid To]), 0),
            o.[Stock Item Key] = COALESCE((SELECT TOP(1) si.[Stock Item Key]
                                           FROM Dimension.[Stock Item] AS si
                                           WHERE si.[WWI Stock Item ID] = o.[WWI Stock Item ID]
                                           AND o.[Last Modified When] > si.[Valid From]
                                           AND o.[Last Modified When] <= si.[Valid To]), 0),
            o.[Salesperson Key] = COALESCE((SELECT TOP(1) e.[Employee Key]
                                         FROM Dimension.Employee AS e
                                         WHERE e.[WWI Employee ID] = o.[WWI Salesperson ID]
                                         AND o.[Last Modified When] > e.[Valid From]
                                         AND o.[Last Modified When] <= e.[Valid To]), 0),
            o.[Picker Key] = COALESCE((SELECT TOP(1) e.[Employee Key]
                                       FROM Dimension.Employee AS e
                                       WHERE e.[WWI Employee ID] = o.[WWI Picker ID]
                                       AND o.[Last Modified When] > e.[Valid From]
                                       AND o.[Last Modified When] <= e.[Valid To]), 0)
    FROM Integration.Order_Staging AS o;

    -- Remove any existing entries for any of these orders

    DELETE o
    FROM Fact.[Order] AS o
    WHERE o.[WWI Order ID] IN (SELECT [WWI Order ID] FROM Integration.Order_Staging);

    -- Insert all current details for these orders

    INSERT Fact.[Order]
        ([City Key], [Customer Key], [Stock Item Key], [Order Date Key], [Picked Date Key],
         [Salesperson Key], [Picker Key], [WWI Order ID], [WWI Backorder ID], [Description],
         Package, Quantity, [Unit Price], [Tax Rate], [Total Excluding Tax], [Tax Amount],
         [Total Including Tax], [Lineage Key])
    SELECT [City Key], [Customer Key], [Stock Item Key], [Order Date Key], [Picked Date Key],
           [Salesperson Key], [Picker Key], [WWI Order ID], [WWI Backorder ID], [Description],
           Package, Quantity, [Unit Price], [Tax Rate], [Total Excluding Tax], [Tax Amount],
           [Total Including Tax], @LineageKey
    FROM Integration.Order_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Order';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedPurchaseData;
GO

CREATE PROCEDURE Integration.MigrateStagedPurchaseData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Purchase'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    -- Find the dimension keys required

    UPDATE p
        SET p.[Supplier Key] = COALESCE((SELECT TOP(1) s.[Supplier Key]
                                     FROM Dimension.Supplier AS s
                                     WHERE s.[WWI Supplier ID] = p.[WWI Supplier ID]
                                     AND p.[Last Modified When] > s.[Valid From]
                                     AND p.[Last Modified When] <= s.[Valid To]), 0),
            p.[Stock Item Key] = COALESCE((SELECT TOP(1) si.[Stock Item Key]
                                           FROM Dimension.[Stock Item] AS si
                                           WHERE si.[WWI Stock Item ID] = p.[WWI Stock Item ID]
                                           AND p.[Last Modified When] > si.[Valid From]
                                           AND p.[Last Modified When] <= si.[Valid To]), 0)
    FROM Integration.Purchase_Staging AS p;

    -- Remove any existing entries for any of these purchase orders

    DELETE p
    FROM Fact.Purchase AS p
    WHERE p.[WWI Purchase Order ID] IN (SELECT [WWI Purchase Order ID] FROM Integration.Purchase_Staging);

    -- Insert all current details for these purchase orders

    INSERT Fact.Purchase
        ([Date Key], [Supplier Key], [Stock Item Key], [WWI Purchase Order ID], [Ordered Outers], [Ordered Quantity],
         [Received Outers], Package, [Is Order Finalized], [Lineage Key])
    SELECT [Date Key], [Supplier Key], [Stock Item Key], [WWI Purchase Order ID], [Ordered Outers], [Ordered Quantity],
           [Received Outers], Package, [Is Order Finalized], @LineageKey
    FROM Integration.Purchase_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Purchase';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedSaleData;
GO

CREATE PROCEDURE Integration.MigrateStagedSaleData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Sale'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    -- Find the dimension keys required

    UPDATE s
        SET s.[City Key] = COALESCE((SELECT TOP(1) c.[City Key]
                                     FROM Dimension.City AS c
                                     WHERE c.[WWI City ID] = s.[WWI City ID]
                                     AND s.[Last Modified When] > c.[Valid From]
                                     AND s.[Last Modified When] <= c.[Valid To]), 0),
            s.[Customer Key] = COALESCE((SELECT TOP(1) c.[Customer Key]
                                           FROM Dimension.Customer AS c
                                           WHERE c.[WWI Customer ID] = s.[WWI Customer ID]
                                           AND s.[Last Modified When] > c.[Valid From]
                                           AND s.[Last Modified When] <= c.[Valid To]), 0),
            s.[Bill To Customer Key] = COALESCE((SELECT TOP(1) c.[Customer Key]
                                                 FROM Dimension.Customer AS c
                                                 WHERE c.[WWI Customer ID] = s.[WWI Bill To Customer ID]
                                                 AND s.[Last Modified When] > c.[Valid From]
                                                 AND s.[Last Modified When] <= c.[Valid To]), 0),
            s.[Stock Item Key] = COALESCE((SELECT TOP(1) si.[Stock Item Key]
                                           FROM Dimension.[Stock Item] AS si
                                           WHERE si.[WWI Stock Item ID] = s.[WWI Stock Item ID]
                                           AND s.[Last Modified When] > si.[Valid From]
                                           AND s.[Last Modified When] <= si.[Valid To]), 0),
            s.[Salesperson Key] = COALESCE((SELECT TOP(1) e.[Employee Key]
                                            FROM Dimension.Employee AS e
                                            WHERE e.[WWI Employee ID] = s.[WWI Salesperson ID]
                                            AND s.[Last Modified When] > e.[Valid From]
                                            AND s.[Last Modified When] <= e.[Valid To]), 0)
    FROM Integration.Sale_Staging AS s;

    -- Remove any existing entries for any of these invoices

    DELETE s
    FROM Fact.Sale AS s
    WHERE s.[WWI Invoice ID] IN (SELECT [WWI Invoice ID] FROM Integration.Sale_Staging);

    -- Insert all current details for these invoices

    INSERT Fact.Sale
        ([City Key], [Customer Key], [Bill To Customer Key], [Stock Item Key], [Invoice Date Key], [Delivery Date Key],
         [Salesperson Key], [WWI Invoice ID], [Description], Package, Quantity, [Unit Price], [Tax Rate],
         [Total Excluding Tax], [Tax Amount], Profit, [Total Including Tax], [Total Dry Items], [Total Chiller Items], [Lineage Key])
    SELECT [City Key], [Customer Key], [Bill To Customer Key], [Stock Item Key], [Invoice Date Key], [Delivery Date Key],
           [Salesperson Key], [WWI Invoice ID], [Description], Package, Quantity, [Unit Price], [Tax Rate],
           [Total Excluding Tax], [Tax Amount], Profit, [Total Including Tax], [Total Dry Items], [Total Chiller Items], @LineageKey
    FROM Integration.Sale_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Sale';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedStockHoldingData;
GO

CREATE PROCEDURE Integration.MigrateStagedStockHoldingData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Stock Holding'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    -- Find the dimension keys required

    UPDATE s
        SET s.[Stock Item Key] = COALESCE((SELECT TOP(1) si.[Stock Item Key]
                                           FROM Dimension.[Stock Item] AS si
                                           WHERE si.[WWI Stock Item ID] = s.[WWI Stock Item ID]
                                           ORDER BY si.[Valid To] DESC), 0)
    FROM Integration.StockHolding_Staging AS s;

    -- Remove all existing holdings

    TRUNCATE TABLE Fact.[Stock Holding];

    -- Insert all current stock holdings

    INSERT Fact.[Stock Holding]
        ([Stock Item Key], [Quantity On Hand], [Bin Location], [Last Stocktake Quantity],
         [Last Cost Price], [Reorder Level], [Target Stock Level], [Lineage Key])
    SELECT [Stock Item Key], [Quantity On Hand], [Bin Location], [Last Stocktake Quantity],
           [Last Cost Price], [Reorder Level], [Target Stock Level], @LineageKey
    FROM Integration.StockHolding_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Stock Holding';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS Integration.MigrateStagedTransactionData;
GO

CREATE PROCEDURE Integration.MigrateStagedTransactionData
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

    BEGIN TRAN;

    DECLARE @LineageKey int = (SELECT TOP(1) [Lineage Key]
                               FROM Integration.Lineage
                               WHERE [Table Name] = N'Transaction'
                               AND [Data Load Completed] IS NULL
                               ORDER BY [Lineage Key] DESC);

    -- Find the dimension keys required

    UPDATE t
        SET t.[Customer Key] = COALESCE((SELECT TOP(1) c.[Customer Key]
                                         FROM Dimension.Customer AS c
                                         WHERE c.[WWI Customer ID] = t.[WWI Customer ID]
                                         AND t.[Last Modified When] > c.[Valid From]
                                         AND t.[Last Modified When] <= c.[Valid To]), 0),
            t.[Bill To Customer Key] = COALESCE((SELECT TOP(1) c.[Customer Key]
                                                 FROM Dimension.Customer AS c
                                                 WHERE c.[WWI Customer ID] = t.[WWI Bill To Customer ID]
                                                 AND t.[Last Modified When] > c.[Valid From]
                                                 AND t.[Last Modified When] <= c.[Valid To]), 0),
            t.[Supplier Key] = COALESCE((SELECT TOP(1) s.[Supplier Key]
                                         FROM Dimension.Supplier AS s
                                         WHERE s.[WWI Supplier ID] = t.[WWI Supplier ID]
                                         AND t.[Last Modified When] > s.[Valid From]
                                         AND t.[Last Modified When] <= s.[Valid To]), 0),
            t.[Transaction Type Key] = COALESCE((SELECT TOP(1) tt.[Transaction Type Key]
                                                 FROM Dimension.[Transaction Type] AS tt
                                                 WHERE tt.[WWI Transaction Type ID] = t.[WWI Transaction Type ID]
                                                 AND t.[Last Modified When] > tt.[Valid From]
                                                 AND t.[Last Modified When] <= tt.[Valid To]), 0),
            t.[Payment Method Key] = COALESCE((SELECT TOP(1) pm.[Payment Method Key]
                                                 FROM Dimension.[Payment Method] AS pm
                                                 WHERE pm.[WWI Payment Method ID] = t.[WWI Payment Method ID]
                                                 AND t.[Last Modified When] > pm.[Valid From]
                                                 AND t.[Last Modified When] <= pm.[Valid To]), 0)
    FROM Integration.Transaction_Staging AS t;

    -- Insert all the transactions

    INSERT Fact.[Transaction]
        ([Date Key], [Customer Key], [Bill To Customer Key], [Supplier Key], [Transaction Type Key],
         [Payment Method Key], [WWI Customer Transaction ID], [WWI Supplier Transaction ID],
         [WWI Invoice ID], [WWI Purchase Order ID], [Supplier Invoice Number], [Total Excluding Tax],
         [Tax Amount], [Total Including Tax], [Outstanding Balance], [Is Finalized], [Lineage Key])
    SELECT [Date Key], [Customer Key], [Bill To Customer Key], [Supplier Key], [Transaction Type Key],
         [Payment Method Key], [WWI Customer Transaction ID], [WWI Supplier Transaction ID],
         [WWI Invoice ID], [WWI Purchase Order ID], [Supplier Invoice Number], [Total Excluding Tax],
         [Tax Amount], [Total Including Tax], [Outstanding Balance], [Is Finalized], @LineageKey
    FROM Integration.Transaction_Staging;

    UPDATE Integration.Lineage
        SET [Data Load Completed] = SYSDATETIME(),
            [Was Successful] = 1
    WHERE [Lineage Key] = @LineageKey;

    UPDATE Integration.[ETL Cutoff]
        SET [Cutoff Time] = (SELECT [Source System Cutoff Time]
                             FROM Integration.Lineage
                             WHERE [Lineage Key] = @LineageKey)
    FROM Integration.[ETL Cutoff]
    WHERE [Table Name] = N'Transaction';

    COMMIT;

    RETURN 0;
END;
GO

DROP PROCEDURE IF EXISTS [Application].Configuration_ReseedETL;
GO

CREATE PROCEDURE [Application].Configuration_ReseedETL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartingETLCutoffTime datetime2(7) = '20121231';
	DECLARE @StartOfTime datetime2(7) = '20130101';
	DECLARE @EndOfTime datetime2(7) =  '99991231 23:59:59.9999999';

	UPDATE Integration.[ETL Cutoff]
		SET [Cutoff Time] = @StartingETLCutoffTime;

	TRUNCATE TABLE Fact.Movement;
	TRUNCATE TABLE Fact.[Order];
	TRUNCATE TABLE Fact.Purchase;
	TRUNCATE TABLE Fact.Sale;
	TRUNCATE TABLE Fact.[Stock Holding];
	TRUNCATE TABLE Fact.[Transaction];

	DELETE Dimension.City;
	DELETE Dimension.Customer;
	DELETE Dimension.Employee;
	DELETE Dimension.[Payment Method];
	DELETE Dimension.[Stock Item];
	DELETE Dimension.Supplier;
	DELETE Dimension.[Transaction Type];

    INSERT Dimension.City
        ([City Key], [WWI City ID], City, [State Province], Country, Continent, [Sales Territory], Region, Subregion,
         [Location], [Latest Recorded Population], [Valid From], [Valid To], [Lineage Key])
    VALUES
        (0, 0, N'Unknown', N'N/A', N'N/A', N'N/A', N'N/A', N'N/A', N'N/A',
         NULL, 0, @StartOfTime, @EndOfTime, 0);

    INSERT Dimension.Customer
        ([Customer Key], [WWI Customer ID], [Customer], [Bill To Customer], Category, [Buying Group],
         [Primary Contact], [Postal Code], [Valid From], [Valid To], [Lineage Key])
    VALUES
        (0, 0, N'Unknown', N'N/A', N'N/A', N'N/A',
         N'N/A', N'N/A', @StartOfTime, @EndOfTime, 0);

    INSERT Dimension.Employee
        ([Employee Key], [WWI Employee ID], Employee, [Preferred Name],
         [Is Salesperson], Photo, [Valid From], [Valid To], [Lineage Key])
    VALUES
        (0, 0, N'Unknown', N'N/A',
         0, NULL, @StartOfTime, @EndOfTime, 0);

    INSERT Dimension.[Payment Method]
        ([Payment Method Key], [WWI Payment Method ID], [Payment Method], [Valid From], [Valid To], [Lineage Key])
    VALUES
        (0, 0, N'Unknown', @StartOfTime, @EndOfTime, 0);

    INSERT Dimension.[Stock Item]
        ([Stock Item Key], [WWI Stock Item ID], [Stock Item], Color, [Selling Package], [Buying Package],
         Brand, Size, [Lead Time Days], [Quantity Per Outer], [Is Chiller Stock],
         Barcode, [Tax Rate], [Unit Price], [Recommended Retail Price], [Typical Weight Per Unit],
         Photo, [Valid From], [Valid To], [Lineage Key])
    VALUES
        (0, 0, N'Unknown', N'N/A', N'N/A', N'N/A',
         N'N/A', N'N/A', 0, 0, 0,
         N'N/A', 0, 0, 0, 0,
         NULL, @StartOfTime, @EndOfTime, 0);

    INSERT Dimension.[Supplier]
        ([Supplier Key], [WWI Supplier ID], Supplier, Category, [Primary Contact], [Supplier Reference],
         [Payment Days], [Postal Code], [Valid From], [Valid To], [Lineage Key])
    VALUES
        (0, 0, N'Unknown', N'N/A', N'N/A', N'N/A',
         0, N'N/A', @StartOfTime, @EndOfTime, 0);

    INSERT Dimension.[Transaction Type]
        ([Transaction Type Key], [WWI Transaction Type ID], [Transaction Type], [Valid From], [Valid To], [Lineage Key])
    VALUES
        (0, 0, N'Unknown', @StartOfTime, @EndOfTime, 0);
END;
GO

DROP PROCEDURE IF EXISTS [Application].Configuration_EnableInMemory;
GO

CREATE PROCEDURE [Application].Configuration_EnableInMemory
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF SERVERPROPERTY(N'IsXTPSupported') = 0
    BEGIN
        PRINT N'Warning: In-memory tables cannot be created on this edition.';
    END ELSE BEGIN -- if in-memory can be created

		DECLARE @SQL nvarchar(max) = N'';

		BEGIN TRY
			IF CAST(SERVERPROPERTY(N'EngineEdition') AS int) <> 5   -- Not an Azure SQL DB
			BEGIN
				DECLARE @SQLDataFolder nvarchar(max) = (SELECT SUBSTRING(df.physical_name, 1, CHARINDEX(N'WideWorldImportersDW.mdf', df.physical_name, 1) - 1)
				                                        FROM sys.database_files AS df
				                                        WHERE df.file_id = 1);
				DECLARE @MemoryOptimizedFilegroupFolder nvarchar(max) = @SQLDataFolder + N'WideWorldImportersDW_InMemory_Data_1';

				IF NOT EXISTS (SELECT 1 FROM sys.filegroups WHERE name = N'WWIDW_InMemory_Data')
				BEGIN
				    SET @SQL = N'
ALTER DATABASE WideWorldImportersDW
ADD FILEGROUP WWIDW_InMemory_Data CONTAINS MEMORY_OPTIMIZED_DATA;';
					EXECUTE (@SQL);

					SET @SQL = N'
ALTER DATABASE WideWorldImportersDW
ADD FILE (name = N''WWIDW_InMemory_Data_1'', filename = '''
		                 + @MemoryOptimizedFilegroupFolder + N''')
TO FILEGROUP WWIDW_InMemory_Data;';
					EXECUTE (@SQL);

					SET @SQL = N'
ALTER DATABASE WideWorldImportersDW
SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;';
					EXECUTE (@SQL);
				END;
            END;

            IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Customer_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.Customer_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[Customer_Staging]
(
	[Customer Staging Key] [int] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[WWI Customer ID] [int] NOT NULL,
	[Customer] [nvarchar](100) NOT NULL,
	[Bill To Customer] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[Buying Group] [nvarchar](50) NOT NULL,
	[Primary Contact] [nvarchar](50) NOT NULL,
	[Postal Code] [nvarchar](10) NOT NULL,
	[Valid From] [datetime2](7) NOT NULL,
	[Valid To] [datetime2](7) NOT NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

            IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Employee_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.Employee_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[Employee_Staging]
(
	[Employee Staging Key] [int] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[WWI Employee ID] [int] NOT NULL,
	[Employee] [nvarchar](50) NOT NULL,
	[Preferred Name] [nvarchar](50) NOT NULL,
	[Is Salesperson] [bit] NOT NULL,
	[Photo] [varbinary](max) NULL,
	[Valid From] [datetime2](7) NOT NULL,
	[Valid To] [datetime2](7) NOT NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Movement_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.Movement_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[Movement_Staging]
(
	[Movement Staging Key] [bigint] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[Date Key] [date] NULL,
	[Stock Item Key] [int] NULL,
	[Customer Key] [int] NULL,
	[Supplier Key] [int] NULL,
	[Transaction Type Key] [int] NULL,
	[WWI Stock Item Transaction ID] [int] NULL,
	[WWI Invoice ID] [int] NULL,
	[WWI Purchase Order ID] [int] NULL,
	[Quantity] [int] NULL,
	[WWI Stock Item ID] [int] NULL,
	[WWI Customer ID] [int] NULL,
	[WWI Supplier ID] [int] NULL,
	[WWI Transaction Type ID] [int] NULL,
	[Last Modifed When] [datetime2](7) NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Order_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.Order_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[Order_Staging](
	[Order Staging Key] [bigint] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[City Key] [int] NULL,
	[Customer Key] [int] NULL,
	[Stock Item Key] [int] NULL,
	[Order Date Key] [date] NULL,
	[Picked Date Key] [date] NULL,
	[Salesperson Key] [int] NULL,
	[Picker Key] [int] NULL,
	[WWI Order ID] [int] NULL,
	[WWI Backorder ID] [int] NULL,
	[Description] [nvarchar](100) NULL,
	[Package] [nvarchar](50) NULL,
	[Quantity] [int] NULL,
	[Unit Price] [decimal](18, 2) NULL,
	[Tax Rate] [decimal](18, 3) NULL,
	[Total Excluding Tax] [decimal](18, 2) NULL,
	[Tax Amount] [decimal](18, 2) NULL,
	[Total Including Tax] [decimal](18, 2) NULL,
	[Lineage Key] [int] NULL,
	[WWI City ID] [int] NULL,
	[WWI Customer ID] [int] NULL,
	[WWI Stock Item ID] [int] NULL,
	[WWI Salesperson ID] [int] NULL,
	[WWI Picker ID] [int] NULL,
	[Last Modified When] [datetime2](7) NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'PaymentMethod_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.PaymentMethod_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[PaymentMethod_Staging]
(
	[Payment Method Staging Key] [int] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[WWI Payment Method ID] [int] NOT NULL,
	[Payment Method] [nvarchar](50) NOT NULL,
	[Valid From] [datetime2](7) NOT NULL,
	[Valid To] [datetime2](7) NOT NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Purchase_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.Purchase_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[Purchase_Staging]
(
	[Purchase Staging Key] [bigint] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[Date Key] [date] NULL,
	[Supplier Key] [int] NULL,
	[Stock Item Key] [int] NULL,
	[WWI Purchase Order ID] [int] NULL,
	[Ordered Outers] [int] NULL,
	[Ordered Quantity] [int] NULL,
	[Received Outers] [int] NULL,
	[Package] [nvarchar](50) NULL,
	[Is Order Finalized] [bit] NULL,
	[WWI Supplier ID] [int] NULL,
	[WWI Stock Item ID] [int] NULL,
	[Last Modified When] [datetime2](7) NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Sale_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.Sale_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[Sale_Staging]
(
	[Sale Staging Key] [bigint] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[City Key] [int] NULL,
	[Customer Key] [int] NULL,
	[Bill To Customer Key] [int] NULL,
	[Stock Item Key] [int] NULL,
	[Invoice Date Key] [date] NULL,
	[Delivery Date Key] [date] NULL,
	[Salesperson Key] [int] NULL,
	[WWI Invoice ID] [int] NULL,
	[Description] [nvarchar](100) NULL,
	[Package] [nvarchar](50) NULL,
	[Quantity] [int] NULL,
	[Unit Price] [decimal](18, 2) NULL,
	[Tax Rate] [decimal](18, 3) NULL,
	[Total Excluding Tax] [decimal](18, 2) NULL,
	[Tax Amount] [decimal](18, 2) NULL,
	[Profit] [decimal](18, 2) NULL,
	[Total Including Tax] [decimal](18, 2) NULL,
	[Total Dry Items] [int] NULL,
	[Total Chiller Items] [int] NULL,
	[WWI City ID] [int] NULL,
	[WWI Customer ID] [int] NULL,
	[WWI Bill To Customer ID] [int] NULL,
	[WWI Stock Item ID] [int] NULL,
	[WWI Salesperson ID] [int] NULL,
	[Last Modified When] [datetime2](7) NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'StockHolding_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.StockHolding_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[StockHolding_Staging]
(
	[Stock Holding Staging Key] [bigint] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[Stock Item Key] [int] NULL,
	[Quantity On Hand] [int] NULL,
	[Bin Location] [nvarchar](20) NULL,
	[Last Stocktake Quantity] [int] NULL,
	[Last Cost Price] [decimal](18, 2) NULL,
	[Reorder Level] [int] NULL,
	[Target Stock Level] [int] NULL,
	[WWI Stock Item ID] [int] NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'StockItem_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.StockItem_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[StockItem_Staging]
(
	[Stock Item Staging Key] [int] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[WWI Stock Item ID] [int] NOT NULL,
	[Stock Item] [nvarchar](100) NOT NULL,
	[Color] [nvarchar](20) NOT NULL,
	[Selling Package] [nvarchar](50) NOT NULL,
	[Buying Package] [nvarchar](50) NOT NULL,
	[Brand] [nvarchar](50) NOT NULL,
	[Size] [nvarchar](20) NOT NULL,
	[Lead Time Days] [int] NOT NULL,
	[Quantity Per Outer] [int] NOT NULL,
	[Is Chiller Stock] [bit] NOT NULL,
	[Barcode] [nvarchar](50) NULL,
	[Tax Rate] [decimal](18, 3) NOT NULL,
	[Unit Price] [decimal](18, 2) NOT NULL,
	[Recommended Retail Price] [decimal](18, 2) NULL,
	[Typical Weight Per Unit] [decimal](18, 3) NOT NULL,
	[Photo] [varbinary](max) NULL,
	[Valid From] [datetime2](7) NOT NULL,
	[Valid To] [datetime2](7) NOT NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Supplier_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.Supplier_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[Supplier_Staging]
(
	[Supplier Staging Key] [int] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[WWI Supplier ID] [int] NOT NULL,
	[Supplier] [nvarchar](100) NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[Primary Contact] [nvarchar](50) NOT NULL,
	[Supplier Reference] [nvarchar](20) NULL,
	[Payment Days] [int] NOT NULL,
	[Postal Code] [nvarchar](10) NOT NULL,
	[Valid From] [datetime2](7) NOT NULL,
	[Valid To] [datetime2](7) NOT NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Transaction_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.Transaction_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[Transaction_Staging]
(
	[Transaction Staging Key] [bigint] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[Date Key] [date] NULL,
	[Customer Key] [int] NULL,
	[Bill To Customer Key] [int] NULL,
	[Supplier Key] [int] NULL,
	[Transaction Type Key] [int] NULL,
	[Payment Method Key] [int] NULL,
	[WWI Customer Transaction ID] [int] NULL,
	[WWI Supplier Transaction ID] [int] NULL,
	[WWI Invoice ID] [int] NULL,
	[WWI Purchase Order ID] [int] NULL,
	[Supplier Invoice Number] [nvarchar](20) NULL,
	[Total Excluding Tax] [decimal](18, 2) NULL,
	[Tax Amount] [decimal](18, 2) NULL,
	[Total Including Tax] [decimal](18, 2) NULL,
	[Outstanding Balance] [decimal](18, 2) NULL,
	[Is Finalized] [bit] NULL,
	[WWI Customer ID] [int] NULL,
	[WWI Bill To Customer ID] [int] NULL,
	[WWI Supplier ID] [int] NULL,
	[WWI Transaction Type ID] [int] NULL,
	[WWI Payment Method ID] [int] NULL,
	[Last Modified When] [datetime2](7) NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'TransactionType_Staging' AND is_memory_optimized <> 0)
            BEGIN

                SET @SQL = N'
DROP TABLE IF EXISTS Integration.TransactionType_Staging;';
                EXECUTE (@SQL);

                SET @SQL = N'
CREATE TABLE [Integration].[TransactionType_Staging]
(
	[Transaction Type Staging Key] [int] IDENTITY(1,1) NOT NULL
		PRIMARY KEY NONCLUSTERED,
	[WWI Transaction Type ID] [int] NOT NULL,
	[Transaction Type] [nvarchar](50) NOT NULL,
	[Valid From] [datetime2](7) NOT NULL,
	[Valid To] [datetime2](7) NOT NULL
) WITH (MEMORY_OPTIMIZED = ON ,DURABILITY = SCHEMA_ONLY);';
                EXECUTE (@SQL);
			END;

        END TRY
        BEGIN CATCH
            PRINT N'Unable to apply in-memory tables';
            THROW;
        END CATCH;
    END; -- of in-memory is allowed
END;
GO

DROP PROCEDURE IF EXISTS [Application].Configuration_ApplyPartitionedColumnstoreIndexing;
GO

CREATE PROCEDURE [Application].[Configuration_ApplyPartitionedColumnstoreIndexing]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF SERVERPROPERTY(N'IsXTPSupported') = 0 -- TODO !! - currently no separate test for columnstore
    BEGIN                                    -- but same editions with XTP support columnstore
        PRINT N'Warning: Columnstore indexes cannot be created on this edition.';
    END ELSE BEGIN -- if columnstore can be created
        DECLARE @SQL nvarchar(max) = N'';

        BEGIN TRY;

			IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = N'PF_Date')
			BEGIN
				SET @SQL =  N'
CREATE PARTITION FUNCTION PF_Date(date)
AS RANGE RIGHT
FOR VALUES (N''20120101'',N''20130101'',N''20140101'', N''20150101'', N''20160101'', N''20170101'');';
				EXECUTE (@SQL);
				PRINT N'Created partition function PF_Date';
			END;

			IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = N'PS_Date')
			BEGIN
				SET @SQL =  N'
CREATE PARTITION SCHEME PS_Date
AS PARTITION PF_Date 
ALL TO ([USERDATA]);';
				EXECUTE (@SQL);
				PRINT N'Created partition scheme PS_Date';
			END;

            IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'CCX_Fact_Movement')
            BEGIN
				BEGIN TRAN;

                SET @SQL = N'

DROP INDEX [FK_Fact_Movement_Customer_Key] ON Fact.Movement;
DROP INDEX [FK_Fact_Movement_Date_Key] ON Fact.Movement;
DROP INDEX [FK_Fact_Movement_Stock_Item_Key] ON Fact.Movement;
DROP INDEX [FK_Fact_Movement_Supplier_Key] ON Fact.Movement;
DROP INDEX [FK_Fact_Movement_Transaction_Type_Key] ON Fact.Movement;
DROP INDEX [IX_Integration_Movement_WWI_Stock_Item_Transaction_ID] ON Fact.Movement;

ALTER TABLE Fact.Movement
DROP CONSTRAINT PK_Fact_Movement;

CREATE CLUSTERED INDEX CCX_Fact_Movement
ON Fact.Movement
(
	[Date Key]
)
ON PS_Date([Date Key]);

CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Movement
ON Fact.Movement WITH (DROP_EXISTING = ON)
ON PS_Date([Date Key]);

ALTER TABLE [Fact].[Movement]
ADD  CONSTRAINT [PK_Fact_Movement] PRIMARY KEY NONCLUSTERED
(
	[Movement Key],
	[Date Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Customer_Key]
ON [Fact].[Movement]
(
	[Customer Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Date_Key]
ON [Fact].[Movement]
(
	[Date Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Stock_Item_Key]
ON [Fact].[Movement]
(
	[Stock Item Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Supplier_Key]
ON [Fact].[Movement]
(
	[Supplier Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Movement_Transaction_Type_Key]
ON [Fact].[Movement]
(
	[Transaction Type Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [IX_Integration_Movement_WWI_Stock_Item_Transaction_ID]
ON [Fact].[Movement]
(
	[WWI Stock Item Transaction ID]
)
ON PS_Date([Date Key]);

DROP INDEX [FK_Fact_Order_City_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Customer_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Order_Date_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Picked_Date_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Picker_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Salesperson_Key] ON Fact.[Order];
DROP INDEX [FK_Fact_Order_Stock_Item_Key] ON Fact.[Order];
DROP INDEX [IX_Integration_Order_WWI_Order_ID] ON Fact.[Order];

ALTER TABLE Fact.[Order]
DROP CONSTRAINT PK_Fact_Order;

CREATE CLUSTERED INDEX CCX_Fact_Order
ON Fact.[Order]
(
	[Order Date Key]
)
ON PS_Date([Order Date Key]);

CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Order
ON Fact.[Order] WITH (DROP_EXISTING = ON)
ON PS_Date([Order Date Key]);

ALTER TABLE [Fact].[Order]
ADD  CONSTRAINT [PK_Fact_Order] PRIMARY KEY NONCLUSTERED
(
	[Order Key],
	[Order Date Key]
)
ON PS_Date([Order Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Order_City_Key]
ON [Fact].[Order]
(
	[City Key]
)
ON PS_Date([Order Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Order_Customer_Key]
ON [Fact].[Order]
(
	[Customer Key]
)
ON PS_Date([Order Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Order_Order_Date_Key]
ON [Fact].[Order]
(
	[Order Date Key]
)
ON PS_Date([Order Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Order_Picked_Date_Key]
ON [Fact].[Order]
(
	[Picked Date Key]
)
ON PS_Date([Order Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Order_Picker_Key]
ON [Fact].[Order]
(
	[Picker Key] ASC
)
ON PS_Date([Order Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Order_Salesperson_Key]
ON [Fact].[Order]
(
	[Salesperson Key]
)
ON PS_Date([Order Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Order_Stock_Item_Key]
ON [Fact].[Order]
(
	[Stock Item Key]
)
ON PS_Date([Order Date Key]);

CREATE NONCLUSTERED INDEX [IX_Integration_Order_WWI_Order_ID]
ON [Fact].[Order]
(
	[WWI Order ID]
)
ON PS_Date([Order Date Key]);

DROP INDEX [FK_Fact_Purchase_Date_Key] ON Fact.Purchase;
DROP INDEX [FK_Fact_Purchase_Stock_Item_Key] ON Fact.Purchase;
DROP INDEX [FK_Fact_Purchase_Supplier_Key] ON Fact.Purchase;

ALTER TABLE Fact.Purchase
DROP CONSTRAINT PK_Fact_Purchase;

CREATE CLUSTERED INDEX CCX_Fact_Purchase
ON Fact.Purchase
(
	[Date Key]
)
ON PS_Date([Date Key]);

CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Purchase
ON Fact.Purchase WITH (DROP_EXISTING = ON)
ON PS_Date([Date Key]);

ALTER TABLE Fact.Purchase
ADD CONSTRAINT [PK_Fact_Purchase] PRIMARY KEY NONCLUSTERED
(
	[Purchase Key],
	[Date Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Purchase_Date_Key]
ON [Fact].[Purchase]
(
	[Date Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Purchase_Stock_Item_Key]
ON [Fact].[Purchase]
(
	[Stock Item Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Purchase_Supplier_Key]
ON [Fact].[Purchase]
(
	[Supplier Key]
)
ON PS_Date([Date Key]);

DROP INDEX [FK_Fact_Sale_Bill_To_Customer_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_City_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_Customer_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_Delivery_Date_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_Invoice_Date_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_Salesperson_Key] ON Fact.Sale;
DROP INDEX [FK_Fact_Sale_Stock_Item_Key] ON Fact.Sale;

ALTER TABLE Fact.Sale
DROP CONSTRAINT PK_Fact_Sale;

CREATE CLUSTERED INDEX CCX_Fact_Sale
ON Fact.Sale
(
	[Invoice Date Key]
)
ON PS_Date([Invoice Date Key]);

CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Sale
ON Fact.Sale WITH (DROP_EXISTING = ON)
ON PS_Date([Invoice Date Key]);

ALTER TABLE Fact.Sale
ADD CONSTRAINT [PK_Fact_Sale] PRIMARY KEY NONCLUSTERED
(
	[Sale Key],
	[Invoice Date Key]
)
ON PS_Date([Invoice Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Bill_To_Customer_Key]
ON [Fact].[Sale]
(
	[Bill To Customer Key]
)
ON PS_Date([Invoice Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Sale_City_Key]
ON [Fact].[Sale]
(
	[City Key]
)
ON PS_Date([Invoice Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Customer_Key]
ON [Fact].[Sale]
(
	[Customer Key]
)
ON PS_Date([Invoice Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Delivery_Date_Key]
ON [Fact].[Sale]
(
	[Delivery Date Key]
)
ON PS_Date([Invoice Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Invoice_Date_Key]
ON [Fact].[Sale]
(
	[Invoice Date Key]
)
ON PS_Date([Invoice Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Salesperson_Key]
ON [Fact].[Sale]
(
	[Salesperson Key]
)
ON PS_Date([Invoice Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Stock_Item_Key]
ON [Fact].[Sale]
(
	[Stock Item Key]
)
ON PS_Date([Invoice Date Key]);

ALTER TABLE Fact.[Stock Holding]
DROP CONSTRAINT PK_Fact_Stock_Holding;

ALTER TABLE Fact.[Stock Holding]
ADD CONSTRAINT PK_Fact_Stock_Holding PRIMARY KEY NONCLUSTERED ([Stock Holding Key]);

CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Stock_Holding
ON Fact.[Stock Holding];

DROP INDEX [FK_Fact_Transaction_Bill_To_Customer_Key] ON Fact.[Transaction];
DROP INDEX [FK_Fact_Transaction_Customer_Key] ON Fact.[Transaction];
DROP INDEX [FK_Fact_Transaction_Date_Key] ON Fact.[Transaction];
DROP INDEX [FK_Fact_Transaction_Payment_Method_Key] ON Fact.[Transaction];
DROP INDEX [FK_Fact_Transaction_Supplier_Key] ON Fact.[Transaction];
DROP INDEX [FK_Fact_Transaction_Transaction_Type_Key] ON Fact.[Transaction];

ALTER TABLE Fact.[Transaction]
DROP CONSTRAINT PK_Fact_Transaction;

CREATE CLUSTERED INDEX CCX_Fact_Transaction
ON Fact.[Transaction]
(
	[Date Key]
)
ON PS_Date([Date Key]);

CREATE CLUSTERED COLUMNSTORE INDEX CCX_Fact_Transaction
ON Fact.[Transaction] WITH (DROP_EXISTING = ON)
ON PS_Date([Date Key]);

ALTER TABLE Fact.[Transaction]
ADD CONSTRAINT [PK_Fact_Transaction] PRIMARY KEY NONCLUSTERED
(
	[Transaction Key],
	[Date Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Bill_To_Customer_Key]
ON [Fact].[Transaction]
(
	[Bill To Customer Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Customer_Key]
ON [Fact].[Transaction]
(
	[Customer Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Date_Key]
ON [Fact].[Transaction]
(
	[Date Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Payment_Method_Key]
ON [Fact].[Transaction]
(
	[Payment Method Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Supplier_Key]
ON [Fact].[Transaction]
(
	[Supplier Key]
)
ON PS_Date([Date Key]);

CREATE NONCLUSTERED INDEX [FK_Fact_Transaction_Transaction_Type_Key]
ON [Fact].[Transaction]
(
	[Transaction Type Key]
)
ON PS_Date([Date Key]);';
                EXECUTE (@SQL);

				COMMIT;

                PRINT N'Applied partitioned columnstore indexing';
            END;

        END TRY
        BEGIN CATCH
            PRINT N'Unable to apply partitioned columnstore indexing';
            THROW;
        END CATCH;
    END; -- of partitioned columnstore is allowed
END;
GO

DROP PROCEDURE IF EXISTS [Application].Configuration_ApplyPolybase;
GO

CREATE PROCEDURE [Application].Configuration_ApplyPolybase
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF SERVERPROPERTY(N'IsPolybaseInstalled') = 0
    BEGIN
        PRINT N'Warning: Either Polybase cannot be created on this edition or it has not been installed.';
	END ELSE BEGIN -- if installed
		IF (SELECT value FROM sys.configurations WHERE name = 'hadoop connectivity') NOT IN (1, 4, 7)
		BEGIN
	        PRINT N'Warning: Hadoop connectivity has not been enabled. It must be set to 1, 4, or 7 for Azure Storage connectivity.';
		END ELSE BEGIN -- if Polybase can be created

			DECLARE @SQL nvarchar(max) = N'';

			BEGIN TRY

				SET @SQL = N'
CREATE EXTERNAL DATA SOURCE AzureStorage
WITH
(
	TYPE=HADOOP, LOCATION = ''wasbs://data@sqldwdatasets.blob.core.windows.net''
);';
				EXECUTE (@SQL);

				SET @SQL = N'
CREATE EXTERNAL FILE FORMAT CommaDelimitedTextFileFormat
WITH
(
	FORMAT_TYPE = DELIMITEDTEXT,
	FORMAT_OPTIONS
	(
		FIELD_TERMINATOR = '',''
	)
);';
				EXECUTE (@SQL);

				SET @SQL = N'
CREATE EXTERNAL TABLE dbo.CityPopulationStatistics
(
	CityID int NOT NULL,
	StateProvinceCode nvarchar(5) NOT NULL,
	CityName nvarchar(50) NOT NULL,
	YearNumber int NOT NULL,
	LatestRecordedPopulation bigint NULL
)
WITH
(
	LOCATION = ''/'',
	DATA_SOURCE = AzureStorage,
	FILE_FORMAT = CommaDelimitedTextFileFormat,
	REJECT_TYPE = VALUE,
	REJECT_VALUE = 4 -- skipping 1 header row per file
);';
				EXECUTE (@SQL);

	        END TRY
			BEGIN CATCH
				PRINT N'Unable to apply Polybase connectivity to Azure storage';
				THROW;
			END CATCH;
		END; -- if connectivity enabled
    END; -- of Polybase is allowed and installed
END;
GO

DROP PROCEDURE IF EXISTS [Application].Configuration_ConfigureForEnterpriseEdition;
GO

CREATE PROCEDURE [Application].Configuration_ConfigureForEnterpriseEdition
AS
BEGIN

    EXEC [Application].Configuration_ApplyPartitionedColumnstoreIndexing;

    EXEC [Application].Configuration_EnableInMemory;

	EXEC [Application].Configuration_ApplyPolybase;

END;
GO

DROP PROCEDURE IF EXISTS [Application].Configuration_PopulateLargeSaleTable;
GO

CREATE PROCEDURE [Application].[Configuration_PopulateLargeSaleTable]
@EstimatedRowsFor2012 bigint = 12000000
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

	EXEC Integration.PopulateDateDimensionForYear 2012;
	DECLARE @ReturnValue int;

	EXEC @ReturnValue = [Application].Configuration_ApplyPartitionedColumnstoreIndexing;
	DECLARE @LineageKey int = NEXT VALUE FOR Sequences.LineageKey;

	INSERT Integration.Lineage
		([Lineage Key], [Data Load Started], [Table Name], [Data Load Completed], [Was Successful],
		 [Source System Cutoff Time])
	VALUES
		(@LineageKey, SYSDATETIME(), N'Sale', NULL, 0, '20121231')

	DECLARE @OrderCounter bigint = 0;
	DECLARE @NumberOfSalesPerDay bigint = @EstimatedRowsFor2012 / 365;
	DECLARE @DateCounter date = '20120101';
	DECLARE @StartingSaleKey bigint;
	DECLARE @MaximumSaleKey bigint = (SELECT MAX([Sale Key]) FROM Fact.Sale);

	PRINT 'Targeting ' + CAST(@NumberOfSalesPerDay AS varchar(20)) + ' sales per day.';
	IF @NumberOfSalesPerDay > 50000
	BEGIN
		PRINT 'WARNING: Limiting sales to 40000 per day';
		SET @NumberOfSalesPerDay = 50000;
	END;

	DECLARE @OutputCounter varchar(20);
	DECLARE @RowCnt int = 0;


-- DROP CONSTRAINTS
	ALTER TABLE [Fact].[Sale] DROP CONSTRAINT [FK_Fact_Sale_City_Key_Dimension_City]
	ALTER TABLE [Fact].[Sale] DROP CONSTRAINT [FK_Fact_Sale_Customer_Key_Dimension_Customer]
	ALTER TABLE [Fact].[Sale] DROP CONSTRAINT [FK_Fact_Sale_Delivery_Date_Key_Dimension_Date]
	ALTER TABLE [Fact].[Sale] DROP CONSTRAINT [FK_Fact_Sale_Invoice_Date_Key_Dimension_Date]
	ALTER TABLE [Fact].[Sale] DROP CONSTRAINT [FK_Fact_Sale_Salesperson_Key_Dimension_Employee]
	ALTER TABLE [Fact].[Sale] DROP CONSTRAINT [FK_Fact_Sale_Stock_Item_Key_Dimension_Stock Item]
	ALTER TABLE [Fact].[Sale] DROP CONSTRAINT [FK_Fact_Sale_Bill_To_Customer_Key_Dimension_Customer]
	ALTER TABLE [Fact].[Sale] DROP CONSTRAINT [PK_Fact_Sale]
	DROP INDEX  IF EXISTS [FK_Fact_Sale_Bill_To_Customer_Key] ON [Fact].[Sale]
	DROP INDEX  IF EXISTS [FK_Fact_Sale_City_Key] ON [Fact].[Sale]
	DROP INDEX  IF EXISTS [FK_Fact_Sale_Customer_Key] ON [Fact].[Sale]
	DROP INDEX  IF EXISTS [FK_Fact_Sale_Delivery_Date_Key] ON [Fact].[Sale]
	DROP INDEX  IF EXISTS [FK_Fact_Sale_Invoice_Date_Key] ON [Fact].[Sale]
	DROP INDEX  IF EXISTS [FK_Fact_Sale_Salesperson_Key] ON [Fact].[Sale]
	DROP INDEX  IF EXISTS [FK_Fact_Sale_Stock_Item_Key] ON [Fact].[Sale]

	WHILE @DateCounter < '20121231'
	BEGIN
		SET @OutputCounter = CONVERT(varchar(20), @DateCounter, 112);
		RAISERROR(@OutputCounter, 0, 1) WITH NOWAIT;

		SET @StartingSaleKey = @MaximumSaleKey - @NumberOfSalesPerDay - FLOOR(RAND() * 20000);
		SET @OrderCounter = 0;

		INSERT Fact.Sale WITH (TABLOCK)
			([City Key], [Customer Key], [Bill To Customer Key], [Stock Item Key], [Invoice Date Key],
			 [Delivery Date Key], [Salesperson Key], [WWI Invoice ID], [Description],
			 Package, Quantity, [Unit Price], [Tax Rate], [Total Excluding Tax],
			 [Tax Amount], Profit, [Total Including Tax], [Total Dry Items], [Total Chiller Items],
			 [Lineage Key])
		SELECT TOP(@NumberOfSalesPerDay)
			   [City Key], [Customer Key], [Bill To Customer Key], [Stock Item Key], @DateCounter,
			   DATEADD(day, 1, @DateCounter), [Salesperson Key], [WWI Invoice ID], [Description],
			   Package, Quantity, [Unit Price], [Tax Rate], [Total Excluding Tax],
			   [Tax Amount], Profit, [Total Including Tax], [Total Dry Items], [Total Chiller Items],
			   @LineageKey
		FROM Fact.Sale
		WHERE [Sale Key] > @StartingSaleKey
			and [Invoice Date Key] >='2013-01-01'
		ORDER BY [Sale Key];

		SET @DateCounter = DATEADD(day, 1, @DateCounter);
	END;

	RAISERROR('Compressing all open Rowgroups', 0, 1) WITH NOWAIT;

	ALTER INDEX CCX_Fact_Sale
	ON Fact.Sale
	REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);

	UPDATE Integration.Lineage
		SET [Data Load Completed] = SYSDATETIME(),
		    [Was Successful] = 1;

	-- Add back Constraints
	RAISERROR('Adding Constraints', 0, 1) WITH NOWAIT;

	ALTER TABLE [Fact].[Sale]
	ADD CONSTRAINT [PK_Fact_Sale] PRIMARY KEY NONCLUSTERED
	(
		[Sale Key] ASC,
		[Invoice Date Key] ASC
	);

	ALTER TABLE [Fact].[Sale]
	WITH CHECK ADD CONSTRAINT [FK_Fact_Sale_Bill_To_Customer_Key_Dimension_Customer]
	FOREIGN KEY([Bill To Customer Key])
	REFERENCES [Dimension].[Customer] ([Customer Key]);

	ALTER TABLE [Fact].[Sale] CHECK CONSTRAINT [FK_Fact_Sale_Bill_To_Customer_Key_Dimension_Customer];

	ALTER TABLE [Fact].[Sale]
	WITH CHECK ADD CONSTRAINT [FK_Fact_Sale_Stock_Item_Key_Dimension_Stock Item]
	FOREIGN KEY([Stock Item Key])
	REFERENCES [Dimension].[Stock Item] ([Stock Item Key]);

	ALTER TABLE [Fact].[Sale] CHECK CONSTRAINT [FK_Fact_Sale_Stock_Item_Key_Dimension_Stock Item];

	ALTER TABLE [Fact].[Sale]
	WITH CHECK ADD  CONSTRAINT [FK_Fact_Sale_Salesperson_Key_Dimension_Employee]
	FOREIGN KEY([Salesperson Key])
	REFERENCES [Dimension].[Employee] ([Employee Key]);

	ALTER TABLE [Fact].[Sale] CHECK CONSTRAINT [FK_Fact_Sale_Salesperson_Key_Dimension_Employee];

	ALTER TABLE [Fact].[Sale]
	WITH CHECK ADD  CONSTRAINT [FK_Fact_Sale_Invoice_Date_Key_Dimension_Date]
	FOREIGN KEY([Invoice Date Key])
	REFERENCES [Dimension].[Date] ([Date]);

	ALTER TABLE [Fact].[Sale] CHECK CONSTRAINT [FK_Fact_Sale_Invoice_Date_Key_Dimension_Date];

	ALTER TABLE [Fact].[Sale]
	WITH CHECK ADD CONSTRAINT [FK_Fact_Sale_Delivery_Date_Key_Dimension_Date]
	FOREIGN KEY([Delivery Date Key])
	REFERENCES [Dimension].[Date] ([Date]);

	ALTER TABLE [Fact].[Sale] CHECK CONSTRAINT [FK_Fact_Sale_Delivery_Date_Key_Dimension_Date];

	ALTER TABLE [Fact].[Sale]
	WITH CHECK ADD CONSTRAINT [FK_Fact_Sale_Customer_Key_Dimension_Customer]
	FOREIGN KEY([Customer Key])
	REFERENCES [Dimension].[Customer] ([Customer Key]);

	ALTER TABLE [Fact].[Sale] CHECK CONSTRAINT [FK_Fact_Sale_Customer_Key_Dimension_Customer];

	ALTER TABLE [Fact].[Sale]
	WITH CHECK ADD  CONSTRAINT [FK_Fact_Sale_City_Key_Dimension_City]
	FOREIGN KEY([City Key])
	REFERENCES [Dimension].[City] ([City Key]);

	ALTER TABLE [Fact].[Sale] CHECK CONSTRAINT [FK_Fact_Sale_City_Key_Dimension_City];

	-- Recreate indexes
	RAISERROR('Adding Non-clustered Indexes', 0, 1) WITH NOWAIT;
	CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Salesperson_Key] ON [Fact].[Sale] ([Salesperson Key] ASC);
	CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Invoice_Date_Key] ON [Fact].[Sale] ([Invoice Date Key] ASC);
	CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Delivery_Date_Key] ON [Fact].[Sale] ([Delivery Date Key] ASC);
	CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Bill_To_Customer_Key] ON [Fact].[Sale] ([Bill To Customer Key] ASC);
	CREATE NONCLUSTERED INDEX [FK_Fact_Sale_City_Key] ON [Fact].[Sale] ([City Key] ASC);
	CREATE NONCLUSTERED INDEX [FK_Fact_Sale_Customer_Key] ON [Fact].[Sale] ([Customer Key] ASC);

	RETURN 0;
END;
GO

USE tempdb;
GO
