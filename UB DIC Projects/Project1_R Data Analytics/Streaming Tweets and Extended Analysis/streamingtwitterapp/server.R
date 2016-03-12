# install.packages("twitteR")
# install.packages("wordcloud")
# install.packages("plyr")
# install.packages("dplyr")
# install.packages("stringr")
# install.packages("ggplot2")
# install.packages("tm")
library(ggplot2)
library(shiny)
library("ggmap")
library("maptools")
library(maps)
source("helpers.R")
library(plyr)
library(dplyr)
library(stringr)
library(ggplot2)
library(reshape2)
library(twitteR)
library(wordcloud)
library(jsonlite)
library(tm)
library(SnowballC)
library(RColorBrewer)
library(sqldf)
#install.packages("devtools")
loadAuth()

tweets <<- data.frame()
trump_tweets <<- NULL
clinton_tweets <<- NULL
sanders_tweets <<- NULL
bush_tweets <<- NULL
cruz_tweets <<- NULL
carson_tweets <<- NULL

 allData <<- NULL
  for(i in 1:8){
    cat(i)
    filename <- paste("F:/Projects/streamingtwitterapp/electionData",i,".json",sep="")
    data <- fromJSON(paste(readLines(filename), collapse=""))
    if(ncol(data)==14){
      data[,"latitude"] <- NA
      data[,"longitude"] <- NA
    }
    allData <<- rbind(allData,data)
    rm(data)
  }

allData$created_day <- strptime(allData$created, format='%Y-%m-%d %H:%M:%S') 
 allData$tweet_date <- format(allData$created_day, "%d")
 allDataForTrend2 <- allData
 allDataForTrend2$created <- NULL 
 allDataForTrend2$created_day <- NULL


