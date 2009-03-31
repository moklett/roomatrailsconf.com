class SiteController < ApplicationController
  caches_page :index
  cache_sweeper :page_sweeper, :only => [:index]

  before_filter :set_body_class
  
  def index
    @my_tweets = MyTweet.all
    @followers = Follower.all
    @replies = Reply.all
    @body_class
  end
  
  def what_is_this
  end

  private
  def set_body_class
    @body_class = "#{params[:controller]}-#{params[:action]}"
  end
end
