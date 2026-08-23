# frozen_string_literal: true

# Adds a human-friendly order number in the form YYYYMMDD### where ### is a
# daily, store-wide sequence (not per customer). Existing orders are backfilled
# based on their creation date and creation order.

class AddOrderNumberToOrders < ActiveRecord::Migration[8.0]
  def up
    add_column :orders, :order_number, :string
    add_index :orders, :order_number, unique: true

    # Backfill existing orders, grouped by creation date, ordered by id
    counters = Hash.new(0)
    execute("SELECT id, created_at FROM orders ORDER BY created_at ASC, id ASC").each do |row|
      created_at = row["created_at"]
      date = created_at.is_a?(String) ? Time.parse(created_at) : created_at
      prefix = date.strftime("%Y%m%d")
      counters[prefix] += 1
      number = format("%s%03d", prefix, counters[prefix])
      execute(
        "UPDATE orders SET order_number = #{ActiveRecord::Base.connection.quote(number)} WHERE id = #{row["id"].to_i}"
      )
    end
  end

  def down
    remove_index :orders, :order_number
    remove_column :orders, :order_number
  end
end
