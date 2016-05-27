CREATE TABLE [dbo].[TicketReservationDetail] (
    TicketReservationID BIGINT	NOT NULL,
    TicketReservationDetailID BIGINT IDENTITY	NOT NULL,
    Quantity    INT             NOT NULL,
    FlightID	INT             NOT NULL,
    Comment      NVARCHAR (1000),
-- disk-based table:
/*
    CONSTRAINT [PK_TicketReservationDetail] PRIMARY KEY CLUSTERED (TicketReservationDetailID)
);
*/

-- for memory-optimized, replace the last two lines with the following:
    CONSTRAINT [PK_TicketReservationDetail] PRIMARY KEY NONCLUSTERED (TicketReservationDetailID)
) WITH (MEMORY_OPTIMIZED=ON);
GO

-- For SQL Server, include the following filegroup. For Azure DB, leave out the filegroup
 ALTER DATABASE [$(DatabaseName)] ADD FILEGROUP [mod] CONTAINS MEMORY_OPTIMIZED_DATA

