class Ronin::PaymentMethod < Ronin::Base
  # Alias for `payment_method_token`
  def token
    self.attributes["payment_method_token"]
  end
end
