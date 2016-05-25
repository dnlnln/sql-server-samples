################################################################
## Title: Data Science For Database Professionals
## Description: Setting up relevant R packages
## Author: Microsoft
################################################################

####################################################################################################
##Install packages
####################################################################################################

##Install packages for data exploration usage
if (!require("devtools"))
    install.packages("devtools")
devtools::install_github("rstudio/d3heatmap")
install.packages("dplyr")
install.packages("gplots")
install.packages("ggplot2")
install.packages("qcc")
install.packages("Rcpp")
install.packages("d3heatmap")
install.packages("GGally")

##Install packages for model building usage
install.packages("unbalanced")
install.packages("rpart")
install.packages("randomForest")
install.packages("Matrix")
install.packages("xgboost")
install.packages("Ckmeans.1d.dp")
install.packages("DiagrammeR")
install.packages("ROCR")
install.packages("pROC")
install.packages("AUC")

######################################################################################################
##Set directory
######################################################################################################
setwd("C:/demo/TelcoChurn/TelcoChurn")

####################################################################################################
##Define functions
####################################################################################################

##Define evaluation metrics
evaluate_model <- function(data, observed, predicted) {
    confusion <- table(data[[observed]], data[[predicted]])
    print(confusion)
    tp <- confusion[rownames(confusion) == 1, colnames(confusion) == 1]
    fn <- confusion[rownames(confusion) == 1, colnames(confusion) == 0]
    fp <- confusion[rownames(confusion) == 0, colnames(confusion) == 1]
    tn <- confusion[rownames(confusion) == 0, colnames(confusion) == 0]
    accuracy <- (tp + tn) / (tp + fn + fp + tn)
    precision <- tp / (tp + fp)
    recall <- tp / (tp + fn)
    fscore <- 2 * (precision * recall) / (precision + recall)
    metrics <- c("Accuracy" = accuracy,
               "Precision" = precision,
               "Recall" = recall,
               "F-Score" = fscore)
    return(metrics)
}

##Define ROC curve for rx-model
roc_curve <- function(data, observed, predicted) {
    data <- data[, c(observed, predicted)]
    data[[observed]] <- as.numeric(as.character(data[[observed]]))
    rxRocCurve(actualVarName = observed,
             predVarNames = predicted,
             data = data)
}

##Define ROC curve for open source R model
roc.curve <- function(s) {
    Ps = (S > s) * 1
    FP = sum((Ps == 1) * (Y == 0)) / sum(Y == 0)
    TP = sum((Ps == 1) * (Y == 1)) / sum(Y == 1)
    vect = c(FP, TP)
    names(vect) = c("FPR", "TPR")
    return(vect)
}

