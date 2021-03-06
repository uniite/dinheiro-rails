class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :institution_id
      t.string :account_number
      t.string :name
      t.string :routing_number
      t.decimal :balance, precision: 15, scale: 2
      t.string :ofx_broker

      t.timestamps
    end
  end
end
