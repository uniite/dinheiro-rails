class Category < ActiveRecord::Base
  belongs_to :parent, :class_name => Category
  has_many :rules
  has_many :transactions
end
