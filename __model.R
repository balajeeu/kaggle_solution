setwd("C:/Users/ssn/Documents/R/Balajee/telstra")
library(xgboost)
library(Matrix)
library(reshape2)
library(caTools)
source("__func.R")
source("__preprocess.R")


###############Parameter##################
param <- list("objective" = "multi:softprob",
              "eval_metric" = "mlogloss",
              "num_class" = 3,
              "nthread "=16,
              "subsample" = .95,
              "colsample_bytree" = .95)
###############cross validation###################

model.cv = xgb.cv(data = trainMat,label = train$fault_severity,param = param,nround=7000,nfold = 5,max_depth = 12,eta=.03,min_child_weight = 0,early.stop.round = 60,set.seed = 4492,gamma = 2,stratified = T,maximize = F)


round.no = which.min(model.cv$test.mlogloss.mean)

model = xgboost(data = trainMat,label = train$fault_severity,param = param,eta=.03,nround=round.no,max_depth =12,early.stop.round = 60,set.seed = 4492,gamma = 2,maximize = F,min_child_weight = 0,stratified = T)

#######################################################


################predicition and output#################
pred = predict(model,testMat)
output = submit(pred,test$id)
head(output)
write.csv(output,"submit.csv",row.names = F)
#######################
