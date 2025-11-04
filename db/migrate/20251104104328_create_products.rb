class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.references :subcategory, null: true, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :products, :category_id
    add_index :products, :subcategory_id
    add_index :products, :active
  end
end
