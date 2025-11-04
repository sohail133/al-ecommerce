class CreateSubcategories < ActiveRecord::Migration[8.1]
  def change
    create_table :subcategories do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :subcategories, :category_id
    add_index :subcategories, :name
  end
end
