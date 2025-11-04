class CreateInventories < ActiveRecord::Migration[8.1]
  def change
    create_table :inventories do |t|
      t.references :product_variant, null: false, foreign_key: true
      t.integer :quantity, default: 0, null: false
      t.integer :reserved_quantity, default: 0, null: false
      t.integer :threshold_level, default: 10, null: false

      t.timestamps
    end

    add_index :inventories, :product_variant_id, unique: true
  end
end
