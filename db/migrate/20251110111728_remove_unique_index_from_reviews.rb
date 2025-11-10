class RemoveUniqueIndexFromReviews < ActiveRecord::Migration[8.1]
  def change
    remove_index :reviews, [:order_id, :user_id], if_exists: true
  end
end
