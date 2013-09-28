class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.string :operator
      t.string :field
      t.string :content
      t.integer :category_id

      t.timestamps
    end
  end
end
