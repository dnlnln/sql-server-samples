

CREATE PROCEDURE [dbo].[InsertMeterMeasurement] 
	@Batch AS dbo.udtMeterMeasurement READONLY,
	@BatchSize INT

WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL=SNAPSHOT, LANGUAGE=N'English')
	DECLARE @i INT = 1
	DECLARE @MeterID INT
	DECLARE @MeasurementInkWh DECIMAL(9, 4)
	DECLARE @PostalCode NVARCHAR(10)
	DECLARE @MeasurementDate DATETIME2(7) 
	
	WHILE (@i <= @BatchSize)
	BEGIN	
	
		SELECT	@MeterID = MeterID,
				@MeasurementInkWh = MeasurementInkWh, 
				@MeasurementDate = MeasurementDate,
				@PostalCode = PostalCode
		FROM	@Batch
		WHERE	RowID = @i
		
		UPDATE	dbo.MeterMeasurement 
		SET		MeasurementInkWh += @MeasurementInkWh,
				MeasurementDate = @MeasurementDate,
				PostalCode = @PostalCode
		WHERE	MeterID = @MeterID							
		
		IF(@@ROWCOUNT = 0)
		BEGIN
			INSERT INTO dbo.MeterMeasurement (MeterID, MeasurementInkWh, PostalCode, MeasurementDate)
			VALUES (@MeterID, @MeasurementInkWh, @PostalCode, @MeasurementDate);			
		END 

		SET @i += 1
	END	
END
