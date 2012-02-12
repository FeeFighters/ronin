class Ronin::Processor < Ronin::Base
  attr_accessor :gateway

  def initialize(_attributes={})
    super()
    self.attributes['processor_token'] = _attributes.with_indifferent_access['processor_token']
    self.gateway = _attributes.with_indifferent_access['gateway']
    raise ArgumentError.new("Gateway not set") if gateway.nil?
  end

  # Alias for `payment_method_token`
  def token
    self.attributes["processor_token"]
  end

  # create transactions
  def authorize(payment_method_token, amount, params={})
    create_transaction(payment_method_token, amount, 'authorize', params)
  end

  def purchase(payment_method_token, amount, params={})
    create_transaction(payment_method_token, amount, 'purchase', params)
  end

  private

  def create_transaction(payment_method_token, amount, method, params={})
    transaction_params = params.merge(:payment_method_token => payment_method_token, :amount => amount)
    response = post("processors/#{token}/#{method}", transaction_params.to_xml(:root=>'transaction'))
    process_response(Ronin::Transaction, 'transaction', response)
  end
end

