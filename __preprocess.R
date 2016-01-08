train = read.csv("train.csv")
test = read.csv("test.csv")
r.type = read.csv("resource_type.csv")  ##resource tyoe
l.feat = read.csv("log_feature.csv")    ##feature type
s.type = read.csv("severity_type.csv")  ##severity type
e.type = read.csv("event_type.csv")     ##event type
###########################reshape###########################
train$set = "train"
test$set = "test"
test$fault_severity = 0 #fault for test
dtrain = rbind.data.frame(train,test)   ##combine test and train
dtrain$location = as.numeric(gsub("location ","",dtrain$location))


rl.feat = dcast(l.feat,id~log_feature,value.var = "volume")
rr.type = dcast(r.type,id~resource_type,fun.aggregate = length)
re.type = dcast(e.type,id~event_type,fun.aggregate = length)
rs.type = dcast(s.type,id~severity_type,fun.aggregate = length)

############################################################

# medvol = aggregate(volume ~ id, data = l.feat,sum)
# quart = aggregate(volume ~ id, data = l.feat,quantile,c(.5,.6,.7,.8,.9,1))
# quart = as.matrix(quart)

#############################Merge##########################

dtrain = merge.data.frame(x = dtrain,y = rs.type,by = ("id"))
dtrain = merge.data.frame(x = dtrain,y = rr.type,by = ("id"))
dtrain = merge.data.frame(x = dtrain,y = re.type,by = ("id"))
dtrain = merge.data.frame(x = dtrain,y = rl.feat,by = ("id"))
# dtrain = merge.data.frame(x = dtrain,y = medvol,by = ("id"))
# dtrain = merge.data.frame(x = dtrain,y = quart,by = ("id"))
# dtrain$location1 = as.numeric(as.factor(dtrain$location))
#dtrain = merge.data.frame(x = dtrain,y = cnt,by = ("id"))

####################split################

train = dtrain[dtrain$set == "train",]
test = dtrain[dtrain$set == "test",]
train$set = NULL
test$set = NULL
test$fault_severity = NULL
row.names(train) = NULL
row.names(test) = NULL
train[is.na(train)] <- 0
test[is.na(test)] <- 0

################train and Hold out##################

# split = sample.split(train$fault_severity,SplitRatio = .9)
# train.1 = subset(train,split == T)
# holdout = subset(train,split == F)

################Matrix####################
trainMat = model.matrix(~.-1,train[,-c(1,3)],sparse = T)
#trainMat = fsum(trainMat)
trainMat = Matrix(trainMat,sparse = T)
#t = xgb.DMatrix(data = trainMat,label = train$fault_severity)


# holdMat = model.matrix(~.-1,holdout[,-c(1,3)],sparce = T)
# holdMat = Matrix(holdMat,sparse = T)
# h = xgb.DMatrix(data = holdMat,label = holdout$fault_severity)
# 
# watchlist = list(train = t,test = h)

testMat = model.matrix(~.-1,test[,-c(1,2)],sparse = T)
#testMat = fsum(testMat)
testMat = Matrix(testMat,sparse = T)

