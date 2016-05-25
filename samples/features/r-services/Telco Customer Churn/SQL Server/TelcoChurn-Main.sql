--Set DB
use telcoedw2
go

-- Show the serialized model
select * from cdr_rx_models

-- Step 1 - Train the customer churn model
-- After successful execution, this will create a binary representation of the model
exec generate_cdr_rx_DForest;

-- Step 2 - Score the model- In this step, you will invoke the stored procedure predict_cdr_churn_forst
-- The stored procedure uses the rxPredict function to predict the customers that are likely to churn
-- Results are returned as an output dataset
-- Execute scoring procedure
drop table if exists edw_cdr_test_pred;
go
create table edw_cdr_test_pred(
customerid int,
churn varchar(255),
probability float,
prediction float
)
insert into edw_cdr_test_pred
exec predict_cdr_churn_rx_forest 'rxDForest';
go
select * from edw_cdr_test_pred

-- Step 3 - Evaluate the model
-- This uses test data to evaluate the performance of the model.
exec model_evaluate

-- Step 4 - Repeat Step 2-3 to invoke and evaluate Boosted Decision Tree model
drop table if exists edw_cdr_test_pred;
go
create table edw_cdr_test_pred(
customerid int,
churn varchar(255),
probability float,
prediction float
)
insert into edw_cdr_test_pred
exec predict_cdr_churn_rx_boost 'rxBTrees';
go
select * from edw_cdr_test_pred

exec model_evaluate

-- Step 5 - Repeat Step 2-3 to invoke and evaluate Xgboost model
drop table if exists edw_cdr_test_pred;
go
create table edw_cdr_test_pred(
customerid int,
churn varchar(255),
probability float,
prediction float
)
insert into edw_cdr_test_pred
exec predict_cdr_churn_rx_boost 'rxBTrees';
go
select * from edw_cdr_test_pred

exec model_evaluate