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
	try:
		language_id = b.detect_language()
		connection = requests.get('http://athigale.koding.io:8983/solr/projc/select?defType=dismax&q=*'+query+'*&rows=10000&start=0&sort=rank+desc&qf=text_'+ language_id +'^1+hashtags^1+concept^0.1+keywords^1&wt=json&facet=true&facet.field=text_'+language_id)
	except Exception:
		connection = requests.get('http://athigale.koding.io:8983/solr/projc/select?defType=dismax&q=*'+query+'*&rows=10000&start=0&sort=rank+desc&qf=text^1+hashtags^1+concept^0.1+keywords^1&wt=json&facet=true&facet.field=text')
	# connection = requests.get('http://athigale.koding.io:8983/solr/projc/select?defType=dismax&q=*paris*&rows=1&start=1&sort=name asc&qf=text_en^1+hashtags^1+concept^0.1+keywords^1&wt=json&facet=true&facet.field=text_en')
	response = json.loads(json.dumps(connection.json()))
	# print json.loads(json.dumps(response))['response']['docs'][0]['text_en']
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
		tempd['user_dp']=tweet['user_dp']
		tempd['user_name']=tweet['user_name']
		tempd['retweet_count']=tweet['retweet_count']
		tempd['followers_count']=tweet['followers_count']
		tempd['favorite_count']=tweet['favorite_count']
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
	# returnArr['facet_fields']=response['facet_counts']['facet_fields']
	return make_response(json.dumps(returnArr))


@app.route('/trendingTopics', methods=['GET'])
def trendingTopics():
	query = request.args.get('q')
	rowno = request.args.get('row')
	b = TextBlob(u""+query+"")
	language_id=""
	connection = requests.get('http://athigale.koding.io:8983/solr/projc/select?defType=dismax&q=*'+query+'*&rows=10000&start=0&sort=retweet_count+desc%2Ccreated_at+desc&qf=text_en^1+hashtags^1+concept^0.1+keywords^1&wt=json&facet=true&facet.field=text_en')
	response = json.loads(json.dumps(connection.json()))
	# print json.loads(json.dumps(response))['response']['docs'][0]['text_en']
	returnArr={}
	tweets=[]
	locations=[]
	for tweet in response['response']['docs']:
		tempd={}
		tempd['text']=tweet['text_en']
		tempd['user_dp']=tweet['user_dp']
		tempd['user_name']=tweet['user_name']
		tempd['retweet_count']=tweet['retweet_count']
		tempd['followers_count']=tweet['followers_count']
		tempd['favorite_count']=tweet['favorite_count']
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
	# returnArr['facet_fields']=response['facet_counts']['facet_fields']
	return make_response(json.dumps(returnArr))



# @app.route('/search/<string:query>', methods=['GET'])
# def search(query):
# 	#gs = goslate.Goslate()
# 	#language_id = gs.detect(query)
# 	#print gs.get_languages()[language_id] #German
# 	#print language_id #de	='
# 	# Example Query : http://athigale.koding.io:8983/solr/projc/select?defType=dismax&q=*attack*&qf=text_en^3+tweet_hashtags^2+keywords^2&wt=json
# 	b = TextBlob(u""+query+"")
# 	language_id = b.detect_language()	
# 	connection = urlopen('http://athigale.koding.io:8983/solr/projc/select?defType=dismax&q=*'+query+'*&qf=text_'+ language_id +'^1+hashtags^1+concept^0.1+keywords^1&wt=json')
# 	response = simplejson.load(connection)
# 	#print response['response']['numFound'], "documents found."
# 	#print response
# 	#for document in response['response']['docs']:
#   	#	print document['text_en']	
# 	return make_response(jsonify(response))	
# 	#return make_response(jsonify({'name': query+"shit"}))

# @app.route('/search2/<string:query>', methods=['GET'])
# def search2(query):
# 	gs = goslate.Goslate()
# 	language_id = gs.detect(query)
# 	#print gs.get_languages()[language_id] #German
# 	#print language_id #de	
# 	# create a connection to a solr server
# 	s = solr.SolrConnection('http://athigale.koding.io:8983/solr/projc/')
# 	# do a search
# 	response = s.query('hashtags:'+query)
# 	return make_response(jsonify(response))

@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)


if __name__ == '__main__':
    app.run(debug=True)
