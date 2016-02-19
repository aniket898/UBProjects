data1 <- read.csv("nyt1.csv")
head(data1)
data1$agecat <-cut(data1$Age,c(-Inf,0,18,24,34,44,54,64,Inf))
summary(data1)
library("doBy")
siterange <- function(x){c(length(x), min(x), mean(x), max(x))}
summaryBy(Age~agecat, data =data1, FUN=siterange)
summaryBy(Gender+Signed_In+Impressions+Clicks~agecat,
          data =data1)
# plot
library(ggplot2)
ggplot(data1, aes(x=Impressions, fill=agecat))
+geom_histogram(binwidth=1)
ggplot(data1, aes(x=agecat, y=Impressions, fill=agecat))
+geom_boxplot()