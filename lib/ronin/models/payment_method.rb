class Ronin::PaymentMethod
  attr_accessor :attributes

  def id
    self.token
  end

  # Alias for `payment_method_token`
  def token
    self.attributes["payment_method_token"]
  end
end
