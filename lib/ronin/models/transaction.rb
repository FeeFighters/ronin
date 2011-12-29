class Ronin::Transaction < Ronin::Base
  # Alias for `transaction_token`
  def token
    self.attributes["transaction_token"]
  end

  def amount
    self.attributes["amount"]
  end

  def process_response_errors(attributes)
    super(attributes)
    add_messages(attributes['processor_response']['messages'])
    add_messages(attributes['payment_method']['messages'])
  end

  def capture(amount = self.amount)
    transaction_method('capture', amount)
  end

  def reverse(amount = self.amount)
    transaction_method('reverse', amount)
  end

  def credit(amount = self.amount)
    transaction_method('credit', amount)
  end

  def void(amount = self.amount)
    transaction_method('void', amount)
  end

  private

  def transaction_method(method, amount)
    transaction_params = {:amount => amount}
    response = post("transactions/#{self.token}/#{method}", :transaction => transaction_params)

    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    process_response(Ronin::Transaction, 'transaction', response.body)
  end
end
