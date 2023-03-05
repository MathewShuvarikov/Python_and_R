# Research on Moscow flats prices. Link for the dataset in Kaggle: https://www.kaggle.com/datasets/hugoncosta/price-of-flats-in-moscow
# Download necessary libraries
library(lmtest)
library(sandwich)
library(Metrics)
library(ggplot2)
library(dplyr)
library(fastDummies)
library(caret)

# download the dataset
df <- read.csv('path_to_file')
# drop unnecessary column
df <- df[,-1]

# glimpse on the data
glimpse(df)
#Variables description: price - flat price in $ 1000, totsp - total flat area in sq meters, 
#livesp - living area in sq meters, kitsp - kitchen area in sq meters, 
#dist - distance to the city center in km, metrdist - distance to metro station in minutes, 
#walk - binary variable "is it possible to get to the metro on foot?" (1 - yes, 0 - no), brick - binary variable if the house is constructed of brick (1 - yes, 0 - no), 
#floor - binary variable (0 - first or last floor, 1 - other); 
#code - a number from 1 to 8, with which the data is grouped observations by subsamples: 1. Observations are grouped in the north, around the Kaluga-Riga metro; 
#line 2. North, around the Serpukhovsko-Timiryazevskaya metro line; 3. Northwest, around the Zamoskvoretskaya metro line; 4. Northwest, around the Tagansko-Krasnopresnenskaya metro line; 
#5. Southeast, around the Lublin metro line; 6. Southeast, around Tagansko-Krasnopresnenskaya metro line; 
#7. East, around Kalininskaya metro line; 8. East, around Arbatsko-Pokrovskaya metro line

colSums(is.na(df)) # there is no nan

# correlations
cor(df) #There are strong linear correlations between price and totsp and price and livesp Let's build scatter plots
cor(df, method = 'spearman') #Spearman rank correlations between price and totsp and kitsp is higher than linear ones, so it can indicate about the presence of non-linear causation

# scatterplots
qplot(x=df$totsp, y=df$price)
qplot(x=df$livesp, y=df$price) #We better use natural log of price, and that of totsp and of livesp
qplot(x=df$kitsp, y=df$price) # Chances are that kitsp is not very informative variable comparing with totsp and livesp, we may observe clusters of flats with similar kitchen area, but different prices. 
#So, the variable may be used as auxiliary variable. All the other variables will be used for the same function.

qplot(x=log(df$totsp), y=log(df$price))
qplot(x=log(df$livesp), y=log(df$price)) # I will use log(price) in upcoming modeling

# add dummies for code variable
df <- dummy_cols(.data = df, select_columns = 'code', remove_selected_columns = TRUE)
df <- subset(x = df, select = -c(code_1))

# divide the data into train and test sample
set.seed(42)
train_n <- createDataPartition(df$price, p = 0.9, list = FALSE)
head(train_n) 
train <- df[train_n, ]  
test <- df[-train_n, ] 

# first model
m1 <- lm(data=train, price~.-code_4-code_2-code_8) # we expose from insignificant variables
summary(m1)
#All the coefficients are significant on 5%-level. R-square is significant on 5%-level and is higher than 0.5, so the model has a statistical quality. 
#Durbin-Watson statistic shows the absence of autocorrelation in residuals, but, speaking of autocorrelation in residuals spatial data (data without time series), 
#computing autocorrelation test makes no sense, since we may resample our data, randomly change the position of observations, and autocorrelation may disappear or vice versa. 
#Let's check the model for heteroscedastisity, since on the scatterplots we observe different conditional variance in data (with the growth of the dependent variables). 
#The insignificance of code 2,4,8 means that there is no difference between flats in code 4 area and code 1.

qplot(x = m1$fitted.values, y=train$price) + geom_smooth(method = 'lm')
#As I sad before, variance increases with the growth of the dependent variables, let's compute Breush-Pagan test for heteroscedastisity.
bptest(m1) # Since BP_test p-value << 0.05, there is a heteroscedastisity, let's try to upgrade the model and to smooth out heteroscedasticity. Let's use the natural logarithms of variables.

# second model
m2 <- lm(data = train, log(price)~.+log(totsp)-totsp-livesp-code_4-code_2-code_8)
summary(m2)
#All the coefs remain significant on 5%-level, and the R-square increased by ~0.06 from the previous figure.
#Let's compute BP-test again. The insignificance of some codes means that there is no difference between flats in code 8 area and that of code 1, code 2, and code 4. 
#The insignificance of log(livesp) probably indicates that this variable is highly dependent on total area of the flat, so it definitely makes sense to use log(totsp) only.

bptest(m2) #P-value of test remains << 0.05, but test statistic decreased, so we have slightly smoothed out the heteroscedastisity. We will use robust standard errors afterwords, now let's check our model on test data.
qplot(x=m2$fitted.values, y=log(train$price)) + geom_smooth(method = 'lm')
#New results look much better on the scatterplot, than the predious ones. The data looks more linear and conditional variable is lower.

# let's make a prediction on the test sample
p <- as.data.frame(predict(object = m2, newdata = test, interval = 'prediction'))
p$true <- log(test$price)
p$isin <- ifelse((p$true>=p$lwr)&(p$true<=p$upr), 1,0)
mean(p$isin) #Most of true log(price) values are inside the prediction interval. so the model statisticaly adequate

mape(test$price, exp(p$fit)) #The mape of prediction is slightly above the 10%, so the model is quite accurate (since the mape is lower than 12-15%) and can be used in further predictions. 
#Let's estimate the final model on the whole dataset.

# final model
model <- lm(data=df, log(price)~.+log(totsp)-livesp-totsp-code_4-code_2-code_8)
summary(model)
coeftest(model, vcov. = vcovHC(model, type = 'HC3'))
#The final model looks like: 
#log(price) = 0.355 + 1.0646 log(totsp) + 0.0137 * kitsp - 0.0214 * dist - 0.0088 * metrdist + 0.088 * walk + 0.029 * brick + 0.055 * floor + 0.0552 * code_3 - 0.1529 * code_5 - 0.1137 * code_6 - 0.098 * code_7, R-sq = 0.78. 
#It's of good quality since R-sq is significant on 5%-level, so as coefs are. We used robust standard errors to glide the effects of heteroscedastisity. 
#Let's try to interprete the results from economic point of view, to make this possible let's tranform coefs through exponent to go to the usual units of measurement ($ 1000).

exp(model$coefficients)
#So, generally speaking, because of extra log in regressors, it's difficult to get the exact effects of totsp, but it's the most important and influental one - each additional unit of log(totsp) raises the price in 2.9 times. Constant can't be interprete, since there is no flat out there with 0 area;
#An additional square meter of kitchen space raises the price by 1.38%;
#An additional km far from the Moscow center drops the price down by 2.1%;
#An additional minute of walking from the nearest metro stationa decreses the price by 0.88%; The presence of the metro in walking distance increases the price by 9.4%;
#If the house was constructed of brick, the price increases by 2.85%;
#If the floor on which the flat is located is not the 1st of the last, the price increses by 5.47%; The influence of the codes depends on the district (on its popularity/prestige), so the areas of codes 1, 4, 8 are quite similar, but code 3 district is better (since flats in general cost 4.45% more), 
#and the folowing sequence of codes represents the decline of the prestige of the district comparing to preious ones: 7,6,5.

#At the end of a day, the model should be shown to a real estate agency, where the quality and adequacy of our model can be properly estimated from the market point of view.
#One of the problem of the model is quite a big number of regressors, even though there are enouth obrserations, but some of the variables may seem unimportant to realtors.



