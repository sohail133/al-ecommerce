class CreateCategoryAttributesSystem < ActiveRecord::Migration[8.1]
  def change
    create_table :category_attributes do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :input_type, null: false, default: "select"
      t.boolean :required, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :category_attributes, [:category_id, :slug], unique: true
    add_index :category_attributes, [:category_id, :position]

    create_table :category_attribute_options do |t|
      t.references :category_attribute, null: false, foreign_key: true
      t.string :value, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :category_attribute_options, [:category_attribute_id, :value], unique: true, name: "index_category_attribute_options_on_attr_and_value"
    add_index :category_attribute_options, [:category_attribute_id, :position], name: "index_category_attribute_options_on_attr_and_position"

    create_table :product_variant_attribute_values do |t|
      t.references :product_variant, null: false, foreign_key: true
      t.references :category_attribute, null: false, foreign_key: true
      t.string :value, null: false

      t.timestamps
    end

    add_index :product_variant_attribute_values,
              [:product_variant_id, :category_attribute_id],
              unique: true,
              name: "index_variant_attribute_values_uniqueness"
  end
end
