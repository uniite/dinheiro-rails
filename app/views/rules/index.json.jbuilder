json.array!(@rules) do |rule|
  json.extract! rule, 
  json.url rule_url(rule, format: :json)
end
