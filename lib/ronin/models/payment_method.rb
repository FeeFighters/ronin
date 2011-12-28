class Ronin::PaymentMethod < Ronin::Base
  # Alias for `payment_method_token`
  def token
    self.attributes["payment_method_token"]
  end

  def redact
    self.replace self.gateway.redact_payment_method(self.token)
  end

  def retain
    self.replace self.gateway.retain_payment_method(self.token)
  end
end
