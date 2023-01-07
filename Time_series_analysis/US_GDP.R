# import necessary libraries
library(Quandl)
library(forecast)
library(tseries)
library(lmtest)
library(nortest)
library(ggplot2)
library(Metrics)
library(lubridate)
library(FinTS)
library(rugarch)
# import my functions
source('/Users/user/Py_and_R/Package/Garch_pred.R')

#import GDP data from FRED
df <- Quandl('FRED/GDP', order = 'asc', collapse = 'annual', start_date='1950-01-01', end_date='2022-01-01')

# draw the graph of GDP in time
plot(y=df$Value, x=df$Date, type='line')

# Series have several twists in overall trend in 2008 and 2020
# let's change several values with Nan, since they are clogging up time series
# then we interpolate our series and plot the result
spisok <- c("2007-12-31","2008-12-31", "2009-12-31", "2010-12-31","2020-12-31")
for (i in spisok) {
  df$Value <- ifelse(df$Date==i, NaN, df$Value)
}
df$Value <- na.approx.default(df$Value)
plot(y=df$Value, x=df$Date, type='line') # Now the plot of time series looks much smoother

# divide sample into train and test one
train <- df[year(df$Date)<2019,]
test <- df[-index(train),]

# let's use first differences of natural logarithms of Values, 
# since logarithm makes our data more linear, and differences make our data stationary
tsdisplay(diff(log(train$Value)))
# We may observe significant correlations on 1-4 lags, and significant partial correlations on 1st and 3rd lags, 
#it's highly likely autoregressional process, not a moving average one

#Dicky-Fuller test for determining the stationarity of series, spoiler: they are, since p-value >> 0.1)
adf.test(diff(log(train$Value)), alternative = 'explosive')

# let's create our own Arima model, ARIMA([1,3,4], 1, 0)
model1 <- arima(x=log(train$Value), order=c(4,1,0), fixed = c(NA,0,NA,NA))
summary(model1)
coeftest(model1)

# let's estimate auto_arima model and compare with our own
model2 <- auto.arima(log(train$Value))
summary(model2)
coeftest(model2)          

# forecast from model_1, predictive intervals and mape of the prediction
f1 <- forecast(model1, h = nrow(test))
plot(f1, xlim = c(40, nrow(df)), ylim = c(8, 10.5))
lines(y=log(test$Value), x=c((nrow(train)+1):(nrow(train)+nrow(test))), col='red')
mape(test$Value, exp(f1$mean))
#All the read test GDP values are in predictive intervals, so model_1 is statistically adequate
# the mape is also quite low

# forecast from model_2, predictive intervals and mape of the prediction
f2 <- forecast(model2, h = nrow(test))
plot(f2, xlim = c(40, nrow(df)), ylim = c(8, 10.5))
lines(y=log(test$Value), x=c((nrow(train)+1):(nrow(train)+nrow(test))), col='red')
mape(test$Value, exp(f2$mean))
#All the read test GDP values are in predictive intervals, so model_2 is statistically adequate
# the mape is even lower than that of model_2

#Let's think whether we need to estimate garch model, which considers the variance
#Let's compute a formal test for determining arch effets presence in the data
ArchTest(diff(log(train$Value))) # Since p-value of arch test is lower than significance level [0.01,0.05,0.1], there are arch effect in the series

# garch model 
garch_spec <- ugarchspec(variance.model = list(model = "sGARCH", 
                                              garchOrder = c(0,1)), 
                        mean.model = list(armaOrder = c(4, 0)), fixed.pars = list(omega=0, ar2=0, ar4=0)) 
fit_garch <- ugarchfit(spec = garch_spec, data = diff(log(train$Value)))
fit_garch

# forecast from garch
f.sgarch <- ugarchforecast(fit_garch, n.ahead = nrow(test)) 

# transform garch forecast values into those of GDP-forecast
gar_pred <- garch_log_forecast(forecast = f.sgarch, alpha = 0.05, test = test$Value, train = train$Value)

# plot the forecast
plot(x = c(1:nrow(train)), y = log(train$Value), type='line', ylim = c(8,(log(train$Value[nrow(train)]))+0.5), xlim = c(40,nrow(df)),
     ylab='log GDP', xlab='time', main='The US GDP prediction')
lines(x = c((nrow(train)+1):nrow(df)), y = log(test$Value), col='red')
lines(x = c((nrow(train)+1):nrow(df)), y = log(gar_pred$fitted), col='blue')
lines(x = c((nrow(train)+1):nrow(df)), y = log(gar_pred$upper), col='dark green')
lines(x = c((nrow(train)+1):nrow(df)), y = log(gar_pred$lower), col='dark green')

mape(test$Value, gar_pred$fitted)
#All the real test GDP values are in predictive intervals, so garch model is statistically adequate
#Moreover, mape of forecast is incomparably better than that of other models, so garch is the best model in this particular case

#Let's re-estimate the garch model on the whole dataframe and make a prediction for 2022-2024
garch2 <- ugarchspec(variance.model = list(model = "sGARCH", 
                                           garchOrder = c(0,1)), 
                     mean.model = list(armaOrder = c(4, 0)), fixed.pars = list(omega=0, ar2=0, ar4=0)) 
fit_garch2 <- ugarchfit(spec = garch_spec, data = diff(log(df$Value)))
fit_garch2
f.sgarch2 <- ugarchforecast(fit_garch, n.ahead = 3)

garch_pred2 <- garch_log_forecast_outtest(forecast = f.sgarch2, alpha = 0.2, h = 3, train = df$Value)
plot(x = c(1:nrow(train)), y = log(train$Value), type='line', ylim = c(8,(log(df$Value[nrow(df)]))+0.5), xlim = c(40,nrow(df)),
     ylab='log GDP', xlab='time', main='The US GDP prediction')
lines(x = c((nrow(train)+1):nrow(df)), y = log(test$Value), col='red')
lines(x = c((nrow(train)+1):nrow(df)), y = log(gar_pred$fitted), col='blue')
lines(x = c((nrow(train)+1):nrow(df)), y = log(gar_pred$upper), col='dark green')
lines(x = c((nrow(train)+1):nrow(df)), y = log(gar_pred$lower), col='dark green')

garch_pred2
#As we see, according to the model, 
#the US GDP will be 25058 bln dollars in 2022, 26257.17 bln in 2023, 27545.39 bln in 2024
# the results are slightly different from those from python, but overall pattern remains

