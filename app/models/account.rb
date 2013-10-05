require 'csv'

class Account < ActiveRecord::Base
  belongs_to :institution
  has_many :transactions


  def self.import_csv(path)
    headers = nil
    transactions = []
    transactions_by_id = {}
    CSV.foreach(path) do |line|
      # First iteration only
      if headers.nil?
        headers = line.map { |x| x.strip }
        next
      end
      # Map the CSV row into a hash
      trx = {related: []}
      line.each_with_index do |val,i|
        key = headers[i]
        next if key.blank?
        trx[key] = val
      end
      # Store and index it
      transactions << trx
      transactions_by_id[trx['Transaction ID']] = trx
    end

    # Store transaction relations
    transactions.each do |trx|
      ref = trx['Reference Txn ID']
      if ref.present? and transactions_by_id[ref]
        transactions_by_id[ref][:related] << trx
      end
    end

    [transactions, transactions_by_id]
  end

  def import_ofx(path)
    ofx = OFX(path)

    #account_number = ofx.account.id
    #account_number = ofx.account.bank_id

    ofx.account.transactions.each do |t|
      transactions.create!(
        amount: t.amount,
        currency: ofx.account.currency,
        date: t.posted_at,
        ofx_transaction: t.fit_id,
        payee: t.name,
        type: t.type,
        account_id: self.id,
      )
    end
    self.balance = ofx.account.balance
    save!
  end

end
