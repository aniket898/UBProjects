#!venv/bin/python

import json
import requests
from flask import Flask, jsonify
from flask import abort
from flask import make_response
from flask import request
from flask import url_for
from flask.ext.cors import CORS
from urllib2 import *
import simplejson
import goslate
import solr
from textblob import TextBlob

app = Flask(__name__)
CORS(app)

@app.route('/search', methods=['GET'])
def search():
	query = request.args.get('q')
	rowno = request.args.get('row')
	b = TextBlob(u""+query+"")
	language_id=""
	flag=0
	try:
		language_id = b.detect_language()
		connection = requests.get('http://athigale.koding.io:8983/solr/projc/select?defType=dismax&q=*'+query+'*&rows=10000&start=0&sort=rank+desc&qf=text_'+ language_id +'^1+hashtags^1+concept^0.1+keywords^1&wt=json&facet=true&facet.field=text')
		flag=1
	except Exception:
		connection = requests.get('http://athigale.koding.io:8983/solr/projc/select?defType=dismax&q=*'+query+'*&rows=10000&start=0&sort=rank+desc&qf=text^1+hashtags^1+concept^0.1+keywords^1&wt=json&facet=true&facet.field=text')
	response = json.loads(json.dumps(connection.json()))
	returnArr={}
	tweets=[]
	locations=[]
	if response['response']['numFound']==0:
		return  make_response(jsonify({'status':200,'numFound':0}))
	for tweet in response['response']['docs']:
		tempd={}
		if 'text_'+language_id in tweet:
			tempd['text']=tweet['text_'+language_id]
		elif 'text_en' in tweet:
			tempd['text']=tweet['text_en']
		elif 'text_fr' in tweet:
			tempd['text']=tweet['text_fr']
		elif 'text_ar' in tweet:
			tempd['text']=tweet['text_ar']
		elif 'text_ru' in tweet:
			tempd['text']=tweet['text_ru']
		if 'user_dp' in tweet:
			tempd['user_dp']=tweet['user_dp']
		if 'user_name' in tweet:
			tempd['user_name']=tweet['user_name']
		tempd['retweet_count']=tweet['retweet_count']
		tempd['followers_count']=tweet['followers_count']
		tempd['favorite_count']=tweet['favorite_count']
		tempd['date']=tweet['created_at']
		if 'ent_type' in tweet:
			d={}
			for i in xrange(len(tweet['ent_type'])):
				d[tweet['ent_type'][i]]=tweet['entities'][i]
			tempd['entities']=d
		if float(tweet['sentiment']) >0:
			tempd['sentiment']= "Positive"
		elif float(tweet['sentiment']) <0:
			tempd['sentiment'] ="Negative"
		else:
			tempd['sentiment']="Neutral"
		tweets.append(tempd)
		if tweet['locationCoordinates'] and len(tweet['locationCoordinates'])==2:
			locations.append([float(tweet['locationCoordinates'][0]),float(tweet['locationCoordinates'][1])])
	returnArr['tweets']=tweets
	returnArr['locations']=locations
	facet=[]
	temp=""
	# if flag:
	# 	temp='text_'+language_id
	# else:
	# 	temp='text'
	for x in response['facet_counts']['facet_fields']['text']:
		if type(x)==int or ("https" in x) or ("RT" in x) or ("rt" in x) or x==query or x.isdigit():
			continue
		if len(facet)>=10:
			break
		facet.append(x)
	returnArr['facet_fields']=facet
	return make_response(json.dumps(returnArr))


@app.route('/trendingTopics', methods=['GET'])
def trendingTopics():
	connection = requests.get('http://athigale.koding.io:8983/solr/projc/select?q=*%3A*&sort=retweet_count+desc%2Ccreated_at+desc&start=0&rows=1000&wt=json&indent=true&facet=true&facet.field=text')
	response = json.loads(json.dumps(connection.json()))
	returnArr={}
	trending=[]
	for x in response['facet_counts']['facet_fields']['text']:
		if type(x)==int or ("https" in x) or ("RT" in x) or ("rt" in x) or x.isdigit():
			continue
		if len(trending)>=10:
			break
		trending.append(x)
	returnArr['trending']=trending
	return make_response(json.dumps(returnArr))

@app.route('/trendingCloud', methods=['GET'])
def trendingCloud():
	connection = requests.get('http://athigale.koding.io:8983/solr/projc/select?q=*%3A*&sort=retweet_count+desc%2Ccreated_at+desc&start=0&rows=1000&wt=json&indent=true&facet=true&facet.field=text')
	response = json.loads(json.dumps(connection.json()))
	returnArr={}
	trending=[]
	facetdict=response['facet_counts']['facet_fields']['text']
	for x in xrange(0,len(facetdict),2):
		if ("https" in facetdict[x]) or ("RT" in facetdict[x]) or ("rt" in facetdict[x]):
			continue
		if len(trending)>=50:
			break
		trending.append({'text':facetdict[x],'weight':facetdict[x+1]})
	returnArr['trending']=trending
	return make_response(json.dumps(returnArr))

@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)


if __name__ == '__main__':
    app.run(debug=True)
