library(twitteR)
library(df2json)

CONSUMER_KEY <- "ax4TCkpNczz2gGZCQPzlTieZ1"
CONSUMER_SECRET <- "t6anJn4xZHfkNGubGDqh5CrWUJW9pXT9rqNvTd1Rao0twux6pg"
ACCESS_TOKEN <- "1157935387-R1Ff7RmqXrNy08zTtllK34Xd2NS7JaDuwtvm0mt"
ACCESS_TOKEN_SECRET <- "foITlPmbBEcGQc3TbFWjYbSumDiUPJ4XZ3L8RJZTzEIIK"

#getTwitterOAuth(consumer_key, consumer_secret)
setup_twitter_oauth(CONSUMER_KEY, CONSUMER_SECRET, ACCESS_TOKEN, ACCESS_TOKEN_SECRET)
tweets = searchTwitter("data mining", lang="en",n=10)
tweets_df = twListToDF(tweets)
write(exportJson<-df2json(tweets_df), "test.json")