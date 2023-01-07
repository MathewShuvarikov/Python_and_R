# Moscow flats dataset, I will compare the accuracy of prediction of linear regression and of random forest
library("randomForest")
library("ggplot2")
library('readr')
library("dplyr") 
library('caret')

df <- read_csv('path_to_file') 
df <- df[,-1]

# divide data to train and test sample
set.seed(42)
train_n <- createDataPartition(df$price, p = 0.75, list = FALSE)
head(train_n) 
train <- df[train_n, ]  
test <- df[-train_n, ] 

# create model
set.seed(42) 
model_rf <- randomForest(data = train, log(price) ~ .)

# let's compare with regression results
y <- log(test$price) # prices from test sample
yhat_rf <- predict(model_rf, test) # random forest prediction

model_lm <- lm(data = train, log(price) ~ .) # regression model
yhat_lm <- predict(model_lm, test) # 

mean(abs(y - yhat_lm)/y)# Regression error
mean(abs(y - yhat_rf)/y)# RF error is less than Regr error




