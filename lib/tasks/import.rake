namespace :import do
  desc 'Import data from the dinheiro Django API'
  task :all => :environment do
    api_host = ENV['API_HOST'] || 'localhost:8000'
    base_url = "http://#{api_host}/finance/api"

    api_account_mapping = {}
    api_category_mapping = {}
    imported = 0

    HTTParty.get("#{base_url}/accounts").each do |acct|
      account = Account.find_by_name(acct['name'])
      if account.nil?
        account = Account.create!(
          name: acct['name'],
          account_number: acct['censored_account_number'],
          balance: acct['balance']
        )
        imported += 1
      end
      api_account_mapping[acct['id']] = account.id
    end
    puts "Imported #{imported} accounts"

    HTTParty.get("#{base_url}/categories").each do |cat|
      category = Category.find_by_name(cat['name'])
      if category.nil?
        category = Category.create!(
          name: cat['name']
        )
        cat['rules'].each do |rule|
          rule.delete 'id'
          rule['operator'] = rule.delete 'type'
          category.rules.create!(rule)
        end
        imported += 1
      end
      api_category_mapping[cat['id']] = category.id
    end
    puts "Imported #{imported} categories"
    
    HTTParty.get("#{base_url}/transactions").each do |trx|
      trx_id = trx.delete('transaction_id') || trx.delete('id')
      unless Transaction.find_by_ofx_transaction(trx_id)
        trx['date'] = Date.parse trx['date']
        trx['account_id'] = api_account_mapping[trx.delete('account')]
        trx['category_id'] = api_category_mapping[trx.delete('category')]
        trx['ofx_transaction'] = trx_id
        Transaction.create!(trx)
        imported += 1
      end
    end
    puts "Imported #{imported} transactions"

    Rule.all.each do |r|
      r.execute
    end
    puts "Ran #{Rule.count} rules"
  end

  desc 'Import transactions from a PayPal CSV file'
  task :paypal_csv, [:account_name, :path] => :environment do |t,args|
    acct = Account.find_by_name(args[:account_name])
    acct.transactions.destroy_all
    acct.import_paypal_csv(args[:path])
  end

  desc 'Import transactions from an OFX file'
  task :ofx, [:account_name, :path] => :environment do |t,args|
    acct = Account.find_by_name(args[:account_name])
    acct.transactions.destroy_all
    acct.import_ofx(args[:path])
  end
end