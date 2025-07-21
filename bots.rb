#!/usr/bin/env ruby

require 'twitter_ebooks'
require 'twitter'

def clean_tweet(tweet)
  return tweet.sub %r{[:;,/>]+$}, ''
end

class MyBot < Ebooks::Bot
  W = 60

  # Configuration here applies to all MyBots
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = "XXX" # Your app consumer key
    self.consumer_secret = "XXXXXX" # Your app consumer secret

    # Users to block instead of interacting with
    # self.blacklist = ['ciainsider', 'nwo_agent', 'leoboshaar', 'ciatakeover', 'worlddom0', 'p0s1vibe']
    # seconds to randomize delay when bot.delay is called
    # self.delay_range = 1..50
    @myblacklist = [] 
  end

  def on_startup

    @model = Ebooks::Model.load("model/thegrugq.model")
    @topwords = @model.keywords[6..100]
    @oldtweet = @model.make_statement(280)

     tweet(@oldtweet)
    
     scheduler.every '136m' do
       if rand(10) == 0
         @oldtweet = clean_tweet(@model.make_statement(280))
       else
         @oldtweet = clean_tweet(@model.make_response(@oldtweet,280))
       end
       tweet(@oldtweet)
     end
    
  end

  def on_message(dm)
    if dm.sender.screen_name == "agelastic"
      case dm.text.downcase
      when "tweet"
        @oldtweet=tweet(clean_tweet(@model.make_statement(280)))
      else
        @oldtweet=tweet(clean_tweet(@model.make_response(dm.text,280)))
      end
    else
	reply_tweet = clean_tweet(@model.make_response(dm.text, 280-dm.sender.screen_name.length))
	sleep(W)
	reply(dm, reply_tweet)
    end
  end

  def on_follow(user)
    #follow(user.screen_name)
  end

  def on_mention(tweet)
    prefix = meta(tweet).reply_prefix
    if ! (@myblacklist.include?(tweet.user.screen_name) || self.twitter.block?(tweet.user.screen_name))
	@oldtweet = clean_tweet(@model.make_response(tweet.text, 280-prefix.length))
	sleep(W)
    	reply(tweet, prefix + @oldtweet)
	@myblacklist << tweet.user.screen_name if self.twitter.block?(tweet.user.screen_name)
    end
  end

  def on_timeline(tweet)
     tokens = Ebooks::NLP.tokenize(tweet.text)
     if tokens.find { |t| @topwords.include?(t) } and rand(20) == 0 and tweet.user.screen_name!="agelastic"
       #favorite(tweet)
       prefix = meta(tweet).reply_prefix
       @oldtweet= @model.make_response(tweet.text, 280-prefix.length)
       sleep(W)
       reply(tweet, prefix + @oldtweet)
     end
  end
end

# Make a MyBot and attach it to an account
MyBot.new("thegrugq_ebooks") do |bot|
  bot.access_token = "XXX-XXXXXX" # Token connecting the app to this account
  bot.access_token_secret = "XXXXXXX" # Secret connecting the app to this account

  bot.twitter.access_token = "XXX-XXXXXX"
  bot.twitter.access_token_secret = "XXXXXXX"
end
