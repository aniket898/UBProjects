library(gdata)
library(plyr)
library(sqldf)
library(ggplot2)
perl <- "C:/Strawberry/perl/bin/perl5.22.1.exe"
bk <- read.xls("rollingsales_brooklyn.xls",pattern="BOROUGH",perl = perl)
#head(bk)
summary(bk)
bk$sale_price_n <- as.numeric(gsub("[^[:digit:]]","",bk$SALE.PRICE))
count(is.na(bk$sale_price_n))
names(bk) <- tolower(names(bk))
## clean/format the data with regular expressions
bk$gross.sqft <- as.numeric(gsub("[^[:digit:]]","",bk$gross.square.feet))
bk$land.sqft <- as.numeric(gsub("[^[:digit:]]","",bk$land.square.feet))
bk$sale.date <- as.Date(bk$sale.date)
bk$year.built <- as.numeric(as.character(bk$year.built))
colnames(bk)[which(names(bk) == "sale.price.n")] <- "sale_price_n"
colnames(bk)[which(names(bk) == "sale.date")] <- "sale_date"
colnames(bk)[which(names(bk) == "year.built")] <- "year_built"
colnames(bk)[which(names(bk) == "zip.code")] <- "zip_code"
## do a bit of exploration to make sure there's not anything
## weird going on with sale prices
attach(bk)
hist(sale_price_n)
hist(sale_price_n[sale_price_n>0])
hist(gross.sqft[sale_price_n==0])
detach(bk)
## keep only the actual sales ,ie, remove where sale price =0 and gross sq feet = 0
bk_sale <- bk[bk$sale_price_n!=0,]
bk_sale <- bk_sale[bk_sale$gross.sqft>0,]
## Gross sq feet vs Sale Price
plot(bk_sale$gross.sqft,bk_sale$sale_price_n, main="Sale Price vs Gross Sq. Feet", xlab="Sale Price", ylab="Gross Sq. feet") 
plot(log(bk_sale$gross.sqft),log(bk_sale$sale_price_n), main="Log Sale Price vs Log Gross Sq. Feet", xlab="Sale Price", ylab="Gross Sq. feet")
## 1-, 2-, and 3-FAMILY HOMES
bk_homes <- bk_sale[which(grepl("FAMILY",bk_sale$building.class.category)),]
plot(log(bk_homes$gross.sqft),log(bk_homes$sale_price_n),main="FAMILY HOMES - Sale Price vs Gross Sq. Feet", xlab="Sale Price", ylab="Gross Sq. feet")
bk_homes[which(bk_homes$sale_price_n<100000),][order(bk_homes[which(bk_homes$sale_price_n<100000),]$sale_price_n),]
## remove outliers that seem like they weren't actual sales
bk_homes$outliers <- (log(bk_homes$sale_price_n) <=5) + 0
bk_homes <- bk_homes[which(bk_homes$outliers==0),]
plot(log(bk_homes$gross.sqft),log(bk_homes$sale_price_n),main="Sale Price vs Gross Sq. Feet without outliers", xlab="Sale Price", ylab="Gross Sq. feet")
#year,building class,tax class,neighborhood,zipcode
# Year Built vs avg sale price 
bk_yearbuilt <- bk_sale[bk_sale$year_built>1900,]
temp_data <- sqldf('select year_built,avg(sale_price_n) AS avg_sale_price from bk_yearbuilt group by year_built')
ggplot(temp_data,aes(x=year_built,y=avg_sale_price)) +geom_bar(stat="identity") + coord_flip() +ggtitle("Year Built vs Avg Sale Price")
rm(temp_data)
# Yearly Sales
bk_yearsales <- bk_sale[bk_sale$sale_date>1900,]
bk_yearsales$sale_year <- format(bk_yearsales$sale_date, "%Y") ## Year with century
# Yearly sales
ggplot(bk_yearsales,aes(x=sale_year)) +geom_bar(aes(fill=sale_year)) +ggtitle("Yearly Sales")
# Sales by Neighborhood
ggplot(bk_yearsales,aes(x=neighborhood)) +geom_bar() + coord_flip() + ggtitle("Sales by Neighborhood")
# Average Price by Neighborhood
temp_data <- sqldf('select neighborhood,avg(sale_price_n) AS avg_sale_price from bk_yearsales group by neighborhood')
ggplot(temp_data,aes(x=neighborhood,y=avg_sale_price)) +geom_bar(stat="identity") + coord_flip() + ggtitle("Neighborhood vs Avg Sale Price")
rm(temp_data)
# Yearly avg sale price
temp_data <- sqldf('select sale_year,avg(sale_price_n) AS avg_sale_price from bk_yearsales group by sale_year')
ggplot(temp_data,aes(x=sale_year,y=avg_sale_price)) +geom_bar(stat="identity",aes(fill=temp_data$sale_year)) + ggtitle("Year vs Avg Sale Price")
rm(temp_data)
# Zip Code Sales
bk_zipcodesales <- bk_yearsales[bk_yearsales$zip_code!=0,]
temp_data <- sqldf('select zip_code,avg(sale_price_n) AS avg_sale_price from bk_zipcodesales group by zip_code')
ggplot(temp_data,aes(x=zip_code,y=avg_sale_price)) +geom_bar(stat="identity") + ggtitle("Sales by Zipcode")
rm(temp_data)
# Neighbourhood vs Borough
ggplot(subset(bk_yearsales,!is.na(building.class.category) && !is.na(neighborhood)),aes(x=neighborhood,y=building.class.category)) +geom_bar(stat="identity",aes(fill=building.class.category))+ coord_flip() +ggtitle("Neighborhood vs Borough")

# Category vs Borough
ggplot(bk_yearsales,aes(x=borough,y=building.class.category)) +geom_bar(stat="identity",aes(fill=building.class.category)) + ggtitle("Borough vs Building Category")



