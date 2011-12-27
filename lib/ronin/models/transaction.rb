class Ronin::Transaction < Ronin::Base
  # Alias for `transaction_token`
  def token
    self.attributes["transaction_token"]
  end

  def process_response_errors(attributes)
    super(attributes)

    processor_messages = attributes['processor_response']['messages']
    add_messages(processor_messages)

    payment_method_messages = attributes['payment_method']['messages']
    add_messages(payment_method_messages)
  end
end
