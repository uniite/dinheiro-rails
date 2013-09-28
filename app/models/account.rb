class Account < ActiveRecord::Base
  belongs_to :institution
  has_many :transactions
end
