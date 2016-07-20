-- <Migration ID="4564a689-a19d-4aec-bbe1-ae2742d2d263" TransactionHandling="Custom" />
GO
-- Enable Enterprise Edition features (also available in Evaluation/Developer Edition) 

USE [$(DatabaseName)];
GO

SET NOCOUNT ON;

EXECUTE [Application].Configuration_ConfigureForEnterpriseEdition
GO

