class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :twitter_id
      t.string :name
      t.string :screen_name
      t.string :location
      t.text :profile_image_url
      t.string :url
      t.boolean :protected
      t.integer :followers_count
      t.string :type

      t.timestamps
    end
    add_index :users, :screen_name, :unique => true
    add_index :users, :twitter_id, :unique => true
    
  end

  def self.down
    drop_table :users
  end
end
