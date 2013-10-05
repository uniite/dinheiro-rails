class Category < ActiveRecord::Base
  belongs_to :parent, :class_name => Category
  has_many :rules
  has_many :transactions


  def self.categorize_all
    Category.all.each do |c|
      c.categorize_all
    end
  end

  def categorize_all
    rules.each do |r|
      r.execute
    end
  end

  def top_level
    if parent.nil?
      self
    else
      parent.top_level
    end
  end

end
