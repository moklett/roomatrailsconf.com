class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.boolean :truncated
      t.boolean :favorited
      t.text :text
      t.integer :twitter_id
      t.integer :in_reply_to_status_id
      t.integer :in_reply_to_user_id
      t.string :source
      t.datetime :timestamp
      t.integer :user_id
      t.string :user_name
      t.string :user_screen_name
      t.string :user_profile_image_url
      t.string :type

      t.timestamps
    end
    
    add_index(:tweets, :twitter_id, :unique => true)
  end

  def self.down
    drop_table :tweets
  end
end
