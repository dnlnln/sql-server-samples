
CREATE PROCEDURE InsertReservationDetails(@Iteration int, @LineCount int, @CharDate NVARCHAR(23), @ThreadID int)
as
BEGIN


	DECLARE @loop int = 0;
	while (@loop < @LineCount)
	BEGIN
		INSERT INTO dbo.TicketReservationDetail VALUES(@Iteration, @loop, @CharDate, @ThreadID);
		SET @loop += 1;
	END
END


/*
-- natively compiled version of the stored procedure:
CREATE PROCEDURE InsertReservationDetails(@Iteration int, @LineCount int, @CharDate NVARCHAR(23), @ThreadID int)
WITH NATIVE_COMPILATION, SCHEMABINDING
as
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL=SNAPSHOT, LANGUAGE=N'English')


	DECLARE @loop int = 0;
	while (@loop < @LineCount)
	BEGIN
		INSERT INTO dbo.TicketReservationDetail VALUES(@Iteration, @loop, @CharDate, @ThreadID);
		SET @loop += 1;
	END
END
*/