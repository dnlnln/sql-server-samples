-- <Migration ID="9adeb340-2b1b-4a86-9185-e46ef42f274a" TransactionHandling="Custom" />
GO
-- Run data simulation to populate the database.
-- Runtime: ~15 minutes from 20130101 to 20151219

USE [$(DatabaseName)];
GO

IF NOT DB_NAME() LIKE '%_SHADOW'
BEGIN
	SET NOCOUNT ON;

	EXEC DataLoadSimulation.Configuration_ApplyDataLoadSimulationProcedures;

	EXEC DataLoadSimulation.DailyProcessToCreateHistory 
		@StartDate = '20130101',
		@EndDate = '20151219', -- the day after 20151220 will trigger RecordColdRoomTemperatures, which is the next work item to tune
		@AverageNumberOfCustomerOrdersPerDay = 60,
		@SaturdayPercentageOfNormalWorkDay = 50,
		@SundayPercentageOfNormalWorkDay = 0,
		@UpdateCustomFields = 1,
		@IsSilentMode = 1,
		@AreDatesPrinted = 1,
		@CommitBatchSize=10;

	EXEC DataLoadSimulation.Configuration_RemoveDataLoadSimulationProcedures;
END
GO

