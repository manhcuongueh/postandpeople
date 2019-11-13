class CreateHashtags < ActiveRecord::Migration[5.2]
  def change
    create_table :hashtags do |t|
      t.date :date
      t.string :tag

      t.timestamps
    end
  end
end
