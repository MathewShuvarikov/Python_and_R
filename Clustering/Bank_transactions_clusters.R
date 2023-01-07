# download necessary libraries
library(readr)
library(ggplot2)
library(dplyr)
library(psych)
library(purrr)

# download data
df <- read_csv('path_to_file')
# glimpse on data
glimpse(df)

df_train <- df[,-4] # delete unnecessary columns
df_train <- scale(df_train) # standardize data

set.seed(123)

# function to compute total within-cluster sum of square 
wss <- function(k) {
  kmeans(df_train, k, nstart = 10 )$tot.withinss
}
 
# Compute and plot wss for k from 2 to 15
k.values <- c(2:15)

# extract wss for 2-15 clusters
wss_values <- map_dbl(k.values, wss)

plot(k.values, wss_values,
     type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares")

km <- kmeans(x = df_train, centers = 5) # train model

df$cluster <- km$cluster # add cluster to initial data
df %>% group_by(cluster) %>% summarise(median(gender), median(age), median(acc_balance), median(amount))
#1-cluster: 42 year old men with 3 743 220 rupies account balance, and median transaction for 2500 rupies. 
#2: 30 year old men with 8 194 rupies account balance, and median transaction for 230 rupies. 
#3: 44 year old men with 30 128 rupies account balance, and median transaction for 700 rupies. 
#4: 33 year old women with 17 848 rupies account balance, and median transaction for 490 rupies. 
#5: 36 year old men with 15 159 rupies account balance, and median transaction for 396 rupies.

# slightly different results in Python and R, but clusters from both python and r are generally similar.


