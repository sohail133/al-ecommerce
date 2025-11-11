class ChangeReviewsToOrderItems < ActiveRecord::Migration[8.1]
  def up
    # Add order_item_id column as nullable first
    add_reference :reviews, :order_item, foreign_key: true
    
    # Migrate existing reviews: assign them to the first order_item of their order
    # This is a best-effort migration - in production you might want to handle this differently
    execute <<-SQL
      UPDATE reviews
      SET order_item_id = (
        SELECT id FROM order_items 
        WHERE order_items.order_id = reviews.order_id 
        LIMIT 1
      )
      WHERE order_item_id IS NULL
    SQL
    
    # Delete any reviews that couldn't be migrated (orders with no order_items)
    execute <<-SQL
      DELETE FROM reviews WHERE order_item_id IS NULL
    SQL
    
    # Now make it not null
    change_column_null :reviews, :order_item_id, false
    
    # Remove the old order_id column and foreign key
    remove_reference :reviews, :order, foreign_key: true, index: false
    
    # Add index on order_item_id and user_id
    add_index :reviews, [:order_item_id, :user_id]
  end

  def down
    # Add back order_id
    add_reference :reviews, :order, foreign_key: true
    
    # Migrate data back
    execute <<-SQL
      UPDATE reviews
      SET order_id = (
        SELECT order_id FROM order_items 
        WHERE order_items.id = reviews.order_item_id
      )
    SQL
    
    change_column_null :reviews, :order_id, false
    
    # Remove order_item_id
    remove_reference :reviews, :order_item, foreign_key: true
    
    # Add back the old index
    add_index :reviews, [:order_id, :user_id], unique: true
  end
end
