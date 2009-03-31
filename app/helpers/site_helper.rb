module SiteHelper
  def twitter_status_url(tweet)
    "#{twitter_user_url(tweet.user_screen_name)}/status/#{tweet.twitter_id}"
  end
  
  def twitter_user_url(screen_name)
    "http://twitter.com/#{screen_name}"
  end
end
