class Tweet < ActiveRecord::Base
  FETCH_RETRY_LIMIT = 5
  PACKET_SIZE = 20

  default_scope :order => 'timestamp DESC, id DESC'
  
  # Fetches the most recent PACKET_SIZE tweets.  Can also access older tweets by passing an
  # id in the +:from+ parameter, in which case only tweets before the specified id will be considered.
  #
  #   Tweet.packet
  #   # => Most recent tweets stored, limited to PACKET_SIZE
  #
  #   Tweet.packet(:from => 1234)
  #   # => A packet of tweets that came before Tweet id 1234 (assumes unique monotonically increasing
  #        primary key)
  #  
  named_scope :packet, lambda {|*args|
    options = args.shift || {}
    conditions = options[:from] ? ['id < ?', options[:from].to_i] : nil
    {:limit => PACKET_SIZE, :conditions => conditions}
  }
  
  named_scope :twitter_order, :order => 'twitter_id DESC'
  named_scope :twitter_reverse_order, :order => 'twitter_id ASC'
  
  named_scope :most_recent, {}
  
  class << self
    extend ActiveSupport::Memoizable

    # Override this method in the subclasses to define how to fetch tweets from Twitter
    def fetch
      import_counter
    end
    
    def most_recent
      find :first # default scope takes care of ordering
    end

    protected
    # A smart fetcher for Tweets.
    def fetcher(mode = :recent, &block)
      fetch_loop do
        params = { :count => ActiveTwitter::MAX_FETCH_COUNT }
        if mode == :recent
          params.merge!(:since_id => fetch_since_id) if fetch_since_id
        else
          params.merge!(:max_id => fetch_max_id) if fetch_max_id
        end
        count = self.import(yield(params))
        if count == 0
          if mode == :recent
            fetcher(:historical, &block)
          else
            no_need_to_fetch!
          end
          break
        end
      end
    end

    def fetch_loop
      retry_count = Tweet::FETCH_RETRY_LIMIT
      while retry_count > 0 && need_to_fetch?
        yield
        retry_count -= 1
      end
    end

    def need_to_fetch?
      remote_count > self.count
    end
    
    # Can be used to signal an end of fetching in cases where a remote count can not be determined
    def no_need_to_fetch!
    end
    
    # Override in subclasses
    def remote_count
      0
    end
    memoize :remote_count
    
    def import(api_tweets = [])
      import_count = import_counter(self.create_from_api(api_tweets))
      import_count
    end
    
    # Maintain an import counter.  If no parameter is passed, it will return the current value of the
    # import counter.  If an integer is passed, the counter will be incremented by that amount and
    # return the amount by which it was just incremented.
    def import_counter(inc = nil)
      @import_counter ||= 0
      
      if inc.nil?
        @import_counter
      elsif inc.is_a? Numeric
        @import_counter += inc
        inc
      end
    end

    # Creates Tweets from the passed in Array of attributes or Hash of attributes.  Returns the number
    # of records created
    def create_from_api(api_tweets)
      created_count = 0
      case api_tweets
      when Array
        api_tweets.reverse.each {|tweet| created_count += create_from_api(tweet)}
      when ActiveTwitter::Status
        begin
          created_count += 1 if self.create!(from_api(api_tweets))
        rescue ActiveRecord::StatementInvalid
          logger.debug("-- Tweet creation skipped - already in database: #{api_tweets.id}")
          false
        end
      else
        raise ImportError, "Could not create a local Tweet from the passed in #{api_tweets.class.to_s}.  +create_from_api+ requires an ActiveTwitter::Status object or an Array of such."
      end
      created_count
    end

    def fetch_since_id
      most_recent_tweet = self.twitter_order.first
      most_recent_tweet ? most_recent_tweet.twitter_id : nil
    end
    
    def fetch_max_id
      oldest_tweet = self.twitter_reverse_order.first
      oldest_tweet ? oldest_tweet.twitter_id : nil
    end
    
    private
    
    # Returns a Hash of Tweet attributes extracted from an ActiveTwitter::Status
    def from_api(status)
      attrs = {}
      attrs[:truncated]                 = status.truncated
      attrs[:favorited]                 = status.favorited
      attrs[:text]                      = status.text
      attrs[:twitter_id]                = status.id
      attrs[:in_reply_to_status_id]     = status.in_reply_to_status_id
      attrs[:in_reply_to_user_id]       = status.in_reply_to_user_id
      attrs[:source]                    = status.source
      attrs[:timestamp]                 = status.created_at
      if status.user
        attrs[:user_id]                 = status.user.id
        attrs[:user_name]               = status.user.name
        attrs[:user_screen_name]        = status.user.screen_name
        attrs[:user_profile_image_url]  = status.user.profile_image_url
      end
      attrs
    end
    
  end
  
  
  class ImportError < StandardError
  end
end
