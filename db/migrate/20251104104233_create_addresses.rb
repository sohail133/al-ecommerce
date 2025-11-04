class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name, null: false
      t.string :phone_number, null: false
      t.string :address_line_1, null: false
      t.string :address_line_2
      t.string :city, null: false
      t.string :province, null: false
      t.string :postal_code, null: false
      t.boolean :is_default, default: false, null: false

      t.timestamps
    end

    add_index :addresses, :user_id
    add_index :addresses, :is_default
  end
end
