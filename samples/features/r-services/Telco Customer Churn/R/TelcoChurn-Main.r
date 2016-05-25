################################################################
## Title: Data Science For Database Professionals
## Description:: Main R file
## Author: Microsoft
################################################################

####################################################################################################
##Compute context
####################################################################################################
connection_string <- "Driver=SQL Server;Server=.;Database=telcoedw2;Trusted_Connection=yes;"
sql <- RxInSqlServer(connectionString = connection_string, autoCleanup = FALSE, consoleOutput = TRUE)
local <- RxLocalParallel()
rxOptions(reportProgress = 0)

####################################################################################################
##Connect to the data
####################################################################################################
rxSetComputeContext(local)

##SQL data source
myDataTb <- RxSqlServerData(
  connectionString = connection_string,
  table = "edw_cdr",
  colInfo = col_info)

trainDataTb <- RxSqlServerData(
  connectionString = connection_string,
  table = "edw_cdr_train",
  colInfo = col_info)

testDataTb <- RxSqlServerData(
  connectionString = connection_string,
  table = "edw_cdr_test",
  colInfo = col_info)

rxGetInfo(myDataTb, getVarInfo = T)
rxGetInfo(trainDataTb, getVarInfo = T)
rxGetInfo(testDataTb, getVarInfo = T)

##Data frame
myData <- rxDataStep(myDataTb, overwrite = TRUE)
trainData <- rxDataStep(trainDataTb, overwrite = TRUE)
testData <- rxDataStep(testDataTb, overwrite = TRUE)
str(myData)
str(trainData)
str(testData)

####################################################################################################
##Data exploration and visualization on the data frame myData
####################################################################################################
#impact of callfailure rate (%) on churn
myData %>%
   group_by(month, callfailurerate) %>%
   summarize(countofchurn = sum(as.numeric(churn))) %>%
   ggplot(aes(x = month,
              y = countofchurn,
              group = factor(callfailurerate),
              fill = factor(callfailurerate))) +
  geom_bar(stat = "identity", position = position_dodge()) +
  labs(x = "month",
       y = "Counts of churn") +
  theme_minimal()

####################################################################################################
##Data exploration and visualization on the SQL data source myDataTb
####################################################################################################
rxSetComputeContext(sql)

#Counts of churned customer by age and state (Interactive HeatMap)
tmp <- rxCrossTabs(N(churn) ~ F(age):state, myDataTb, means = FALSE)
Results_df <- rxResultsDF(tmp, output = "sums")
colnames(Results_df) <- substring(colnames(Results_df), 7)
library(Rcpp)
library(d3heatmap)
d3heatmap(data.matrix(Results_df[, -1]), scale = "none", labRow = Results_df[, 1], dendrogram = "none",
          color = cm.colors(255))

####################################################################################################
## Extreme gradient boost with xgboost on the data frame trainData & testData
####################################################################################################

##Step 1- Train Model
library(Matrix)
library(xgboost)
system.time(
xgboost_model <- xgboost(data = dtrainData$data, label = dtrainData$label, max.depth = 32, eta = 1, nthread = 2, nround = 2, objective = "binary:logistic")
)
importance <- xgb.importance(feature_names = dtrainData$data@Dimnames[[2]], model = xgboost_model)
library(Ckmeans.1d.dp)
xgb.plot.importance(importance)

##Step 2- Score Model
predictions <- predict(xgboost_model, dtestData$data)
threshold <- 0.5
xgboost_Probability <- predictions
xgboost_Prediction <- ifelse(xgboost_Probability > threshold, 1, 0)
testPredData <- cbind(testData[, -27], dtestData$label, xgboost_Prediction, xgboost_Probability)
names(testPredData)[names(testPredData) == "dtestData$label"] <- "churn"
head(testPredData)

##Step 3- Evaluate Model
xgboost_metrics <- evaluate_model(data = testPredData,
                                  observed = "churn",
                                  predicted = "xgboost_Prediction")
xgboost_metrics

threshold = 0.5
S = testPredData$xgboost_Probability
Y = testPredData$churn
roc.curve(s = threshold)
ROC.curve = Vectorize(roc.curve)
M.ROC.xgboost = ROC.curve(s = seq(0, 1, by = .01))
library(AUC)
library(pROC)
xgboost.auc <- auc(testPredData$xgboost_Prediction, testPredData$churn)
plot(M.ROC.xgboost[1,], M.ROC.xgboost[2,], main = "ROC Curves for Xgboost", col = "blue", lwd = 4, type = "l", xlab = "False Positive Rate", ylab = "True Positive Rate")
text(0.5, 0, paste("AUC=", round(xgboost.auc, 2)))

####################################################################################################
## Decision forest with rxDForest on SQL data source trainDataTb & testDataTb
####################################################################################################

##Step 1- Train Model
rxSetComputeContext(sql)
train_vars <- rxGetVarNames(trainDataTb)
train_vars <- train_vars[!train_vars %in% c("churn")]
temp <- paste(c("churn", paste(train_vars, collapse = "+")), collapse = "~")
formula <- as.formula(temp)

system.time(
  rx_forest_model <- rxDForest(formula = formula,
                            data = trainDataTb,
                            nTree = 8,
                            maxDepth = 32,
                            mTry = 2,
                            minBucket = 1,
                            replace = TRUE,
                            importance = TRUE,
                            seed = 8,
                            parms = list(loss = c(0, 4, 1, 0))))
rx_forest_model
plot(rx_forest_model)
rxVarImpPlot(rx_forest_model)

##Step 2- Score Model
rxSetComputeContext(local)
system.time(
  predictions <- rxPredict(modelObject = rx_forest_model,
                           data = testData,
                           type = "prob",
                           overwrite = TRUE))
threshold <- 0.5
predictions$X0_prob <- NULL
predictions$churn_Pred <- NULL
names(predictions) <- c("Forest_Probability")
predictions$Forest_Prediction <- ifelse(predictions$Forest_Probability > threshold, 1, 0)
predictions$Forest_Prediction <- factor(predictions$Forest_Prediction, levels = c(1, 0))
testPredData <- cbind(testData, predictions)
head(testPredData)

##Step 3- Evaluate Model
rx_forest_metrics <- evaluate_model(data = testPredData,
                                 observed = "churn",
                                 predicted = "Forest_Prediction")
rx_forest_metrics

roc_curve(data = testPredData,
          observed = "churn",
          predicted = "Forest_Probability")