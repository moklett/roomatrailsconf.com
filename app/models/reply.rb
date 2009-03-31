class Reply < Tweet
  class << self
    # Fetches new tweets from the Twitter API service and stores them in our database.  This
    # method accesses the Twitter API, so rate limit its use.
    #
    # It tries to keep fetching Tweets, in chunks limited in size to ActiveTwitter's MAX_FETCH_COUNT,
    # until our local database has the same number of tweets as Twitter reports having.  It only performs
    # consecutive fetches up to the FETCH_RETRY_LIMIT so as not to get too carried away.
    def fetch
      fetcher {|params| ActiveTwitter.replies(params)}
      super
    end
    
    protected
    # Twitter doesn't provide an accessible counter for Replies, so we'll assume we need to fetch until
    # proven otherwise
    def need_to_fetch?
      @need_to_fetch = true if @need_to_fetch.nil?
      @need_to_fetch
    end
    
    def no_need_to_fetch!
      @need_to_fetch = false
    end
    
    private
    
    def remote_count
      ActiveTwitter.me.statuses_count.to_i
    end
    
  end
end
