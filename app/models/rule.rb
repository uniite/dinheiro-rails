class Rule < ActiveRecord::Base
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

  belongs_to :category

  validates_presence_of :content
  validates_inclusion_of :field, in: FIELDS.keys.map { |f| f.to_s }, allow_nil: false
  validates_inclusion_of :operator, in: OPERATORS.keys.map { |o| o.to_s }, allow_nil: false

  before_save :normalize!
  after_save :execute


  def normalize!
    self.content = content.downcase
  end

  def execute
    return unless FIELDS.keys.include? field.to_sym
    # TODO: This seems bad
    matches = Transaction.where("#{field} LIKE :content", content: "%#{content}%")
    matches.update_all(category_id: category_id)
  end

end
