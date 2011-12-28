class Ronin::Transaction < Ronin::Base
  # Alias for `transaction_token`
  def token
    self.attributes["transaction_token"]
  end

  def process_response_errors(attributes)
    super(attributes)
    add_messages(attributes['processor_response']['messages'])
    add_messages(attributes['payment_method']['messages'])
  end

  def capture(amount = self.amount)
    self.gateway.capture(self.token, amount)
  end

  def reverse(amount = self.amount)
    self.gateway.reverse(self.token, amount)
  end

  def credit(amount = self.amount)
    self.gateway.credit(self.token, amount)
  end

  def void(amount = self.amount)
    self.gateway.void(self.token, amount)
  end
end
