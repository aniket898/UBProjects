# -*- coding: utf-8 -*-
import tweepy
import json
import sys
import codecs
import jsonpickle
from datetime import datetime
from time import mktime
from twitter_config import CONSUMER_KEY,CONSUMER_SECRET,ACCESS_TOKEN,ACCESS_TOKEN_SECRET



class MyEncoder(json.JSONEncoder):

    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            return int(mktime(obj.timetuple()))

        return json.JSONEncoder.default(self, obj)
        
        
        
auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET)

api = tweepy.API(auth)

# public_tweets = api.home_timeline()
# for tweet in public_tweets:
    # print tweet.text.encode('utf-8')

# query = '"big bang theory" since:2015-09-01 until:2015-09-08'    
# for tweets in tweepy.Cursor(api.search, q=query,lang='en', count=100).pages(10):
    # print tweets[0].text.encode('utf-8')
    
# fo = open("exampletweets.json","a+")    
# query = 'big OR bang OR theory'    
# for tweets in tweepy.Cursor(api.search, q=query,lang='en', count=100).pages(10):
    # for tweet in tweets:
        # fo.write("text:"+tweet.text.encode('utf-8'))
# fo.close()

    
# query = 'big OR bang OR theory'    
# with open('exampletweetsinjson','a') as f:
    # for tweets in tweepy.Cursor(api.search, q=query,lang='en', count=100).pages(10):
        # for tweet in tweets:
            # json_tweet = jsonpickle.encode(tweet)
            # json.dump(json_tweet,f)
            # f.write('\n')


###############MAIN QUERY#######################            
#query = u'инженер'
#query = 'castle'
query = 'schule'
englishquery = query.encode('utf-8')
cnt = 1    
#with open('exampletweetsinjson','a') as f:
with codecs.open('file','a', encoding='utf-8') as f:
    for tweets in tweepy.Cursor(api.search, q=englishquery,lang='de', count=100).pages(10):
        print(cnt)
        cnt += 1
        for tweet in tweets:
            tweet_data = {}
            tweet_data['id'] = str(tweet.id)
            tweet_data['text'] = tweet.text
            #tweet_data['hashtags']  = tweet.entities.get('hashtags')
            hashtagData  = tweet.entities.get('hashtags')
            hashtagList = []
            if not hashtagData:
                tweet_data['hashtags'] = hashtagList
            else:
                for tag in hashtagData:
                    hashtagList.append(tag['text'])
                tweet_data['hashtags'] = hashtagList    
            #URLData = tweet.entities.get('urls')
            #if not URLData:
            #    tweet_data['urls'] = ""
            #else:
            #    for urllink in URLData:
            #        tweet_data['urls'] = urllink['url']
            URLData = tweet.user.entities.get('url')
            if not URLData:
                tweet_data['urls'] = ""
            else:
                URLlist = URLData['urls']
                tweet_data['url'] = URLlist[0].get('expanded_url')
            tweet_data['lang'] = tweet.lang
	        ######handling datetime formats##############
            fmt = '%Y-%m-%d %H:%M:%SZ'
            created_at = str(tweet.created_at)
            temp = datetime.strptime(created_at,'%Y-%m-%d %H:%M:%S')
            tweet_data['created_at'] = str(temp.strftime('%A, %B %d, %Y %H:%M:%S'))
            ##tweet_data['entities'] = tweet.entities
            ##tweet_data['place'] = tweet.place
            tweet_data['retweet_count'] = tweet.retweet_count
            #tweet_json = json.dumps(tweet_data,cls=MyEncoder)
            json.dump(tweet_data,f,ensure_ascii=False)
            f.write('\n')
            
##########DESERIALIZATION FAULTY#########
# data = []          
# with open('exampletweetsinjson','r') as f:
    # for line in f:
        # data.append(json.loads(line))
        #print data
        
        
data = []          
f = codecs.open('file',"r","utf-8")
f.read()
