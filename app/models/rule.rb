class Rule < ActiveRecord::Base
  belongs_to :category

  #TODO: Validations

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


  def execute
    return unless FIELDS.keys.include? field.to_sym
    # TODO: This seems bad
    matches = Transaction.where("#{field} LIKE :content", content: "%#{content}%")
    matches.update_all(category_id: category_id)
  end

end
