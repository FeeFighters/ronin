class Ronin::PaymentMethod < Ronin::Base
  # Alias for `payment_method_token`
  def token
    self.attributes["payment_method_token"]
  end

  [:redact, :retain].each do |meth|
    define_method meth do
      self.replace(payment_method(meth))
    end
  end

  def update(params={})
    response = put('payment_methods', self.token, :payment_method => params)
    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    process_response(Ronin::PaymentMethod, 'payment_method', response.body)
  end

  private

  def payment_method(method)
    response = post("payment_methods/#{token}/#{method}", {})

    raise Ronin::ResourceNotFound.new(response.body) if response.code == 404
    process_response(Ronin::PaymentMethod, 'payment_method', response.body)
  end
end
