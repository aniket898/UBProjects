library(gdata)
library(plyr)
library(sqldf)
library(ggplot2)
perl <- "C:/Strawberry/perl/bin/perl5.22.1.exe"
bk <- read.xls("rollingsales_brooklyn.xls",pattern="BOROUGH",perl = perl)
bk2 <- read.xls("rollingsales_bronx.xls",pattern="BOROUGH",perl = perl)
bk3 <- read.xls("rollingsales_manhattan.xls",pattern="BOROUGH",perl = perl)
bk4 <- read.xls("rollingsales_queens.xls",pattern="BOROUGH",perl = perl)
bk5 <- read.xls("rollingsales_statenisland.xls",pattern="BOROUGH",perl = perl)
bk1<-bk
rm(bk)
bk <- rbind(bk1,bk2,bk3,bk4,bk5)
bk$sale_price_n <- as.numeric(gsub("[^[:digit:]]","",bk$SALE.PRICE))
count(is.na(bk$sale_price_n))

names(bk) <- tolower(names(bk))
bk$gross.sqft <- as.numeric(gsub("[^[:digit:]]","",bk$gross.square.feet))
bk$land.sqft <- as.numeric(gsub("[^[:digit:]]","",bk$land.square.feet))
bk$sale.date <- as.Date(bk$sale.date)
bk$year.built <- as.numeric(as.character(bk$year.built))
colnames(bk)[which(names(bk) == "sale.price.n")] <- "sale_price_n"
colnames(bk)[which(names(bk) == "sale.date")] <- "sale_date"
colnames(bk)[which(names(bk) == "year.built")] <- "year_built"
colnames(bk)[which(names(bk) == "zip.code")] <- "zip_code"
bk_sale <- bk[bk$sale_price_n>10000,]
bk_sale <- bk_sale[bk_sale$gross.sqft>100,]
bk_sale <- bk_sale[bk_sale$zip_code!=0,]
#bk_saletouse <- bk_sale[1:1000,]
bk_saletouse <- bk_sale[sample(1:nrow(bk_sale), 12000,replace=FALSE),]
#pairs(bk_saletouse)
threePredictorModel <- lm(sale_price_n ~ borough + zip_code + gross.square.feet + year_built, bk_saletouse)
threePredictorModel

bk_testdata <- bk_sale[sample(1:nrow(bk_sale), 10,replace=FALSE),]
predict(threePredictorModel, bk_testdata, interval="predict") 
bk_testdata$sale_price_n
plot(threePredictorModel)