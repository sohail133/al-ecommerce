class CreateSubscribers < ActiveRecord::Migration[8.1]
  def change
    create_table :subscribers do |t|
      t.string :email, null: false
      t.datetime :subscribed_at
      t.datetime :unsubscribed_at
      t.string :status, default: 'active', null: false

      t.timestamps
    end
    
    add_index :subscribers, :email, unique: true
    add_index :subscribers, :status
  end
end
