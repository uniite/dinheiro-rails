require 'csv'

class Account < ActiveRecord::Base
  belongs_to :institution
  has_many :transactions


  def self.parse_paypal_csv(path)
    headers = nil
    paypal_trx = []
    paypal_trx_by_id = {}
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
      # Ignore expired transactions (usually temporary holds, or fraudulent/rejected charges)
      next if trx['Status'] == 'Expired'
      # Store and index it
      paypal_trx << trx
      paypal_trx_by_id[trx['Transaction ID']] = trx
    end

    # Store transaction relations
    paypal_trx.each do |trx|
      ref = trx['Reference Txn ID']
      if ref.present? and paypal_trx_by_id[ref]
        paypal_trx_by_id[ref][:related] << trx
      end
    end

    [paypal_trx, paypal_trx_by_id]
  end

  def import_paypal_csv(path)
    paypal_trx, trx_by_id = self.class.parse_paypal_csv(path)

    # Only save to-level transactions
    # (the ones with references are usually supporting transactions to fund a purchase)
    paypal_trx.reject { |t| t['Reference Txn ID'].present? }.map do |t|
      # Need to reformat the date and time for Ruby to parse it ('10/1/2013' -> '2013-10-01')
      month, day, year = t['Date'].split('/')
      date = Time.parse("#{year}-%02i-%02i #{t['Time']}" % [month, day])

      transactions.create!(
          # TODO: Not sure when we would want 'Gross'
          amount: t['Net'],
          currency: t['Currency'],
          date: date,
          ofx_transaction: t['Transaction ID'],
          payee: t['Name'],
          type: t['Type'],
      )
    end

    # Ensure the new transactions are categorized
    Category.categorize_all

    true
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
      )
    end
    self.balance = ofx.account.balance
    save!

    # Ensure the new transactions are categorized
    Category.categorize_all

    true
  end

end
