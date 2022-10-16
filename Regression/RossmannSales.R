# Sales in Rossmann Stores
# load necessary libraries
library(readr)
library(lmtest)
library(dplyr)
library(ggplot2)
library(car)
library(nortest)
library(memisc)
library(psych)
library(sandwich)

# download data
df <- read.csv("/Users/user/Desktop/df/RossmannStoreSales.csv")

# glimpse of data and remain only necessary columns 
glimpse(df)
df <- df[,c(3,4,5,6,8)]

# histogram of Sales and Customers
qplot(df$Sales, bins = 100)
qplot(df$Customers, bins = 100)

# on hists we may see a lot of zero-outliers, let's drop them
df <-df[(df$Sales>0)&(df$Customers>0),]

# now hists look better, normally-distributed-like 
qplot(df$Sales, bins = 100)
qplot(df$Customers, bins = 100)

# lets build boxplots
boxplot(df$Sales)
boxplot(df$Customers)

#we may see a lot of outliers, they will create noise while we estimate reg model 
#let's delete them, firstly: estimate upper border 

quantile(x = df$Sales, probs = 0.75) + 1.5*IQR(df$Sales)
quantile(x = df$Customers, probs = 0.75) + 1.5*IQR(df$Customers)
# this process can be repeated several times for cleaning all the outliers

# clean the data
df <- df[(df$Sales<12296)&(df$Customers<1300)&(df$Customers>55),]


# lets build boxplots again
boxplot(df$Sales)
boxplot(df$Customers)

# correlation
cor(df)
cor(df, method = 'spearman')

# scatter plots
qplot(x=df$Customers, y = df$Sales)

# scatter plots + regression line
qplot(x=log(df$Customers), y = log(df$Sales)) + geom_smooth()

# estimate linear model
m1 <- lm(data = df, Sales ~ Customers + DayOfWeek + Promo) 
summary(m1)
round(coeftest(m1, vcov = vcovHC,type = "HC3"), 2) #with robust errors
round(coeftest(m1), 2) 
bgtest(m1) # there is autocorrelation
bptest(m1)# there is heteroscedastisity

# estimate non-linear model (half-logarithmic)
m2 <- lm(data = df, log(Sales) ~ log(Customers) + DayOfWeek + Promo) 
summary(m2)
round(coeftest(m2, vcov = vcovHC,type = "HC3"), 5) #with robust errors
round(coeftest(m2), 5)
bgtest(m2) # there is autocorrelation
bptest(m2) # there is heteroscedastisity


# the best is non-linear model,  despite homoscedasticity and autocorrelation of residues
#After implementing robust standard errors all coefs remain signinficant; 
#R-square is 0.719; Model can be applied; 
#Final model equation looks like this: ln(Sales) = 3.56 + 0.78 ln(Customers) - 0.0026 DayOfWeek + 0.164 * Promo
