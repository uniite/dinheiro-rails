class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :category
  # Lets us have an attribute called type, specific to transactions
  self.inheritance_column = nil

  validates_presence_of :category_id

  after_initialize :ensure_category_present

  DEFAULT_CATEGORY = Category.find_by_name('Uncategorized')


  private
    # Ensures we have some sort of category assigned,
    # so we don't have to check rule.category.nil? every time we want to use it
    def ensure_category_present
      self.category ||= DEFAULT_CATEGORY
    end
end
