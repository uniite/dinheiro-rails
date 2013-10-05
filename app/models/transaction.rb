class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :category

  DEFAULT_CATEGORY = Category.find_by_name('Uncategorized')

  after_initialize :ensure_category_present

  self.inheritance_column = nil

  private
    # Ensures we have some sort of category assigned,
    # so we don't have to check rule.category.nil? every time we want to use it
    def ensure_category_present
      self.category ||= DEFAULT_CATEGORY
    end
end
