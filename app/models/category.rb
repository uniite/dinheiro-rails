class Category < ActiveRecord::Base
  belongs_to :parent, :class_name => Category
  has_many :rules
  has_many :transactions


  def top_level
    if parent.nil?
      self
    else
      parent.top_level
    end
  end

end
