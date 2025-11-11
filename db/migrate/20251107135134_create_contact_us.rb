class CreateContactUs < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_us do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.text :message
      t.text :admin_response
      t.datetime :replied_at

      t.timestamps
    end
  end
end
