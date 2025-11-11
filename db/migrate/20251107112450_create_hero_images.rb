class CreateHeroImages < ActiveRecord::Migration[8.1]
  def change
    create_table :hero_images do |t|
      t.string :title
      t.text :subtitle
      t.text :description
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
