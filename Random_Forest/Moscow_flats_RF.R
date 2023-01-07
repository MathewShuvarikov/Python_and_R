# Moscow flats dataset, I will compare the accuracy of prediction of linear regression and of random forest
library("randomForest")
library("ggplot2")
library('readr')
library("dplyr") 
library('caret')
library('Metrics')

#upload the data
df <- read_csv('path_to_file') 
glimpse(df) # glimpse on the data
df <- df[,-1] # drop unnecessary column

# divide data to train and test sample
set.seed(42)
train_n <- createDataPartition(df$price, p = 0.75, list = FALSE)
head(train_n) 
train <- df[train_n, ]  
test <- df[-train_n, ] 

cor(train) #There are strong correlations between price and totsp and price livesp

#Let's build scatter plots
qplot(x = train$totsp, y=train$price) + geom_smooth(method = 'lm')
qplot(x = train$livesp, y=train$price) + geom_smooth(method = 'lm')

# let's use natural logs of variables, plots look much better that previous ones
qplot(x = log(train$totsp), y=log(train$price)) + geom_smooth(method = 'lm')
qplot(x = log(train$livesp), y=log(train$price)) + geom_smooth(method = 'lm')

# log manipulations with data
train$totsp <- log(train$totsp)
train$livesp <- log(train$livesp)
test$totsp <- log(test$totsp)
test$livesp <- log(test$livesp)

# create model
set.seed(42) 
model_rf <- randomForest(data = train, log(price) ~ .) # use natural log of price, totsp, livesp

# let's compare with regression results
y <- test$price # prices from test sample
yhat_rf <- exp(predict(model_rf, test)) # random forest prediction

model_lm <- lm(data = train, log(price) ~ .) # regression model
summary(model_lm)
yhat_lm <- exp(predict(model_lm, test)) # regression prediction

mape(y, yhat_lm)# Regression error
mape(y, yhat_rf)# Random forest error is less than Regr error

# Random forest prediction shows more accuracy than that of regression, 
# however both metrics are lower than 15%, thus both models can be applied, 
# but random forest are generally better than regression in this particular case



