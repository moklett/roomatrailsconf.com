class Follower < User
  TWITTER_PAGE_SIZE = 100
  
  class << self
    extend ActiveSupport::Memoizable

    # The fetch method syncs Twitter followers to our local Follower database.  It is expected
    # that this method be called periodically.
    #
    # If there are no Followers in our local database, or if there are a lot of un-scynced followers,
    # an #init will be performed, which esentially fetches and imports pages worth of followers at a time.
    # Once we get more "caught up", we throttle back and selectively import outstanding followers (by id)
    #
    # Individual fetching mode can be forced by passing +true+ as the +force_individual_method+ parameter.
    def fetch(force_individual_fetching = false)
      if should_fetch_by_page? && !force_individual_fetching
        init
      else
        fetch_loop do
          Follower.import(ActiveTwitter::User.find(next_fetch_id))
        end
      end
      import_counter
    end

    protected
    # Bulk fetch and initialization of followers.  Currently, it seems Twitter places your most
    # recent subscribers first.  We only fetch a few pages at a time.  So, until fetching gets
    # close to "caught up", fetch older and older pages - call this 'historical' mode.  Whenever
    # old pages don't yield more subscribers, then we need to switch to 'recent' mode to get
    # the more recent subscribers off of the front of the stack.  If recent mode isn't yielding
    # new followers either, and we know there are more followers, then switch to
    def init(mode = :historical)
      page = mode == :historical ? historical_fetch_start_page : 1
      fetch_loop do
        count = Follower.import(ActiveTwitter.followers(:page => page))
        if count == 0
          # Switch modes and abort if no new followers were encountered
          if mode == :historical
            init(:recent)
          else
            fetch(true) if need_to_fetch?
          end
          break
        end
        page += 1
      end
    end
    
    def need_to_fetch?
      remote_followers_count > Follower.count
    end
  
    def ids_to_fetch
      ActiveTwitter.my.follower_ids - Follower.all.collect{|f| f.id.to_i}
    end
    memoize :ids_to_fetch
  
    # A loop to control fetching and throttle API calls.  The passed block will be executed at most 
    # FETCH_RETRY_LIMIT times, and will stop if we've appeared to have fetched all followers from
    # Twitter.  The passed block should perform some sort of Follower creation.
    def fetch_loop
      retry_count = User::FETCH_RETRY_LIMIT
      while retry_count > 0 && need_to_fetch?
        yield
        retry_count -= 1
      end
    end
  
    # Number of followers, as reported by Twitter
    def remote_followers_count
      ActiveTwitter::User.follower_ids.size
    end
    memoize :remote_followers_count
  
    # Fetch by page if the outstanding followers to fetch is greater than the Twitter follower page size.
    # Otherwise it will be okay to just fetch by discrete id.
    def should_fetch_by_page?
      Follower.count == 0 || remote_followers_count - Follower.count > TWITTER_PAGE_SIZE
    end
  
    # A rough way of estimating what page of followers from Twitter we should fetch in order to sync
    # up in the most efficient way
    # Note: page numbers start at 1
    def historical_fetch_start_page
      (Follower.count.to_f/TWITTER_PAGE_SIZE).floor + 1
    end
  
    # Index in to the ids_to_fetch array and return the next one to fetch by remembering the last one we fetched.
    def next_fetch_id
      @next_fetch_index ||= 0
      returning ids_to_fetch[@next_fetch_index] do
        @next_fetch_index += 1
      end
    end
  end # class << self
end
