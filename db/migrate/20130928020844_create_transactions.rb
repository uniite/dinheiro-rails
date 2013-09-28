class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :account_id
      t.string :currency
      t.datetime :date
      t.decimal :amount, precision: 15, scale: 2
      t.string :payee
      t.string :ofx_transaction
      t.string :type
      t.integer :category_id

      t.timestamps
    end
  end
end
