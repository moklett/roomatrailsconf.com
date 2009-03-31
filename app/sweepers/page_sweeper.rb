class PageSweeper < ActionController::Caching::Sweeper
    observe Tweet, User

    def after_create(record)
      # Rake tasks don't have a @controller in scope, so the normal expire_page does nothing
      # if the models are created via rake
      # Just delete the index file.  I know which one I want.
      index_page = Rails.root.join('public', 'index.html')
      File.delete(index_page) if File.exist?(index_page)
    end
  end