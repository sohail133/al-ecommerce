class AddSlugToSubcategories < ActiveRecord::Migration[8.1]
  def change
    add_column :subcategories, :slug, :string
    add_index :subcategories, :slug, unique: true
  end
end
