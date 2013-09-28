class CreateInstitutions < ActiveRecord::Migration
  def change
    create_table :institutions do |t|
      t.integer :user_id
      t.integer :ofx_fid
      t.string :ofx_org
      t.string :url
      t.string :username
      t.string :password
      t.string :name

      t.timestamps
    end
  end
end
