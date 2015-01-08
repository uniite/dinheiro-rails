namespace :crypto do
  task :generate_keys do
    key = RbNaCl::PrivateKey.generate
    puts "FRONTEND_PUBLIC_KEY=#{key.public_key.to_bytes.unpack('H*').first}"
    puts "PRIVATE_KEY=#{key.to_bytes.unpack('H*').first}"
  end
end
