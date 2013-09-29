class Rule < ActiveRecord::Base
  belongs_to :category

  FIELDS = {
    date: 'Date',
    payee: 'Payee',
    type: 'Type'
  }
  OPERATORS = {
    contains: 'Contains',
    endswith: 'Ends With',
    startswith: 'Starts With'
  }

end
