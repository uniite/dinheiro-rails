class Category < ActiveRecord::Base
  belongs_to :parent, :class_name => Category
  has_many :rules
  has_many :transactions

  validates_presence_of :category_id

  after_destroy :uncategorize_transactions


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

  # Resets the category on all transactions assigned to this category
  def uncategorize_transactions
    Transaction.where(category_id: self.id).update_all(category_id: Transaction::DEFAULT_CATEGORY.id)
  end

end
