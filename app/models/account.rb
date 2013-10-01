class Account < ActiveRecord::Base
  belongs_to :institution
  has_many :transactions


  def self.import_ofx(path)
    ofx = OFX(path)

    account_number = ofx.account.id
    account_number = ofx.account.bank_id

    ofx.account.transactions.each do |t|
      transactions.create!(
        amount: t.amount,
        currency: t.currency,
        date: t.date,
        ofx_transaction: fit_id,
        payee: payee,
        type: type,
      )
    end
    balance = ofx.account.balance
    save!
  end

end
