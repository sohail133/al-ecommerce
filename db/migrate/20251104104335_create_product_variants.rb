class CreateProductVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :sku, null: false
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :product_variants, :product_id
    add_index :product_variants, :sku, unique: true
    add_index :product_variants, :active
  end
end
