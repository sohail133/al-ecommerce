class UpdateSubscribersTable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :subscribers, :email, false
    change_column_default :subscribers, :status, from: nil, to: 'active'
    change_column_null :subscribers, :status, false
    add_index :subscribers, :status
  end
end
