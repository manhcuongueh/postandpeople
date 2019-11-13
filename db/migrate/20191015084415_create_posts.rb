class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.string :username
      t.text :image
      t.text :description
      t.integer :likes
      t.integer :comments
      t.string :date
      t.text :hashtags
      t.integer :hashtag_id

      t.timestamps
    end
  end
end
