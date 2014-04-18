dotenv = require 'dotenv'
dotenv.load()

Twit = require 'twit'
T = new Twit
  consumer_key:         process.env.CONSUMER_KEY
  consumer_secret:      process.env.CONSUMER_SECRET
  access_token:         process.env.ACCESS_TOKEN
  access_token_secret:  process.env.ACCESS_TOKEN_SECRET


class TwitterSearch
  constructor: (@search_term)->
    @filter()
    @search_previous() if process.argv[2] is 'history'

  filter: ->
    stream = T.stream('statuses/filter', { track: @search_term, language: 'en' })
    stream.on 'tweet', (tweet)=> @log(tweet)

  #
  #  search twitter for all tweets containing the word 'banana' since Nov. 11, 2011
  #
  search_previous: ->
    T.get 'search/tweets', { q: @search_term, count: 100, result_type: 'recent'}, (err, reply)=>
      console.log reply.statuses.length
      @log tweet for tweet in reply.statuses

  #
  #  Send Tweet Object to ElasticSearch
  #
  log: (tweet)->
    console.log @parse_tweet(tweet)

  #
  #  Twitter object is too verbose so only keep the attributes we need
  #
  parse_tweet: (tweet)->
    attributes = [ 'id', 'text', 'created_at', 'entities', 'geo','place', 'coordinates', 'retweet_count','favorite_count']
    user_attributes = ['id', 'name', 'screen_name', 'location', 'followers_count', 'friends_count', 'listed_count', 'favourites_count', 'profile_image_url']
    log_obj = user: {}
    log_obj[attr] = tweet[attr] for attr in attributes
    log_obj.user[u_attr] = tweet.user[u_attr] for u_attr in user_attributes
    log_obj

searches =
  can_anyone_recommend: new TwitterSearch 'Can anyone recommend'
