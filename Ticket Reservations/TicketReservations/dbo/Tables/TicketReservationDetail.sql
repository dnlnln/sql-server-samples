CREATE TABLE [dbo].[TicketReservationDetail] (
    [iteration] INT             NOT NULL,
    [lineId]    INT             NOT NULL,
    [col3]      NVARCHAR (1000) NOT NULL,
    [ThreadID]  INT             NOT NULL,
-- disk-based table:
    CONSTRAINT [sql_ts_th] PRIMARY KEY CLUSTERED ([iteration] ASC, [lineId] ASC)
);

-- for memory-optimized, replace the last two lines with the following:
--    CONSTRAINT [sql_ts_th] PRIMARY KEY NONCLUSTERED ([iteration] ASC, [lineId] ASC)
--) WITH (MEMORY_OPTIMIZED=ON);
--GO

-- For SQL Server, include the following filegroup. For Azure DB, leave out the filegroup
-- ALTER DATABASE [$(DatabaseName)] ADD FILEGROUP [mod] CONTAINS MEMORY_OPTIMIZED_DATA

