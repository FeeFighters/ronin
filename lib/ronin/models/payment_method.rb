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
    response = put('payment_methods', self.token, params.to_xml(:root=>'payment_method'))
    process_response(Ronin::PaymentMethod, 'payment_method', response)
  end

  private

  def payment_method(method)
    response = post("payment_methods/#{token}/#{method}", '')
    process_response(Ronin::PaymentMethod, 'payment_method', response)
  end
end
