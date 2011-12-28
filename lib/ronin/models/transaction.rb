class Ronin::Transaction < Ronin::Base
  attr_accessor :gateway

  # Alias for `transaction_token`
  def token
    self.attributes["transaction_token"]
  end

  # transaction methods
  def capture(amount=nil)
    transaction_method('capture', token, amount)
  end

  def reverse(amount=nil)
    transaction_method('reverse', token, amount)
  end

  def void(amount=nil)
    transaction_method('void', token, amount)
  end

  def credit(amount=nil)
    transaction_method('credit', token, amount)
  end

  def process_response_errors(attributes)
    super(attributes)

    processor_messages = attributes['processor_response']['messages']
    add_messages(processor_messages)

    payment_method_messages = attributes['payment_method']['messages']
    add_messages(payment_method_messages)
  end

  private

  def transaction_method(method, token, amount=nil)
    transaction_params = {:amount => amount}
    response = @gateway.post("transactions/#{token}/#{method}", :transaction => transaction_params)

    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    @gateway.process_response(Ronin::Transaction, 'transaction', response.body)
  end

end
