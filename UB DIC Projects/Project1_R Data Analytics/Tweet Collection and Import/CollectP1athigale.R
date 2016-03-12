## PROJECT 1 : MODULE 1 ##

## SCRIPT FOR DATA MINING ## 

library(twitteR)
library(df2json)
#library(rjson)
library(jsonlite)
CONSUMER_KEY <- "***********************"
CONSUMER_SECRET <- "*******************************************"
ACCESS_TOKEN <- "*******************************************"
ACCESS_TOKEN_SECRET <- "*******************************************"

#getTwitterOAuth(consumer_key, consumer_secret)
setup_twitter_oauth(CONSUMER_KEY, CONSUMER_SECRET, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
tweets = searchTwitter("#election2016",n=10000,lang="en", since="2016-02-27",until = "2016-02-28")
tweets_df = twListToDF(tweets)
#write(exportJson<-df2json(tweets_df), "test.json")
write(exportJson<-toJSON(tweets_df), "electionData27.json")