cat("Files loaded")
shinyServer(function(input, output,session) {
  
  streamData <- function(data) {
    observe({
      cat("Streaming data")
      if (file.exists("tweets.json")) 
        file.remove("tweets.json")
      filterStream(file.name = "tweets.json", timeout=5,track = data, oauth = my_oauth)
      tweets <<- rbind(tweets,parseTweets("tweets.json", verbose = FALSE))
      ###  STREAMING DATA ANALYSIS ###
#       # Generate an HTML table view of the streaming data
#       output$streamingtable1 <- renderTable({
#         data.frame(tweets)
#       })
      
#       output$streamingsummary1 <- renderPrint({
#         summary(tweets)
#       })
      
      # language graph
      output$streamingplot1 <- renderPlot({
        ggplot(tweets,aes(x=tweets$lang,fill=lang)) + geom_bar() +  ggtitle("Language Graph") + labs(x="Language") 
      })
      
      # createdat graph
      output$streamingplot2 <- renderPlot({
        ggplot(tweets,aes(x=tweets$created_at)) + geom_bar() + ggtitle("Created At Graph") + labs(x="Created At") 
      })
      
      #USA map
      output$streamingplot3 <- renderPlot({
        tweetswithloc <- subset(tweets,tweets$location!="NA")
        visited <- tweetswithloc$location
        ll.visited <- geocode(visited)
        visit.x <- ll.visited$lon
        visit.y <- ll.visited$lat
        map("state", mar=c(0,0,0,0))
        title("Tweets Plot")
        points(visit.x,visit.y, col="red", pch=10)
        
      })
        invalidateLater(0,session = getDefaultReactiveDomain())
    })
  }
  
  
  newdata <- observeEvent(input$getdata, {
      streamData(input$searchterm)
      
  })
  #tweets <- reactive({
  #  parseTweets("F:/Projects/streamingtwitterapp/tweets.json")
  #})
  #fileReaderData <- reactiveFileReader(1000,filePath = "F:/Projects/streamingtwitterapp/tweets.json",session, readFunc = readFile())
  
  
  ### WORD CLOUD : TOO HEAVY BUT IT WORKS SEE THE WORDCLOUD ATTACHED ###
  output$trendplot1 <- renderPlot({
    
    trump_tweets <<- allData[which(grepl("Trump",allData$text)),]
    trump_text <<- sapply( unlist(trump_tweets) , function(x) ( x["text"]))
    trump_tweets$text <<- clean.text(trump_tweets$text)
    trumpCorpus <<- Corpus(VectorSource(trump_tweets$text))
    trumpCorpus <<- tm_map(trumpCorpus, PlainTextDocument)
    trumpCorpus <<- tm_map(trumpCorpus, removePunctuation)
    trumpCorpus <<- tm_map(trumpCorpus, removeWords, c('the', 'this', stopwords('english'),"marco","keep","begin","know","email","hillaryclinton","week","clinton","trump","call","time","break","deleg","run","doesnt","take","donald","rubio","christi","republican","establish","need","news","whos","campaign","gopdeb","president","year","years", "yes","republicans","democrats","amp","polls","USA",
                                                    "elections","election","todays", "reads", "live","tedcruz","watch", "the","and","this","that","what",
                                                    "will","can","must","many","make","say","says","cant", "uselection", "obama","gop","cruz","chris",
                                                    "party","vote","even","now","nota","notamensrights","hey","world","class","create","men","christi",
                                                    "sure","every","day","dont","get","media","one","see","said","feb","like","support"
                                                    ,"use","together","election2016","donaldtrump","https","caucus","votetrump2016"))
    trumpCorpus <<- tm_map(trumpCorpus, stemDocument)
    pal2 <- brewer.pal(8,"Dark2")
    wordcloud(trumpCorpus, max.words = 200, random.order = FALSE,colors=pal2)
  })
  
  output$trendplot3 <- renderPlot({
    trump_tweets <<- allDataForTrend2[which(grepl("Trump",allData$text)),]
    trump_tweets$NomineeName <- "Trump"
    clinton_tweets <<- allDataForTrend2[which(grepl("Clinton",allData$text)),]
    clinton_tweets$NomineeName <- "Clinton"
    sanders_tweets <<- allDataForTrend2[which(grepl("Sanders",allData$text)),]
    sanders_tweets$NomineeName <- "Sanders"
    bush_tweets <<- allDataForTrend2[which(grepl("Bush",allData$text)),]
    bush_tweets$NomineeName <- "Bush"
    cruz_tweets <<- allDataForTrend2[which(grepl("Cruz",allData$text)),]
    cruz_tweets$NomineeName <- "Cruz"
    
    #trump_tweets <<- allData[which(grepl("Trump",allData$text)),]
    #trump_tweets <<- allData[which(grepl("Trump",allData$text)),]
    temp_data1 <- sqldf('select tweet_date,count(tweet_date) AS trumpcount,NomineeName from trump_tweets group by tweet_date')
    temp_data2 <- sqldf('select tweet_date,count(tweet_date) AS clintoncount,NomineeName from clinton_tweets group by tweet_date')
    temp_data3 <- sqldf('select tweet_date,count(tweet_date) AS sanderscount,NomineeName from sanders_tweets group by tweet_date')
    temp_data4 <- sqldf('select tweet_date,count(tweet_date) AS bushcount,NomineeName from bush_tweets group by tweet_date')
    temp_data5 <- sqldf('select tweet_date,count(tweet_date) AS cruzcount,NomineeName from cruz_tweets group by tweet_date')
    ggplot() +
      geom_line(data = temp_data1, aes(x = tweet_date,y= trumpcount, color = NomineeName,group=1)) +
      geom_line(data = temp_data2, aes(x = tweet_date,y = clintoncount,color = NomineeName,group=1)) +
      geom_line(data = temp_data3, aes(x = tweet_date,y = sanderscount,color = NomineeName,group=1)) +
      geom_line(data = temp_data4, aes(x = tweet_date,y = bushcount,color = NomineeName,group=1)) +
      geom_line(data = temp_data5, aes(x = tweet_date,y = cruzcount,color = NomineeName,group=1)) +
      xlab('Day in February') +
      ylab('Count')+ ggtitle("Tweeting Trend")
    
  })
  
  output$trendplot2 <- renderPlot({
    ggplot(tweets,aes(x=allData$tweet_date)) + geom_bar() + ggtitle("Tweets per Day") + labs(x="Created On (February)") 
  })
  
  # Generate a summary of the data
  output$trendsummary <- renderPrint({
    summary(allData)
  })
  
  #USA map
  output$trendplot4 <- renderPlot({
    ad <- subset(allData,allData$latitude!="NA")
    map("state", fill=TRUE, col="white", bg="white",mar=c(0,0,0,0))
    points(ad$longitude,ad$latitude, col="red", pch=10)
    title("Tweets Map Plot")
  })
  
#   # Generate an HTML table view of the data
##  output$trendtable <- renderTable({
#     data.frame(head(allData))
#   })
  
  
  
})