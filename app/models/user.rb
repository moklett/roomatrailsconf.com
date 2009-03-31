class User < ActiveRecord::Base
  FETCH_RETRY_LIMIT = 20 # Fetch 20 new followers (or pages of followers) at a time
  PACKET_SIZE = 20
  
  default_scope :order => 'id DESC'

  named_scope :packet, lambda {|*args|
    options = args.shift || {}
    conditions = options[:from] ? ['id < ?', options[:from].to_i] : nil
    {:limit => PACKET_SIZE, :conditions => conditions}
  }
  
  class << self
    def import(api_followers = [])
      import_counter(self.create_from_api(api_followers))
    end
    
    protected
    def create_from_api(api_followers)
      created_count = 0
      case api_followers
      when Array
        api_followers.collect {|follower| create_from_api(follower)}
      when ActiveTwitter::User
        # When creating a Follower from the Twitter API, we don't want to enter any duplicates.
        # Our unique index on the twitter_id should take care of this by raising 
        # ActiveRecord::StatementInvalid if we try to create a duplicate
        begin
          created_count += 1 if self.create!(from_api(api_followers))
        rescue ActiveRecord::StatementInvalid
          logger.debug("-- User creation skipped - already in database: #{api_followers.screen_name} (#{api_followers.id})")
          false
        end
      else
        raise ImportError, "Could not create a local User from the passed in #{api_followers.class.to_s}.  +create_from_api+ requires an ActiveTwitter::User object or an Array of such."
      end
      created_count
    end
    
    def import_counter(inc = nil)
      @import_counter ||= 0
      
      if inc.nil?
        @import_counter
      elsif inc.is_a? Numeric
        @import_counter += inc
        inc
      end
    end
    
    # Returns a Hash of Tweet attributes extracted from an ActiveTwitter::Status
    def from_api(user)
      attrs = {}
      attrs[:twitter_id]        = user.id
      attrs[:name]              = user.name
      attrs[:screen_name]       = user.screen_name
      attrs[:location]          = user.location
      attrs[:profile_image_url] = user.profile_image_url
      attrs[:url]               = user.url
      attrs[:protected]         = user.protected
      attrs[:followers_count]   = user.followers_count
      attrs
    end
    
  end
  
  class ImportError < StandardError
  end
  
end
