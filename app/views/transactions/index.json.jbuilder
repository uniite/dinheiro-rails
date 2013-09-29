json.array!(@transactions) do |transaction|
  json.extract! transaction, 
  json.url transaction_url(transaction, format: :json)
end
