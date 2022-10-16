library("randomForest")
library("ggplot2")
library('readr')
library("dplyr") 
library('caret')

df <- read_csv('/Users/user/Desktop/df/flats_moscow.csv') 
df <- df[,-1]

set.seed(42) # для точной воспроизводимости случайного разбиения
train_n <- createDataPartition(df$price, p = 0.75, list = FALSE)
head(train_n)  # несколько номеров наблюдений, входящих в обучающую выборку

train <- df[train_n, ]  # отбираем наблюдения с номерами из in_sample
test <- df[-train_n, ] 

set.seed(42) # для точной воспроизводимости случайного леса
model_rf <- randomForest(data = train, log(price) ~ .)
summary(model_rf)

y <- log(test$price)
yhat_rf <- predict(model_rf, test)
sum((y - yhat_rf)^2)

model_lm <- lm(data = train, log(price) ~ .)
yhat_lm <- predict(model_lm, test)
sum((y - yhat_lm)^2)

mean(abs(y - yhat_lm)/y)
mean(abs(y - yhat_rf)/y)#ошибка меньше, чем у регрессии




