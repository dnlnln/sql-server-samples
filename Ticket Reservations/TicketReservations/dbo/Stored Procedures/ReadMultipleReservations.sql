create proc ReadMultipleReservations(@ServerTransactions int, @RowsPerTransaction int, @ThreadID int)
AS
begin 
	DECLARE @tranCount int = 0;
	DECLARE @CurrentSeq int = 0;
	DECLARE @Sum int = 0;
	DECLARE @loop int = 0;
	WHILE (@tranCount < @ServerTransactions)	
	BEGIN
		BEGIN TRY
			BEGIN TRAN
			select @CurrentSeq = convert(int, current_value) from sys.sequences where name = 'TicketReservationSequence'
			SET @loop = 0
			while (@loop < @RowsPerTransaction)
			BEGIN
				SELECT @Sum += ThreadID from dbo.TicketReservationDetail where iteration = @CurrentSeq and lineId = @loop;
				SET @loop += 1;
			END
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
		END CATCH
		SET @tranCount += 1;
	END
END
