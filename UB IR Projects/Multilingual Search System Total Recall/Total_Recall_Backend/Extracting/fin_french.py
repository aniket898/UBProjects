# -*- coding: utf-8 -*-
import tweepy
import json
import sys
import codecs
import re
from datetime import datetime
from time import mktime
from twitter_config import CONSUMER_KEY,CONSUMER_SECRET,ACCESS_TOKEN,ACCESS_TOKEN_SECRET
from nltk.tokenize import WhitespaceTokenizer
from stop_words import get_stop_words
from nltk.stem.porter import PorterStemmer
from gensim import corpora, models
import gensim
from textblob import TextBlob
import requests
from alchemyapi import AlchemyAPI

class MyEncoder(json.JSONEncoder):

def default(self, obj):
if isinstance(obj, datetime.datetime):
return int(mktime(obj.timetuple()))

return json.JSONEncoder.default(self, obj)

def getloc(locname):
if locname:
url="https://maps.googleapis.com/maps/api/geocode/json?address="+locname
response = requests.get(url)
jsonvalues = response.json()
if jsonvalues['status']=="OK":
locvalue=jsonvalues['results'][0]['geometry']['location']
return [locvalue['lat'],locvalue['lng']]
return "Null"


auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET)

api = tweepy.API(auth)

# FRENCH QUERIES
#querys = ['pray4paris',u'Le Carillon',u'Eagles of Death Metal',u'portesouvertes',u'théâtre Bataclan','portesouvertes']

# ENGLISH QUERIE
querys = ['pray4paris','paris attacks','Eagles of Death Metal','pray4peace','Bataclan','Mohamed Abdeslam','Le Carillon','ISIL Paris','pray4syria',u'syria réfugiés',u'syria attaques']
#querys = '"syrian refugees" since:2015-11-15 until:2015-11-28'

#querys = '["pray4paris"] since:2015-11-23 until:2015-11-28'

# query = '"big bang theory" since:2015-09-01 until:2015-09-08'
# RUSSIAN QUERIES
#querys = ['pray4paris']

# ARABIC QUERIES
#querys = ['pray4paris']

# Translate:
#gs = goslate.Goslate()
langs=["fr"]
count=10
pages=1
filename="frfin01.json"
en_stop = get_stop_words('fr')

# Create p_stemmer of class PorterStemmer
p_stemmer = PorterStemmer()
gen_stop = ['-','rt','RT','get','ReTweet',':']
cnt=0

#sin_id=670979025204094048
#maxi_id=670979025204994048
alchemyapi = AlchemyAPI()

for lang in langs:
for query in querys:

for tweets in tweepy.Cursor(api.search, q=query.encode('utf-8'), since="2015-11-15",until="2015-11-30",lang=lang, count=200).pages(4):
for tweet in tweets:
tweet_data = {}
tweet_data['id'] = str(tweet.id)
tweet_data['text'] = tweet.text
#topic modelling

blob = TextBlob(tweet.text)
#   trans_text=blob.translate(to="en")
#   trans_text=str(trans_text).decode('utf-8')
#trans_text=gs.translate(tweet.text, 'en')
senti=blob.sentiment.polarity
trans_text=tweet.text
topic = []
raw=trans_text
#raw='https://t.co/rfzlthVqqh paris attacks bataclan'
#raw=UR.lower()
URLless = re.sub(r'(?i)\b((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:\'".,<>?«»“”‘’]))', '', raw)
at_less = re.sub(r'[@]\w*', '', URLless)
#raw.lower()
print at_less
tokens = WhitespaceTokenizer().tokenize(at_less)
stopped_tokens = [i for i in tokens if not i in en_stop]
stopped_tokens2 = [i for i in stopped_tokens if not i in gen_stop]
#stemmed_tokens = [p_stemmer.stem(i) for i in stopped_tokens2]
topic.append(stopped_tokens2)
dictionary = corpora.Dictionary(topic)
corpus = [dictionary.doc2bow(text1) for text1 in topic]
ldamodel = gensim.models.ldamodel.LdaModel(corpus, num_topics=2, id2word = dictionary, passes=20)
tweet_data['topic'] = ldamodel.print_topics(num_topics=1, num_words=1)
print (ldamodel.print_topics(num_topics=1, num_words=1))
#Alchemy Stuff:

response = json.loads(json.dumps(alchemyapi.entities('text', trans_text , {'sentiment': 1})))
# size=len(response['entities'])
flag=0
ent=[]
ent_rele=[]
ent_type=[]
if response['status'] == 'OK':
flag=1
for entity in response['entities']:
ent.append(entity['text'])
ent_rele.append(entity['relevance'])
ent_type.append(entity['type'])
else:
print('Error in entity extraction call: ', response['statusInfo'])

if flag==1:
print cnt
cnt=cnt+1
#response = json.loads(json.dumps(alchemyapi.sentiment("text", trans_text)))
###### GETTING AN ERROR HERE FOR SOME REASON ######
#senti=response["docSentiment"]["type"]
response = json.loads(json.dumps(alchemyapi.keywords('text', trans_text, {'sentiment': 1})))
#size=len(response['keywords'])
keywords=[]
if response['status'] == 'OK':
for word in response['keywords']:
keywords.append(word['text'])
else:
print('Error in entity extraction call: ', response['statusInfo'])


response=json.loads(json.dumps(alchemyapi.concepts("text",trans_text)))
#size=len(response['concepts'])
concept=[]
if response['status'] == 'OK':

for con in response['concepts']:
concept.append(con['text'])
else:
print('Error in entity extraction call: ', response['statusInfo'])
tweet_data['entities']=ent
tweet_data['ent_relevance']=ent_rele
tweet_data['ent_type']=ent_type
tweet_data['keywords']=keywords
tweet_data['concepts']=concept
tweet_data['sentiment']=senti
hashtagData  = tweet.entities.get('hashtags')
hashtagList = []
if not hashtagData:
tweet_data['hashtags'] = hashtagList
else:
for tag in hashtagData:
hashtagList.append(tag['text'])
tweet_data['hashtags'] = hashtagList
URLData = tweet.user.entities.get('url')
if not URLData:
tweet_data['urls'] = ""
else:
URLlist = URLData['urls']
tweet_data['url'] = URLlist[0].get('expanded_url')
tweet_data['lang'] = tweet.lang
fmt = '%Y-%m-%dT%H:%M:%SZ'
created_at = str(tweet.created_at)
print tweet.text
temp = datetime.strptime(created_at,'%Y-%m-%d %H:%M:%S')
tweet_data['created_at'] = str(temp.strftime(fmt))
tweet_data['retweet_count'] = tweet.retweet_count
tweet_data['timezone'] = tweet.user.time_zone
tweet_data['location'] = tweet.user.location
tweet_data['locationCoordinates'] = getloc(tweet.user.location)
if tweet.place:
tweet_data['place'] = tweet.place.country
tweet_data["favorite_count"]=tweet.favorite_count
tweet_data["followers_count"]=tweet.user.followers_count
with codecs.open(filename,'a', encoding='utf-8') as f:
json.dump(tweet_data,f,ensure_ascii=False)
f.write(',\n')
