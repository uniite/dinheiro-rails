class BackendClient

  BACKEND_QUEUE = ENV['BACKEND_QUEUE'] || 'dinheiro-backend-dev'
  BACKEND_PUBLIC_KEY = ENV['BACKEND_PUBLIC_KEY']
  SECRET_KEY = ENV['SECRET_KEY']


  def request(params={})
    # Serialize it as JSON, encrypt it, and encode it as a hex string (eg. 'abcd')
    message = encrypt(params.to_json).unpack('H*').first
    queue.send_message(message)
  end

  def encrypt(data)
    box = RbNaCl::SimpleBox.from_keypair(decode_key(BACKEND_PUBLIC_KEY), decode_key(SECRET_KEY))
    box.encrypt(data)
  end


  private

    def decode_key(key)
      [key].pack('H*')
    end

    def queue
      @queue ||= sqs.queues.named(BACKEND_QUEUE)
    end

    def sqs
      @sqs ||= AWS::SQS.new(region: 'us-east-1')
    end

end
