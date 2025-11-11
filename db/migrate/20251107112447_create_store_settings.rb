class CreateStoreSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :store_settings do |t|
      t.string :email
      t.text :location
      t.string :phone_number
      t.string :facebook_url
      t.string :instagram_url
      t.string :youtube_url

      t.timestamps
    end
  end
end
