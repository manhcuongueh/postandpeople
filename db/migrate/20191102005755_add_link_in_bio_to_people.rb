class AddLinkInBioToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :link_in_bio, :string
  end
end
