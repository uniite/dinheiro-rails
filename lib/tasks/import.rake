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
      unless Transaction.find_by_ofx_transaction(trx['transaction_id'])
        trx.delete 'id'
        trx['date'] = Date.parse trx['date']
        trx['account_id'] = api_account_mapping[trx.delete('account')]
        trx['category_id'] = api_category_mapping[trx.delete('category')]
        trx['ofx_transaction'] = trx.delete 'transaction_id'
        Transaction.create!(trx)
        imported += 1
      end
    end
    puts "Imported #{imported} transactions"
  end
end