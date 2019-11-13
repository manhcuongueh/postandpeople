class CreatePeople < ActiveRecord::Migration[5.2]
  def change
    create_table :people do |t|
      t.string :username
      t.string :url
      t.integer :posts
      t.integer :followers
      t.integer :followings
      t.text :bio
      t.integer :hashtag_id
      
      t.timestamps
    end
  end
end
