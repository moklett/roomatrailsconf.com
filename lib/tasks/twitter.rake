namespace :twitter do
  desc "Sync the Twitter Account to the Database"
  task :sync => :environment do
    log = Logger.new(Rails.root.join('log', 'twitter_sync.log'))
    log.info Time.now.strftime('-- %m/%d/%Y %I:%M%p')
    log.info "Tweets     : #{MyTweet.fetch} new"
    log.info "Followers  : #{Follower.fetch} new"
    log.info "Unfollowers: #{Follower.purge}"
    log.info "Replies    : #{Reply.fetch} new"
    log.info "==============================================================="
  end
end
